//
//  OrderActionGridView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - OrderActionGridView

/// 订单操作网格页面 — DoNotMake / Fire / Remake / Repeat 共用的全屏页面模板
///
/// 页面结构（从上到下）：
/// 1. HeaderBar:
///    - 左侧: 图标 + 标题（如 "Do Not Make"）
///    - 中间: AI 语音搜索栏（占位）
///    - 右侧: Back + All + Confirm（带已选数量徽章）
/// 2. 响应式网格（LazyVGrid）:
///    - iPad 横屏: 4 列
///    - iPad 竖屏: 3 列
///    - iPhone 竖屏: 2 列
///    - iPhone 横屏: 4 列
struct OrderActionGridView: View {

    // MARK: - 配置参数

    let actionType: OrderActionType
    let items: [OrderActionItem]
    let selectedIDs: Set<String>
    let selectedCount: Int
    let editingItemID: String?
    let onTapItem: (String) -> Void
    let onQuantityTap: ((String) -> Void)?
    let onSelectAll: () -> Void
    let onConfirm: () -> Void
    let onBack: () -> Void
    /// 报告卡片 frame（用于 DoNotMake 键盘定位）
    var cardFrameReporter: ((String, CGRect) -> Void)?

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let columns = columnCount(isLandscape: isLandscape)

            VStack(spacing: 0) {
                headerSection(containerWidth: geometry.size.width)
                gridContent(columns: columns)
            }
            .background(AppColors.pageBg)
        }
    }

    // MARK: - 顶部导航栏

    private func headerSection(containerWidth: CGFloat) -> some View {
        // 迁移至通用 AldeloModalHeaderView（C 族 + AI 中心搜索条）：
        // 图标+标题 LEFT，AI 条 CENTER，Back / All / Confirm(带已选数量角标) RIGHT。
        AldeloModalHeaderView(
            leadingIcon: actionType.headerIcon,
            title: actionType.pageTitle,
            actions: [
                .back(onBack),
                AldeloHeaderAction(title: "All", style: .secondary, action: onSelectAll),
                .primary("Confirm", badge: selectedCount > 0 ? selectedCount : nil, action: onConfirm)
            ],
            aiState: .idle
        )
    }

    // MARK: - 网格内容

    private func gridContent(columns: Int) -> some View {
        let spacing: CGFloat = isCompact ? Spacing.sm : Spacing.md

        return ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
                spacing: spacing
            ) {
                ForEach(items) { item in
                    OrderActionItemCard(
                        item: item,
                        isSelected: selectedIDs.contains(item.id),
                        isEditing: editingItemID == item.id,
                        isCompact: isCompact,
                        onTap: { onTapItem(item.id) },
                        onTapQuantity: onQuantityTap != nil
                            ? { onQuantityTap?(item.id) }
                            : nil
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: CardFramePreferenceKey.self,
                                    value: [item.id: geo.frame(in: .named("doNotMakeRoot"))]
                                )
                        }
                    )
                }
            }
            .padding(.horizontal, isCompact ? Spacing.md : Spacing.lg)
            .padding(.top, isCompact ? Spacing.md : Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .onPreferenceChange(CardFramePreferenceKey.self) { frames in
            if let reporter = cardFrameReporter {
                for (id, frame) in frames {
                    reporter(id, frame)
                }
            }
        }
    }

    // MARK: - 列数计算

    private func columnCount(isLandscape: Bool) -> Int {
        if isCompact {
            return isLandscape ? 4 : 2
        } else {
            return isLandscape ? 4 : 3
        }
    }
}

// MARK: - CardFramePreferenceKey

struct CardFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Preview

#Preview("iPad") {
    OrderActionGridView(
        actionType: .doNotMake,
        items: [
            OrderActionItem(id: "1", name: "Orange Juice", itemDescription: "Small Cup", quantity: 5, hasStatusDot: true),
            OrderActionItem(id: "2", name: "Mango Juice", itemDescription: "Small Cup", quantity: 1, hasStatusDot: true),
            OrderActionItem(id: "3", name: "Fish", itemDescription: "1.5 kg", quantity: 1),
            OrderActionItem(id: "4", name: "Wine", itemDescription: "Bottle", quantity: 1),
        ],
        selectedIDs: ["1", "2"],
        selectedCount: 2,
        editingItemID: "1",
        onTapItem: { _ in },
        onQuantityTap: { _ in },
        onSelectAll: {},
        onConfirm: {},
        onBack: {}
    )
}
