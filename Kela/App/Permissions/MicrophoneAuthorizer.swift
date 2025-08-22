import AVFoundation
import AVKit

enum MicrophoneAuthorizer {
    static func ensureAuthorized() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: return true
        case .denied, .restricted: return false
        case .notDetermined: return await PermissionsManager.requestMicrophone()
        @unknown default: return false
        }
    }
}

