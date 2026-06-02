import SwiftUI

// Shown as the menubar icon. Displays elapsed time when a timer is running.
struct MenuBarLabel: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: appState.isRunning ? "clock.fill" : "clock")
            if appState.isRunning, let project = appState.activeProject {
                Text(formatDuration(appState.currentSeconds(for: project)))
                    .monospacedDigit()
                    .font(.system(size: 12))
            }
        }
    }
}
