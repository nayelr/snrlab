import Foundation

final class WhisperWrapper {
    private var partialHandler: ((String) -> Void)?

    func startStreamingTranscription(partial: @escaping (String) -> Void) {
        // Mock: emit deterministic partials
        self.partialHandler = partial
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { partial("Hello ") }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) { partial("Hello Kela") }
    }

    func stopAndFinalize() -> String? {
        // Mock final transcript
        return "Hello Kela"
    }

    func transcribeWithBinary(audioURL: URL, modelPath: String) async throws -> String {
        // Placeholder for invoking whisper.cpp via Process
        return "Mock transcript"
    }
}


