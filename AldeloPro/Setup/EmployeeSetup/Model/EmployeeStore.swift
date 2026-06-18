//
//  EmployeeStore.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/04.
//

import Foundation

@Observable @MainActor
final class EmployeeStore {
    private(set) var employees: [Employee] = []

    var hasEmployees: Bool { employees.isEmpty == false }

    func add(_ employee: Employee) {
        employees.append(employee)
    }

    func remove(at index: Int) {
        guard employees.indices.contains(index) else { return }
        employees.remove(at: index)
    }

    func removeById(_ id: UUID) {
        employees.removeAll { $0.id == id }
    }

    func update(_ employee: Employee) {
        guard let index = employees.firstIndex(where: { $0.id == employee.id }) else { return }
        employees[index] = employee
    }
}
