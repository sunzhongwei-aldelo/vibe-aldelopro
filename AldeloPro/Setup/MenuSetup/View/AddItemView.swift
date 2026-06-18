//
//  AddItemView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/08.
//

import SwiftUI

struct AddItemView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - Focus
    enum FocusedField: Hashable {
        case itemName, unitPrice, productionName, attribute
        case nutrition(String)
    }
    @FocusState private var focusedField: FocusedField?

    // MARK: - ViewModel
    @State private var viewModel: AddItemViewModel

    // MARK: - UI State（下拉/弹窗显隐 —— 属于 View 的本地 UI 状态，不入 VM）
    @State private var showMoreSettings: Bool = true
    @State private var showTaxClassDropdown: Bool = false
    @State private var showPrepTimeDropdown: Bool = false
    @State private var showGroupDropdown: Bool = false
    @State private var showCreateOptionGroup: Bool = false
    @State private var showSelectOptionGroup: Bool = false

    // MARK: - Init
    init(
        availableGroups: [SetupMenuGroup],
        initialGroupId: UUID? = nil,
        editingItem: SetupMenuItem? = nil,
        optionGroupPool: [OptionGroup] = [],
        onCreateOptionGroup: ((OptionGroup) -> Void)? = nil,
        onAdd: ((SetupMenuItem) -> Void)? = nil
    ) {
        _viewModel = State(initialValue: AddItemViewModel(
            availableGroups: availableGroups,
            initialGroupId: initialGroupId,
            editingItem: editingItem,
            optionGroupPool: optionGroupPool,
            onCreateOptionGroup: onCreateOptionGroup,
            onAdd: onAdd
        ))
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        nameAndGroupRow.zIndex(4)
                        unitPriceField
                        optionsSection
                        taxClassField.zIndex(3)
                        moreSettingsSection.zIndex(2)
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
        .fullScreenCover(isPresented: $showCreateOptionGroup) {
            CreateOptionGroupView(itemName: viewModel.itemName, isEditingItem: viewModel.isEditing, editingGroup: viewModel.editingOptionGroup) { savedGroup in
                viewModel.upsertOptionGroup(savedGroup)
            }
        }
        .fullScreenCover(isPresented: $showSelectOptionGroup) {
            SelectOptionGroupView(
                itemName: viewModel.itemName,
                allOptionGroups: viewModel.allOptionGroups,
                selectedGroupIds: Set(viewModel.optionGroups.map { $0.id }),
                isEditing: viewModel.isEditing
            ) { selectedGroups in
                viewModel.replaceOptionGroups(selectedGroups)
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if newValue != nil {
                showGroupDropdown = false
                showTaxClassDropdown = false
                showPrepTimeDropdown = false
            }
            // 单价失焦：补齐两位小数（"5" → "5.00"）
            if oldValue == .unitPrice && newValue != .unitPrice {
                viewModel.padUnitPrice()
            }
        }
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Text(viewModel.isEditing ? "Edit Item" : "Add Item")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(height: 48)
            .padding(.horizontal, Spacing.lg)
            .background(AppColors.buttonSecondaryBg)
            .cornerRadius(AppRadius.Tablet.lg)

            Button(action: handleAdd) {
                Text(viewModel.isEditing ? "Save" : "Add")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
            }
            .frame(height: 48)
            .padding(.horizontal, Spacing.xl)
            .background(viewModel.isFormValid ? AppColors.buttonPrimaryBg : AppColors.buttonDisabledBg)
            .cornerRadius(AppRadius.Tablet.lg)
            .disabled(!viewModel.isFormValid)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 84)
        .background(AppColors.glass)
    }

    // MARK: - Name & Group Row
    private var nameAndGroupRow: some View {
        HStack(spacing: Spacing.md) {
            inputField(
                label: "Item Name",
                placeholder: "Item Name",
                text: $viewModel.itemName,
                isRequired: true,
                field: .itemName
            )
            groupDropdownField
        }
    }

    // MARK: - Group Dropdown
    private var groupDropdownField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            requiredLabel("Group")
            Button(action: {
                showGroupDropdown.toggle()
                if showGroupDropdown {
                    showTaxClassDropdown = false
                    showPrepTimeDropdown = false
                    focusedField = nil
                }
            }) {
                HStack {
                    Text(viewModel.selectedGroupName)
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(viewModel.selectedGroupId == nil ? AppColors.inputPlaceholder : AppColors.textPrimary)
                    Spacer()
                    Image(systemName: showGroupDropdown ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.card)
                .cornerRadius(AppRadius.Tablet.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(showGroupDropdown ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
            }
            .overlay(alignment: .top) {
                if showGroupDropdown {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.availableGroups.enumerated()), id: \.element.id) { index, group in
                            Button(action: {
                                viewModel.selectedGroupId = group.id
                                showGroupDropdown = false
                            }) {
                                Text(group.name)
                                    .font(AppFont.tabletBody2Regular)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                            }
                            if index < viewModel.availableGroups.count - 1 {
                                Divider()
                                    .background(AppColors.line)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.sm)
                    .shadow(color: AppColors.black8, radius: 8, y: 4)
                    .offset(y: 52)
                }
            }
        }
    }

    // MARK: - Unit Price
    private var unitPriceField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            requiredLabel("Unit Price")
            HStack(spacing: Spacing.xs) {
                Text(CurrencyFormatter.currencySymbol)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
                TextField("", text: $viewModel.unitPrice)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .unitPrice)
                    .onChange(of: viewModel.unitPrice) { _, _ in
                        viewModel.sanitizeUnitPrice()
                    }
            }
            .frame(height: 48)
            .padding(.horizontal, Spacing.md)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(focusedField == .unitPrice ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
            )
        }
        .id(FocusedField.unitPrice)
    }

    // MARK: - Options Section
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Options")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)

            ForEach(Array(viewModel.optionGroups.enumerated()), id: \.element.id) { index, group in
                optionGroupCard(group: group, index: index)
            }

            HStack(spacing: Spacing.md) {
                // 只要共享池里有任何选项组数据（含其它 item 创建的），就显示 Select。
                if !viewModel.allOptionGroups.isEmpty {
                    actionButton(icon: "addMenuBlue", title: "Select Option Group") {
                        showSelectOptionGroup = true
                    }
                }
                actionButton(icon: "addMenuBlue", title: "Create Option Group") {
                    viewModel.editingOptionGroup = nil
                    showCreateOptionGroup = true
                }
            }
        }
    }

    private func optionGroupCard(group: OptionGroup, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(group.name)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(group.summary)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: {
                focusedField = nil
                viewModel.editingOptionGroup = group
                showCreateOptionGroup = true
            }) {
                Image(.frame2)
                    .foregroundColor(AppColors.textSecondary)
            }
            Button(action: {
                focusedField = nil
                viewModel.removeOptionGroup(at: index)
            }) {
                Image(.frame3)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(Spacing.md)
        .frame(height: 71)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            focusedField = nil
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primaryNormal)
                Text(title)
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

    // MARK: - Tax Class
    private var taxClassField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            requiredLabel("Tax Class")
            Button(action: {
                showTaxClassDropdown.toggle()
                if showTaxClassDropdown {
                    showGroupDropdown = false
                    showPrepTimeDropdown = false
                    focusedField = nil
                }
            }) {
                HStack {
                    Text(viewModel.selectedTaxClass.rawValue)
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: showTaxClassDropdown ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.card)
                .cornerRadius(AppRadius.Tablet.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(showTaxClassDropdown ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
            }
            .overlay(alignment: .top) {
                if showTaxClassDropdown {
                    VStack(spacing: 0) {
                        ForEach(Array(TaxClass.allCases.enumerated()), id: \.element) { index, taxClass in
                            Button(action: {
                                viewModel.selectedTaxClass = taxClass
                                showTaxClassDropdown = false
                            }) {
                                Text(taxClass.rawValue)
                                    .font(AppFont.tabletBody2Regular)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                            }
                            if index < TaxClass.allCases.count - 1 {
                                Divider()
                                    .background(AppColors.line)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.sm)
                    .shadow(color: AppColors.black8, radius: 8, y: 4)
                    .offset(y: 52)
                }
            }
        }
    }

    // MARK: - More Settings
    private var moreSettingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Button(action: {
                focusedField = nil
                showMoreSettings.toggle()
            }) {
                HStack(spacing: Spacing.xs) {
                    Text("More Settings")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Image(systemName: showMoreSettings ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textPrimary)
                }
            }

            if showMoreSettings {
                moreSettingsContent
            }
        }
    }

    private var moreSettingsContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            ItemImagesSection(
                imageDataList: $viewModel.imageDataList,
                coverImageIndex: $viewModel.coverImageIndex,
                focusedField: $focusedField
            )
            inputField(
                label: "Production Facing Name (e.g. Item Name for Kitchen)",
                placeholder: "E.G. Custom Name For Kitchen Printers Or KDS",
                text: $viewModel.productionFacingName,
                isRequired: false,
                field: .productionName
            )
            ItemAttributesSection(
                attributes: $viewModel.attributes,
                focusedField: $focusedField
            )
            prepTimeField.zIndex(1)
            ItemNutritionSection(
                nutrition: $viewModel.nutrition,
                focusedField: $focusedField
            )
        }
    }

    // MARK: - Estimated Prepare Time
    private var prepTimeField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Estimated Prepare Time")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            Button(action: {
                showPrepTimeDropdown.toggle()
                if showPrepTimeDropdown {
                    showGroupDropdown = false
                    showTaxClassDropdown = false
                    focusedField = nil
                }
            }) {
                HStack {
                    Text(viewModel.prepTimeText)
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(viewModel.estimatedPrepareTime == nil ? AppColors.inputPlaceholder : AppColors.textPrimary)
                    Spacer()
                    Image(systemName: showPrepTimeDropdown ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.card)
                .cornerRadius(AppRadius.Tablet.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(showPrepTimeDropdown ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
            }
            .overlay(alignment: .top) {
                if showPrepTimeDropdown {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.prepTimeOptions.enumerated()), id: \.element) { index, mins in
                            Button(action: {
                                viewModel.estimatedPrepareTime = mins
                                showPrepTimeDropdown = false
                            }) {
                                Text("\(mins) Mins")
                                    .font(AppFont.tabletBody2Regular)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                            }
                            if index < viewModel.prepTimeOptions.count - 1 {
                                Divider()
                                    .background(AppColors.line)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                    }
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.sm)
                    .shadow(color: AppColors.black8, radius: 8, y: 4)
                    .offset(y: 52)
                }
            }
        }
    }

    // MARK: - Shared Components
    private func inputField(label: String, placeholder: String, text: Binding<String>, isRequired: Bool, field: FocusedField) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if isRequired {
                requiredLabel(label)
            } else {
                Text(label)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
            TextField(placeholder, text: text)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.inputBg)
                .cornerRadius(AppRadius.Tablet.sm)
                .focused($focusedField, equals: field)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(focusedField == field ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
        }
        .id(field)
    }

    private func requiredLabel(_ title: String) -> some View {
        HStack(spacing: 2) {
            Text("*")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.errorNormal)
            Text(title)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Actions
    private func handleAdd() {
        if viewModel.save() {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    AddItemView(
        availableGroups: [
            SetupMenuGroup(name: "Burgers & Sandwiches"),
            SetupMenuGroup(name: "Beverages"),
            SetupMenuGroup(name: "Desserts")
        ]
    )
}
