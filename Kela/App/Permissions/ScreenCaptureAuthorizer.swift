import Foundation
import ScreenCaptureKit

enum ScreenCaptureAuthorizer {
    static func ensureAuthorized() async -> Bool {
        do {
            _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            return true
        } catch {
            return false
        }
    }
}


