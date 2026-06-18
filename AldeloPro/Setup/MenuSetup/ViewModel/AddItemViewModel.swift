//
//  AddItemViewModel.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import Foundation

/// 驱动 `AddItemView` 的表单数据与业务逻辑（新增/编辑菜单项）。
/// 仅持有数据与动作；焦点（`@FocusState`）与下拉/弹窗显隐开关属于 UI 状态，保留在 View。
@Observable
@MainActor
final class AddItemViewModel {

    // MARK: - Form Data
    var itemName: String
    var selectedGroupId: UUID?
    var unitPrice: String
    var optionGroups: [OptionGroup]
    var selectedTaxClass: TaxClass
    var imageDataList: [Data]
    var coverImageIndex: Int?
    var productionFacingName: String
    var attributes: [String]
    var estimatedPrepareTime: Int?
    var nutrition: NutritionInfo

    // MARK: - Constants
    /// 单价上限（与 CreateOptionGroupView 的 maxPrice 一致）。
    private let maxUnitPrice: Decimal = 9999.99

    // MARK: - Option Group Pool
    /// 跨 item 共享的可选池（含其它 item 创建的）。仅由 `upsertOptionGroup` 维护。
    private(set) var allOptionGroups: [OptionGroup]
    /// 当前正在编辑的选项组；nil 表示 Create 按钮触发的新建。
    var editingOptionGroup: OptionGroup?

    // MARK: - Dependencies
    let availableGroups: [SetupMenuGroup]
    let editingItem: SetupMenuItem?
    /// 创建/编辑选项组后回调父级，持久化进共享池。
    private let onCreateOptionGroup: ((OptionGroup) -> Void)?
    private let onAdd: ((SetupMenuItem) -> Void)?

    // MARK: - Init
    init(
        availableGroups: [SetupMenuGroup],
        initialGroupId: UUID? = nil,
        editingItem: SetupMenuItem? = nil,
        optionGroupPool: [OptionGroup] = [],
        onCreateOptionGroup: ((OptionGroup) -> Void)? = nil,
        onAdd: ((SetupMenuItem) -> Void)? = nil
    ) {
        self.availableGroups = availableGroups
        self.editingItem = editingItem
        self.onCreateOptionGroup = onCreateOptionGroup
        self.onAdd = onAdd

        // 本地可选池 = 共享池 ∪ 本 item 已挂载的选项组（保证 Select 页能看到/管理它们）。
        var seededPool = optionGroupPool
        for group in (editingItem?.optionGroups ?? []) where !seededPool.contains(where: { $0.id == group.id }) {
            seededPool.append(group)
        }
        self.allOptionGroups = seededPool

        if let item = editingItem {
            itemName = item.name
            selectedGroupId = item.groupId
            unitPrice = item.unitPrice == 0 ? "" : CurrencyFormatter.string(from: item.unitPrice)
            optionGroups = item.optionGroups
            selectedTaxClass = item.taxClass
            imageDataList = item.imageData
            coverImageIndex = item.coverImageIndex
            productionFacingName = item.productionFacingName
            attributes = item.attributes
            estimatedPrepareTime = item.estimatedPrepareTime
            nutrition = item.nutrition
        } else {
            itemName = ""
            selectedGroupId = initialGroupId
            unitPrice = ""
            optionGroups = []
            selectedTaxClass = .standard
            imageDataList = []
            coverImageIndex = nil
            productionFacingName = ""
            attributes = []
            estimatedPrepareTime = nil
            nutrition = NutritionInfo()
        }
    }

    // MARK: - Computed
    /// 是否处于编辑模式（决定标题与按钮文案）。
    var isEditing: Bool { editingItem != nil }

    var isFormValid: Bool {
        !itemName.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedGroupId != nil
            && !unitPrice.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var selectedGroupName: String {
        if let id = selectedGroupId, let group = availableGroups.first(where: { $0.id == id }) {
            return group.name
        }
        return "Select Group"
    }

    var prepTimeText: String {
        if let time = estimatedPrepareTime {
            return "\(time) Mins"
        }
        return "Select Time"
    }

    let prepTimeOptions = [5, 10, 15, 20, 25, 30, 45, 60]

    // MARK: - Actions
    /// 过滤单价输入：仅保留数字与单个小数点，小数最多两位，并封顶到 maxUnitPrice。
    func sanitizeUnitPrice() {
        let sanitized = CurrencyFormatter.sanitize(unitPrice, max: maxUnitPrice)
        if sanitized != unitPrice {
            unitPrice = sanitized
        }
    }

    /// 失焦补齐单价为两位小数（`"5"` → `"5.00"`）；空串保持空。
    func padUnitPrice() {
        let padded = CurrencyFormatter.padToTwoDecimals(unitPrice)
        if padded != unitPrice {
            unitPrice = padded
        }
    }

    /// 移除指定下标的选项组。
    func removeOptionGroup(at index: Int) {
        guard optionGroups.indices.contains(index) else { return }
        optionGroups.remove(at: index)
    }

    /// 用 Select 页返回的结果整体替换本 item 已挂载的选项组。
    func replaceOptionGroups(_ groups: [OptionGroup]) {
        optionGroups = groups
    }

    /// 保存选项组：按 id 命中则替换（编辑），否则追加（新建）；同时维护可选池 allOptionGroups。
    func upsertOptionGroup(_ group: OptionGroup) {
        if let idx = optionGroups.firstIndex(where: { $0.id == group.id }) {
            optionGroups[idx] = group
        } else {
            optionGroups.append(group)
        }
        if let poolIdx = allOptionGroups.firstIndex(where: { $0.id == group.id }) {
            allOptionGroups[poolIdx] = group
        } else {
            allOptionGroups.append(group)
        }
        onCreateOptionGroup?(group)  // 持久化到跨 item 的共享池
        editingOptionGroup = nil
    }

    /// 构建并回传菜单项；校验未过返回 false（此时 View 不应 dismiss）。
    @discardableResult
    func save() -> Bool {
        guard let groupId = selectedGroupId, !itemName.isEmpty else { return false }
        let item = SetupMenuItem(
            id: editingItem?.id ?? UUID(),
            name: itemName,
            groupId: groupId,
            unitPrice: Decimal(string: unitPrice) ?? 0,
            optionGroups: optionGroups,
            taxClass: selectedTaxClass,
            imageData: imageDataList,
            coverImageIndex: coverImageIndex,
            productionFacingName: productionFacingName,
            attributes: attributes,
            estimatedPrepareTime: estimatedPrepareTime,
            nutrition: nutrition
        )
        onAdd?(item)
        return true
    }
}
