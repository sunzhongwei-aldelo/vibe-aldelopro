//
//  CreateOptionGroupView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/09.
//

import SwiftUI

struct CreateOptionGroupView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - Focus
    @FocusState private var focusedField: FocusedField?

    // MARK: - Constants
    private let maxPrice: Decimal = 9999.99

    // MARK: - Validation
    /// 表单是否可保存：必填项（Option Group Name + 至少一个非空 Option Item Name）都填了才允许 Save。
    /// 与 AddItemView 的 isFormValid 置灰逻辑一致。
    private var isFormValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty
            && optionItems.contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    // MARK: - State
    @State private var groupName: String
    @State private var optionItems: [OptionChoice]

    // MARK: - Props
    let itemName: String
    /// 父级菜单项是否处于编辑模式（决定面包屑根节点 Add Item / Edit Item）。
    let isEditingItem: Bool
    /// 编辑模式下传入的已有选项组；nil 表示新建。
    let editingGroup: OptionGroup?
    var onSave: ((OptionGroup) -> Void)?

    // MARK: - Init
    init(
        itemName: String,
        isEditingItem: Bool = false,
        editingGroup: OptionGroup? = nil,
        onSave: ((OptionGroup) -> Void)? = nil
    ) {
        self.itemName = itemName
        self.isEditingItem = isEditingItem
        self.editingGroup = editingGroup
        self.onSave = onSave
        if let group = editingGroup {
            _groupName = State(initialValue: group.name)
            _optionItems = State(initialValue: group.choices)
        } else {
            _groupName = State(initialValue: "")
            _optionItems = State(initialValue: [OptionChoice(name: "", sortOrder: 0)])
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        itemNameLabel
                        groupNameField
                        optionItemsList
                        addOptionItemButton
                    }
                    .padding(.horizontal, Spacing.xxxxxxxl)
                    .padding(.top, Spacing.lg)
                    // 固定底部余量：给系统键盘避让留出滚动空间（动态 keyboardHeight 会与系统避让叠加顶起顶栏，故用固定值）。
                    .padding(.bottom, 300)
                }
                .scrollDismissesKeyboard(.interactively)
                // 键盘弹出后把聚焦字段滚到键盘上方（仅改滚动位置，不顶顶栏）
                .keyboardFocusScroll(focused: focusedField, proxy: proxy)
            }
        }
        .background(AppColors.pageBg)
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Text(isEditingItem ? "Edit Item" : "Add Item")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textTertiary)
                Text("/")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textTertiary)
                Text(editingGroup != nil ? "Edit Option Group" : "Create Option Group")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Text("Back")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(height: 48)
            .padding(.horizontal, Spacing.lg)
            .background(AppColors.buttonSecondaryBg)
            .cornerRadius(AppRadius.Tablet.lg)

            Button(action: handleSave) {
                Text("Save")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
            }
            .frame(height: 48)
            .padding(.horizontal, Spacing.xl)
            .background(isFormValid ? AppColors.buttonPrimaryBg : AppColors.buttonDisabledBg)
            .cornerRadius(AppRadius.Tablet.lg)
            .disabled(!isFormValid)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 84)
        .background(AppColors.glass)
    }

    // MARK: - Item Name Label
    private var itemNameLabel: some View {
        Text(itemName)
            .font(AppFont.tabletBody2Regular)
            .foregroundColor(AppColors.textTertiary)
    }

    // MARK: - Group Name Field
    private var groupNameField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: 2) {
                Text("*")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.errorNormal)
                Text("Option Group Name")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
            TextField("Option Group Name", text: $groupName)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.inputBg)
                .cornerRadius(AppRadius.Tablet.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(focusedField == .groupName ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
                .focused($focusedField, equals: .groupName)
                .id(FocusedField.groupName)
        }
    }

    // MARK: - Option Items List
    private var optionItemsList: some View {
        VStack(spacing: Spacing.lg) {
            ForEach(Array(optionItems.enumerated()), id: \.element.id) { index, item in
                optionItemCard(index: index, item: item)
            }
        }
    }

    // MARK: - Option Item Card
    private func optionItemCard(index: Int, item: OptionChoice) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                TextField("Option Item \(index + 1) Name", text: optionItemNameBinding(index: index))
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(height: 48)
                    .padding(.horizontal, Spacing.md)
                    .background(AppColors.inputBg)
                    .cornerRadius(AppRadius.Tablet.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .stroke(focusedField == .optionItemName(index) ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                    )
                    .focused($focusedField, equals: .optionItemName(index))
                    .id(FocusedField.optionItemName(index))

                OptionPriceField(
                    placeholder: "\(CurrencyFormatter.currencySymbol) 0.00",
                    fieldTag: .optionItemPrice(index),
                    maxValue: maxPrice,
                    initialValue: optionItems[index].price,
                    showsZero: false,
                    focus: $focusedField,
                    onValueChange: { optionItems[index].price = $0 ?? 0 }
                )
                .frame(width: 180, height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.inputBg)
                .cornerRadius(AppRadius.Tablet.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(focusedField == .optionItemPrice(index) ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )

                Button(action: { deleteOptionItem(at: index) }) {
                    Image(.frame3)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(width: 48, height: 48)
                .background(AppColors.card)
                .cornerRadius(AppRadius.Tablet.sm)
            }

            HStack {
                Text("Actions")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Toggle("", isOn: optionItemActionsBinding(index: index))
                    .labelsHidden()
                    .tint(AppColors.primaryNormal)
            }

            if item.actionsEnabled {
                actionModifiersGrid(index: index)
            }
        }
        .padding(Spacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    // MARK: - Action Modifiers Grid
    private func actionModifiersGrid(index: Int) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md)
        ]
        return LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(Array(optionItems[index].actionModifiers.enumerated()), id: \.element.id) { modIndex, modifier in
                actionModifierCell(itemIndex: index, modIndex: modIndex, modifier: modifier)
            }
        }
    }

    private func actionModifierCell(itemIndex: Int, modIndex: Int, modifier: ActionModifier) -> some View {
        HStack(spacing: 0) {
            Text(modifier.name)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)

            OptionPriceField(
                placeholder: "Extra Price",
                fieldTag: .modifierPrice(itemIndex, modIndex),
                maxValue: maxPrice,
                initialValue: optionItems[itemIndex].actionModifiers[modIndex].extraPrice,
                showsZero: true,
                focus: $focusedField,
                onValueChange: { optionItems[itemIndex].actionModifiers[modIndex].extraPrice = $0 }
            )
            .frame(width: 140, height: 48)
            .padding(.horizontal, Spacing.xs)
            .background(AppColors.buttonSecondaryBg)
            .cornerRadius(AppRadius.Tablet.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(focusedField == .modifierPrice(itemIndex, modIndex) ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
            )
        }
        .frame(height: 72)
        .padding(.horizontal, Spacing.md)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
    }

    // MARK: - Add Option Item Button
    private var addOptionItemButton: some View {
        Button(action: addOptionItem) {
            HStack(spacing: Spacing.xs) {
                Image(.addMenuBlue)
                    .foregroundColor(AppColors.primaryNormal)
                Text("Add Option Item")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.primaryNormal)
            }
            .frame(height: 41)
            .padding(.horizontal, Spacing.md)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.primaryNormal, lineWidth: 1)
            )
        }
    }

    // MARK: - Bindings
    private func optionItemNameBinding(index: Int) -> Binding<String> {
        Binding<String>(
            get: { optionItems[index].name },
            set: { optionItems[index].name = $0 }
        )
    }

    private func optionItemActionsBinding(index: Int) -> Binding<Bool> {
        Binding<Bool>(
            get: { optionItems[index].actionsEnabled },
            set: { optionItems[index].actionsEnabled = $0 }
        )
    }

    // MARK: - Actions
    private func addOptionItem() {
        let newItem = OptionChoice(
            name: "",
            sortOrder: optionItems.count
        )
        optionItems.append(newItem)
    }

    private func deleteOptionItem(at index: Int) {
        guard optionItems.count > 1 else { return }
        optionItems.remove(at: index)
    }

    private func handleSave() {
        guard !groupName.isEmpty else { return }
        // 如实保存全部 action（含填 0 与留空）；是否上架由展示侧依据 extraPrice 是否为 nil 决定。
        let validItems = optionItems.filter { !$0.name.isEmpty }
        guard !validItems.isEmpty else { return }
        // 编辑模式复用原 id，保证回写时按 id 替换原组而非新增。
        let group = OptionGroup(
            id: editingGroup?.id ?? UUID(),
            name: groupName,
            choices: validItems,
            sortOrder: editingGroup?.sortOrder ?? 0
        )
        onSave?(group)
        dismiss()
    }
}

// MARK: - FocusedField

/// CreateOptionGroupView 的焦点字段标识（顶层类型，供 OptionPriceField 子控件共享）。
enum FocusedField: Hashable {
    case groupName
    case optionItemName(Int)
    case optionItemPrice(Int)
    case modifierPrice(Int, Int)
}

// MARK: - Preview

#Preview {
    CreateOptionGroupView(itemName: "Cheese Burger")
}
