//
//  FormToggleInputField.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

// MARK: - FormToggleInputField

/// 开关联动输入组件
///
/// Toggle 关闭时只显示标题和开关；打开时显示关联的输入框。
///
/// 用法示例：
/// ```swift
/// FormToggleInputField(
///     title: "Bank Surcharge %",
///     isOn: $surchargeEnabled,
///     text: $surchargeValue,
///     placeholder: "0.00",
///     keyboardType: .decimalPad
/// )
/// ```
struct FormToggleInputField: View {

    // MARK: - Public Properties

    let title: String
    @Binding var isOn: Bool
    @Binding var text: String
    var placeholder: String = ""
    var isRequired: Bool = false
    var helpText: String? = nil
    var isDisabled: Bool = false
    /// 控件高度（pt）。不传 → 设备感知默认(48/64)并自动缩放；传值 → 绝对高度，绕过缩放。
    var inputHeight: CGFloat? = nil
    var inputCornerRadius: CGFloat = 8
    var keyboardType: UIKeyboardType = .default
    var onInputTapped: (() -> Void)? = nil

    // MARK: - Environment

    /// 控件高度缩放因子（大屏 iPad=1.0，其它=0.85；由根视图 `.provideControlHeightScale()` 注入）
    @Environment(\.controlHeightScale) private var controlHeightScale
    /// 设备布局（由根视图 `.provideDeviceLayout()` 注入；默认 iPad 横屏）
    @Environment(\.deviceLayout) private var deviceLayout

    /// 实际渲染高度：
    /// - `inputHeight` 传值 → 视为绝对高度，原样使用（逃生舱，绕过缩放）
    /// - `inputHeight` 为 nil → 设备感知默认（iPhone 48 / iPad 64）经 `AppControl.height` 自动缩放（含 44pt 兜底）
    private var resolvedHeight: CGFloat {
        if let inputHeight { return inputHeight }
        let designPx: CGFloat = 64
        return AppControl.height(designPx, scale: controlHeightScale)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            titleLabel
            toggleRow
            bottomText
        }
    }

    // MARK: - Title Label

    private var titleLabel: some View {
        HStack(spacing: 0) {
            if isRequired {
                Text("*")
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.errorNormal)
            }
            Text(title)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.inputTitle)
        }
    }

    // MARK: - Toggle Row

    private var toggleRow: some View {
        HStack(spacing: Spacing.md) {
            toggleSwitch
            if isOn {
                associatedInput
            }
        }
        .frame(minHeight: resolvedHeight)
    }

    // MARK: - Toggle Switch

    private var toggleSwitch: some View {
        Button {
            if isDisabled == false {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? AppColors.toggleOnBg : AppColors.toggleOffBg)
                    .frame(width: 76, height: 36)

                Circle()
                    .fill(AppColors.toggleNob)
                    .frame(width: 26, height: 26)
                    .shadow(color: AppColors.black20, radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 5)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }

    // MARK: - Associated Input

    private var associatedInput: some View {
        Group {
            if let onTapped = onInputTapped {
                inputDisplay
                    .contentShape(Rectangle())
                    .onTapGesture { onTapped() }
            } else {
                TextField(placeholder, text: $text)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputText)
                    .disabled(isDisabled)
                    .keyboardType(keyboardType)
                    .padding(.horizontal, Spacing.md)
                    .frame(maxWidth: .infinity)
                    .frame(height: resolvedHeight)
                    .background(isDisabled ? AppColors.inputDisabledBg : AppColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
            }
        }
    }

    private var inputDisplay: some View {
        HStack {
            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
            } else {
                Text(text)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputText)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: resolvedHeight)
        .background(isDisabled ? AppColors.inputDisabledBg : AppColors.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: inputCornerRadius))
    }

    // MARK: - Bottom Text

    @ViewBuilder
    private var bottomText: some View {
        if let help = helpText {
            Text(help)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.inputPlaceholder)
        }
    }
}

// MARK: - Preview

#Preview("FormToggleInputField") {
    VStack(spacing: Spacing.xl) {
        FormToggleInputField(
            title: "Bank Surcharge %",
            isOn: .constant(false),
            text: .constant(""),
            placeholder: "0.00"
        )

        FormToggleInputField(
            title: "Bank Surcharge %",
            isOn: .constant(true),
            text: .constant("2.00"),
            placeholder: "0.00",
            keyboardType: .decimalPad
        )

        FormToggleInputField(
            title: "Bank Surcharge %",
            isOn: .constant(true),
            text: .constant("2.00"),
            placeholder: "0.00",
            isRequired: true,
            helpText: "Please input passenger's name or delete this field."
        )
    }
    .padding(Spacing.lg)
    .background(AppColors.pageBg)
}
