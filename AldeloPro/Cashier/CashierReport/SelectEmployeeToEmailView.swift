//
//  SelectEmployeeToEmailView.swift
//  AldeloPro
//

import SwiftUI

struct SelectEmployeeToEmailView: View {
    let data: SelectEmployeeToEmailData
    let onCancel: () -> Void
    let onConfirm: (EmailEmployee?) -> Void

    @State private var selectedEmployeeId: String?
    @State private var selectedFilter: String
    @State private var searchText: String = ""
    @State private var isFilterOpen: Bool = false

    init(
        data: SelectEmployeeToEmailData,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (EmailEmployee?) -> Void
    ) {
        self.data = data
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _selectedFilter = State(initialValue: data.selectedFilter)
    }

    private var selectedFilterLabel: String {
        data.filterOptions.first(where: { $0.value == selectedFilter })?.label
            ?? data.filterOptions.first?.label
            ?? "All Employees"
    }

    private var filteredEmployees: [EmailEmployee] {
        data.employees.filter { employee in
            let matchesRole = selectedFilter == "all"
                || employee.role.rawValue.lowercased() == selectedFilter.lowercased()
            let matchesSearch = searchText.isEmpty
                || employee.name.localizedCaseInsensitiveContains(searchText)
                || employee.email.localizedCaseInsensitiveContains(searchText)
            return matchesRole && matchesSearch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            controlsBar
                .zIndex(1)
            employeeGrid
            bottomBar
        }
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }

    // MARK: - Title Bar

    private var titleBar: some View {
        HStack {
            Text(data.title)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Controls Bar (filter dropdown + search)

    private var controlsBar: some View {
        HStack(spacing: Spacing.md) {
            filterDropdown
            searchField
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    private var filterDropdown: some View {
        Button {
            isFilterOpen.toggle()
        } label: {
            HStack(spacing: Spacing.sm) {
                Text(selectedFilterLabel)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(AppColors.primaryLight)
                    .cornerRadius(AppRadius.Tablet.xs)
                    .padding(Spacing.xxs)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .rotationEffect(.degrees(isFilterOpen ? 180 : 0))
                    .padding(.trailing, Spacing.md)
            }
        }
        .frame(width: 255)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            if isFilterOpen {
                filterDropdownMenu
            }
        }
    }

    private var filterDropdownMenu: some View {
        VStack(spacing: 0) {
            ForEach(data.filterOptions) { option in
                Button {
                    selectedFilter = option.value
                    isFilterOpen = false
                } label: {
                    HStack {
                        Text(option.label)
                            .font(AppFont.tabletH3Medium)
                            .foregroundColor(
                                option.value == selectedFilter
                                    ? AppColors.primaryNormal
                                    : AppColors.textPrimary
                            )
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        option.value == selectedFilter
                            ? AppColors.primaryLight
                            : AppColors.card
                    )
                }
                if option.id != data.filterOptions.last?.id {
                    Divider()
                }
            }
        }
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .shadow(color: AppColors.black20, radius: 8, y: 4)
        .offset(y: 68)
    }

    private var searchField: some View {
        HStack(spacing: Spacing.sm) {
            TextField(data.searchPlaceholder, text: $searchText)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColors.buttonSecondaryBg)
        .cornerRadius(AppRadius.Tablet.sm)
    }

    // MARK: - Employee Grid

    private var employeeGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ],
                spacing: Spacing.md
            ) {
                ForEach(filteredEmployees) { employee in
                    employeeCard(employee)
                        .onTapGesture {
                            selectedEmployeeId = employee.id
                        }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.md)
        }
    }

    // MARK: - Employee Card

    private func employeeCard(_ employee: EmailEmployee) -> some View {
        let isSelected = selectedEmployeeId == employee.id

        return VStack(alignment: .leading, spacing: Spacing.md) {
            // Name row
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                Text(employee.name)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                Spacer(minLength: 0)
            }

            // Email row
            HStack(spacing: Spacing.sm) {
                Image(systemName: "envelope")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                Text(employee.email)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(isSelected ? AppColors.primaryNormal : AppColors.line,
                        lineWidth: isSelected ? 2 : 1)
        )
        .overlay(alignment: .topTrailing) {
            roleBadge(employee.role)
        }
    }

    // MARK: - Role Badge

    private func roleBadge(_ role: EmailEmployeeRole) -> some View {
        let color: Color = {
            switch role {
            case .waiter:  return AppColors.roleWaiter
            case .cashier: return AppColors.roleCashier
            case .manager: return AppColors.roleManager
            }
        }()

        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: AppRadius.Tablet.sm,
            bottomTrailingRadius: 0,
            topTrailingRadius: AppRadius.Tablet.sm
        )

        return Text(role.rawValue)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(color)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(color.opacity(0.08))
            .clipShape(shape)
            .overlay(shape.stroke(color, lineWidth: 1))
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: Spacing.md) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(AppColors.buttonSecondaryBg)
                        .cornerRadius(AppRadius.Tablet.lg)
                }

                Button {
                    let selected = data.employees.first(where: { $0.id == selectedEmployeeId })
                    onConfirm(selected)
                } label: {
                    Text("Confirm")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.white100)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(AppColors.primaryNormal)
                        .cornerRadius(AppRadius.Tablet.lg)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
}

#Preview {
    SelectEmployeeToEmailView(
        data: .mock,
        onCancel: {},
        onConfirm: { _ in }
    )
    .frame(width: 920, height: 760)
    .padding()
    .background(AppColors.pageBg)
}
