//
//  VoidOrderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - VoidOrderView

/// 撤单页面 — 用户选择或输入撤销订单的原因
///
/// 基于 OrderReasonPageView 通用模板，传入 Void 相关的文案配置。
/// 与 DenyOrderView 共享完全相同的 UI 结构，仅标题和占位文字不同。
struct VoidOrderView: View {

    // MARK: - ViewModel

    @State private var viewModel: VoidOrderViewModel

    // MARK: - 回调

    /// 点击 Back 返回上一页
    let onBack: () -> Void

    /// 点击 Confirm 提交原因（参数为最终原因文本）
    let onConfirm: (String) -> Void

    // MARK: - Init

    init(
        viewModel: VoidOrderViewModel = VoidOrderViewModel(),
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
            pageTitle: "Void Order",
            sectionTitle: "Void Reason",
            placeholder: "Custom Void Reason About This Order",
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
    VoidOrderView(
        onBack: {},
        onConfirm: { _ in }
    )
}

#Preview("With Selection") {
    let vm = VoidOrderViewModel()
    VoidOrderView(
        viewModel: vm,
        onBack: {},
        onConfirm: { _ in }
    )
    .onAppear { vm.selectReason("Order Mistake") }
}
