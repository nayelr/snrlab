import Foundation
import AVFoundation
import AVKit

enum PermissionsManager {
    static func requestMicrophone() async -> Bool {
        await withCheckedContinuation { cont in
            AVCaptureDevice.requestAccess(for: .audio) { ok in
                cont.resume(returning: ok)
            }
        }
    }

    static func repair() {
        // Placeholder for guiding users to System Settings
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}

