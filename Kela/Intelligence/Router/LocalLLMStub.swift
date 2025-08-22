import Foundation

final class LocalLLMStub: LLMServing {
    func complete(prompt: String, context: ContextBundle) async throws -> KelaReply {
        let lower = (context.ocrExcerpt + " " + prompt).lowercased()
        if lower.contains("error") || lower.contains("exception") {
            return KelaReply(text: "It looks like an error. Try checking logs and recent changes.", actions: [.init(title: "Explain error", command: "explain_error")])
        }
        if lower.contains("meeting") || context.windowTitle.lowercased().contains("calendar") {
            return KelaReply(text: "Upcoming discussion: clarify goals and next steps.", actions: [.init(title: "Draft agenda", command: "agenda")])
        }
        return KelaReply(text: "Here’s a concise tip based on your context.", actions: [.init(title: "Copy", command: "copy")])
    }
}


