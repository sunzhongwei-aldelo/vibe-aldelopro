//
//  ItemAttributesSection.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import SwiftUI

/// 菜单项「属性标签」区块（最多 3 个、单个 ≤20 字符，内嵌输入框流式折行）。
/// 从 AddItemView 抽出的纯展示组件；焦点状态由父级注入。
struct ItemAttributesSection: View {
    @Binding var attributes: [String]
    @FocusState.Binding var focusedField: FocusedField?

    /// 内嵌输入框的当前文本（仅 UI 局部状态）。
    @State private var attributeInput: String = ""

    typealias FocusedField = AddItemView.FocusedField

    /// 每个菜单项最多 3 个标签。
    private let maxAttributeCount = 3
    /// 单个标签最多 20 个字符。
    private let maxAttributeLength = 20

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Item Attributes")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            // 标签直接显示在输入框内部：chips 与输入框在同一带边框容器里流式折行。
            TokenFlowLayout(spacing: Spacing.xs) {
                ForEach(attributes, id: \.self) { attr in
                    attributeChip(attr)
                }
                attributeTextField
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .frame(minHeight: 48)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(focusedField == .attribute ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if attributes.count < maxAttributeCount {
                    focusedField = .attribute
                }
            }
        }
        .id(FocusedField.attribute)
    }

    /// 内嵌输入框：标签满 3 个时禁用；无标签时显示完整 placeholder。
    private var attributeTextField: some View {
        TextField(
            attributes.isEmpty ? "Custom Attributes Associated with Item (e.g. Allergen or Special Ingredients)" : "",
            text: $attributeInput
        )
        .font(AppFont.tabletBody2Regular)
        .foregroundColor(AppColors.textPrimary)
        .frame(height: 32)
        .focused($focusedField, equals: .attribute)
        .submitLabel(.done)
        .disabled(attributes.count >= maxAttributeCount)
        .onChange(of: attributeInput) { _, newValue in
            handleAttributeInputChange(newValue)
        }
        .onSubmit {
            commitAttribute(attributeInput)
            attributeInput = ""
        }
    }

    /// 处理输入变化：回车/逗号（中英文）作为分隔符自动成标签，并限制单个标签长度。
    private func handleAttributeInputChange(_ newValue: String) {
        if newValue.contains(where: { $0 == "," || $0 == "，" || $0 == "\n" }) {
            let parts = newValue.split(whereSeparator: { $0 == "," || $0 == "，" || $0 == "\n" })
            for part in parts {
                commitAttribute(String(part))
            }
            attributeInput = ""
        } else if newValue.count > maxAttributeLength {
            attributeInput = String(newValue.prefix(maxAttributeLength))
        }
    }

    /// 提交一个标签：去空白、截断 20 字符、去重，受 3 个上限约束。
    private func commitAttribute(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, attributes.count < maxAttributeCount else { return }
        let clipped = String(trimmed.prefix(maxAttributeLength))
        guard !attributes.contains(clipped) else { return }
        attributes.append(clipped)
    }

    /// 移除指定标签。
    private func removeAttribute(_ attr: String) {
        attributes.removeAll { $0 == attr }
    }

    /// 单个标签：文本 + 删除按钮，置于输入框内部（圆角矩形描边药丸）。
    private func attributeChip(_ attr: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Text(attr)
                .font(AppFont.tabletBody4Regular)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            Button {
                removeAttribute(attr)
            } label: {
                Image(systemName: "xmark")
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.sm)
        .frame(height: 32)
        .background(AppColors.buttonSecondaryBg)
        .cornerRadius(AppRadius.Tablet.sm)
    }
}
