import SwiftUI

// MARK: - 餐桌视图底部操作栏
// 包含左侧 Orders/Hostess 快捷入口（带红点提示）和右侧订单类型按钮组

struct DiningTableBottomBar: View {
    // MARK: - Badge 状态
    var ordersHasBadge: Bool = true
    var hostessHasBadge: Bool = true

    // MARK: - 按钮回调
    var onOrdersTap: () -> Void = {}
    var onHostessTap: () -> Void = {}
    var onMoreTap: () -> Void = {}
    var onAttachTablesTap: () -> Void = {}
    var onBarTap: () -> Void = {}
    var onDeliveryTap: () -> Void = {}
    var onTakeOutTap: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.xs) {
            // MARK: 左侧快捷入口
            leftSection

            // MARK: 右侧按钮组
            rightSection
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Spacing.xxxxxxxl)
        .background(AppColors.white100)
    }

    // MARK: - 左侧: Orders + Hostess

    private var leftSection: some View {
        HStack(spacing: .zero) {
            badgeButton(title: "Orders", hasBadge: ordersHasBadge, action: onOrdersTap)

            Rectangle()
                .fill(AppColors.line)
                .frame(width: 1, height: 34)

            badgeButton(title: "Hostess", hasBadge: hostessHasBadge, action: onHostessTap)
        }
    }

    private func badgeButton(title: String, hasBadge: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Text(title)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)

                if hasBadge {
                    Circle()
                        .fill(AppColors.errorNormal)
                        .frame(width: Spacing.xs, height: Spacing.xs)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - 右侧: 操作按钮组

    private var rightSection: some View {
        HStack(spacing: Spacing.xs) {
            Spacer()

            AldeloButton(
                title: "More",
                style: .grayStroke,
                size: .large,
                icon: Image(systemName: "ellipsis.circle"),
                action: onMoreTap
            )
            .frame(width: 137)

            AldeloButton(
                title: "Attach Tables",
                style: .grayStroke,
                size: .large,
                icon: Image(systemName: "arrow.left.and.right.square"),
                action: onAttachTablesTap
            )
            .frame(width: 239)

            orderTypeButton(
                title: "Bar",
                iconColor: AppColors.orderTypeBar,
                iconName: "leaf.fill",
                action: onBarTap
            )
            .frame(width: 170)

            orderTypeButton(
                title: "Delivery",
                iconColor: AppColors.orderTypeDelivery,
                iconName: "bicycle",
                action: onDeliveryTap
            )
            .frame(width: 170)

            orderTypeButton(
                title: "Take Out",
                iconColor: AppColors.orderTypeTakeOut,
                iconName: "bag.fill",
                action: onTakeOutTap
            )
            .frame(width: 170)
        }
    }

    // MARK: - 订单类型按钮（带彩色图标方块）

    private func orderTypeButton(
        title: String,
        iconColor: Color,
        iconName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .fill(iconColor)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(AppColors.white100)
                    )

                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 63, maxHeight: 63)
            .background(AppColors.white100)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(AppColors.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }
}

// MARK: - Preview

#Preview("DiningTableBottomBar") {
    VStack {
        Spacer()
        DiningTableBottomBar()
    }
    .background(AppColors.pageBg)
}
