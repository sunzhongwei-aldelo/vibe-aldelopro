//
//  SelectEmployeeToEmailModel.swift
//  AldeloPro
//

import Foundation

// MARK: - Employee Role

/// Job title shown as a colored badge on each employee card.
enum EmailEmployeeRole: String, CaseIterable {
    case waiter = "Waiter"
    case cashier = "Cashier"
    case manager = "Manager"
}

// MARK: - Filter Option

/// A selectable option for the "All Employees" dropdown filter.
struct EmailEmployeeFilterOption: Identifiable, Hashable {
    var id: String { value }
    let label: String
    let value: String
}

// MARK: - Employee

/// A single employee row rendered as a card in the selection grid.
struct EmailEmployee: Identifiable {
    let id: String
    let name: String
    let email: String
    let role: EmailEmployeeRole
}

// MARK: - Screen Data

/// All data backing the Select Employee To Email dialog.
struct SelectEmployeeToEmailData {
    let title: String
    let filterOptions: [EmailEmployeeFilterOption]
    let selectedFilter: String
    let searchPlaceholder: String
    let employees: [EmailEmployee]
}

// MARK: - Mock Data

extension SelectEmployeeToEmailData {
    static let mock = SelectEmployeeToEmailData(
        title: "Select Employee To Email",
        filterOptions: [
            EmailEmployeeFilterOption(label: "All Employees", value: "all"),
            EmailEmployeeFilterOption(label: "Waiter", value: "waiter"),
            EmailEmployeeFilterOption(label: "Cashier", value: "cashier"),
            EmailEmployeeFilterOption(label: "Manager", value: "manager")
        ],
        selectedFilter: "all",
        searchPlaceholder: "Search By Employee or Email",
        employees: [
            EmailEmployee(id: "1", name: "Anderson", email: "Anderson@Gmail.Com", role: .waiter),
            EmailEmployee(id: "2", name: "Anderson", email: "Anderson@Gmail.Com", role: .cashier),
            EmailEmployee(id: "3", name: "Anderson", email: "Anderson@Gmail.Com", role: .cashier),
            EmailEmployee(id: "4", name: "James", email: "James@Gmail.Com", role: .manager),
            EmailEmployee(id: "5", name: "Anderson", email: "Anderson@Gmail.Com", role: .cashier),
            EmailEmployee(id: "6", name: "James", email: "James@Gmail.Com", role: .cashier),
            EmailEmployee(id: "7", name: "Anderson", email: "Anderson@Gmail.Com", role: .cashier),
            EmailEmployee(id: "8", name: "James", email: "James@Gmail.Com", role: .cashier)
        ]
    )
}
