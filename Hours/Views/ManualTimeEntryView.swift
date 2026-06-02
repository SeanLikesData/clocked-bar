import SwiftUI

struct ManualTimeEntryView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    let project: Project

    @State private var hours = ""
    @State private var minutes = ""
    @State private var seconds = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(project.name)
                .font(.headline)

            // h : m : s fields
            HStack(spacing: 6) {
                timeField(label: "h", value: $hours)
                Text(":").foregroundColor(.secondary)
                timeField(label: "m", value: $minutes, max: 59)
                Text(":").foregroundColor(.secondary)
                timeField(label: "s", value: $seconds, max: 59)
            }

            // Quick-add buttons
            HStack(spacing: 6) {
                Text("Add:")
                    .font(.callout)
                    .foregroundColor(.secondary)
                ForEach([15, 30, 60], id: \.self) { mins in
                    Button("+\(mins < 60 ? "\(mins)m" : "1h")") {
                        let current = appState.currentSeconds(for: project)
                        appState.setTime(for: project, seconds: current + mins * 60)
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            Divider()

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Set Time") {
                    let h = Int(hours) ?? 0
                    let m = Int(minutes) ?? 0
                    let s = Int(seconds) ?? 0
                    appState.setTime(for: project, seconds: h * 3600 + m * 60 + s)
                    isPresented = false
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .frame(width: 270)
        .onAppear {
            let total = appState.currentSeconds(for: project)
            hours = String(total / 3600)
            minutes = String((total % 3600) / 60)
            seconds = String(total % 60)
        }
    }

    @ViewBuilder
    private func timeField(label: String, value: Binding<String>, max: Int? = nil) -> some View {
        VStack(spacing: 2) {
            TextField("0", text: value)
                .frame(width: 48)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .onChange(of: value.wrappedValue) { newVal in
                    // Clamp to valid range
                    if let n = Int(newVal), let maxVal = max, n > maxVal {
                        value.wrappedValue = String(maxVal)
                    }
                }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
