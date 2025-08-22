import AppKit
import AVFoundation

final class TTSService {
    private let synth = AVSpeechSynthesizer()
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }
}

