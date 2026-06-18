//
//  FormDateField.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

// MARK: - FormDateField

/// 日期输入框公共控件
///
/// 支持 6 种状态：default / focus / inputting / completed / error / disabled
/// 右侧显示日历图标，点击可触发日期选择。
///
/// 用法示例：
/// ```swift
/// FormDateField(
///     title: "Start Date",
///     date: $startDate,
///     placeholder: "MM/DD/YY",
///     isRequired: true,
///     helpText: "Select a start date"
/// )
/// ```
struct FormDateField: View {

    // MARK: - Public Properties

    let title: String
    @Binding var date: Date?
    var placeholder: String = "MM/DD/YY"
    var isRequired: Bool = false
    var helpText: String? = nil
    var errorMessage: String? = nil
    var isDisabled: Bool = false
    /// 控件高度（pt）。不传 → 设备感知默认(48/64)并自动缩放；传值 → 绝对高度，绕过缩放。
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 8
    var displayFormat: String = "MM/dd/yy"
    var isFocused: Bool = false
    var onInputTapped: (() -> Void)? = nil

    // MARK: - Environment

    /// 控件高度缩放因子（大屏 iPad=1.0，其它=0.85；由根视图 `.provideControlHeightScale()` 注入）
    @Environment(\.controlHeightScale) private var controlHeightScale
    /// 设备布局（由根视图 `.provideDeviceLayout()` 注入；默认 iPad 横屏）
    @Environment(\.deviceLayout) private var deviceLayout

    /// 实际渲染高度：
    /// - `height` 传值 → 视为绝对高度，原样使用（逃生舱，绕过缩放）
    /// - `height` 为 nil → 设备感知默认（iPhone 48 / iPad 64）经 `AppControl.height` 自动缩放（含 44pt 兜底）
    private var resolvedHeight: CGFloat {
        if let height { return height }
        let designPx: CGFloat = 64
        return AppControl.height(designPx, scale: controlHeightScale)
    }

    // MARK: - Private State

    @State private var showPicker: Bool = false
    @State private var pickerDate: Date = Date()

    // MARK: - Computed State

    private var fieldState: DateFieldState {
        if isDisabled { return .disabled }
        if errorMessage != nil { return .error }
        if showPicker || isFocused { return .focus }
        if date != nil { return .completed }
        return .default
    }

    private var displayText: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = displayFormat
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            titleLabel
            dateInput
            if showPicker && isDisabled == false {
                datePicker
            }
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

    // MARK: - Date Input

    private var dateInput: some View {
        HStack {
            if displayText.isEmpty {
                Text(placeholder)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
            } else {
                Text(displayText)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputText)
            }

            Spacer()

            calendarIcon
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: resolvedHeight)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: hasBorder ? 1 : 0)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isDisabled == false {
                if let onTapped = onInputTapped {
                    onTapped()
                } else {
                    showPicker.toggle()
                }
            }
        }
    }

    // MARK: - Calendar Icon

    private var calendarIcon: some View {
        Image(systemName: "calendar")
            .font(.system(size: 18))
            .foregroundColor(AppColors.inputPlaceholder)
    }

    // MARK: - Date Picker

    private var datePicker: some View {
        DatePicker(
            "",
            selection: $pickerDate,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .onChange(of: pickerDate) { _, newValue in
            date = newValue
        }
        .padding(Spacing.md)
        .background(AppColors.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: AppColors.black8, radius: 8, x: 0, y: 4)
    }

    // MARK: - Bottom Text

    @ViewBuilder
    private var bottomText: some View {
        if fieldState == .error, let error = errorMessage {
            Text(error)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.errorNormal)
        } else if let help = helpText {
            Text(help)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.inputPlaceholder)
        }
    }

    // MARK: - Style Helpers

    private var backgroundColor: Color {
        switch fieldState {
        case .disabled:
            return AppColors.inputDisabledBg
        default:
            return AppColors.inputBg
        }
    }

    private var borderColor: Color {
        switch fieldState {
        case .focus:
            return AppColors.inputFocusBorder
        case .error:
            return AppColors.inputErrorBorder
        default:
            return .clear
        }
    }

    private var hasBorder: Bool {
        switch fieldState {
        case .focus, .error:
            return true
        default:
            return false
        }
    }
}

// MARK: - DateFieldState

private enum DateFieldState {
    case `default`
    case focus
    case completed
    case error
    case disabled
}

// MARK: - Preview

#Preview("FormDateField") {
    VStack(spacing: Spacing.xl) {
        FormDateField(
            title: "Start Date",
            date: .constant(nil),
            placeholder: "MM/DD/YY"
        )

        FormDateField(
            title: "Start Date",
            date: .constant(Date()),
            placeholder: "MM/DD/YY",
            isRequired: true
        )

        FormDateField(
            title: "Start Date",
            date: .constant(nil),
            placeholder: "MM/DD/YY",
            errorMessage: "Date is required."
        )

        FormDateField(
            title: "Start Date",
            date: .constant(Date()),
            placeholder: "MM/DD/YY",
            isDisabled: true
        )

        FormDateField(
            title: "Start Date",
            date: .constant(nil),
            placeholder: "MM/DD/YY",
            helpText: "Select your preferred start date."
        )
    }
    .padding(Spacing.lg)
    .background(AppColors.pageBg)
}
