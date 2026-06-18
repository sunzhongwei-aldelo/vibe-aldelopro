//
//  CashierReportSelectEmployeeModel.swift
//  AldeloPro
//

import Foundation

// MARK: - Job Title

enum EmployeeJobTitle: String {
    case cashier = "Cashier"
    case serverBank = "Server Bank"
}

// MARK: - Filter Option

struct EmployeeFilterOption: Identifiable, Hashable {
    var id: String { value }
    let label: String
    let value: String
}

// MARK: - Employee Card Data

struct EmployeeCardData: Identifiable {
    let id: String
    let name: String
    let jobTitle: EmployeeJobTitle
    let signInTime: String
    let signOutStatus: SignOutStatus
    let device: String?
    let drawer: String?
}

// MARK: - Select Employee Data

struct CashierReportSelectEmployeeData {
    let title: String
    let bankOptions: [EmployeeFilterOption]
    let sourceOptions: [EmployeeFilterOption]
    let selectedBank: String
    let selectedSource: String
    let selectedDate: String
    let employees: [EmployeeCardData]
}

// MARK: - Mock Data

extension CashierReportSelectEmployeeData {
    static let mock = CashierReportSelectEmployeeData(
        title: "Select An Employee",
        bankOptions: [
            EmployeeFilterOption(label: "All Banks", value: "all"),
            EmployeeFilterOption(label: "Bank 1", value: "bank1"),
            EmployeeFilterOption(label: "Bank 2", value: "bank2")
        ],
        sourceOptions: [
            EmployeeFilterOption(label: "All Sources", value: "all"),
            EmployeeFilterOption(label: "POS", value: "pos"),
            EmployeeFilterOption(label: "Online", value: "online")
        ],
        selectedBank: "all",
        selectedSource: "all",
        selectedDate: "01/16/2026",
        employees: [
            EmployeeCardData(id: "1", name: "Zhang San", jobTitle: .cashier, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: "001", drawer: "1"),
            EmployeeCardData(id: "2", name: "Mike Smith", jobTitle: .cashier, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: "001", drawer: "1"),
            EmployeeCardData(id: "3", name: "Emily Anderson", jobTitle: .serverBank, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: nil, drawer: nil),
            EmployeeCardData(id: "4", name: "Alex Brown", jobTitle: .serverBank, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: nil, drawer: nil),
            EmployeeCardData(id: "5", name: "Uber Eats & DoorDash", jobTitle: .serverBank, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: nil, drawer: nil),
            EmployeeCardData(id: "6", name: "Masa Online Order", jobTitle: .serverBank, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: nil, drawer: nil),
            EmployeeCardData(id: "7", name: "Ben Jones", jobTitle: .cashier, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: "001", drawer: "1"),
            EmployeeCardData(id: "8", name: "Eva Miller", jobTitle: .serverBank, signInTime: "2025-09-09  07:58 PM", signOutStatus: .stillSignedIn, device: nil, drawer: nil)
        ]
    )
}
