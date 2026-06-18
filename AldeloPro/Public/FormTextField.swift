//
//  FormTextField.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

// MARK: - FormTextField

/// 表单输入框公共控件
///
/// 支持 6 种状态：default / focus / inputting / completed / error / disabled
/// 状态根据 focus、text、errorMessage、isDisabled 自动推导，无需手动传入。
///
/// 键盘与校验：
/// - `keyboardType` / `autocapitalization` / `disableAutocorrection` 控制输入法行为
/// - `validate` 为失焦校验闭包：光标离开时执行，返回错误文案则显示；返回 nil 表示通过。
///   重新聚焦时自动清除该错误。外部传入的 `errorMessage` 优先级高于失焦校验结果。
///
/// 用法示例：
/// ```swift
/// FormTextField(
///     title: "Email",
///     text: $email,
///     keyboardType: .emailAddress,
///     autocapitalization: .never,
///     disableAutocorrection: true,
///     validate: FieldValidator.email
/// )
/// ```
struct FormTextField: View {

    // MARK: - Public Properties

    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isRequired: Bool = false
    var helpText: String? = nil
    var errorMessage: String? = nil
    var isDisabled: Bool = false
    /// 控件高度（pt）。不传 → 设备感知默认(48/64)并自动缩放；传值 → 绝对高度，绕过缩放。
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 8
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var disableAutocorrection: Bool = false
    /// 失焦校验闭包：返回错误文案则显示，返回 nil 表示通过
    var validate: ((String) -> String?)? = nil
    /// 可选：本字段在父级 `@FocusState` 中的标识值。配合 `externalFocus` 使用，
    /// 让父页面能感知聚焦的是哪个字段（用于键盘弹出时滚动到该字段）。不传则不影响行为。
    var fieldTag: Int? = nil
    /// 可选：父级 `@FocusState<Int?>` 的绑定。传入后本控件聚焦会写回该绑定。
    var externalFocus: FocusState<Int?>.Binding? = nil

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

    @FocusState private var isFocused: Bool
    /// 失焦校验产生的错误（与外部 errorMessage 区分；聚焦时清除）
    @State private var validationError: String? = nil

    // MARK: - Computed State

    /// 最终展示的错误：外部 errorMessage 优先，其次失焦校验结果
    private var displayedError: String? {
        errorMessage ?? validationError
    }

    private var fieldState: FieldState {
        if isDisabled { return .disabled }
        if displayedError != nil { return .error }
        if isFocused && text.isEmpty { return .focus }
        if isFocused && !text.isEmpty { return .inputting }
        if !isFocused && !text.isEmpty { return .completed }
        return .default
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            titleLabel
            inputField
            bottomText
        }
        .onChange(of: isFocused) { _, focused in
            if focused {
                // 重新聚焦：清除上一次失焦校验错误
                validationError = nil
            } else {
                // 失焦：执行校验
                validationError = validate?(text)
            }
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

    // MARK: - Text Field（按需挂接父级 focus 绑定）

    @ViewBuilder
    private var textField: some View {
        if let externalFocus, let fieldTag {
            TextField("", text: $text)
                .focused(externalFocus, equals: fieldTag)
        } else {
            TextField("", text: $text)
        }
    }

    // MARK: - Input Field

    private var inputField: some View {
        ZStack(alignment: .leading) {
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
                    .padding(.horizontal, Spacing.md)
            }

            // TextField
            textField
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.inputText)
                .focused($isFocused)
                .disabled(isDisabled)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(disableAutocorrection)
                .padding(.horizontal, Spacing.md)
        }
        .frame(height: resolvedHeight)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: hasBorder ? 1 : 0)
        )
    }

    // MARK: - Bottom Text (Help / Error)

    @ViewBuilder
    private var bottomText: some View {
        if fieldState == .error, let error = displayedError {
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
        case .focus, .inputting:
            return AppColors.inputFocusBorder
        case .error:
            return AppColors.inputErrorBorder
        default:
            return .clear
        }
    }

    private var hasBorder: Bool {
        switch fieldState {
        case .focus, .inputting, .error:
            return true
        default:
            return false
        }
    }
}

// MARK: - FieldState

private enum FieldState {
    case `default`
    case focus
    case inputting
    case completed
    case error
    case disabled
}

// MARK: - Preview

#Preview("Default") {
    VStack(spacing: Spacing.lg) {
        FormTextField(
            title: "First Name",
            text: .constant(""),
            placeholder: "Example"
        )

        FormTextField(
            title: "Email",
            text: .constant("bad-email"),
            placeholder: "Example",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            disableAutocorrection: true,
            validate: FieldValidator.email
        )

        FormTextField(
            title: "First Name",
            text: .constant("John"),
            placeholder: "Example",
            errorMessage: "This field is required."
        )

        FormTextField(
            title: "First Name",
            text: .constant("John"),
            placeholder: "Example",
            isDisabled: true
        )
    }
    .padding(Spacing.lg)
    .background(AppColors.pageBg)
}
