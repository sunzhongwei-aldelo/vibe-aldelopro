//
//  OrderActionViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import Foundation

// MARK: - OrderActionViewModel

/// 通用订单操作 ViewModel — Fire / Remake / Repeat 共用
///
/// 管理逻辑：
/// - 点击选中/取消选中项目（toggle 模式）
/// - "All" 全选/全不选
/// - 统计已选数量供 Confirm 按钮展示
@Observable
final class OrderActionViewModel {

    // MARK: - State

    private(set) var items: [OrderActionItem]
    private(set) var selectedIDs: Set<String> = []

    // MARK: - 派生状态

    var selectedCount: Int { selectedIDs.count }
    var canConfirm: Bool { !selectedIDs.isEmpty }

    // MARK: - Init

    init(items: [OrderActionItem] = []) {
        self.items = items
    }

    // MARK: - Actions

    /// 切换某个项目的选中状态
    func toggleSelection(_ itemID: String) {
        if selectedIDs.contains(itemID) {
            selectedIDs.remove(itemID)
        } else {
            selectedIDs.insert(itemID)
        }
    }

    /// 全选/全不选切换
    func toggleSelectAll() {
        if selectedIDs.count == items.count {
            selectedIDs.removeAll()
        } else {
            selectedIDs = Set(items.map(\.id))
        }
    }

    /// 获取所有已选中的项目
    func confirmedItems() -> [OrderActionItem] {
        items.filter { selectedIDs.contains($0.id) }
    }
}
