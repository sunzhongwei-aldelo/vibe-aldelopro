//
//  MenuSetupViewModel.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import Foundation

// MARK: - Add Item Presentation

enum AddItemPresentation: Identifiable {
    case create(groupId: UUID?)
    case edit(item: SetupMenuItem)
    case editPending(item: SetupMenuItem)

    var id: String {
        switch self {
        case .create(let groupId):
            return "create-\(groupId?.uuidString ?? "none")"
        case .edit(let item):
            return "edit-\(item.id.uuidString)"
        case .editPending(let item):
            return "editPending-\(item.id.uuidString)"
        }
    }
}

// MARK: - ViewModel

@Observable @MainActor
final class MenuSetupViewModel {
    // MARK: - Method Selection State

    var selectedMethod: SetupMethod?
    var presentedMethod: SetupMethod?
    var isProcessing = false
    /// 处理中提示文案：扫描走「Image Processing」，上传文件走「Document Processing」。
    var processingMessage = "Document Processing By AI..."
    var showManualSetup = false

    // MARK: - Menu Data State

    private(set) var menuGroups: [SetupMenuGroup] = []
    private(set) var menuItems: [SetupMenuItem] = []
    private(set) var aiAddedItemIds: Set<UUID> = []

    // MARK: - Staging Buffer（已识别但尚未提交）

    private(set) var pendingGroups: [SetupMenuGroup] = []
    private(set) var pendingItems: [SetupMenuItem] = []
    var showConfirmMenu = false

    /// 识别流程是否从手动列表页（MenuSetupManualView）发起，决定 Confirm Menu「Back」的返回去向。
    private var didEnterConfirmFromManual = false

    /// 处理中的可取消任务（模拟 AI 识别）。
    private var processingTask: Task<Void, Never>?

    /// 跨 item 共享的选项组池：任何 item 创建的选项组都进入此池，供其它 item 选择。
    private(set) var optionGroupPool: [OptionGroup] = []

    // MARK: - Group / Item Presentation State

    var showMenuGroupView = false
    var addItemPresentation: AddItemPresentation?
    var editingGroupId: UUID?

    // MARK: - Deletion State

    var itemToDelete: SetupMenuItem?
    var groupToDelete: SetupMenuGroup?
    var deleteGroupItems: Bool = true

    /// 暂存区待删除项（独立于 itemToDelete，后者作用于已提交的 menuItems）。
    var pendingItemToDelete: SetupMenuItem?

    // MARK: - Queries

    func itemsForGroup(groupId: UUID) -> [SetupMenuItem] {
        menuItems.filter { $0.groupId == groupId }
    }

    var hasGroups: Bool { !menuGroups.isEmpty }

    // MARK: - Method Selection Actions

    func selectMethod(_ method: SetupMethod) {
        selectedMethod = method
        if method == .manuallyAdd {
            showManualSetup = true
        } else {
            presentedMethod = method
        }
    }

