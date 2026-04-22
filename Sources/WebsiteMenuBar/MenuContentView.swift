import SwiftUI
import AppKit

struct MenuContentView: View {
    @EnvironmentObject var store: WebsiteStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Divider()

            if store.websites.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "bookmark")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("저장된 웹사이트가 없습니다")
                        .foregroundStyle(.secondary)
                    Text("아래 ‘웹사이트 관리’에서 추가하세요")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(store.websites) { website in
                            WebsiteRow(website: website)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 360)
            }

            Divider()

            footer
        }
        .frame(width: 300)
    }

    private var header: some View {
        HStack {
            Image(systemName: "globe")
            Text("웹사이트")
                .font(.headline)
            Spacer()
            Text("\(store.websites.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var footer: some View {
        VStack(spacing: 0) {
            MenuButton(systemImage: "plus.circle", title: "웹사이트 관리...") {
                openWindow(id: "manage")
                NSApp.activate(ignoringOtherApps: true)
            }
            MenuButton(systemImage: "power", title: "종료", shortcut: "Q") {
                NSApp.terminate(nil)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct WebsiteRow: View {
    let website: Website
    @State private var hovering = false

    var body: some View {
        Button(action: open) {
            HStack(spacing: 10) {
                Image(systemName: "link")
                    .frame(width: 16)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(website.title)
                        .lineLimit(1)
                    Text(displayURL)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if hovering {
                    Image(systemName: "arrow.up.forward")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hovering ? Color.accentColor.opacity(0.18) : .clear)
                    .padding(.horizontal, 4)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }

    private var displayURL: String {
        guard let host = URL(string: website.url)?.host else { return website.url }
        return host
    }

    private func open() {
        guard let url = normalizedURL(website.url) else { return }
        NSWorkspace.shared.open(url)
    }

    private func normalizedURL(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if let url = URL(string: trimmed), url.scheme != nil { return url }
        return URL(string: "https://" + trimmed)
    }
}

private struct MenuButton: View {
    let systemImage: String
    let title: String
    var shortcut: String? = nil
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .frame(width: 16)
                    .foregroundStyle(.secondary)
                Text(title)
                Spacer()
                if let shortcut {
                    Text("⌘\(shortcut)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hovering ? Color.accentColor.opacity(0.18) : .clear)
                    .padding(.horizontal, 4)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
