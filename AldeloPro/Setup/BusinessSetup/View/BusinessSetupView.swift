//
//  BusinessSetupView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/11.
//

import SwiftUI

struct BusinessSetupView: View {

    // MARK: - Environment

    /// 全局设备布局（由根视图 `.provideDeviceLayout()` 注入）
    @Environment(\.deviceLayout) private var layout

    // MARK: - State

    @State private var viewModel = BusinessSetupViewModel()
    @State private var isCategoryOpen = false

    // MARK: - Callbacks

    /// 下一步导航（由父级 SetupFlowRootView 注入）。
    var onNext: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SetupTopBarView(progress: 0.2)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        titleSection
                        industrySection
                        categorySection
                            .id("categoryField")
                        orderTypeSection
                    }
                    .padding(.horizontal, !layout.iPadLandscape ? Spacing.md : Spacing.xx100)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, bottomScrollPadding)
                }
                .onChange(of: isCategoryOpen) { _, opened in
                    guard opened, layout.isPhonePortrait else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo("categoryField", anchor: .top)
                    }
                }
            }
            
            nextStepButton
        }
        .background(AppColors.pageBg)
        // 点击空白处 / 普通控件时自动收起 FormSelectField 下拉面板
        .dropdownHost()
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Business")
            .font(layout.isPhonePortrait ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Industry Section

    private var industrySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Industry")
                .font(layout.isPhonePortrait ? AppFont.mobileH2Medium : AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)

            switch layout {
            case .iPadLandscape:
                HStack(spacing: Spacing.md) {
                    ForEach(IndustryType.allCases) { industry in
                        industryCard(for: industry)
                    }
                }
            case .iPadPortrait:
                // 2 列等宽 Grid：3 个卡片上下两行宽度完全一致，
                // 第 3 个落在第二行左列
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.md),
                        GridItem(.flexible(), spacing: Spacing.md)
                    ],
                    spacing: Spacing.sm
                ) {
                    ForEach(IndustryType.allCases) { industry in
                        industryCard(for: industry)
                    }
                }
            case .iPhonePortrait:
                VStack(spacing: Spacing.sm) {
                    ForEach(IndustryType.allCases) { industry in
                        industryCard(for: industry)
                    }
                }
            }
        }
    }

    private func industryCard(for industry: IndustryType) -> some View {
        let isSelected = viewModel.selectedIndustry == industry
        let isPhone = layout.isPhonePortrait
        return Button {
            viewModel.selectIndustry(industry)
        } label: {
            HStack(spacing: Spacing.md) {
                iconBox(for: industry)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(industry.rawValue)
                        .font(isPhone ? AppFont.mobileH2Medium : AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)

                    Text(industry.subtitle)
                        .font(isPhone ? AppFont.mobileBody1Regular : AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
            .padding(Spacing.xs)
            .frame(maxWidth: .infinity)
            .frame(height: isPhone ? 80 : 90)
            .background(isSelected ? AppColors.optionSelectedFill : AppColors.optionUnselectedFill)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(
                        isSelected ? AppColors.optionSelectedStroke : AppColors.optionUnselectedStroke,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func iconBox(for industry: IndustryType) -> some View {
        let isPhone = layout.isPhonePortrait
        let size: CGFloat = isPhone ? 44 : 54
        return Image(industry.iconName)
            .font(.system(size: isPhone ? 18 : 24, weight: .medium))
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - Category Section

    private var categorySection: some View {
        FormSelectField(
            title: "Category",
            options: viewModel.categoryOptions,
            selectedOptions: $viewModel.selectedCategories,
            placeholder: "Select categories",
            onOpenChange: { opened in
                isCategoryOpen = opened
            }
        )
    }

    // MARK: - Order Type Section

    private var orderTypeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Order Type")
                .font(layout.isPhonePortrait ? AppFont.mobileH2Medium : AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)

            if layout.isPhonePortrait {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ],
                    spacing: Spacing.md
                ) {
                    ForEach(BusinessOrderType.allCases) { type in
                        orderTypeCheckbox(for: type)
                    }
                }
            } else {
                HStack(spacing: Spacing.xxl) {
                    ForEach(BusinessOrderType.allCases) { type in
                        orderTypeCheckbox(for: type)
                    }
                    Spacer()
                }
            }
        }
    }

    private func orderTypeCheckbox(for type: BusinessOrderType) -> some View {
        let isChecked = viewModel.selectedOrderTypes.contains(type)
        let isPhone = layout.isPhonePortrait
        return Button {
            viewModel.toggleOrderType(type)
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(.system(size: isPhone ? 18 : 20))
                    .foregroundColor(isChecked ? AppColors.primaryNormal : AppColors.black40)

                Text(type.rawValue)
                    .font(isPhone ? AppFont.mobileBody1Regular : AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Next Step Button

    private var nextStepButton: some View {
        let isPhone = layout.isPhonePortrait
        return Button {
            viewModel.nextStep()
            onNext?()
        } label: {
            Text("Next Step")
                .font(isPhone ? AppFont.mobileButton1Medium : AppFont.tabletButton3Medium)
                .foregroundColor(.white)
                .frame(maxWidth: isPhone ? .infinity : 382)
                .controlHeight(64)
                .background(AppColors.primaryNormal)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, isPhone ? Spacing.md : Spacing.xl)
        .padding(.bottom, Spacing.xl)
    }

    // MARK: - Helpers

    /// iPhone 竖屏展开 Category 时，预留额外底部空间，
    /// 让 ScrollViewReader 能把字段滚到顶部、面板完整可见
    private var bottomScrollPadding: CGFloat {
        if layout.isPhonePortrait && isCategoryOpen {
            return 520
        }
        return 120
    }
}

// MARK: - Preview

#Preview {
    BusinessSetupView()
        .provideDeviceLayout()
}
