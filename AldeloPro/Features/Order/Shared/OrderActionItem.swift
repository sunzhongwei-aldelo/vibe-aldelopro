//
//  OrderActionItem.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - ItemStatusTag

/// 项目状态标签 — 显示在卡片右上角的彩色标签
///
/// 例如："Hold 2:00 PM"（红色）、"Do Not Make"（灰色描边）
struct ItemStatusTag: Identifiable, Equatable, Sendable {
    let id: String
    let text: String
    let style: TagStyle

    init(id: String = UUID().uuidString, text: String, style: TagStyle = .outlined) {
        self.id = id
        self.text = text
        self.style = style
    }

    enum TagStyle: Equatable, Sendable {
        /// 红色填充背景 + 白色文字（如 "Hold", "Hold 2:00 PM"）
        case filled
        /// 灰色描边 + 灰色文字（如 "Do Not Make"）
        case outlined
    }
}

// MARK: - OrderActionItem

/// 订单操作项目数据模型 — DoNotMake / Fire / Remake / Repeat 共用
///
/// 表示一个可被选中操作的 Transaction Item（菜品或商品）。
/// 各功能页面通过该模型统一传递数据，保持接口一致性。
struct OrderActionItem: Identifiable, Equatable, Sendable {

    /// 唯一标识符
    let id: String

    /// 菜品/商品名称
    let name: String

    /// 描述文本（如 "Small Cup"、"Bottle"）
    let itemDescription: String?

    /// 附加描述（如 "Lafite,Vintage 1992"，显示为强调色文字）
    let subDescription: String?

    /// 远程图片 URL（nil 使用占位图）
    let imageURL: String?

    /// 当前数量
    var quantity: Int

    /// 是否允许编辑数量（DoNotMake 支持，其他功能一般不需要）
    let allowQuantityEdit: Bool

    /// 是否显示左上角蓝色状态圆点（表示 Transaction 状态）
    let hasStatusDot: Bool

    /// 状态标签数组（如 "Hold"、"Do Not Make" 等，显示在卡片名称行右侧）
    let tags: [ItemStatusTag]

    init(
        id: String = UUID().uuidString,
        name: String,
        itemDescription: String? = nil,
        subDescription: String? = nil,
        imageURL: String? = nil,
        quantity: Int = 1,
        allowQuantityEdit: Bool = false,
        hasStatusDot: Bool = false,
        tags: [ItemStatusTag] = []
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.subDescription = subDescription
        self.imageURL = imageURL
        self.quantity = quantity
        self.allowQuantityEdit = allowQuantityEdit
        self.hasStatusDot = hasStatusDot
        self.tags = tags
    }
}

// MARK: - OrderActionType

/// 订单操作类型枚举 — 区分不同功能页面的行为和样式
enum OrderActionType: String, CaseIterable {
    case doNotMake = "Do Not Make"
    case fire = "Fire"
    case remake = "Remake"
    case `repeat` = "Repeat"

    /// 顶部导航栏标题
    var pageTitle: String { rawValue }

    /// 导航栏左侧图标（SF Symbol）
    var headerIcon: String {
        switch self {
        case .doNotMake: return "xmark.circle"
        case .fire: return "flame"
        case .remake: return "arrow.counterclockwise.circle"
        case .repeat: return "repeat.circle"
        }
    }
}
