//
//  DoNotMakeView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - DoNotMakeView

/// DoNotMake 页面 — 标记 Transaction 项目为"不制作"
///
/// 基于 OrderActionGridView 通用网格模板，传入 .doNotMake 配置。
/// 支持选中/取消选中项目，选中后可点击数量胶囊弹出键盘编辑数量。
/// 数量规则：默认=最大值，不可超过最大值，减到0自动取消选中。
///
/// 键盘弹出策略：
/// - 键盘在选中卡片正下方弹出，与卡片左侧对齐
/// - 使用 coordinateSpace 追踪卡片位置
struct DoNotMakeView: View {

    // MARK: - ViewModel

    @State private var viewModel: DoNotMakeViewModel

    // MARK: - 键盘定位

    @State private var cardFrames: [String: CGRect] = [:]

    private var editingCardFrame: CGRect {
        guard let id = viewModel.editingQuantityItemID else { return .zero }
        return cardFrames[id] ?? .zero
    }

    // MARK: - 回调

    let onBack: () -> Void
    let onConfirm: ([OrderActionItem]) -> Void

    // MARK: - Init

    init(
        items: [OrderActionItem] = [],
        onBack: @escaping () -> Void,
        onConfirm: @escaping ([OrderActionItem]) -> Void
    ) {
        _viewModel = State(initialValue: DoNotMakeViewModel(items: items))
        self.onBack = onBack
        self.onConfirm = onConfirm
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topLeading) {
            OrderActionGridView(
                actionType: .doNotMake,
                items: viewModel.items,
                selectedIDs: viewModel.selectedIDs,
                selectedCount: viewModel.selectedCount,
                editingItemID: viewModel.editingQuantityItemID,
                onTapItem: { viewModel.toggleSelection($0) },
                onQuantityTap: { id in
                    viewModel.startEditQuantity(itemID: id)
                },
                onSelectAll: { viewModel.toggleSelectAll() },
                onConfirm: { onConfirm(viewModel.confirmedItems()) },
                onBack: onBack,
                cardFrameReporter: { id, frame in
                    cardFrames[id] = frame
                }
            )

            // 数字键盘覆盖层
            if viewModel.editingQuantityItemID != nil {
                keypadOverlay
            }
        }
        .coordinateSpace(name: "doNotMakeRoot")
    }

    // MARK: - NumpadView Binding

    private var editingQuantityBinding: Binding<Int> {
        Binding(
            get: { viewModel.editingQuantityValue },
            set: { viewModel.editingQuantityValue = $0 }
        )
    }

    // MARK: - 数字键盘覆盖层

    private var keypadOverlay: some View {
        ZStack(alignment: .topLeading) {
            // 透明点击拦截层 — 点击关闭键盘
            Color.black.opacity(0.001)
                .contentShape(Rectangle())
                .onTapGesture { viewModel.dismissKeypad() }

            // 键盘面板 — 定位在卡片正下方，左侧对齐
            NumpadView(
                quantity: editingQuantityBinding,
                style: .share,
                onCommit: { viewModel.keypadConfirm() },
                primaryButtonTitle: "Confirm",
                minValue: 1,
                maxValue: viewModel.editingMaxQuantity
            )
            .offset(
                x: editingCardFrame.minX,
                y: editingCardFrame.maxY + Spacing.sm
            )
        }
    }
}

// MARK: - Preview

#Preview("DoNotMake - iPad") {
    DoNotMakeView(
        items: [
            OrderActionItem(id: "1", name: "Orange Juice", itemDescription: "Small Cup", quantity: 5, allowQuantityEdit: true, hasStatusDot: true),
            OrderActionItem(id: "2", name: "Mango Juice", itemDescription: "Small Cup", quantity: 1, allowQuantityEdit: true, hasStatusDot: true),
            OrderActionItem(id: "3", name: "Fish", itemDescription: "1.5 kg", quantity: 2, allowQuantityEdit: true),
            OrderActionItem(id: "4", name: "Wine", itemDescription: "Bottle", quantity: 1, allowQuantityEdit: true),
        ],
        onBack: {},
        onConfirm: { _ in }
    )
}
