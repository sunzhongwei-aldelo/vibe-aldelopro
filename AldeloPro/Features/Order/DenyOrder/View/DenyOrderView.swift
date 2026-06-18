//
//  DenyOrderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - DenyOrderView

/// 拒单页面 — 用户选择或输入拒绝订单的原因
///
/// 基于 OrderReasonPageView 通用模板，传入 Deny 相关的文案配置。
/// ViewModel 管理状态逻辑（选中/输入/互斥），View 仅负责绑定。
struct DenyOrderView: View {

    // MARK: - ViewModel

    @State private var viewModel: DenyOrderViewModel

    // MARK: - 回调

    /// 点击 Back 返回上一页
    let onBack: () -> Void

    /// 点击 Confirm 提交原因（参数为最终原因文本）
    let onConfirm: (String) -> Void

    // MARK: - Init

    init(
        viewModel: DenyOrderViewModel = DenyOrderViewModel(),
        onBack: @escaping () -> Void,
        onConfirm: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onConfirm = onConfirm
    }

    // MARK: - Body

    var body: some View {
        OrderReasonPageView(
            pageTitle: "Deny Order",
            sectionTitle: "Deny Reason",
            placeholder: "Custom Deny Reason About This Order",
            presetReasons: viewModel.presetReasons,
            selectedReason: viewModel.selectedReason,
            displayedInputText: viewModel.displayedInputText,
            canConfirm: viewModel.canConfirm,
            onBack: onBack,
            onConfirm: { onConfirm(viewModel.effectiveReason) },
            onSelectReason: { viewModel.selectReason($0) },
            onUpdateCustomReason: { viewModel.updateCustomReason($0) }
        )
    }
}

// MARK: - Preview

#Preview("Empty State") {
    DenyOrderView(
        onBack: {},
        onConfirm: { _ in }
    )
}

#Preview("With Selection") {
    let vm = DenyOrderViewModel()
    DenyOrderView(
        viewModel: vm,
        onBack: {},
        onConfirm: { _ in }
    )
    .onAppear { vm.selectReason("Order Mistake") }
}
