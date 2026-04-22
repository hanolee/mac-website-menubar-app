import SwiftUI

struct ManageWebsitesView: View {
    @EnvironmentObject var store: WebsiteStore
    @State private var selection: Website.ID?
    @State private var showingAdd = false
    @State private var editing: Website?

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                ForEach(store.websites) { website in
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(website.title)
                            Text(website.url)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 2)
                    .tag(website.id)
                    .contextMenu {
                        Button("편집") { editing = website }
                        Button("삭제", role: .destructive) { store.remove(website) }
                    }
                }
                .onMove { store.move(from: $0, to: $1) }
            }
            .listStyle(.inset)

            Divider()

            HStack(spacing: 8) {
                Button { showingAdd = true } label: {
                    Image(systemName: "plus")
                        .frame(width: 20, height: 20)
                }
                .help("추가")

                Button {
                    if let id = selection,
                       let ws = store.websites.first(where: { $0.id == id }) {
                        store.remove(ws)
                        selection = nil
                    }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 20, height: 20)
                }
                .disabled(selection == nil)
                .help("삭제")

                Button {
                    if let id = selection,
                       let ws = store.websites.first(where: { $0.id == id }) {
                        editing = ws
                    }
                } label: {
                    Image(systemName: "pencil")
                        .frame(width: 20, height: 20)
                }
                .disabled(selection == nil)
                .help("편집")

                Spacer()
                Text("드래그로 순서 변경")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(8)
        }
        .navigationTitle("웹사이트 관리")
        .frame(minWidth: 440, minHeight: 340)
        .sheet(isPresented: $showingAdd) {
            WebsiteEditor(website: nil) { title, url in
                store.add(title: title, url: url)
            }
        }
        .sheet(item: $editing) { website in
            WebsiteEditor(website: website) { title, url in
                var updated = website
                updated.title = title.isEmpty ? url : title
                updated.url = url
                store.update(updated)
            }
        }
    }
}

private struct WebsiteEditor: View {
    let website: Website?
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var url: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(website == nil ? "웹사이트 추가" : "웹사이트 편집")
                .font(.headline)

            Form {
                TextField("이름", text: $title, prompt: Text("예: Apple"))
                TextField("URL", text: $url, prompt: Text("https://example.com"))
            }
            .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("취소") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(website == nil ? "추가" : "저장") {
                    let normalized = normalize(url)
                    onSave(title, normalized)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(url.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(18)
        .frame(width: 380)
        .onAppear {
            if let website {
                title = website.title
                url = website.url
            }
        }
    }

    private func normalize(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        let lower = trimmed.lowercased()
        if lower.hasPrefix("http://") || lower.hasPrefix("https://") { return trimmed }
        return "https://" + trimmed
    }
}
