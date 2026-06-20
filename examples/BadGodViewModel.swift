import SwiftUI
import SwiftData
import Foundation

// MARK: - Bad: god coordinator mixing everything

// This is the anti-pattern. A single type imports SwiftUI, SwiftData, and
// Foundation, and owns persistence, network, runtime simulation, haptics,
// widget sync, and UI presentation state.

@MainActor
@Observable
final class ChatViewModel {
    // UI state
    var messages: [Message] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var isModelPickerPresented: Bool = false
    var isSettingsPresented: Bool = false

    // Persistence
    var modelContainer: ModelContainer?
    var context: ModelContext?

    // Runtime / network
    var selectedModelID: String?
    var streamingTask: Task<Void, Never>?

    // Widget sync
    func syncWidgetThreads() {
        // Widget update logic here
    }

    // Haptics
    func hapticSuccess() {
        // UINotificationFeedbackGenerator logic here
    }

    func sendMessage() {
        let text = inputText
        messages.append(Message(role: .user, text: text))
        inputText = ""
        isLoading = true

        streamingTask = Task {
            // Simulated network + streaming + persistence + haptics
            try? await Task.sleep(for: .seconds(1))
            messages.append(Message(role: .assistant, text: "Reply"))
            isLoading = false
            hapticSuccess()
            syncWidgetThreads()

            if let context {
                try? context.save()
            }
        }
    }

    func loadThreads() {
        guard let context else { return }
        // SwiftData fetch
    }

    func deleteThread(_ message: Message) {
        // SwiftData delete
    }
}

struct Message: Identifiable {
    let id = UUID()
    let role: Role
    var text: String

    enum Role {
        case user
        case assistant
    }
}
