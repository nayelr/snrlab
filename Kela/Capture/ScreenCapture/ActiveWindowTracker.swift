import AppKit

struct ActiveWindowInfo {
    let appName: String
    let windowTitle: String
    let frame: CGRect
}

final class ActiveWindowTracker {
    private var timer: Timer?
    var onChange: ((ActiveWindowInfo) -> Void)?

    private(set) var currentAppName: String = ""
    private(set) var currentWindowTitle: String = ""
    private(set) var currentFrame: CGRect = .zero

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() { timer?.invalidate(); timer = nil }

    private func poll() {
        guard let front = NSWorkspace.shared.frontmostApplication else { return }
        let appName = front.localizedName ?? front.bundleIdentifier ?? "App"
        let title = getWindowTitle(of: front.processIdentifier) ?? ""
        let frame = NSScreen.main?.frame ?? .zero

        if appName != currentAppName || title != currentWindowTitle {
            currentAppName = appName
            currentWindowTitle = title
            currentFrame = frame
            onChange?(ActiveWindowInfo(appName: appName, windowTitle: title, frame: frame))
        }
    }

    func cursorBandRegion() -> CGRect? {
        guard let screen = NSScreen.main else { return nil }
        let loc = NSEvent.mouseLocation
        let size = CGSize(width: 600, height: 220)
        let origin = CGPoint(x: max(0, loc.x - size.width/2), y: max(0, screen.frame.height - loc.y - size.height/2))
        return CGRect(origin: origin, size: size)
    }

    func fileHints() -> [String] { [] }

    private func getWindowTitle(of pid: pid_t) -> String? {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        guard let windowInfoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else { return nil }
        for info in windowInfoList {
            if let ownerPID = info[kCGWindowOwnerPID as String] as? Int, ownerPID == pid {
                if let name = info[kCGWindowName as String] as? String { return name }
            }
        }
        return nil
    }
}


