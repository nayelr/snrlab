import AVFoundation
import Accelerate

final class MicEngine {
    private let engine = AVAudioEngine()
    private var levelHandler: ((Float) -> Void)?

    func start(level: @escaping (Float) -> Void) {
        levelHandler = level
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }
        do { try engine.start() } catch { }
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }

    private func process(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        var rms: Float = 0
        vDSP_meamgv(channelData, 1, &rms, vDSP_Length(frameLength))
        let level = max(0.0, min(1.0, rms * 20))
        levelHandler?(level)
    }
}

