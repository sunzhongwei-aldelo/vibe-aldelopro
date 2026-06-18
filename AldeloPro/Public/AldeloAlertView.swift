import SwiftUI

// MARK: - Alert Mode

enum AldeloAlertMode {
    /// Mode 1: Simple confirmation with title + Cancel/Confirm buttons
    case confirm
    /// Mode 2: Error info with icon + subtitle (with highlighted value) + title, no action buttons
    case errorInfo
    /// Mode 3: Warning confirmation with warning icon + title + Confirm(destructive)/Cancel buttons
    case warningConfirm
}

// MARK: - Alert Configuration

struct AldeloAlertConfig {
    let mode: AldeloAlertMode
    let title: String
    var subtitle: String? = nil
    var highlightedValue: String? = nil
    var confirmTitle: String = "Confirm"
    var cancelTitle: String = "Cancel"
}

// MARK: - AldeloAlertView
/// ### AldeloAlertView
/// 一个高可定制化的全局弹窗组件，支持确认、警告确认、错误提示等多种交互模式。
///
/// #### 💡 使用场景与示例：
///
/// ```swift
/// // 模式 1：确认弹窗 (Confirm)
/// // 带有“确认”与“取消”双按钮，适用于轻量级操作确认。
/// uiManager.showAlert(
///     config: AldeloAlertConfig(mode: .confirm, title: "Tip Out $5.00 By Mike?"),
///     onConfirm: { print("confirmed") },
///     onCancel: { print("cancelled") }
/// )
///
/// // 模式 2：错误信息提示 (ErrorInfo)
/// // 无按钮或单确认按钮，支持副标题和高亮数值，适用于展示账目不足、系统报错等。
/// uiManager.showAlert(
///     config: AldeloAlertConfig(
///         mode: .errorInfo,
///         title: "Not Enough Cash for Safe Drop",
///         subtitle: "Cash Drawer Balance:",
///         highlightedValue: "$2.00"
///     )
/// )
///
/// // 模式 3：警告确认 (WarningConfirm)
/// // 通常带有强烈的视觉提示（如红色按钮），适用于清空数据、注销等敏感操作。
/// uiManager.showAlert(
///     config: AldeloAlertConfig(mode: .warningConfirm, title: "Clear All?"),
///     onConfirm: { print("cleared") }
/// )
///
struct AldeloAlertView: View {
    let config: AldeloAlertConfig
    var onConfirm: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.xl) {
            switch config.mode {
            case .confirm:
                confirmModeContent
            case .errorInfo:
                errorInfoModeContent
            case .warningConfirm:
                warningConfirmModeContent
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxxl)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }

    // MARK: - Mode 1: Confirm

    private var confirmModeContent: some View {
        VStack(spacing: Spacing.xl) {
            Text(config.title)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            buttonRow(
                leftButton: secondaryButton(title: config.cancelTitle, action: onCancel),
                rightButton: primaryButton(title: config.confirmTitle, action: onConfirm)
            )
        }
    }

    // MARK: - Mode 2: Error Info

    private var errorInfoModeContent: some View {
        VStack(spacing: Spacing.md) {
            errorIcon
                .padding(.bottom, Spacing.xs)

            if let subtitle = config.subtitle {
                HStack(spacing: Spacing.xxs) {
                    Text(subtitle)
                        .font(AppFont.tabletH2Medium)
                        .foregroundColor(AppColors.textSecondary)
                    if let value = config.highlightedValue {
                        Text(value)
                            .font(AppFont.tabletH2Medium)
                            .foregroundColor(AppColors.errorNormal)
                    }
                }
            }

            Text(config.title)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, Spacing.xs)
        }
        .onTapGesture {
            onConfirm?()
        }
    }

    // MARK: - Mode 3: Warning Confirm

    private var warningConfirmModeContent: some View {
        VStack(spacing: Spacing.xl) {
            HStack(spacing: Spacing.xs) {
                warningIcon
                Text(config.title)
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            buttonRow(
                leftButton: destructiveButton(title: config.confirmTitle, action: onConfirm),
                rightButton: secondaryButton(title: config.cancelTitle, action: onCancel)
            )
        }
    }

    // MARK: - Icons

    private var errorIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.errorNormal)
                .frame(width: 68, height: 68)
            VStack(spacing: Spacing.xxs) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.white100)
                    .frame(width: 5, height: 18)
                Circle()
                    .fill(AppColors.white100)
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var warningIcon: some View {
        Image(systemName: "exclamationmark.circle")
            .font(.system(size: 24))
            .foregroundColor(Color(hex: "#FAAD14"))
    }

    // MARK: - Buttons

    private func buttonRow(leftButton: some View, rightButton: some View) -> some View {
        HStack(spacing: Spacing.md) {
            leftButton
            rightButton
        }
    }

    private func primaryButton(title: String, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            Text(title)
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(AppColors.buttonPrimaryBg)
                .cornerRadius(AppRadius.Tablet.lg)
        }
    }

    private func secondaryButton(title: String, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            Text(title)
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(AppColors.pageBg)
                .cornerRadius(AppRadius.Tablet.lg)
        }
    }

    private func destructiveButton(title: String, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            Text(title)
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.white100)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(AppColors.errorNormal)
                .cornerRadius(AppRadius.Tablet.lg)
        }
    }
}

// MARK: - Convenience Modifiers

extension AldeloAlertView {
    /// Present as a modal overlay with dimmed background
    static func overlay(
        isPresented: Binding<Bool>,
        config: AldeloAlertConfig,
        onConfirm: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        ZStack {
            if isPresented.wrappedValue {
                AppColors.mask
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                        onCancel?()
                    }

                AldeloAlertView(
                    config: config,
                    onConfirm: {
                        isPresented.wrappedValue = false
                        onConfirm?()
                    },
                    onCancel: {
                        isPresented.wrappedValue = false
                        onCancel?()
                    }
                )
                .frame(width: 560)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented.wrappedValue)
    }
}

// MARK: - Preview

#Preview("Mode 1: Confirm") {
    AldeloAlertView(
        config: AldeloAlertConfig(
            mode: .confirm,
            title: "Tip Out $5.00 By Mike?"
        ),
        onConfirm: {},
        onCancel: {}
    )
    .frame(width: 560)
    .padding()
}

#Preview("Mode 2: Error Info") {
    AldeloAlertView(
        config: AldeloAlertConfig(
            mode: .errorInfo,
            title: "Not Enough Cash for Safe Drop",
            subtitle: "Cash Drawer Balance:",
            highlightedValue: "$2.00"
        )
    )
    .frame(width: 560)
    .padding()
}

#Preview("Mode 3: Warning Confirm") {
    AldeloAlertView(
        config: AldeloAlertConfig(
            mode: .warningConfirm,
            title: "Clear All?"
        ),
        onConfirm: {},
        onCancel: {}
    )
    .frame(width: 560)
    .padding()
}
