//
//  SwitchOrderTypeView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 订单类型六大渠道分流器

/// 页面 2：2x3 六宫格订单类型选择网格
/// 选中项有蓝色高亮边框 + 半透明蓝底
struct SwitchOrderTypeView: View {
    @Binding var selectedType: OrderType
    let isPad: Bool

    /// 2 列自适应网格
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: isPad ? Spacing.md : Spacing.sm) {
            ForEach(OrderType.allCases) { type in
                OrderTypeOptionCard(
                    orderType: type,
                    isSelected: selectedType == type,
                    isPad: isPad,
                    onTap: { selectedType = type }
                )
            }
        }
    }
}
