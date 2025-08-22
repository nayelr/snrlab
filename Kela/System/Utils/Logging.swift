import os.log

enum Log {
    static let subsystem = "com.example.Kela"
    static func info(_ msg: String) { os_log("%{public}@", log: OSLog(subsystem: subsystem, category: "info"), type: .info, msg) }
    static func error(_ msg: String) { os_log("%{public}@", log: OSLog(subsystem: subsystem, category: "error"), type: .error, msg) }
}


