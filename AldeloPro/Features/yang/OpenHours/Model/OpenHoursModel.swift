import Foundation

enum Weekday: Int, CaseIterable, Identifiable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
}

struct TimeRange: Identifiable {
    let id: UUID
    var openTime: Date?
    var closeTime: Date?

    init(id: UUID = UUID(), openTime: Date? = nil, closeTime: Date? = nil) {
        self.id = id
        self.openTime = openTime
        self.closeTime = closeTime
    }
}

struct DaySchedule: Identifiable {
    let id: UUID
    let weekday: Weekday
    var isOpen: Bool
    var timeRanges: [TimeRange]
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        weekday: Weekday,
        isOpen: Bool = true,
        timeRanges: [TimeRange] = [TimeRange()],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.weekday = weekday
        self.isOpen = isOpen
        self.timeRanges = timeRanges
        self.isExpanded = isExpanded
    }
}
