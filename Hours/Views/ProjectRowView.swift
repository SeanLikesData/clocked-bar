import SwiftUI

struct ProjectRowView: View {
    @EnvironmentObject var appState: AppState
    let project: Project

    @State private var showingManualEntry = false
    @State private var isEditingName = false
    @State private var editName = ""
    @FocusState private var nameFieldFocused: Bool

    private var isActive: Bool { appState.activeProjectId == project.id }
    private var currentSeconds: Int { appState.currentSeconds(for: project) }

    var body: some View {
        HStack(spacing: 10) {
            // Running indicator dot
            Circle()
                .fill(isActive ? Color.green : Color.clear)
                .frame(width: 7, height: 7)
                .overlay(
                    Circle().stroke(
                        isActive ? Color.green : Color.secondary.opacity(0.4),
                        lineWidth: 1
                    )
                )
                .padding(.leading, 14)

            // Project name — double-click to rename
            if isEditingName {
                TextField("Name", text: $editName)
                    .textFieldStyle(.plain)
                    .focused($nameFieldFocused)
                    .onSubmit { commitRename() }
                    .onExitCommand { isEditingName = false }
                    .onAppear { nameFieldFocused = true }
            } else {
                Text(project.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .onTapGesture(count: 2) {
                        editName = project.name
                        isEditingName = true
                    }
            }

            Spacer(minLength: 8)

            // Time display — click to adjust manually
            Button {
                showingManualEntry = true
            } label: {
                Text(formatDuration(currentSeconds))
                    .monospacedDigit()
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(isActive ? .green : .primary)
            }
            .buttonStyle(.plain)
            .help("Click to adjust time manually")
            .popover(isPresented: $showingManualEntry, arrowEdge: .trailing) {
                ManualTimeEntryView(isPresented: $showingManualEntry, project: project)
                    .environmentObject(appState)
            }

            // Start / stop button
            Button {
                if isActive {
                    appState.stopTimer()
                } else {
                    appState.startTimer(for: project)
                }
            } label: {
                Image(systemName: isActive ? "stop.fill" : "play.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isActive ? .red : .green)
                    .frame(width: 26, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isActive ? Color.red.opacity(0.12) : Color.green.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
            .help(isActive ? "Stop timer" : "Start timer")
            .padding(.trailing, 10)
        }
        .padding(.vertical, 9)
        .contentShape(Rectangle())
    }

    private func commitRename() {
        let name = editName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty {
            appState.renameProject(project, to: name)
        }
        isEditingName = false
    }
}
