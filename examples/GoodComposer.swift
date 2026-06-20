import SwiftUI

// MARK: - Good: small view, native text field, delegated actions

struct Composer: View {
    @Binding var text: String
    var attachments: [Attachment]
    var isRunning: Bool
    var onSend: () -> Void
    var onAddAttachment: () -> Void
    var onRemoveAttachment: (Attachment) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !attachments.isEmpty {
                AttachmentStrip(
                    attachments: attachments,
                    onRemove: onRemoveAttachment
                )
                .padding(.horizontal)
                .padding(.top, 8)
            }

            HStack(spacing: 12) {
                Button(action: onAddAttachment) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }

                TextField("Message", text: $text, axis: .vertical)
                    .lineLimit(1...6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: Capsule())

                Button(action: onSend) {
                    Image(systemName: isRunning ? "stop.fill" : "arrow.up")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isRunning)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
    }
}

struct Attachment: Identifiable, Hashable {
    let id: String
    let name: String
}

private struct AttachmentStrip: View {
    let attachments: [Attachment]
    let onRemove: (Attachment) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(attachments) { attachment in
                    HStack {
                        Text(attachment.name)
                            .font(.caption)
                        Button { onRemove(attachment) } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                }
            }
        }
    }
}
