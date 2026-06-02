import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") { onDone() }
                    .keyboardShortcut(.return)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Content
            VStack(alignment: .leading, spacing: 20) {
                // Menubar display section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Menubar — when a timer is running")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker(selection: $appState.menubarDisplay, label: EmptyView()) {
                        ForEach(MenubarDisplay.allCases, id: \.self) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .labelsHidden()

                    if appState.menubarDisplay == .time || appState.menubarDisplay == .nameAndTime {
                        Toggle("Show seconds", isOn: $appState.menubarShowSeconds)
                            .padding(.top, 2)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 320)
    }
}
