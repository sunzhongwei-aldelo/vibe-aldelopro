//
//  DoNotMakeViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import Foundation

// MARK: - DoNotMakeViewModel

/// DoNotMake 页面状态管理 — 标记订单项为"不制作"，支持「拆分流」状态机。
///
/// 拆分流（对照图 315 / 316）：
/// - 点击某卡数量胶囊 → 正下方弹出 Numpad，Stepper 表示「要拆出去的克隆数量」 Q_split。
/// - Numpad Confirm → 执行「母体裁剪、异体克隆并默认选中」：
///     • 母卡就地刷新：Q_original = Q_initial − Q_split（保持未选中、普通白底）
///     • 紧随母卡之后插入一张全新克隆卡：Q_new = Q_split（自动强制选中）
/// - 拆分值范围：1 ... (Q_initial − 1)，保证母体至少保留 1（不可拆空）。
/// - 数量降为 1 的卡片不可再拆（键盘 − 与数字键禁用），锁死无限坍塌。
///
/// 选中规则（拆分流下每张卡都是独立实体）：
/// - 克隆卡保持自身数量，取消选中仅去掉蓝框/勾选，数量不变。
/// - 母卡裁剪后数量固定，不再"恢复原值"。
@Observable
final class DoNotMakeViewModel {

    // MARK: - State

    private(set) var items: [OrderActionItem]
    private(set) var selectedIDs: Set<String> = []

    /// 当前正在编辑（拆分）的项目 ID
    var editingQuantityItemID: String?

    /// Numpad 绑定值 = 要拆出去的克隆数量 Q_split（confirm 时才执行拆分）
    var editingQuantityValue: Int = 1

    // MARK: - 派生状态

    var selectedCount: Int { selectedIDs.count }
    var canConfirm: Bool { !selectedIDs.isEmpty }

    /// 当前编辑项的数量（= Q_initial，拆分母体基数）
    private var editingItemQuantity: Int {
        guard let id = editingQuantityItemID,
              let item = items.first(where: { $0.id == id }) else { return 1 }
        return item.quantity
    }

    /// 拆分值上限 = Q_initial − 1（必须给母体留至少 1）
    var editingMaxQuantity: Int {
        max(1, editingItemQuantity - 1)
    }

    // MARK: - Init

    init(items: [OrderActionItem] = []) {
        self.items = items
    }

    // MARK: - Selection Actions

    /// 切换选中态（拆分流下仅切换蓝框/勾选，不改数量）
    func toggleSelection(_ itemID: String) {
        if selectedIDs.contains(itemID) {
            selectedIDs.remove(itemID)
        } else {
            selectedIDs.insert(itemID)
        }
    }

    /// 全选 / 全不选
    func toggleSelectAll() {
        if selectedIDs.count == items.count {
            selectedIDs.removeAll()
        } else {
            selectedIDs = Set(items.map(\.id))
        }
    }

    // MARK: - Split Editing

    /// 点击数量胶囊：数量为 1 无法拆分，直接切换选中；否则打开 Numpad 开始拆分。
    func startEditQuantity(itemID: String) {
        guard let item = items.first(where: { $0.id == itemID }) else { return }

        // 数量为 1 不可拆分 → 仅切换选中态
        if item.quantity <= 1 {
            toggleSelection(itemID)
            return
        }

        editingQuantityItemID = itemID
        // 初始拆分值 = 1（最小拆分），用户可通过 Stepper / 数字键调整
        editingQuantityValue = 1
    }

    /// Numpad Confirm：执行拆分流。
    /// 母卡 quantity = Q_initial − Q_split（未选中）；
    /// 紧随其后插入克隆卡 quantity = Q_split（强制选中）。
    func keypadConfirm() {
        guard let id = editingQuantityItemID,
              let index = items.firstIndex(where: { $0.id == id }) else {
            dismissKeypad()
            return
        }

        let qInitial = items[index].quantity
        let qSplit = min(max(editingQuantityValue, 1), max(1, qInitial - 1))

        // 边界：母体无法再拆（≤1）时不执行拆分，直接关闭
        guard qInitial > 1 else {
            dismissKeypad()
            return
        }

        // 母卡就地裁剪，保持未选中
        var mother = items[index]
        mother.quantity = qInitial - qSplit
        items[index] = mother
        selectedIDs.remove(mother.id)

        // 催生克隆卡（紧随母卡之后），强制选中
        let clone = makeClone(of: mother, quantity: qSplit)
        items.insert(clone, at: index + 1)
        selectedIDs.insert(clone.id)

        dismissKeypad()
    }

    /// 关闭 Numpad（不执行拆分）
    func dismissKeypad() {
        editingQuantityItemID = nil
        editingQuantityValue = 1
    }

    func confirmedItems() -> [OrderActionItem] {
        items.filter { selectedIDs.contains($0.id) }
    }

    // MARK: - Clone Factory

    /// 由母卡克隆出一张全新独立卡片（新 id，承载拆分数量）。
    private func makeClone(of source: OrderActionItem, quantity: Int) -> OrderActionItem {
        OrderActionItem(
            id: UUID().uuidString,
            name: source.name,
            itemDescription: source.itemDescription,
            subDescription: source.subDescription,
            imageURL: source.imageURL,
            quantity: quantity,
            allowQuantityEdit: source.allowQuantityEdit,
            hasStatusDot: source.hasStatusDot,
            tags: source.tags
        )
    }
}
