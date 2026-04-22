import SwiftUI

@main
struct WebsiteMenuBarApp: App {
    @StateObject private var store = WebsiteStore()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environmentObject(store)
        } label: {
            Image(systemName: "globe")
        }
        .menuBarExtraStyle(.window)

        Window("웹사이트 관리", id: "manage") {
            ManageWebsitesView()
                .environmentObject(store)
        }
        .windowResizability(.contentSize)
    }
}