    func startProcessing(hasScannedPages: Bool) {
        guard !isProcessing else { return }
        processingMessage = hasScannedPages
            ? "Image Processing By AI..."
            : "Document Processing By AI..."
        didEnterConfirmFromManual = showManualSetup
        isProcessing = true
        processingTask?.cancel()
        processingTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard let self, !Task.isCancelled else { return }
            let sample = SampleMenuData.makeMenuSample()
            self.pendingGroups = sample.groups
            self.pendingItems = sample.items
            self.isProcessing = false
            self.showConfirmMenu = true
        }
    }

    /// 是否已存在已提交的菜单数据（决定 Confirm Menu 返回去向）。
    var hasCommittedMenu: Bool {
        !menuItems.isEmpty || !menuGroups.isEmpty
    }

    /// Confirm：把暂存区写入正式菜单，标记为 AI 添加，进入手动编辑列表。
    func confirmPendingMenu() {
        menuGroups.append(contentsOf: pendingGroups)
        menuItems.append(contentsOf: pendingItems)
        aiAddedItemIds = Set(pendingItems.map { $0.id })
        for item in pendingItems {
            mergeOptionGroupsIntoPool(item.optionGroups)
        }
        showConfirmMenu = false
        showManualSetup = true
        clearStaging()
    }

    /// Back：丢弃本次识别结果；从手动列表发起或已有提交数据则回手动列表，否则回方法选择页。
    func cancelConfirm() {
        clearStaging()
        showConfirmMenu = false
        showManualSetup = didEnterConfirmFromManual || hasCommittedMenu
    }

    /// 编辑暂存项（不触碰已提交的 menuItems）。
    func editPendingItem(_ item: SetupMenuItem) {
        addItemPresentation = .editPending(item: item)
    }

    /// 用编辑结果替换暂存区中对应项。
    func updatePendingItem(originalId: UUID, with item: SetupMenuItem) {
        if let idx = pendingItems.firstIndex(where: { $0.id == originalId }) {
            pendingItems[idx] = item
        }
        addItemPresentation = nil
    }

    /// 请求删除暂存项（打开复用的二次确认弹窗）。
    func requestDeletePendingItem(_ item: SetupMenuItem) {
        pendingItemToDelete = item
    }

    /// 确认删除暂存项（仅作用于暂存区）。
    func confirmDeletePendingItem(_ item: SetupMenuItem) {
        pendingItems.removeAll { $0.id == item.id }
        pendingItemToDelete = nil
    }

    private func clearStaging() {
        pendingGroups = []
        pendingItems = []
        processingTask?.cancel()
        processingTask = nil
    }

    // MARK: - Menu Group Actions

    func updateGroups(_ updatedGroups: [SetupMenuGroup]) {
        menuGroups = updatedGroups
    }

    func presentCreateGroup() {
        editingGroupId = nil
        showMenuGroupView = true
    }

    func presentEditGroup(_ group: SetupMenuGroup) {
        editingGroupId = group.id
        showMenuGroupView = true
    }

    func confirmDeleteGroup(_ group: SetupMenuGroup) {
        if deleteGroupItems {
            let removedIds = menuItems.filter { $0.groupId == group.id }.map { $0.id }
            menuItems.removeAll { $0.groupId == group.id }
            aiAddedItemIds.subtract(removedIds)
        }
        menuGroups.removeAll { $0.id == group.id }
        groupToDelete = nil
    }

    func requestDeleteGroup(_ group: SetupMenuGroup) {
        deleteGroupItems = true
        groupToDelete = group
    }

    // MARK: - Menu Item Actions

    func presentCreateItem(groupId: UUID?) {
        addItemPresentation = .create(groupId: groupId)
    }

    func presentEditItem(_ item: SetupMenuItem) {
        addItemPresentation = .edit(item: item)
    }

    func addItem(_ item: SetupMenuItem) {
        menuItems.append(item)
        mergeOptionGroupsIntoPool(item.optionGroups)
        aiAddedItemIds = []
        addItemPresentation = nil
    }

    func updateItem(originalId: UUID, with item: SetupMenuItem) {
        if let idx = menuItems.firstIndex(where: { $0.id == originalId }) {
            menuItems[idx] = item
        }
        mergeOptionGroupsIntoPool(item.optionGroups)
        addItemPresentation = nil
    }

    // MARK: - Option Group Pool Actions

    /// 按 id 把单个选项组 upsert 进共享池（创建/编辑选项组后立即调用，先入内存）。
    func upsertOptionGroupInPool(_ group: OptionGroup) {
        if let idx = optionGroupPool.firstIndex(where: { $0.id == group.id }) {
            optionGroupPool[idx] = group
        } else {
            optionGroupPool.append(group)
        }
    }

    /// 把一组选项组并入共享池（保存 item 时同步其挂载组）。
    private func mergeOptionGroupsIntoPool(_ groups: [OptionGroup]) {
        for group in groups {
            upsertOptionGroupInPool(group)
        }
    }

    func confirmDeleteItem(_ item: SetupMenuItem) {
        menuItems.removeAll { $0.id == item.id }
        aiAddedItemIds.remove(item.id)
        itemToDelete = nil
    }
}
