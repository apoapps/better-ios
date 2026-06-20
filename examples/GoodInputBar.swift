import SwiftUI

// MARK: - Good: small view, native text field, delegated actions

struct NoteEntryBar: View {
    @Binding var text: String
    var tags: [Tag]
    var isSaving: Bool
    var onSave: () -> Void
    var onAddTag: () -> Void
    var onRemoveTag: (Tag) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !tags.isEmpty {
                TagStrip(tags: tags, onRemove: onRemoveTag)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }

            HStack(spacing: 12) {
                Button(action: onAddTag) {
                    Image(systemName: "number")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }

                TextField("Add a note...", text: $text, axis: .vertical)
                    .lineLimit(1...6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground), in: Capsule())

                Button(action: onSave) {
                    Image(systemName: isSaving ? "checkmark" : "arrow.up")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
    }
}

struct Tag: Identifiable, Hashable {
    let id: String
    let name: String
}

private struct TagStrip: View {
    let tags: [Tag]
    let onRemove: (Tag) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags) { tag in
                    HStack {
                        Text(tag.name)
                            .font(.caption)
                        Button { onRemove(tag) } label: {
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
