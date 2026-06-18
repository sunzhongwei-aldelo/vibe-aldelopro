//
//  FireView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - FireView

/// Fire 页面 — 标记订单项为"开始制作"（催菜/出菜）
///
/// 基于 OrderActionGridView 通用网格模板，传入 .fire 配置。
/// 选中项目表示需要立即开始制作，Confirm 按钮显示已选总数。
struct FireView: View {

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
            actionType: .fire,
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

#Preview("Fire - iPad") {
    FireView(
        items: [
            OrderActionItem(
                id: "1", name: "Wine", itemDescription: "Bottle",
                subDescription: "Lafite,Vintage 1992",
                quantity: 1, hasStatusDot: true,
                tags: [ItemStatusTag(text: "Hold 2:00 PM", style: .filled)]
            ),
            OrderActionItem(
                id: "2", name: "Apple Juice", itemDescription: "Small Cup",
                quantity: 1, hasStatusDot: true,
                tags: [ItemStatusTag(text: "Hold", style: .filled)]
            ),
            OrderActionItem(
                id: "3", name: "Apple Juice", itemDescription: "Small Cup",
                quantity: 1,
                tags: [ItemStatusTag(text: "Do Not Make", style: .outlined)]
            ),
        ],
        onBack: {},
        onConfirm: { _ in }
    )
}
