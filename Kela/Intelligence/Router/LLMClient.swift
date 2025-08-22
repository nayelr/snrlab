import Foundation

protocol LLMServing {
    func complete(prompt: String, context: ContextBundle) async throws -> KelaReply
}

final class LLMClient: LLMServing {
    private let client: LLMServing
    init(client: LLMServing) { self.client = client }

    func complete(prompt: String, context: ContextBundle) async throws -> KelaReply {
        try await client.complete(prompt: prompt, context: context)
    }
}


