//
//  OrderActionItemCard.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - OrderActionItemCard

/// 订单操作项目卡片 — DoNotMake / Fire / Remake / Repeat 共用的网格项
///
/// 卡片布局（对照设计稿）：
/// - 第一行：蓝色状态圆点 + 菜品名称（+ 右侧状态标签 tags）
/// - 第二行（底部同行）：描述文本 LEFT + 数量胶囊 RIGHT
/// - 选中时：右上角蓝色对勾圆圈 + 3px 蓝色边框
///
/// 交互：
/// - 点击卡片整体 → onTap（选中/取消选中）
/// - 点击数量胶囊 → onTapQuantity（弹出键盘）
/// - 使用 onTapGesture + 独立 Button 避免嵌套 Button 问题
struct OrderActionItemCard: View {

    let item: OrderActionItem
    let isSelected: Bool
    let isEditing: Bool
    let isCompact: Bool
    let onTap: () -> Void
    let onTapQuantity: (() -> Void)?

    init(
        item: OrderActionItem,
        isSelected: Bool,
        isEditing: Bool = false,
        isCompact: Bool = false,
        onTap: @escaping () -> Void,
        onTapQuantity: (() -> Void)? = nil
    ) {
        self.item = item
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.isCompact = isCompact
        self.onTap = onTap
        self.onTapQuantity = onTapQuantity
    }

    // MARK: - Body

    var body: some View {
        cardContent
            .padding(.horizontal, isCompact ? Spacing.sm : Spacing.md)
            .padding(.vertical, isCompact ? Spacing.sm : Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: isCompact ? 96 : 116)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cardRadius)
                    .stroke(
                        isSelected ? AppColors.primaryNormal : Color.clear,
                        lineWidth: 3
                    )
            )
            .overlay(alignment: .topTrailing) {
                checkmarkOverlay
            }
            .onTapGesture { onTap() }
    }

    private var cardRadius: CGFloat {
        isCompact ? AppRadius.Mobile.sm : AppRadius.Tablet.sm
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部：名称 + 标签（标签右对齐）
            nameRow

            Spacer(minLength: 0)

            // 底部：描述 + 数量 + 可选附加描述（始终贴底）
            bottomSection
        }
        .overlay(alignment: .topLeading) {
            // 蓝色状态圆点 — 在名称左上角（overlay 避免推动文字）
            if item.hasStatusDot {
                Circle()
                    .fill(AppColors.primaryNormal)
                    .frame(width: 7, height: 7)
                    .overlay(Circle().stroke(AppColors.white100, lineWidth: 1))
                    .offset(x: -9, y: -4)
            }
        }
    }

    // MARK: - 名称行（名称 + 标签右对齐）

    private var nameRow: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Text(item.name)
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: Spacing.xs)

            // 状态标签（右对齐）
            ForEach(item.tags) { tag in
                statusTagView(tag)
            }
        }
    }

    // MARK: - 底部区域（描述 + 数量 + 附加描述）

    private var bottomSection: some View {
        HStack(alignment: .bottom) {
            // 左侧：描述 + 附加描述叠加
            VStack(alignment: .leading, spacing: 2) {
                if let desc = item.itemDescription, !desc.isEmpty {
                    Text(desc)
                        .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                if let sub = item.subDescription, !sub.isEmpty {
                    Text(sub)
                        .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.warningNormal)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 右下角：数量始终贴底对齐
            quantityPill
        }
    }

    // MARK: - 状态标签视图

    private func statusTagView(_ tag: ItemStatusTag) -> some View {
        Text(tag.text)
            .font(.system(size: isCompact ? 9 : 11, weight: .medium))
            .foregroundColor(tag.style == .filled ? AppColors.white100 : AppColors.textSecondary)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 2)
            .background(
                tag.style == .filled
                    ? AnyShapeStyle(AppColors.errorNormal)
                    : AnyShapeStyle(Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        tag.style == .outlined ? AppColors.line : Color.clear,
                        lineWidth: 1
                    )
            )
    }

    // MARK: - 右上角选中对勾

    @ViewBuilder
    private var checkmarkOverlay: some View {
        if isSelected {
            Circle()
                .fill(AppColors.primaryNormal)
                .frame(width: isCompact ? 18 : 22, height: isCompact ? 18 : 22)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: isCompact ? 9 : 11, weight: .bold))
                        .foregroundColor(AppColors.white100)
                )
                .offset(x: 4, y: -4)
        }
    }

    // MARK: - 数量胶囊

    @ViewBuilder
    private var quantityPill: some View {
        let pillTextColor: Color = isEditing ? AppColors.primaryNormal : AppColors.textPrimary
        let hasBorder = item.quantity > 1

        if let onTapQuantity = onTapQuantity {
            // 可编辑 — Button 包裹
            let pillBg: Color = (isEditing && hasBorder) ? AppColors.primaryNormal.opacity(0.08) : Color.clear
            let pillBorder: Color = isEditing ? AppColors.primaryNormal : AppColors.line

            Button {
                onTapQuantity()
            } label: {
                quantityText(color: hasBorder ? pillTextColor : AppColors.textSecondary)
                    .background(pillBg)
                    .clipShape(Capsule())
                    .overlay(
                        hasBorder
                            ? AnyShapeStyle(pillBorder)
                            : AnyShapeStyle(Color.clear),
                        in: Capsule().stroke(lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        } else if hasBorder {
            // 数量 > 1 不可编辑 — 有边框
            quantityText(color: pillTextColor)
                .background(Color.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(AppColors.line, lineWidth: 1)
                )
        } else {
            // 数量 = 1 且不可编辑 — 无边框，高度一致
            quantityText(color: AppColors.textSecondary)
        }
    }

    /// 数量文字 — 固定 padding 和高度，确保数字位置不随边框变化
    private func quantityText(color: Color) -> some View {
        Text("\u{00D7} \(item.quantity)")
            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody5Regular)
            .foregroundColor(color)
            .padding(.horizontal, isCompact ? Spacing.sm : Spacing.md)
            .frame(height: isCompact ? 28 : 35)
    }
}

// MARK: - Preview

#Preview("Unselected") {
    OrderActionItemCard(
        item: OrderActionItem(name: "Orange Juice", itemDescription: "Small Cup", quantity: 3, hasStatusDot: true),
        isSelected: false,
        onTap: {}
    )
    .frame(width: 309)
    .padding()
    .background(AppColors.pageBg)
}

