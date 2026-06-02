import SwiftUI

struct EditProjectsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Manage Projects")
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.return)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            if appState.projects.isEmpty {
                Text("No projects")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(appState.projects) { project in
                        HStack(spacing: 10) {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.secondary)
                                .font(.caption)

                            Text(project.name)
                                .lineLimit(1)

                            Spacer()

                            Text(formatDurationShort(appState.currentSeconds(for: project)))
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .monospacedDigit()

                            Button {
                                if let idx = appState.projects.firstIndex(where: { $0.id == project.id }) {
                                    appState.deleteProjects(at: IndexSet([idx]))
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .help("Delete \(project.name)")
                        }
                        .padding(.vertical, 2)
                    }
                    .onMove { appState.moveProjects(from: $0, to: $1) }
                }
                .listStyle(.inset)
            }
        }
        .frame(width: 320, height: 380)
    }
}
