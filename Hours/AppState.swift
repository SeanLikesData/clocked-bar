import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var projects: [Project] = []
    @Published var activeProjectId: UUID? = nil
    @Published var timerStartDate: Date? = nil
    // Incremented each second so views that display elapsed time redraw automatically.
    @Published var tick: Date = Date()

    private var timerCancellable: AnyCancellable?

    init() {
        load()
        // .common run loop mode keeps the timer firing while menus are open.
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.tick = date
            }
    }

    var isRunning: Bool { activeProjectId != nil }

    var activeProject: Project? {
        guard let id = activeProjectId else { return nil }
        return projects.first { $0.id == id }
    }

    // Returns the current displayed seconds for a project, including any
    // in-progress running time that has not yet been committed.
    func currentSeconds(for project: Project) -> Int {
        var seconds = project.totalSeconds
        if project.id == activeProjectId, let start = timerStartDate {
            seconds += Int(tick.timeIntervalSince(start))
        }
        return max(0, seconds)
    }

    func startTimer(for project: Project) {
        if activeProjectId != nil {
            commitActiveTimer()
        }
        activeProjectId = project.id
        timerStartDate = Date()
        saveTimerState()
    }

    func stopTimer() {
        commitActiveTimer()
    }

    func addProject(name: String) {
        projects.append(Project(name: name))
        saveProjects()
    }

    func deleteProjects(at offsets: IndexSet) {
        let removingActive = offsets.contains(where: { projects[$0].id == activeProjectId })
        if removingActive {
            activeProjectId = nil
            timerStartDate = nil
        }
        projects.remove(atOffsets: offsets)
        saveProjects()
        saveTimerState()
    }

    func moveProjects(from source: IndexSet, to destination: Int) {
        projects.move(fromOffsets: source, toOffset: destination)
        saveProjects()
    }

    func renameProject(_ project: Project, to name: String) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[idx].name = name
        saveProjects()
    }

    // Sets the total displayed time for a project. If the project's timer is
    // currently running, the running portion is reset so the display continues
    // counting up from the new value.
    func setTime(for project: Project, seconds: Int) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[idx].totalSeconds = max(0, seconds)
        if project.id == activeProjectId {
            timerStartDate = Date()
            saveTimerState()
        }
        saveProjects()
    }

    private func commitActiveTimer() {
        guard let id = activeProjectId, let start = timerStartDate else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        if let idx = projects.firstIndex(where: { $0.id == id }) {
            projects[idx].totalSeconds += elapsed
        }
        activeProjectId = nil
        timerStartDate = nil
        saveProjects()
        saveTimerState()
    }

    // MARK: - Persistence

    private func saveProjects() {
        guard let data = try? JSONEncoder().encode(projects) else { return }
        UserDefaults.standard.set(data, forKey: "hours.projects")
    }

    private func saveTimerState() {
        if let id = activeProjectId {
            UserDefaults.standard.set(id.uuidString, forKey: "hours.activeProjectId")
            UserDefaults.standard.set(timerStartDate, forKey: "hours.timerStartDate")
        } else {
            UserDefaults.standard.removeObject(forKey: "hours.activeProjectId")
            UserDefaults.standard.removeObject(forKey: "hours.timerStartDate")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "hours.projects"),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
        if let idStr = UserDefaults.standard.string(forKey: "hours.activeProjectId"),
           let id = UUID(uuidString: idStr),
           projects.contains(where: { $0.id == id }) {
            activeProjectId = id
            timerStartDate = UserDefaults.standard.object(forKey: "hours.timerStartDate") as? Date ?? Date()
        }
    }
}
