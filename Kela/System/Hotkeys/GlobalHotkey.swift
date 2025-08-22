import AppKit

final class GlobalHotkey {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    enum Mode { case fn, command }
    private var mode: Mode = .fn
    var onHoldChanged: ((Bool) -> Void)?
    private var isDown = false

    func setMode(_ mode: Mode) { self.mode = mode }

    func start() {
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard type == .flagsChanged else { return Unmanaged.passUnretained(event) }
            let hotkey = Unmanaged<GlobalHotkey>.fromOpaque(refcon!).takeUnretainedValue()
            hotkey.handleFlags(event: event)
            return Unmanaged.passUnretained(event)
        }
        let ref = Unmanaged.passUnretained(self).toOpaque()
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: mask, callback: callback, userInfo: ref)
        if let eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    private func handleFlags(event: CGEvent) {
        let flags = event.flags
        let isPressed: Bool
        switch mode {
        case .fn:
            if #available(macOS 13.0, *) {
                isPressed = flags.contains(.maskSecondaryFn)
            } else {
                isPressed = flags.contains(.maskCommand) == false && flags.rawValue & (1 << 23) != 0
            }
        case .command:
            isPressed = flags.contains(.maskCommand)
        }
        if isPressed != isDown {
            isDown = isPressed
            onHoldChanged?(isDown)
        }
    }
}

