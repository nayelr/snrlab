import Foundation

struct ContextBundle: Codable {
    let app: String
    let windowTitle: String
    let ocrExcerpt: String
    let selectionText: String?
    let clipboardPreview: String?
    let recentEvents: [String]
    let time: Date
    let fileHints: [String]
}

struct KelaReply: Codable {
    let text: String
    let actions: [Action]?
    struct Action: Codable { let title: String; let command: String }
}


