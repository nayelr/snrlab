import AppKit
@preconcurrency import Vision

final class OCRService {
    func recognize(in image: NSImage) async throws -> String {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return "" }

        return try await withCheckedThrowingContinuation { cont in
            let request = VNRecognizeTextRequest { request, error in
                if let error { cont.resume(throwing: error); return }
                let texts = (request.results as? [VNRecognizedTextObservation])?.compactMap { $0.topCandidates(1).first?.string } ?? []
                let joined = texts.joined(separator: " ")
                cont.resume(returning: String(joined.prefix(600)))
            }
            request.recognitionLevel = .fast
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do { try handler.perform([request]) } catch { cont.resume(throwing: error) }
            }
        }
    }
}

