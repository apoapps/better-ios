import SwiftUI
import SwiftData

// MARK: - Good: thin coordinator + actor service + AsyncStream

enum GenerationEvent: Sendable {
    case partial(String)
    case done
    case error(String)
}

actor RuntimeService {
    func generate(prompt: String) -> AsyncStream<GenerationEvent> {
        AsyncStream { continuation in
            let task = Task {
                for word in ["Hello", "world", "."] {
                    try? await Task.sleep(for: .milliseconds(50))
                    continuation.yield(.partial(word + " "))
                }
                continuation.yield(.done)
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

@MainActor
@Observable
final class ChatCoordinator {
    private let service: RuntimeService
    var messages: [Message] = []
    var inputText: String = ""
    var isRunning: Bool = false

    init(service: RuntimeService) {
        self.service = service
    }

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        messages.append(Message(role: .user, text: text))
        let assistantMessage = Message(role: .assistant, text: "")
        messages.append(assistantMessage)
        isRunning = true

        Task {
            let stream = await service.generate(prompt: text)
            for await event in stream {
                switch event {
                case .partial(let token):
                    assistantMessage.text += token
                case .done:
                    isRunning = false
                case .error(let message):
                    assistantMessage.text = "Error: \(message)"
                    isRunning = false
                }
            }
        }
    }
}

final class Message: Identifiable {
    let id = UUID()
    let role: Message.Role
    var text: String

    init(role: Message.Role, text: String) {
        self.role = role
        self.text = text
    }

    enum Role {
        case user
        case assistant
    }
}
