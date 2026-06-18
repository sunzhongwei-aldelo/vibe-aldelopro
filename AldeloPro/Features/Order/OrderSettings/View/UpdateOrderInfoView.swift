//
//  UpdateOrderInfoView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 更新点单资料表单

/// 页面 3：客位数步进器 + 客户信息（电话/姓名）
/// 仅渲染左侧表单内容，右侧键盘由容器提供
struct UpdateOrderInfoView: View {
    @Binding var guestsCount: Int
    @Binding var phoneNumber: String
    @Binding var firstName: String
    @Binding var lastName: String
    let isPad: Bool
    var focusedField: FocusState<OrderSettingsField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.xl : Spacing.lg) {
            // 客位数步进器
            guestsSection
            // 客户信息分组
            customerSection
        }
    }

    // MARK: - 客位数

    private var guestsSection: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            Text("Guests Count")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            StepperCounterRow(value: $guestsCount, isPad: isPad)
        }
    }

    // MARK: - 客户信息

    private var customerSection: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.md : Spacing.sm) {
            // 分组标题
            Text("Customer")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            // 水平分割线
            Rectangle()
                .fill(AppColors.line)
                .frame(height: 1)

            // 电话号码输入
            phoneSection

            // 名字输入
            nameField(title: "First Name", text: $firstName, field: .firstName)

            // 姓氏输入
            nameField(title: "Last Name", text: $lastName, field: .lastName)
        }
    }

    // MARK: - 电话号码

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Phone Number")
                .font(isPad ? AppFont.tabletCaption1Regular : AppFont.mobileCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)

            TextField("(___) ___-____", text: $phoneNumber)
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, isPad ? Spacing.md : Spacing.sm)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                .overlay(
                    RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                        .stroke(
                            focusedField.wrappedValue == .phone ? AppColors.theme : AppColors.line,
                            lineWidth: focusedField.wrappedValue == .phone ? 1.5 : 1
                        )
                )
                .focused(focusedField, equals: .phone)
                .keyboardType(.phonePad)
        }
    }

    // MARK: - 姓名输入

    private func nameField(title: String, text: Binding<String>, field: OrderSettingsField) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(isPad ? AppFont.tabletCaption1Regular : AppFont.mobileCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)

            TextField("Optional", text: text)
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .foregroundStyle(AppColors.textPrimary)
                .italic(text.wrappedValue.isEmpty)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, isPad ? Spacing.md : Spacing.sm)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                .overlay(
                    RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                        .stroke(AppColors.line, lineWidth: 1)
                )
                .focused(focusedField, equals: field)
        }
    }
}
