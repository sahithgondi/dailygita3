import SwiftUI
import GitaKit

/// P4 — Note editor (gita-pages.md §7). Free-text note tied to one shloka. Save/cancel; existing
/// notes open pre-filled; delete. Persists via `UserStore` (SwiftData + CloudKit private DB).
struct NoteEditorView: View {
    let shlokaID: String

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var existingNote = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Your note") {
                    TextEditor(text: $text)
                        .frame(minHeight: 160)
                }
                if existingNote {
                    Section {
                        Button("Delete note", role: .destructive) {
                            try? model.userStore.deleteNote(shlokaID: shlokaID)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(shlokaID)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            try? model.userStore.deleteNote(shlokaID: shlokaID)
                        } else {
                            try? model.userStore.upsertNote(shlokaID: shlokaID, text: trimmed)
                        }
                        dismiss()
                    }
                }
            }
            .task {
                if let note = try? model.userStore.note(shlokaID: shlokaID), let body = note.text {
                    text = body
                    existingNote = true
                }
            }
        }
    }
}
