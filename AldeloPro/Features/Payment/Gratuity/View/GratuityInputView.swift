import SwiftUI

// MARK: - 小费输入视图


// MARK: - GratuityInputView

/// 小费金额输入页面
/// 支持百分比/固定金额两种模式切换，含快捷预设按钮和自定义输入
struct GratuityInputView: View {
    @StateObject private var viewModel: GratuityInputViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let onCancel: () -> Void
    let onRemove: () -> Void
    let onConfirm: (GratuityResult) -> Void

    init(
        purchaseAmount: Decimal,
        existingGratuity: Decimal? = nil,
        onCancel: @escaping () -> Void,
        onRemove: @escaping () -> Void,
        onConfirm: @escaping (GratuityResult) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: GratuityInputViewModel(
            purchaseAmount: purchaseAmount,
            existingGratuity: existingGratuity
        ))
        self.onCancel = onCancel
        self.onRemove = onRemove
        self.onConfirm = onConfirm
    }

    private var isTablet: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        if isTablet {
            tabletLayout
        } else {
            phoneLayout
        }
    }

    // MARK: - iPad Layout (Popup with semi-transparent mask)

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

                    numericKeypad
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

    // MARK: - iPhone Layout (Full screen, content top + numpad bottom)

    private var phoneLayout: some View {
        VStack(spacing: 0) {
            headerBar
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

            inputSection
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

            Spacer(minLength: 0)

            numericKeypad
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xs)

            bottomBar
        }
        .background(AppColors.pageBg.ignoresSafeArea())
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Text("Set Gratuity")
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

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            segmentedControl

            Text(viewModel.inputMode == .amount ? "Tip Amount" : "Tip Percent")
                .font(isTablet ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                .foregroundColor(AppColors.textPrimary)

            inputDisplay

            presetButtons

            if viewModel.inputMode == .percentage {
                percentageBreakdown
            }
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(GratuityInputMode.allCases, id: \.self) { mode in
                Button(action: { viewModel.switchMode(mode) }) {
                    Text(mode.rawValue)
                        .font(isTablet ? AppFont.tabletH3Medium : AppFont.mobileButton2Medium)
                        .foregroundColor(
                            viewModel.inputMode == mode
                                ? AppColors.primaryNormal
                                : AppColors.black60
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: isTablet ? 56 : 44)
                        .background(
                            viewModel.inputMode == mode
                                ? AppColors.white100
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
                }
            }
        }
        .padding(Spacing.xxs)
        .background(AppColors.segmentBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .frame(width: isTablet ? 403 : nil)
    }

    // MARK: - Input Display

    private var inputDisplay: some View {
        HStack(spacing: 0) {
            Text(viewModel.displayText)
                .font(isTablet ? AppFont.tabletBody2Regular : AppFont.mobileH2Medium)
                .foregroundColor(AppColors.textPrimary)

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

    // MARK: - Preset Buttons

    private var presetButtons: some View {
        HStack(spacing: Spacing.xs) {
            if viewModel.inputMode == .amount {
                ForEach(viewModel.amountPresets, id: \.self) { amount in
                    presetPill(
                        title: "$\(NSDecimalNumber(decimal: amount).stringValue).00",
                        action: { viewModel.selectPresetAmount(amount) }
                    )
                }
            } else {
                ForEach(viewModel.percentagePresets, id: \.self) { pct in
                    presetPill(
                        title: "\(pct)%",
                        action: { viewModel.selectPresetPercentage(pct) }
                    )
                }
            }
        }
    }

    private func presetPill(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(isTablet ? AppFont.tabletH4Medium : AppFont.mobileButton3Medium)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, Spacing.md)
                .frame(height: isTablet ? 43 : 36)
                .background(AppColors.white100)
                .overlay(
                    Capsule()
                        .stroke(AppColors.line, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Percentage Breakdown

    private var percentageBreakdown: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text("Purchase: \(viewModel.formattedPurchase)")
                .font(isTablet ? AppFont.tabletBody5Regular : AppFont.mobileBody2Regular)
                .foregroundColor(AppColors.textSecondary)

            Text("Gratuity: \(viewModel.formattedGratuity)")
                .font(isTablet ? AppFont.tabletBody5Regular : AppFont.mobileBody2Regular)
                .foregroundColor(AppColors.textSecondary)

            Text("Total: \(viewModel.formattedTotal)")
                .font(isTablet ? AppFont.tabletBody3Regular : AppFont.mobileBody1Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: - Numeric Keypad

    private var numericKeypad: some View {
        let buttonWidth: CGFloat = isTablet ? 150 : 80
        let buttonHeight: CGFloat = isTablet ? 122 : 64
        let spacing: CGFloat = Spacing.lg

        return VStack(spacing: spacing) {
            ForEach(0..<3) { row in
                HStack(spacing: spacing) {
                    ForEach(1...3, id: \.self) { col in
                        let digit = String(row * 3 + col)
                        keypadDigitButton(digit, width: buttonWidth, height: buttonHeight)
                    }
                }
            }
            HStack(spacing: spacing) {
                keypadActionButton(icon: "delete.left", width: buttonWidth, height: buttonHeight) {
                    viewModel.deleteLastDigit()
                }
                keypadDigitButton("0", width: buttonWidth, height: buttonHeight)
                keypadActionButton(text: "Clear", width: buttonWidth, height: buttonHeight) {
                    viewModel.clearInput()
                }
            }
        }
    }

    private func keypadDigitButton(_ digit: String, width: CGFloat, height: CGFloat) -> some View {
        Button(action: { viewModel.appendDigit(digit) }) {
            Text(digit)
                .font(isTablet ? AppFont.tabletDisplay1Regular : AppFont.mobileDisplay1Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: width, height: height)
                .background(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1.4)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    private func keypadActionButton(
        icon: String? = nil,
        text: String? = nil,
        width: CGFloat,
        height: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AppFont.tabletH2Medium)
                } else if let text = text {
                    Text(text)
                        .font(isTablet ? AppFont.tabletDisplay4Semibold : AppFont.mobileDisplay1Medium)
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .frame(width: width, height: height)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            AppColors.line
                .frame(height: 1)

            HStack(spacing: Spacing.md) {
                // Cancel
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(isTablet ? AppFont.tabletH3Medium : AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: isTablet ? 64 : 48)
                        .background(AppColors.buttonTextBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                }

                // Remove
                Button(action: onRemove) {
                    Text("Remove")
                        .font(isTablet ? AppFont.tabletH3Medium : AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: isTablet ? 64 : 48)
                        .background(AppColors.buttonTextBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                }

                // Confirm
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
    GratuityInputView(
        purchaseAmount: 100.00,
        onCancel: {},
        onRemove: {},
        onConfirm: { _ in }
    )
}

#Preview("iPad - Percentage") {
    GratuityInputView(
        purchaseAmount: 100.00,
        onCancel: {},
        onRemove: {},
        onConfirm: { _ in }
    )
}

#Preview("iPhone") {
    GratuityInputView(
        purchaseAmount: 100.00,
        onCancel: {},
        onRemove: {},
        onConfirm: { _ in }
    )
}

