//
//  PizzaBuilderView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import SwiftUI

// MARK: - 披萨定制器


/// 披萨自定义搭配页面
/// 支持分区域选择配料（左半/右半/全部），实时预览披萨外观
struct PizzaBuilderView: View {
    var viewModel: OrderingPageViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
//            Divider().background(AppColors.line)
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    sizeSection
                    crustSection
                    portionSection
                    typeSection
                    sauceSection
                    toppingsSection
                }
                .padding(Spacing.md)
            }
            footerView
                .padding(.bottom,10)
        }
        //.background(AppColors.pageBgDeep)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(viewModel.selectedOrderItem?.name ?? "Pizza")
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
                if let item = viewModel.selectedOrderItem {
                    Text(verbatim: "$\(item.unitPrice)")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            Spacer()
            divisionPicker
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    private var divisionPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(viewModel.divisions, id: \.self) { division in
                let isSelected = viewModel.selectedDivision == division
                Button {
                    viewModel.selectedDivision = division
                } label: {
                    Text(division)
                        .font(AppFont.tabletH6Medium)
                        .lineLimit(1)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                                .stroke(
                                    isSelected ? AppColors.primaryNormal : AppColors.line,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Sections

    private var sizeSection: some View {
        sectionView(for: viewModel.pizzaSections.first(where: { $0.id == "size" }))
    }

    private var crustSection: some View {
        sectionView(for: viewModel.pizzaSections.first(where: { $0.id == "crust" }))
    }

    private var typeSection: some View {
        sectionView(for: viewModel.pizzaSections.first(where: { $0.id == "type" }))
    }

    private var sauceSection: some View {
        sectionView(for: viewModel.pizzaSections.first(where: { $0.id == "sauce" }))
    }

    private var toppingsSection: some View {
        Group {
            if let section = viewModel.pizzaSections.first(where: { $0.id == "toppings" }) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        Text(section.title)
                            .font(AppFont.tabletH6Medium)
                            .foregroundColor(AppColors.textSecondary)

                        if let min = section.minRequired {
                            Text("(Choose \(min) Minimum")
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textSecondary)
                            if let left = viewModel.choicesLeft(for: section) {
                                Text("\(left) Choice Left")
                                    .font(AppFont.tabletBody5Regular)
                                    .foregroundColor(AppColors.errorNormal)
                            }
                            Text(")")
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 3),
                        spacing: Spacing.sm
                    ) {
                        ForEach(section.options) { option in
                            ToppingOptionCardView(option: option) {
                                viewModel.togglePizzaOption(sectionId: section.id, optionId: option.id)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Portion

    @ViewBuilder
    private var portionSection: some View {
        if viewModel.portionCount > 1 {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Portion")
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: Spacing.sm) {
                    ForEach(0..<viewModel.portionCount, id: \.self) { index in
                        portionButton(
                            index: index,
                            label: "1/\(viewModel.portionCount)",
                            icon: portionIcon(for: index)
                        )
                    }
                }
            }
        }
    }

    private func portionIcon(for index: Int) -> String {
        switch viewModel.portionCount {
        case 2:
            return index == 0 ? "circle.lefthalf.filled" : "circle.righthalf.filled"
        default:
            return "circle.fill"
        }
    }

    private func portionButton(index: Int, label: String, icon: String) -> some View {
        let isActive = viewModel.selectedPortion == index
        return Button { viewModel.selectedPortion = index } label: {
            HStack(spacing: Spacing.xs) {
                Text(label)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(isActive ? AppColors.primaryNormal : AppColors.textPrimary)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? AppColors.primaryNormal : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        isActive ? AppColors.primaryNormal : AppColors.line,
                        lineWidth: isActive ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Generic Section

    private func sectionView(for section: PizzaSection?) -> some View {
        Group {
            if let section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.xs) {
                        Text(section.title)
                            .font(AppFont.tabletH6Medium)
                            .foregroundColor(AppColors.textSecondary)

                        if let min = section.minRequired {
                            Text("(Choose \(min) Minimum")
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textSecondary)
                            if let left = viewModel.choicesLeft(for: section) {
                                Text("\(left) Choice Left")
                                    .font(AppFont.tabletBody5Regular)
                                    .foregroundColor(AppColors.errorNormal)
                            }
                            Text(")")
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    optionsGrid(section: section)
                }
            }
        }
    }

    private func optionsGrid(section: PizzaSection) -> some View {
        let columnCount = min(section.options.count, 4)
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: columnCount),
            spacing: Spacing.sm
        ) {
            ForEach(section.options) { option in
                OptionCardView(
                    name: option.name,
                    price: option.price,
                    isSelected: option.isSelected
                ) {
                    viewModel.togglePizzaOption(sectionId: section.id, optionId: option.id)
                }
            }
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 0) {
        Divider().background(AppColors.line)
        HStack(spacing: Spacing.md) {
            Spacer()
            Button { viewModel.deselectItem() } label: {
                Text("Go Back")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 158, height: 63)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }

            Button { viewModel.savePizzaConfig() } label: {
                Text("Done")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(width: 186, height: 63)
                    .background(AppColors.buttonPrimaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        }
        .background(AppColors.card)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: AppRadius.Tablet.lg,
                bottomTrailingRadius: AppRadius.Tablet.lg
            )
        )
    }
}

// MARK: - Preview

#Preview("Pizza Builder") {
    PizzaBuilderView(viewModel: OrderingPageViewModel())
        .frame(width: 700, height: 900)
}

