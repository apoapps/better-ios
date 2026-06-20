import SwiftUI

// MARK: - Bad: boolean flags for mutually exclusive sheets

struct ChatScreen: View {
    @State private var isSettingsPresented = false
    @State private var isModelPickerPresented = false
    @State private var isDownloadsPresented = false

    var body: some View {
        VStack {
            Button("Settings") { isSettingsPresented = true }
            Button("Models") { isModelPickerPresented = true }
            Button("Downloads") { isDownloadsPresented = true }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsScreen()
        }
        .sheet(isPresented: $isModelPickerPresented) {
            ModelPickerScreen()
        }
        .sheet(isPresented: $isDownloadsPresented) {
            DownloadsScreen()
        }
    }
}

// MARK: - Good: enum-driven sheet source of truth

enum ChatSheet: Identifiable {
    case settings
    case modelPicker
    case downloads

    var id: Self { self }
}

struct ChatScreenFixed: View {
    @State private var presentedSheet: ChatSheet?

    var body: some View {
        VStack {
            Button("Settings") { presentedSheet = .settings }
            Button("Models") { presentedSheet = .modelPicker }
            Button("Downloads") { presentedSheet = .downloads }
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .settings: SettingsScreen()
            case .modelPicker: ModelPickerScreen()
            case .downloads: DownloadsScreen()
            }
        }
    }
}

struct SettingsScreen: View {}
struct ModelPickerScreen: View {}
struct DownloadsScreen: View {}
