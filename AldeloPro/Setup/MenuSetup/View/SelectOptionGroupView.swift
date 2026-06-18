//
//  SelectOptionGroupView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/09.
//

import SwiftUI

struct SelectOptionGroupView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var selectedIds: Set<UUID>

    // MARK: - Props
    let itemName: String
    let allOptionGroups: [OptionGroup]
    let isEditing: Bool
    var onApply: (([OptionGroup]) -> Void)?

    init(
        itemName: String,
        allOptionGroups: [OptionGroup],
        selectedGroupIds: Set<UUID> = [],
        isEditing: Bool = false,
        onApply: (([OptionGroup]) -> Void)? = nil
    ) {
        self.itemName = itemName
        self.allOptionGroups = allOptionGroups
        self.isEditing = isEditing
        self.onApply = onApply
        self._selectedIds = State(initialValue: selectedGroupIds)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text(itemName)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textTertiary)

                    optionGroupGrid
                }
                .padding(.horizontal, Spacing.xxxxxxxl)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.xxxl)
            }
        }
        .background(AppColors.pageBg)
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Text(isEditing ? "Edit Item" : "Add Item")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textTertiary)
                Text("/")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textTertiary)
                Text("Select Option Group")
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

            Button(action: handleApply) {
                Text("Apply")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
            }
            .frame(height: 48)
            .padding(.horizontal, Spacing.xl)
            .background(AppColors.buttonPrimaryBg)
            .cornerRadius(AppRadius.Tablet.lg)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 84)
        .background(AppColors.glass)
    }

    // MARK: - Option Group Grid
    private var optionGroupGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md)
        ]
        return LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(allOptionGroups) { group in
                optionGroupCard(group: group)
            }
        }
    }

    private func optionGroupCard(group: OptionGroup) -> some View {
        let isSelected = selectedIds.contains(group.id)
        return Button(action: {
            if isSelected {
                selectedIds.remove(group.id)
            } else {
                selectedIds.insert(group.id)
            }
        }) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(group.name)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(group.summary)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.md)
            .frame(minHeight: 95)
            .background(isSelected ? AppColors.optionSelectedFill : AppColors.optionUnselectedFill)
            .cornerRadius(AppRadius.Tablet.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(isSelected ? AppColors.primaryNormal : AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func handleApply() {
        let selectedGroups = allOptionGroups.filter { selectedIds.contains($0.id) }
        onApply?(selectedGroups)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    SelectOptionGroupView(
        itemName: "Cheese Burger",
        allOptionGroups: [
            OptionGroup(name: "Sauce", choices: [
                OptionChoice(name: "Salad", actionModifiers: [
                    ActionModifier(name: "No"),
                    ActionModifier(name: "A Little"),
                    ActionModifier(name: "Extra")
                ]),
                OptionChoice(name: "Cheese", actionModifiers: [
                    ActionModifier(name: "No"),
                    ActionModifier(name: "A Little"),
                    ActionModifier(name: "Extra")
                ])
            ]),
            OptionGroup(name: "Beef", choices: [
                OptionChoice(name: "Normal"),
                OptionChoice(name: "Extra Beef")
            ]),
            OptionGroup(name: "Burger Bun", choices: [
                OptionChoice(name: "Regular"),
                OptionChoice(name: "Whole Wheat")
            ])
        ],
        selectedGroupIds: []
    )
}
