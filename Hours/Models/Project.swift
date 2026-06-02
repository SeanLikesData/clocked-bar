import Foundation

struct Project: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var totalSeconds: Int

    init(id: UUID = UUID(), name: String, totalSeconds: Int = 0) {
        self.id = id
        self.name = name
        self.totalSeconds = totalSeconds
    }
}
