//
//  RepeatView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - RepeatView

/// Repeat 页面 — 标记订单项为"重复下单"
struct RepeatView: View {

    @State private var viewModel: OrderActionViewModel

    let onBack: () -> Void
    let onConfirm: ([OrderActionItem]) -> Void

    init(
        items: [OrderActionItem] = [],
        onBack: @escaping () -> Void,
        onConfirm: @escaping ([OrderActionItem]) -> Void
    ) {
        _viewModel = State(initialValue: OrderActionViewModel(items: items))
        self.onBack = onBack
        self.onConfirm = onConfirm
    }

    var body: some View {
        OrderActionGridView(
            actionType: .repeat,
            items: viewModel.items,
            selectedIDs: viewModel.selectedIDs,
            selectedCount: viewModel.selectedCount,
            editingItemID: nil,
            onTapItem: { viewModel.toggleSelection($0) },
            onQuantityTap: nil,
            onSelectAll: { viewModel.toggleSelectAll() },
            onConfirm: { onConfirm(viewModel.confirmedItems()) },
            onBack: onBack
        )
    }
}

// MARK: - Preview

#Preview("Repeat - iPad") {
    RepeatView(
        items: [
            OrderActionItem(id: "1", name: "Sushi Roll", itemDescription: "Salmon", quantity: 2, hasStatusDot: true),
            OrderActionItem(id: "2", name: "Miso Soup", quantity: 1),
            OrderActionItem(id: "3", name: "Edamame", quantity: 2),
        ],
        onBack: {},
        onConfirm: { _ in }
    )
}
