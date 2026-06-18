//
//  CustomerInfoInputView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/11.
//

import SwiftUI

/// "Customer"（顾客）分组，含 Phone Number + Name 两个字段。
/// 持有键盘焦点的字段会套上 1.5pt 品牌蓝外圈；闲置字段保持干净的输入框底色。
/// iPad 端两个字段左右并排；iPhone 端上下纵向层叠。
/// 焦点由父级持有并以 binding 传入，使根视图能据此驱动键盘避让滚动。
struct CustomerInfoInputView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let title: String
    let phoneText: String
    let nameText: String
    let onPhoneChange: (String) -> Void
    let onNameChange: (String) -> Void
    var focus: FocusState<CustomerField?>.Binding

    private var isPad: Bool { hSizeClass == .regular }
    private var fieldHeight: CGFloat { isPad ? 64 : 52 }
    private var corner: CGFloat { isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md }

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.md : Spacing.sm) {
            Text(title)
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .lineSpacing(isPad ? AppLineHeight.tabletH3Medium : AppLineHeight.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            if isPad {
                HStack(alignment: .top, spacing: Spacing.lg) {
                    phoneField
                    nameField
                }
            } else {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    phoneField
                    nameField
                }
            }
        }
    }

    // MARK: 字段 (Fields)

    /// 电话字段：数字键盘，文本由 ViewModel 实时格式化为北美格式后回显。
    private var phoneField: some View {
        field(
            label: "Phone Number",
            text: Binding(get: { phoneText }, set: onPhoneChange),
            placeholder: "(000) 000-0000",
            field: .phone,
            keyboard: .phonePad
        )
        .id(CustomerField.phone)
    }

    /// 姓名字段：默认键盘，首字母自动大写。
    private var nameField: some View {
        field(
            label: "Name",
            text: Binding(get: { nameText }, set: onNameChange),
            placeholder: "Customer Name",
            field: .name,
            keyboard: .default
        )
        .id(CustomerField.name)
    }

    /// 通用字段构造器：上方微型灰色标签 + 下方输入框，
    /// 激活态切换蓝色外圈与线宽。
    @ViewBuilder
    private func field(
        label: String,
        text: Binding<String>,
        placeholder: String,
        field: CustomerField,
        keyboard: UIKeyboardType
    ) -> some View {
        let isActive = focus.wrappedValue == field
        VStack(alignment: .leading, spacing: isPad ? Spacing.xs : Spacing.xxs) {
            Text(label)
                .font(isPad ? AppFont.tabletCaption1Regular : AppFont.mobileCaption1Regular)
                .lineSpacing(isPad ? AppLineHeight.tabletCaption1Regular : AppLineHeight.mobileCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)

            TextField(placeholder, text: text)
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .foregroundStyle(AppColors.textPrimary)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(field == .name ? .words : .never)
                .focused(focus, equals: field)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: fieldHeight)
                .padding(.horizontal, isPad ? Spacing.md : Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(AppColors.inputBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(
                            isActive ? AppColors.theme : AppColors.line,
                            lineWidth: isActive ? 1.5 : 1
                        )
                )
                .animation(.easeInOut(duration: 0.18), value: isActive)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

/// Preview 宿主：用本地 @FocusState 模拟父级焦点注入。
private struct CustomerInfoPreviewHost: View {
    @FocusState private var focus: CustomerField?
    let initial: CustomerField?
    let phone: String
    let name: String
    let isPad: Bool

    var body: some View {
        CustomerInfoInputView(
            title: "Customer",
            phoneText: phone,
            nameText: name,
            onPhoneChange: { _ in },
            onNameChange: { _ in },
            focus: $focus
        )
        .padding()
        .background(AppColors.pageBg)
        .environment(\.horizontalSizeClass, isPad ? .regular : .compact)
        .onAppear { focus = initial }
    }
}

#Preview("iPad - Phone Active") {
    CustomerInfoPreviewHost(initial: .phone, phone: "", name: "", isPad: true)
}

#Preview("iPad - Name Active") {
    CustomerInfoPreviewHost(initial: .name, phone: "(877) 639-8767", name: "ZYX", isPad: true)
}

#Preview("iPhone - Stacked") {
    CustomerInfoPreviewHost(initial: .phone, phone: "(877) 639-8767", name: "", isPad: false)
}
