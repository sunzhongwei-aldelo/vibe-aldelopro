import Foundation

// MARK: - Order Prep Time Models

enum PrepTimePlatform: String, CaseIterable, Identifiable {
    case uberEatsDoorDash = "Uber Eats & DoorDash"
    case masa = "Masa+"
    case isv = "ISV"

    var id: String { rawValue }
}

enum PrepTimeOrderType: String, CaseIterable, Identifiable {
    case takeOut = "Take Out"
    case delivery = "Delivery"
    case dineIn = "Dine In"
    case driveThru = "Drive Thru"
    case bar = "Bar"
    case retail = "Retail"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .takeOut: return "bag.fill"
        case .delivery: return "bolt.fill"
        case .dineIn: return "fork.knife"
        case .driveThru: return "car.fill"
        case .bar: return "wineglass.fill"
        case .retail: return "storefront.fill"
        }
    }

    var iconColorHex: String {
        switch self {
        case .takeOut: return "#007CFF"
        case .delivery: return "#FFC919"
        case .dineIn: return "#FF403F"
        case .driveThru: return "#FF403F"
        case .bar: return "#3E9314"
        case .retail: return "#00A5A5"
        }
    }
}

enum PrepTimeDayOfWeek: String, CaseIterable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"

    var id: String { rawValue }
}

struct PrepTimeOption: Identifiable, Equatable, Hashable {
    let id = UUID()
    let label: String
    let minutes: Int

    static func == (lhs: PrepTimeOption, rhs: PrepTimeOption) -> Bool {
        lhs.minutes == rhs.minutes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(minutes)
    }

    static let allOptions: [PrepTimeOption] = [
        .init(label: "10 mins", minutes: 10),
        .init(label: "15 mins", minutes: 15),
        .init(label: "20 mins", minutes: 20),
        .init(label: "25 mins", minutes: 25),
        .init(label: "30 mins", minutes: 30),
        .init(label: "35 mins", minutes: 35),
        .init(label: "40 mins", minutes: 40),
        .init(label: "45 mins", minutes: 45),
        .init(label: "50 mins", minutes: 50),
        .init(label: "55 mins", minutes: 55),
        .init(label: "60 mins", minutes: 60),
        .init(label: "75 mins", minutes: 75),
        .init(label: "90 mins", minutes: 90),
        .init(label: "2 h", minutes: 120),
        .init(label: "3 h", minutes: 180),
    ]
}
