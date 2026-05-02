import SwiftUI

struct NotesAppView: View {
    @State private var notes: [NoteItem] = [
        NoteItem(title: "Welcome", body: "This is your Notes app.\n\nTap + to create a new note."),
        NoteItem(title: "Shopping List", body: "- Milk\n- Eggs\n- Bread\n- Coffee")
    ]
    @State private var selectedNoteId: UUID? = nil
    @State private var searchText = ""

    private var selectedNote: Binding<NoteItem>? {
        guard let id = selectedNoteId,
              let idx = notes.firstIndex(where: { $0.id == id }) else { return nil }
        return $notes[idx]
    }

    private var filteredNotes: [NoteItem] {
        if searchText.isEmpty { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Text("Notes")
                        .font(.headline)
                    Spacer()
                    Button {
                        let note = NoteItem(title: "New Note", body: "")
                        notes.insert(note, at: 0)
                        selectedNoteId = note.id
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $searchText)
                        .font(.system(size: 13))
                }
                .padding(7)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)

                Divider()

                // Note List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredNotes) { note in
                            NoteRow(note: note, isSelected: selectedNoteId == note.id)
                                .onTapGesture { selectedNoteId = note.id }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        notes.removeAll { $0.id == note.id }
                                        if selectedNoteId == note.id { selectedNoteId = nil }
                                    } label: {
                                        Label("Delete Note", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .frame(width: 180)
            .background(Color(.systemGray6))

            Divider()

            // Editor
            if let binding = selectedNote {
                NoteEditorView(note: binding)
            } else {
                VStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("Select or create a note")
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Note Model
struct NoteItem: Identifiable {
    let id: UUID = UUID()
    var title: String
    var body: String
    var modifiedDate: Date = Date()
}

// MARK: - Note Row
struct NoteRow: View {
    let note: NoteItem
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(note.title.isEmpty ? "New Note" : note.title)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
            Text(note.body.isEmpty ? "No additional text" : note.body)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
    }
}

// MARK: - Note Editor
struct NoteEditorView: View {
    @Binding var note: NoteItem

    var body: some View {
        VStack(spacing: 0) {
            // Title
            TextField("Title", text: $note.title)
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .onChange(of: note.title) { note.modifiedDate = Date() }

            Divider()

            // Body
            TextEditor(text: $note.body)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .onChange(of: note.body) { note.modifiedDate = Date() }
        }
        .background(Color(.systemBackground))
    }
}
