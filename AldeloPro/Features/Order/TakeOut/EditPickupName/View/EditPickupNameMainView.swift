//
//  EditPickupNameMainView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

/// 「修改自提人姓名」控制台的根入口（本特性中唯一以 `MainView` 结尾命名的视图）。
///
/// 自适应外壳（iPad / iPhone 同构居中卡片，仅尺寸 / 取宽方式不同）：
/// - iPad（Regular Width）：半透明黑遮罩 `AppColors.black40` + 正中央悬浮固定尺寸白卡（540×240），
///   内部用贪婪 `Spacer` 把动作栏顶到卡片底部。
/// - iPhone（Compact）：同样是 ZStack 居中悬浮白卡，绝不全屏 / 不压栈 / 不做底部抽屉；
///   高度按内容自适应（不用贪婪 Spacer，否则会被撑满全屏），宽度自适应但设上限 + 左右安全边距
///   （避免横屏铺满全宽）。
/// 两端均为静态 `VStack`，绝不包裹 `ScrollView`。
///
/// 弹窗出现瞬间输入框自动获取焦点，由系统从底部拉起原生全字母键盘。
struct EditPickupNameMainView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass
    @State private var viewModel: EditPickupNameViewModel
    @FocusState private var isInputFocused: Bool

    init(viewModel: EditPickupNameViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var isPad: Bool { hSizeClass == .regular }

    var body: some View {
        ZStack {
            // 全景调暗遮罩，点击空白即取消。
            AppColors.black40
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { viewModel.cancel() }

            if isPad {
                padCard
            } else {
                phoneCard
            }
        }
        // 出现即自动聚焦，触发系统键盘从底部滑出。
        .task {
            isInputFocused = true
        }
    }

    // MARK: - iPad：居中悬浮固定卡片

    private var padCard: some View {
        cardContent(fillsHeight: true)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.lg)
            .frame(width: 540, height: 240)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg, style: .continuous)
                    .fill(AppColors.card)
            )
    }

    // MARK: - iPhone：居中悬浮卡片（与 iPad 同构，仅边距 / 取宽方式不同）

    /// iPhone 卡片高度按内容自适应（不用贪婪 Spacer，避免竖屏被撑高），
    /// 宽度自适应但设上限并留出左右安全边距，避免横屏铺满全宽。
    /// 外层 ZStack 负责把它在屏幕正中对齐。
    private var phoneCard: some View {
        cardContent(fillsHeight: false)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .frame(maxWidth: 460)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Mobile.lg, style: .continuous)
                    .fill(AppColors.card)
            )
            .padding(.horizontal, Spacing.lg)
    }

    // MARK: - 卡片内部纵向线性流（iPad / iPhone 共用）

    /// - Parameter fillsHeight: iPad 卡片有固定高度，需要贪婪 Spacer 把动作栏推到底部；
    ///   iPhone 卡片高度按内容自适应，必须用固定间距（否则 Spacer 会把卡片撑满全屏）。
    private func cardContent(fillsHeight: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            PickupNameHeaderView(
                title: "Edit Pickup Name",
                onClose: { viewModel.cancel() }
            )

            PickupNameInputFieldView(
                text: viewModel.pickupName,
                placeholder: "Pickup Name",
                onChange: { viewModel.updateName($0) },
                focus: $isInputFocused
            )
            .onSubmit { viewModel.commit() }

            if fillsHeight {
                Spacer(minLength: 0)
            }

            actionBar
        }
    }

    // MARK: - 底部对等双胶囊动作栏

    private var actionBar: some View {
        HStack(spacing: Spacing.md) {
            actionButton(
                title: "Cancel",
                fill: AppColors.buttonSecondaryBg,
                textColor: AppColors.buttonSecondaryText,
                action: { viewModel.cancel() }
            )

            actionButton(
                title: "Confirm",
                fill: AppColors.theme,
                textColor: AppColors.buttonPrimaryText,
                action: { viewModel.commit() }
            )
            .opacity(viewModel.canConfirm ? 1 : 0.5)
            .disabled(!viewModel.canConfirm)
        }
    }

    private func actionButton(
        title: String,
        fill: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .lineSpacing(isPad ? AppLineHeight.tabletBody1Regular : AppLineHeight.mobileBody1Regular)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: isPad ? 54 : 50)
                .background(
                    RoundedRectangle(
                        cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md,
                        style: .continuous
                    )
                    .fill(fill)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("iPad 横屏 - 已聚焦") {
    EditPickupNameMainView(
        viewModel: EditPickupNameViewModel(initialName: "Sophie")
    )
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 横屏 - 空态 (Dark)") {
    EditPickupNameMainView(
        viewModel: EditPickupNameViewModel(initialName: "")
    )
    .environment(\.horizontalSizeClass, .regular)
    .environment(\.colorScheme, .dark)
}

#Preview("iPhone 竖屏 - 居中卡片") {
    EditPickupNameMainView(
        viewModel: EditPickupNameViewModel(initialName: "Sophie")
    )
    .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPhone 竖屏 - 空态") {
    EditPickupNameMainView(
        viewModel: EditPickupNameViewModel(initialName: "")
    )
    .environment(\.horizontalSizeClass, .compact)
}
