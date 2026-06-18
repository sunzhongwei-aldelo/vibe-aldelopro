//
//  OptionGroup.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/08.
//

import Foundation

/// 选项组（如 "Sauce"、"Beef"）
struct OptionGroup: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var choices: [OptionChoice]
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        choices: [OptionChoice] = [],
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.choices = choices
        self.sortOrder = sortOrder
    }

    /// 选项摘要文本（如 "Salad (No/A Little/Extra), Cheese (No/A Little/Extra)"）。
    /// 仅列出已启用 actions 且已填价（extraPrice != nil，含 0）的 action；价格留空（nil）的不计入。
    var summary: String {
        choices.map { choice in
            let modifiers = choice.listedModifierNames.joined(separator: "/")
            return modifiers.isEmpty ? choice.name : "\(choice.name) (\(modifiers))"
        }.joined(separator: ", ")
    }
}

/// 单个选项（如 "Salad"）及其修饰级别
struct OptionChoice: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var price: Decimal
    var actionsEnabled: Bool
    var actionModifiers: [ActionModifier]
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        price: Decimal = 0,
        actionsEnabled: Bool = false,
        actionModifiers: [ActionModifier] = ActionModifier.defaults,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.actionsEnabled = actionsEnabled
        self.actionModifiers = actionModifiers
        self.sortOrder = sortOrder
    }

    /// 实际上架的 action：仅当启用 actions 且已填价（extraPrice != nil）时计入；留空（nil）视为未上架。
    var listedActionModifiers: [ActionModifier] {
        guard actionsEnabled else { return [] }
        return actionModifiers.filter { $0.extraPrice != nil }
    }

    /// 上架 action 的名称列表（供摘要展示）。
    var listedModifierNames: [String] {
        listedActionModifiers.map(\.name)
    }

    /// Legacy accessor for modifier names
    var modifiers: [String] {
        actionModifiers.map(\.name)
    }
}

/// 操作修饰（如 "No", "A Little", "Extra"）。
/// `extraPrice` 为可选：nil 表示价格留空（未上架），具体数值（含 0）表示已填价（上架）。
struct ActionModifier: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var extraPrice: Decimal?

    init(id: UUID = UUID(), name: String, extraPrice: Decimal? = nil) {
        self.id = id
        self.name = name
        self.extraPrice = extraPrice
    }

    static let defaults: [ActionModifier] = [
        ActionModifier(name: "No"),
        ActionModifier(name: "A Little"),
        ActionModifier(name: "Extra"),
        ActionModifier(name: "2X"),
        ActionModifier(name: "3X")
    ]
}
