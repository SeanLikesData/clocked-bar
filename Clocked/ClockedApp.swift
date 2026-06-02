import SwiftUI

@main
struct ClockedApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        // No windows — the app lives entirely in the menubar.
        // Settings scene suppresses the "no scenes" warning without creating any UI.
        Settings { EmptyView() }
    }
}
