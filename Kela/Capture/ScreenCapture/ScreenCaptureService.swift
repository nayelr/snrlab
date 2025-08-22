import AppKit
import ScreenCaptureKit

final class ScreenCaptureService {
    func capture(region: CGRect) async throws -> NSImage {
        // Try modern ScreenCaptureKit first, fallback to legacy API
        if #available(macOS 14.0, *) {
            return try await captureWithScreenCaptureKit(region: region)
        } else {
            return try await captureWithLegacyAPI(region: region)
        }
    }
    
    @available(macOS 14.0, *)
    private func captureWithScreenCaptureKit(region: CGRect) async throws -> NSImage {
        // For now, fallback to legacy - full ScreenCaptureKit implementation would be more complex
        return try await captureWithLegacyAPI(region: region)
    }
    
    private func captureWithLegacyAPI(region: CGRect) async throws -> NSImage {
        guard let screen = NSScreen.main else { throw NSError(domain: "Kela", code: 1) }
        let scale = screen.backingScaleFactor
        let cgRect = CGRect(x: region.origin.x * scale,
                            y: region.origin.y * scale,
                            width: region.size.width * scale,
                            height: region.size.height * scale)

        // Suppress deprecation warning - we know this is deprecated but it works for our demo
        guard let cgImage = CGWindowListCreateImage(cgRect, .optionOnScreenOnly, kCGNullWindowID, [.bestResolution, .boundsIgnoreFraming]) else {
            throw NSError(domain: "Kela", code: 2)
        }
        return NSImage(cgImage: cgImage, size: region.size)
    }
}

