//
//  SetupMenuGroup.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/08.
//

import Foundation

/// 菜单分组（如 "Burgers & Sandwiches"、"Beverages"）
struct SetupMenuGroup: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var items: [MenuItem]
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        items: [MenuItem] = [],
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.sortOrder = sortOrder
    }
}
