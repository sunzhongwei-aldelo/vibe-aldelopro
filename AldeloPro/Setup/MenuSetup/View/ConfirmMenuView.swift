//
//  ConfirmMenuView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/10.
//

import SwiftUI

struct ConfirmMenuView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Properties
    let menuGroups: [SetupMenuGroup]
    let menuItems: [SetupMenuItem]
    var onBack: (() -> Void)?
    var onConfirm: (() -> Void)?
    var onEditItem: ((SetupMenuItem) -> Void)?
    var onDeleteItem: ((SetupMenuItem) -> Void)?

    // MARK: - Adaptive Sizing
    private var isCompact: Bool { horizontalSizeClass == .compact }
    private var titleFont: Font { isCompact ? AppFont.mobileH1Medium : AppFont.tabletH1Medium }
    private var nameFont: Font { isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium }
    private var priceFont: Font { isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody3Regular }
    private var containerHPadding: CGFloat { isCompact ? Spacing.md : 100 }
    private var actionButtonHeight: CGFloat { isCompact ? 56 : 64 }

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.mask
                .ignoresSafeArea()
                .onTapGesture {}

            containerView
        }
    }

    // MARK: - Container
    private var containerView: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    ForEach(menuGroups) { group in
                        groupSection(group: group)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
            }

            bottomBar
        }
        .background(AppColors.card)
        .cornerRadius(Spacing.md)
        .padding(.vertical,Spacing.lg)
        .padding(.horizontal, containerHPadding)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Confirm Menu")
                    .font(titleFont)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }

    // MARK: - Group Section
    private func groupSection(group: SetupMenuGroup) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(group.name)
                .font(nameFont)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, Spacing.xs)

            let items = menuItems.filter { $0.groupId == group.id }
            ForEach(items) { item in
                itemRow(item: item)
            }
        }
    }

    // MARK: - Item Row
    private func itemRow(item: SetupMenuItem) -> some View {
        HStack(spacing: Spacing.md) {
            itemThumbnail(item: item)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(item.name)
                    .font(nameFont)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text("$ \(formattedPrice(item.unitPrice))")
                    .font(priceFont)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.md) {
                Button {
                    onEditItem?(item)
                } label: {
                    Image(.frame2)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    onDeleteItem?(item)
                } label: {
                    Image(.frame3)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.md)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    // MARK: - Item Thumbnail
    private func itemThumbnail(item: SetupMenuItem) -> some View {
        Group {
            if let firstImageData = item.imageData.first,
               let uiImage = UIImage(data: firstImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.pageBgDeep)
                    .overlay {
                        Image(systemName: "photo")
                            .font(AppFont.tabletH3Medium)
                            .foregroundColor(AppColors.textTertiary)
                    }
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack(spacing: Spacing.md) {
            Button {
                onBack?()
            } label: {
                Text("Back")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: actionButtonHeight)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)

            Button {
                onConfirm?()
            } label: {
                Text("Confirm")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: actionButtonHeight)
                    .background(AppColors.buttonPrimaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Helpers
    private func formattedPrice(_ price: Decimal) -> String {
        let nsDecimal = price as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: nsDecimal) ?? "0.00"
    }
}

// MARK: - Preview

#Preview {
    let group1 = SetupMenuGroup(name: "Burgers & Sandwiches")
    let group2 = SetupMenuGroup(name: "Breakfast")

    let sampleItems: [SetupMenuItem] = [
        SetupMenuItem(name: "Big Mac", groupId: group1.id, unitPrice: 2.99),
        SetupMenuItem(name: "Quarter Pounder", groupId: group1.id, unitPrice: 2.49),
        SetupMenuItem(name: "Double Cheese Burger", groupId: group1.id, unitPrice: 1.99),
        SetupMenuItem(name: "Ham & Egg Sandwich", groupId: group2.id, unitPrice: 19.99),
        SetupMenuItem(name: "Smoked Salmon Bagel", groupId: group2.id, unitPrice: 5.50)
    ]

    ConfirmMenuView(
        menuGroups: [group1, group2],
        menuItems: sampleItems
    )
}


/// 设计稿示例菜单数据（前端 mock，无真实 AI 后端）。
/// 模拟"扫描/上传 → AI 识别"得到的菜单，供 ConfirmMenuView 展示与确认。
enum SampleMenuData {
    static func makeMenuSample() -> (groups: [SetupMenuGroup], items: [SetupMenuItem]) {
        let burgers = SetupMenuGroup(name: "Burgers & Sandwiches", sortOrder: 0)
        let items = [
            SetupMenuItem(name: "Big Mac", groupId: burgers.id, unitPrice: Decimal(string: "2.99") ?? 0, sortOrder: 0),
            SetupMenuItem(name: "Quarter Pounder", groupId: burgers.id, unitPrice: Decimal(string: "2.49") ?? 0, sortOrder: 1),
            SetupMenuItem(name: "Double Cheese Burger", groupId: burgers.id, unitPrice: Decimal(string: "1.99") ?? 0, sortOrder: 2)
        ]
        return (groups: [burgers], items: items)
    }
}
