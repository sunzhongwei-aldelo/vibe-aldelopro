//
//  Employee.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/04.
//

import Foundation

struct Employee: Identifiable, Equatable, Sendable {
    let id: UUID
    var firstName: String
    var lastName: String
    var jobTitle: String
    var avatarImageData: Data?

    var fullName: String { firstName + " " + lastName }

    var initials: String {
        let f = firstName.prefix(1).uppercased()
        let l = lastName.prefix(1).uppercased()
        return f + l
    }
}
