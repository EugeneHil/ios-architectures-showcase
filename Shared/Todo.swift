import Foundation

/// The single domain model shared by every architecture sample.
struct Todo: Identifiable, Codable, Equatable {
    enum Priority: Int, Codable, Comparable {
        case low = 0
        case medium = 1
        case high = 2

        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

        var title: String {
            switch self {
            case .low: "Low"
            case .medium: "Medium"
            case .high: "High"
            }
        }
    }

    let id: UUID
    var title: String
    var notes: String
    var priority: Priority
    var isDone: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        priority: Priority = .medium,
        isDone: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.isDone = isDone
        self.createdAt = createdAt
    }

    /// Seed data shown by every sample before the user creates anything.
    static func samples() -> [Todo] {
        [
            Todo(title: "Read TCA documentation", notes: "State, actions, reducers, effects", priority: .high),
            Todo(title: "Compare MVVM and MVP binding approaches", priority: .medium),
            Todo(title: "Sketch the module layout for VIPER", priority: .low),
            Todo(title: "Prepare one interview story per architecture", priority: .high, isDone: true),
            Todo(title: "Set up the showcase repository", priority: .medium, isDone: true),
        ]
    }
}
