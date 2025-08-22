import Foundation
import AppKit
import SwiftUI

final class AppViewModel: ObservableObject {
    enum AssistantState { case idle, listening, thinking, alert }

    // UI
    @Published var showBubble: Bool = false
    @Published var bubbleText: String = ""
    @Published var transcriptText: String = ""
    @Published var state: AssistantState = .idle { didSet { onStateIconChange?(menuBarIcon) } }

    // Callbacks for app wiring
    var onStateIconChange: ((String) -> Void)?
    var onWantsSettings: (() -> Void)?

    // Services
    let hotkey = GlobalHotkey()
    let mic = MicEngine()
    let whisper = WhisperWrapper()
    let tts = TTSService()
    let capture = ScreenCaptureService()
    let ocr = OCRService()
    let tracker = ActiveWindowTracker()
    let router = LLMClient(client: LocalLLMStub())
    let triggerGraph = TriggerGraph()
    let eventLog = EventLog()
    let embeddings = EmbeddingsStore()

    // Debounce
    private let debounceOCR = Debounce(interval: 0.7)

    var isPaused: Bool = false
    @Published var startAtLogin: Bool = false
    @Published var exclusions: [String] = []

    var menuBarIcon: String {
        switch state {
        case .idle: return "circlebadge"
        case .listening: return "waveform"
        case .thinking: return "gearshape.arrow.triangle.2.circlepath"
        case .alert: return "exclamationmark.circle"
        }
    }

    func start() {
        hotkey.onHoldChanged = { [weak self] isDown in
            Task { await self?.handleHotkey(isDown: isDown) }
        }
        hotkey.setMode(.fn)
        hotkey.start()

        tracker.onChange = { [weak self] info in
            self?.scheduleOCR()
            self?.maybeProactive(info: info)
        }
        tracker.start()
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused { state = .idle; showBubble = false }
    }

    private func scheduleOCR() {
        guard !isPaused else { return }
        debounceOCR.execute { [weak self] in
            Task { await self?.performOCR() }
        }
    }

    private func performOCR() async {
        guard let region = tracker.cursorBandRegion() else { return }
        do {
            let frame = try await capture.capture(region: region)
            let text = try await ocr.recognize(in: frame)
            if !text.isEmpty {
                eventLog.log(type: .ocr, text: text, app: tracker.currentAppName)
                triggerGraph.ingest(ocrText: text)
                if triggerGraph.shouldFireErrorSuggestion() {
                    showSuggestion(text: "I can explain this error and suggest a fix.", action: "Explain error")
                }
            }
        } catch {
            // Swallow errors in background
        }
    }

    private func showSuggestion(text: String, action: String) {
        bubbleText = text
        showBubble = true
        state = .alert
    }

    func addExclusion(_ id: String) { exclusions.append(id) }
    func removeExclusions(at indexSet: IndexSet) { exclusions.remove(atOffsets: indexSet) }

    // Debug actions
    #if DEBUG
    func debugFakeSuggestion() { showSuggestion(text: "Try summarizing this section.", action: "Summarize") }
    func debugFakeError() {
        triggerGraph.ingest(ocrText: "error: something failed")
        _ = triggerGraph.shouldFireErrorSuggestion()
        showSuggestion(text: "I can explain this error and suggest a fix.", action: "Explain error")
    }
    func debugSpeakTest() { tts.speak("This is a test of Kela speech synthesis.") }
    #endif

    private func handleHotkey(isDown: Bool) async {
        guard !isPaused else { return }
        if isDown {
            showBubble = true
            transcriptText = ""
            bubbleText = "Listening…"
            state = .listening
            mic.start { [weak self] level in
                Task { @MainActor in self?.micLevel = level }
            }
            whisper.startStreamingTranscription { [weak self] partial in
                Task { @MainActor in self?.transcriptText = partial }
            }
        } else {
            mic.stop()
            let finalText = whisper.stopAndFinalize() ?? transcriptText
            transcriptText = finalText
            state = .thinking
            bubbleText = "Thinking…"

            let clip = NSPasteboard.general.string(forType: .string)
            let clipPreview = clip.map { String($0.prefix(200)) }
            let context = ContextBundle(app: tracker.currentAppName,
                                        windowTitle: tracker.currentWindowTitle,
                                        ocrExcerpt: triggerGraph.latestOCRPrefix(max: 400),
                                        selectionText: nil,
                                        clipboardPreview: clipPreview,
                                        recentEvents: eventLog.recentSummaries(limit: 5),
                                        time: Date(),
                                        fileHints: tracker.fileHints())
            do {
                let reply = try await router.complete(prompt: finalText, context: context)
                await speakAndShow(reply: reply)
                eventLog.log(type: .reply, text: reply.text, app: tracker.currentAppName)
            } catch {
                await showError("Failed to get reply")
            }
        }
    }

    @Published var micLevel: Float = 0

    private func showError(_ message: String) async {
        bubbleText = message
        state = .alert
        showBubble = true
    }

    private func speakAndShow(reply: KelaReply) async {
        bubbleText = reply.text
        state = .idle
        tts.speak(reply.text)
        showBubble = true
    }

    private func maybeProactive(info: ActiveWindowInfo) {
        let lower = info.windowTitle.lowercased()
        let minute = Calendar.current.component(.minute, from: Date())
        if (lower.contains("calendar") || lower.contains("meeting")) && minute >= 55 {
            showSuggestion(text: "Meeting soon: want an agenda?", action: "Draft agenda")
        }
    }
}

