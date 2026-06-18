//
//  EditPickupNameViewModel.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/10.
//

import Foundation

/// 「修改自提人姓名」弹窗的状态机控制层。
/// 仅 import Foundation —— 不接触任何 UI / SwiftUI 类型。
/// 管理输入中的姓名、提交 / 取消回调，依赖通过 init 注入（禁止 Singleton）。
@MainActor
@Observable
final class EditPickupNameViewModel {

    // MARK: 状态（对外只读）

    /// 输入框中正在编辑的姓名。
    private(set) var pickupName: String

    // MARK: 回调（构造注入）

    /// 点击 Confirm 且姓名非空时回调，携带去除首尾空白后的最终姓名。
    private let onConfirm: (String) -> Void
    /// 点击 Cancel 或关闭叉号时回调。
    private let onCancel: () -> Void

    // MARK: 初始化

    init(
        initialName: String = "",
        onConfirm: @escaping (String) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        self.pickupName = initialName
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    // MARK: 派生值

    /// 去除首尾空白后的姓名。
    var trimmedName: String {
        pickupName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 仅当存在有效（非纯空白）姓名时 Confirm 可用。
    var canConfirm: Bool {
        !trimmedName.isEmpty
    }

    // MARK: 动作

    /// 更新输入文本（由 View 的 TextField 绑定驱动）。
    func updateName(_ value: String) {
        pickupName = value
    }

    /// 提交当前姓名。纯空白输入直接忽略，避免写入无意义值。
    func commit() {
        guard canConfirm else { return }
        onConfirm(trimmedName)
    }

    /// 取消编辑。
    func cancel() {
        onCancel()
    }
}
