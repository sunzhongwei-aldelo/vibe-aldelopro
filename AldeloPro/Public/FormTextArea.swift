//
//  FormTextArea.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

// MARK: - FormTextArea

/// 多行文本输入框公共控件
///
/// 支持 6 种状态：default / focus / inputting / completed / error / disabled
/// 状态根据 focus、text、errorMessage、isDisabled 自动推导。
///
/// 用法示例：
/// ```swift
/// FormTextArea(
///     title: "Notes",
///     text: $notes,
///     placeholder: "Enter additional notes",
///     isRequired: true,
///     helpText: "Max 500 characters",
///     minHeight: 120
/// )
/// ```
struct FormTextArea: View {

    // MARK: - Public Properties

    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isRequired: Bool = false
    var helpText: String? = nil
    var errorMessage: String? = nil
    var isDisabled: Bool = false
    var minHeight: CGFloat = 120
    var cornerRadius: CGFloat = 8

    // MARK: - Private State

    @FocusState private var isFocused: Bool

    // MARK: - Computed State

    private var fieldState: TextAreaState {
        if isDisabled { return .disabled }
        if errorMessage != nil { return .error }
        if isFocused && text.isEmpty { return .focus }
        if isFocused && text.isEmpty == false { return .inputting }
        if isFocused == false && text.isEmpty == false { return .completed }
        return .default
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            titleLabel
            textEditor
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

    // MARK: - Text Editor

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
            }

            TextEditor(text: $text)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.inputText)
                .focused($isFocused)
                .disabled(isDisabled)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
        }
        .frame(minHeight: minHeight)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: hasBorder ? 1 : 0)
        )
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

// MARK: - TextAreaState

private enum TextAreaState {
    case `default`
    case focus
    case inputting
    case completed
    case error
    case disabled
}

// MARK: - Preview

#Preview("FormTextArea") {
    VStack(spacing: Spacing.lg) {
        FormTextArea(
            title: "Notes",
            text: .constant(""),
            placeholder: "Enter additional notes here..."
        )

        FormTextArea(
            title: "Description",
            text: .constant("This is a multi-line text that demonstrates the completed state of the textarea component."),
            placeholder: "Enter description",
            isRequired: true,
            helpText: "Max 500 characters"
        )

        FormTextArea(
            title: "Reason",
            text: .constant("Invalid input"),
            placeholder: "Enter reason",
            errorMessage: "This field cannot be empty."
        )

        FormTextArea(
            title: "Comments",
            text: .constant("Read-only content"),
            placeholder: "Enter comments",
            isDisabled: true
        )
    }
    .padding(Spacing.lg)
    .background(AppColors.pageBg)
}
