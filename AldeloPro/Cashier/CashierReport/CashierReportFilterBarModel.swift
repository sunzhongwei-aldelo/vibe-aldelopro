import Foundation

// MARK: - Cashier Report Filter Bar Data

struct CashierReportFilterBarData {
    let statusOptions: [CashierStatus]
    let selectedStatus: CashierStatus
    let selectedDate: Date
    let employees: [FilterEmployee]
    let selectedEmployee: FilterEmployee?
}

// MARK: - Cashier Status

enum CashierStatus: String, CaseIterable, Identifiable {
    case open = "Open"
    case closed = "Closed"
    case all = "All"

    var id: String { rawValue }
}

// MARK: - Filter Employee

struct FilterEmployee: Identifiable {
    let id: String
    let name: String
}

// MARK: - Mock Data

extension CashierReportFilterBarData {
    static let mock = CashierReportFilterBarData(
        statusOptions: CashierStatus.allCases,
        selectedStatus: .open,
        selectedDate: {
            var components = DateComponents()
            components.year = 2026
            components.month = 1
            components.day = 16
            return Calendar.current.date(from: components) ?? Date()
        }(),
        employees: [
            FilterEmployee(id: "1", name: "Mike Smith"),
            FilterEmployee(id: "2", name: "Zhang San"),
            FilterEmployee(id: "3", name: "Emily Anderson"),
            FilterEmployee(id: "4", name: "Alex Brown")
        ],
        selectedEmployee: nil
    )
}
