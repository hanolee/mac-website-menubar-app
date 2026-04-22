import Foundation

@MainActor
final class WebsiteStore: ObservableObject {
    @Published private(set) var websites: [Website] = []

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let base = (try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fm.homeDirectoryForCurrentUser
        let dir = base.appendingPathComponent("WebsiteMenuBar", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("websites.json")
        load()
        if websites.isEmpty {
            seedDefaults()
        }
    }

    private func load() {
        guard
            let data = try? Data(contentsOf: fileURL),
            let decoded = try? JSONDecoder().decode([Website].self, from: data)
        else { return }
        websites = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(websites) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func seedDefaults() {
        websites = [
            Website(title: "Apple", url: "https://www.apple.com"),
            Website(title: "GitHub", url: "https://github.com"),
            Website(title: "Hacker News", url: "https://news.ycombinator.com")
        ]
        save()
    }

    func add(title: String, url: String) {
        let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let link = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !link.isEmpty else { return }
        websites.append(Website(title: name.isEmpty ? link : name, url: link))
        save()
    }

    func update(_ website: Website) {
        guard let idx = websites.firstIndex(where: { $0.id == website.id }) else { return }
        websites[idx] = website
        save()
    }

    func remove(_ website: Website) {
        websites.removeAll { $0.id == website.id }
        save()
    }

    func remove(at offsets: IndexSet) {
        websites.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        websites.move(fromOffsets: source, toOffset: destination)
        save()
    }
}
