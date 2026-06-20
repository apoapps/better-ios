import SwiftUI

// MARK: - Bad: two controls for the same action

struct ChatScreen: View {
    var body: some View {
        VStack {
            HStack {
                // Top-left button
                Button("New chat") { startNewChat() }

                Spacer()

                // Top-right button with different label/icon
                Button {
                    startNewChat()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
            .padding()

            Spacer()
        }
    }

    func startNewChat() {
        // same action
    }
}

// MARK: - Good: one action, one control, or a shared reusable view

struct ChatScreenFixed: View {
    var body: some View {
        VStack {
            HStack {
                NewChatButton(action: startNewChat)
                Spacer()
            }
            .padding()

            Spacer()
        }
    }

    func startNewChat() {
        // one action
    }
}

struct NewChatButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("New chat", systemImage: "square.and.pencil")
        }
    }
}