#Preview("Selected with checkmark") {
    OrderActionItemCard(
        item: OrderActionItem(name: "Orange Juice", itemDescription: "Small Cup", quantity: 2, hasStatusDot: true),
        isSelected: true,
        onTap: {},
        onTapQuantity: {}
    )
    .frame(width: 309)
    .padding()
    .background(AppColors.pageBg)
}

#Preview("Editing quantity") {
    OrderActionItemCard(
        item: OrderActionItem(name: "Orange Juice", itemDescription: "Small Cup", quantity: 5, hasStatusDot: true),
        isSelected: true,
        isEditing: true,
        onTap: {},
        onTapQuantity: {}
    )
    .frame(width: 309)
    .padding()
    .background(AppColors.pageBg)
}

#Preview("With status tags") {
    VStack(spacing: Spacing.md) {
        OrderActionItemCard(
            item: OrderActionItem(
                name: "Wine",
                itemDescription: "Bottle",
                subDescription: "Lafite,Vintage 1992",
                quantity: 1,
                hasStatusDot: true,
                tags: [ItemStatusTag(text: "Hold 2:00 PM", style: .filled)]
            ),
            isSelected: true,
            onTap: {}
        )
        OrderActionItemCard(
            item: OrderActionItem(
                name: "Apple Juice",
                itemDescription: "Small Cup",
                quantity: 1,
                tags: [ItemStatusTag(text: "Do Not Make", style: .outlined)]
            ),
            isSelected: true,
            onTap: {}
        )
    }
    .frame(width: 309)
    .padding()
    .background(AppColors.pageBg)
}
