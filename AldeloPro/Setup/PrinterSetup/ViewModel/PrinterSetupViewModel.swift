//
//  PrinterSetupViewModel.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/15.
//

import Foundation

// MARK: - ViewModel

/// Add Hardware（打印机/设备搜索）注册步骤页的视图模型。
/// 纯 Foundation 实现，搜索态通过 `@Observable` 暴露给 View，导航由父级处理。
///
/// 设计稿对应同一页面的两个状态：
/// - `isSearching == false`：中心卡片显示「Search for Devices」，可点击触发搜索
/// - `isSearching == true`：卡片显示「Searching …」并在下方展示雷达 loading 动画
@Observable
@MainActor
final class PrinterSetupViewModel {

    // MARK: - State

    /// 是否处于搜索中（点击设备卡片后置为 true）。
    private(set) var isSearching: Bool = false

    // MARK: - Actions

    /// 点击中心卡片：在「待搜索」与「搜索中」之间切换。
    /// 真实蓝牙/网络设备发现逻辑后续接入，此处仅切换 UI 状态。
    func toggleSearching() {
        isSearching.toggle()
    }

    func previousStep() {
        // Navigation handled by parent
    }

    func skipStep() {
        // Navigation handled by parent
    }
}
