//
//  MenuSetupMethodSelectionView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import SwiftUI

/// 菜单搭建「方式选择」界面（AI / Scan / Manually Add 三张卡片 + 标题 + 底部按钮）。
struct MenuSetupMethodSelectionView: View {
    let viewModel: MenuSetupViewModel
    let isCompact: Bool
    let isNarrow: Bool
    var onPreviousStep: (() -> Void)?
    var onSkipStep: (() -> Void)?
    /// 点击 Scan or Upload 卡片时回调父级做相机权限预检（其余方式仍走 viewModel.selectMethod）。
    var onScanOrUpload: (() -> Void)?

    var body: some View {
        if isCompact {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        compactTitleSection
                        compactCardsSection
                    }
                }
                compactBottomButtons
            }
        } else {
            VStack(spacing: 0) {
                regularTitleSection
                cardsSection(isNarrow: isNarrow)
                Spacer()
                regularBottomButtons
            }
        }
    }

    // MARK: - iPad 标题（空状态）
    private var regularTitleSection: some View {
        Text("Menu Builder")
            .font(AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.top, Spacing.xxxl)
            .padding(.bottom, Spacing.xxxxxxxl)
    }

    // MARK: - iPhone 标题（空状态）
    private var compactTitleSection: some View {
        Text("Menu Builder")
            .font(AppFont.mobileH1Medium)
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
    }


    // MARK: - 操作按钮
    private func actionButton(icon: String, title: String, compact: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(compact ? AppFont.mobileBody1Medium : AppFont.tabletH4Medium)
                if compact == false {
                    Text(title)
                        .font(AppFont.tabletH3Medium)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, compact ? Spacing.sm : Spacing.lg)
            .frame(height: 50)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.xs)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad 三张方式卡片
    private func cardsSection(isNarrow: Bool) -> some View {
        let layout = isNarrow
            ? AnyLayout(VStackLayout(spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))

        return layout {
            methodCard(method: .aiVoiceChat, icon: "AI Voice Chat", title: "AI Voice Chat", compact: false)
            methodCard(method: .scanOrUpload, icon: "Scan or Upload", title: "Scan or Upload", compact: false)
            methodCard(method: .manuallyAdd, icon: "Manually Add", title: "Manually Add", compact: false)
        }
    }

    // MARK: - iPhone 三张方式卡片（横向：图标左 + 文字右）
    private var compactCardsSection: some View {
        VStack(spacing: Spacing.sm) {
            compactMethodCard(method: .aiVoiceChat, icon: "AI Voice Chat", title: "AI Voice Chat")
            compactMethodCard(method: .scanOrUpload, icon: "Scan or Upload", title: "Scan or Upload")
            compactMethodCard(method: .manuallyAdd, icon: "Manually Add", title: "Manually Add")
        }
    }

    // MARK: - iPhone 单张方式卡片（横向布局）
    private func compactMethodCard(method: SetupMethod, icon: String, title: String) -> some View {
        Button {
            if method == .scanOrUpload {
                onScanOrUpload?()
            } else {
                viewModel.selectMethod(method)
            }
        } label: {
            HStack(spacing: Spacing.md) {
                Image(icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 32, alignment: .center)

                Text(title)
                    .font(AppFont.mobileH2Medium)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad 单张方式卡片（纵向布局）
    private func methodCard(method: SetupMethod, icon: String, title: String, compact: Bool) -> some View {
        Button {
            if method == .scanOrUpload {
                onScanOrUpload?()
            } else {
                viewModel.selectMethod(method)
            }
        } label: {
            VStack(spacing: Spacing.md) {
                Image(icon)
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.textPrimary)

                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad 底部按钮
    private var regularBottomButtons: some View {
        HStack(spacing: Spacing.md) {
            Button {
                onPreviousStep?()
            } label: {
                Text("Previous Step")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)

            Button {
                onSkipStep?()
            } label: {
                Text("Skip This Step")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - iPhone 底部按钮
    private var compactBottomButtons: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                onSkipStep?()
            } label: {
                Text("Skip This Step")
                    .font(AppFont.mobileButton2Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)

            Button {
                onPreviousStep?()
            } label: {
                Text("Previous Step")
                    .font(AppFont.mobileButton2Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, Spacing.md)
    }
}
