//
//  AdjustTipView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - AdjustTipView

/// 调整小费弹窗页面（结算流程中使用）
///
/// iPad 显示为居中弹窗（带半透明遮罩），iPhone 全屏显示。
/// 左侧为输入区（模式切换 + 输入框 + 快捷预设 + 百分比明细），
/// 右侧为数字键盘。底部为 Cancel / Confirm 按钮。
///
/// 使用共享组件：PaymentNumericKeypad、TipInputModeToggle、TipPresetChips
struct AdjustTipView: View {

    // MARK: - ViewModel

    @State private var viewModel: AdjustTipViewModel

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - 回调

    /// 取消（关闭弹窗）
    let onCancel: () -> Void

    /// 确认提交小费
    let onConfirm: (AdjustTipResult) -> Void

    // MARK: - Init

    init(
        purchaseAmount: Decimal,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (AdjustTipResult) -> Void
    ) {
        _viewModel = State(initialValue: AdjustTipViewModel(purchaseAmount: purchaseAmount))
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }

    // MARK: - Body

    var body: some View {
        if isTablet {
            tabletLayout
        } else {
            phoneLayout
        }
    }

    // MARK: - iPad 布局（居中弹窗 + 遮罩）

    private var tabletLayout: some View {
        ZStack {
            AppColors.mask
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 0) {
                headerBar
                    .padding(.top, Spacing.lg)
                    .padding(.horizontal, Spacing.lg)

                HStack(alignment: .top, spacing: Spacing.lg) {
                    inputSection
                        .frame(maxWidth: .infinity, alignment: .leading)

                    PaymentNumericKeypad(
                        isTablet: true,
                        onDigit: { viewModel.appendDigit($0) },
                        onDelete: { viewModel.deleteLastDigit() },
                        onClear: { viewModel.clearInput() }
                    )
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                Spacer(minLength: 0)

                bottomBar
            }
            .frame(maxWidth: 1104, maxHeight: 797)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    // MARK: - iPhone 布局（全屏）

    private var phoneLayout: some View {
        VStack(spacing: 0) {
            headerBar
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

            inputSection
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

            Spacer(minLength: 0)

            PaymentNumericKeypad(
                isTablet: false,
                onDigit: { viewModel.appendDigit($0) },
                onDelete: { viewModel.deleteLastDigit() },
                onClear: { viewModel.clearInput() }
            )
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xs)

            bottomBar
        }
        .background(AppColors.pageBg.ignoresSafeArea())
    }

    // MARK: - 顶部标题栏

    private var headerBar: some View {
        HStack {
            Text("Adjust Tip")
                .font(isTablet ? AppFont.tabletH1Medium : AppFont.mobileH1Medium)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }

    // MARK: - 左侧输入区

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Amount / Percentage 切换
            TipInputModeToggle(
                modes: TipInputMode.allCases.map(\.rawValue),
                selectedMode: viewModel.inputMode.rawValue,
                isTablet: isTablet,
                onSelect: { mode in
                    if let m = TipInputMode(rawValue: mode) {
                        viewModel.switchMode(m)
                    }
                }
            )

            // 标签（Tip Amount / Tip Percent）
            Text(viewModel.inputMode == .amount ? "Tip Amount" : "Tip Percent")
                .font(isTablet ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                .foregroundColor(AppColors.textPrimary)

            // 输入显示框
            inputDisplay

            // 快捷预设
            presetChips

            // 百分比模式：显示金额明细
            if viewModel.inputMode == .percentage {
                tipBreakdown
            }
        }
    }

    // MARK: - 输入显示框（带闪烁光标）

    private var inputDisplay: some View {
        HStack(spacing: 0) {
            Text(viewModel.displayText)
                .font(isTablet ? AppFont.tabletBody2Regular : AppFont.mobileH2Medium)
                .foregroundColor(AppColors.textPrimary)

            // 模拟光标
            Rectangle()
                .fill(AppColors.primaryNormal)
                .frame(width: 2, height: isTablet ? 32 : 24)

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: isTablet ? 63 : 48)
        .background(AppColors.inputBg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.primaryNormal, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - 快捷预设

    private var presetChips: some View {
        Group {
            if viewModel.inputMode == .amount {
                TipPresetChips(
                    titles: viewModel.amountPresets.map { "$\(NSDecimalNumber(decimal: $0).stringValue).00" },
                    isTablet: isTablet,
                    onSelect: { title in
                        // 从 "$5.00" 解析出 5
                        let cleaned = title.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ".00", with: "")
                        if let val = Decimal(string: cleaned) {
                            viewModel.selectPresetAmount(val)
                        }
                    }
                )
            } else {
                TipPresetChips(
                    titles: viewModel.percentagePresets.map { "\($0)%" },
                    isTablet: isTablet,
                    onSelect: { title in
                        let cleaned = title.replacingOccurrences(of: "%", with: "")
                        if let pct = Int(cleaned) {
                            viewModel.selectPresetPercentage(pct)
                        }
                    }
                )
            }
        }
    }

    // MARK: - 百分比明细

    private var tipBreakdown: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("Purchase: \(viewModel.formattedPurchase)")
                .font(isTablet ? AppFont.tabletBody5Regular : AppFont.mobileBody2Regular)
                .foregroundColor(AppColors.textSecondary)

            Text("Tip: \(viewModel.formattedTip)")
                .font(isTablet ? AppFont.tabletBody5Regular : AppFont.mobileBody2Regular)
                .foregroundColor(AppColors.textSecondary)

            Text("Total: \(viewModel.formattedTotal)")
                .font(isTablet ? AppFont.tabletBody3Regular : AppFont.mobileBody1Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: - 底部按钮栏

    private var bottomBar: some View {
        VStack(spacing: 0) {
            AppColors.line.frame(height: 1)

            HStack(spacing: Spacing.md) {
                // Cancel 按钮
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(isTablet ? AppFont.tabletH3Medium : AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: isTablet ? 64 : 48)
                        .background(AppColors.buttonTextBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                }

                // Confirm 按钮
                Button(action: { onConfirm(viewModel.buildResult()) }) {
                    Text("Confirm")
                        .font(isTablet ? AppFont.tabletH3Medium : AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: isTablet ? 64 : 48)
                        .background(AppColors.buttonPrimaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview("iPad - Amount") {
    AdjustTipView(
        purchaseAmount: 100.00,
        onCancel: {},
        onConfirm: { _ in }
    )
}

#Preview("iPhone") {
    AdjustTipView(
        purchaseAmount: 100.00,
        onCancel: {},
        onConfirm: { _ in }
    )
}
