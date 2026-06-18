//
//  AddEmployeeViewModel.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/03.
//

import Foundation

@Observable @MainActor
final class AddEmployeeViewModel {
    // MARK: - Form State

    var firstName = ""
    var lastName = ""
    var jobTitle = ""
    var phone = ""
    var mobile = ""
    var email = ""
    var passcode = ""
    var selectedRoles: Set<String> = []
    var selectedAccessibilities: Set<String> = []
    var payRate = ""
    var bankSurchargeEnabled = false
    var bankSurcharge = ""
    var startDate = Date()
    var terminationDate = Date()
    var language = "English"

    // MARK: - Formatters

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy"
        return f
    }()

    var startDateText: String {
        Self.dateFormatter.string(from: startDate)
    }

    var terminationDateText: String {
        Self.dateFormatter.string(from: terminationDate)
    }

    // MARK: - Options

    let jobTitleOptions = ["Driver", "Cashier", "Hostess", "Waiter", "Owner"]
    let roleOptions = ["Driver", "Cashier", "Hostess", "Waiter", "Owner"]
    let accessibilityOptions = ["Dine In", "Bar", "Take Out", "Retail"]
    let languageOptions = ["English", "Spanish", "Chinese", "French"]

    // MARK: - Computed

    var avatarInitials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        if f.isEmpty && l.isEmpty { return "" }
        return f + l
    }

    /// 表单是否可保存：必填项（First/Last Name）已填，且选填项（Email/Phone/Mobile）
    /// 要么为空、要么格式合法。@Observable 会随字段变化实时重算，用于 gate Save 按钮。
    var isFormValid: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            && FieldValidator.email(email) == nil
            && FieldValidator.phone(phone) == nil
            && FieldValidator.phone(mobile) == nil
    }

    // MARK: - Actions

    func toggleRole(_ role: String) {
        if selectedRoles.contains(role) {
            selectedRoles.remove(role)
        } else {
            selectedRoles.insert(role)
        }
    }

    func toggleAccessibility(_ item: String) {
        if selectedAccessibilities.contains(item) {
            selectedAccessibilities.remove(item)
        } else {
            selectedAccessibilities.insert(item)
        }
    }

    func removeRole(_ role: String) {
        selectedRoles.remove(role)
    }

    func removeAccessibility(_ item: String) {
        selectedAccessibilities.remove(item)
    }
}

// MARK: - Preview Support

extension AddEmployeeViewModel {
    static func preview() -> AddEmployeeViewModel {
        let vm = AddEmployeeViewModel()
        vm.firstName = "John"
        vm.lastName = "Doe"
        vm.jobTitle = "Waiter"
        vm.selectedRoles = ["Cashier", "Waiter"]
        vm.language = "English"
        return vm
    }
}
