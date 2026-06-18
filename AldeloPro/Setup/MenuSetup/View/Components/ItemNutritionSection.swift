//
//  ItemNutritionSection.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import SwiftUI

/// 菜单项「营养信息」区块（卡路里/脂肪/碳水/糖/蛋白质）。
/// 从 AddItemView 抽出的纯展示组件；焦点状态由父级注入。
struct ItemNutritionSection: View {
    @Binding var nutrition: NutritionInfo
    @FocusState.Binding var focusedField: FocusedField?

    typealias FocusedField = AddItemView.FocusedField

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                nutritionField(label: "Calories", placeholder: "kcal / Item", value: nutritionBinding(\.calories), field: .nutrition("calories"))
                nutritionField(label: "Fat", placeholder: "g / Item", value: nutritionBinding(\.fat), field: .nutrition("fat"))
            }
            HStack(spacing: Spacing.md) {
                nutritionField(label: "Carbohydrates", placeholder: "g / Item", value: nutritionBinding(\.carbohydrates), field: .nutrition("carbs"))
                nutritionField(label: "Sugar", placeholder: "g / Item", value: nutritionBinding(\.sugar), field: .nutrition("sugar"))
            }
            HStack(spacing: Spacing.md) {
                nutritionField(label: "Protein", placeholder: "g / Item", value: nutritionBinding(\.protein), field: .nutrition("protein"))
                Spacer()
            }
        }
    }

    private func nutritionField(label: String, placeholder: String, value: Binding<String>, field: FocusedField) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            TextField(placeholder, text: value)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(height: 48)
                .padding(.horizontal, Spacing.md)
                .background(AppColors.inputBg)
                .cornerRadius(AppRadius.Tablet.sm)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: field)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(focusedField == field ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
        }
        .id(field)
    }

    private func nutritionBinding(_ keyPath: WritableKeyPath<NutritionInfo, Double?>) -> Binding<String> {
        Binding<String>(
            get: {
                if let val = nutrition[keyPath: keyPath] {
                    return String(format: "%.1f", val)
                }
                return ""
            },
            set: { newValue in
                nutrition[keyPath: keyPath] = Double(newValue)
            }
        )
    }
}
