//
//  DenyOrderViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import Foundation

// MARK: - DenyOrderViewModel

/// 拒单页面的状态管理
///
/// 管理预设原因列表、用户自定义输入、选中状态之间的互斥逻辑：
/// - 选中预设原因 → 清空自定义输入，文本框显示预设内容
/// - 编辑自定义输入 → 取消预设选中
/// - 两者不可同时生效，effectiveReason 返回最终提交值
@Observable
final class DenyOrderViewModel {

    // MARK: - 状态

    /// 预设原因选项列表
    private(set) var presetReasons: [String] = [
        "Order Mistake",
        "Wait Time Too Long",
        "Customer No Longer Wanted",
        "Out Of Stock",
        "Item Not As Expected",
        "Given To Wrong Customer"
    ]

    /// 用户手动输入的自定义原因
    var customReason: String = ""

    /// 当前选中的预设原因（nil = 未选中任何预设）
    var selectedReason: String? = nil

    // MARK: - 计算属性

    /// 最终提交的原因文本（预设优先，其次取自定义输入）
    var effectiveReason: String {
        if let selected = selectedReason {
            return selected
        }
        return customReason.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Confirm 按钮是否可用（原因不为空即可提交）
    var canConfirm: Bool {
        !effectiveReason.isEmpty
    }

    /// 文本输入框显示内容（选中预设时显示预设文本）
    var displayedInputText: String {
        selectedReason ?? customReason
    }

    // MARK: - 操作

    /// 切换预设原因选中状态（再次点击取消选中）
    func selectReason(_ reason: String) {
        if selectedReason == reason {
            selectedReason = nil
        } else {
            selectedReason = reason
            customReason = ""
        }
    }

    /// 更新自定义原因文本（有输入时自动取消预设选中）
    func updateCustomReason(_ text: String) {
        customReason = text
        if !text.isEmpty {
            selectedReason = nil
        }
    }

    /// 重置所有状态
    func reset() {
        customReason = ""
        selectedReason = nil
    }
}
