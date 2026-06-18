//
//  CashierReportSelectEmployeeView.swift
//  AldeloPro
//

import SwiftUI

struct CashierReportSelectEmployeeView: View {
    let data: CashierReportSelectEmployeeData
    let onCancel: () -> Void
    let onConfirm: (EmployeeCardData?) -> Void

    @State private var selectedEmployeeId: String?
    @State private var searchText: String = ""

    private var filteredEmployees: [EmployeeCardData] {
        if searchText.isEmpty {
            return data.employees
        }
        return data.employees.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            filterBar
            searchBar
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
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: Spacing.md) {
            // Left: Banks + Sources
            HStack(spacing: 0) {
                filterPill(text: data.bankOptions.first(where: { $0.value == data.selectedBank })?.label ?? "All Banks")
                filterPill(text: data.sourceOptions.first(where: { $0.value == data.selectedSource })?.label ?? "All Sources")
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.trailing, Spacing.md)
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.line, lineWidth: 1)
            )

            // Right: Date picker
            HStack(spacing: 0) {
                Text(data.selectedDate)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(AppColors.primaryLight)
                    .cornerRadius(AppRadius.Tablet.xs)
                    .padding(Spacing.xxs)

                Spacer()

                Image(systemName: "calendar")
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.trailing, Spacing.md)
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    private func filterPill(text: String) -> some View {
        Text(text)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(AppColors.primaryLight)
            .cornerRadius(AppRadius.Tablet.xs)
            .padding(Spacing.xxs)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            TextField("Search By Employee or Cashier No.", text: $searchText)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(AppColors.pageBg)
        .cornerRadius(AppRadius.Tablet.sm)
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
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

    private func employeeCard(_ employee: EmployeeCardData) -> some View {
        let isSelected = selectedEmployeeId == employee.id

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            // Name row
            HStack(spacing: Spacing.sm) {
                Image(systemName: "person.circle")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                Text(employee.name)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.top, Spacing.md)

            // Sign In / Sign Out row
            HStack(spacing: 0) {
                HStack(spacing: Spacing.xs) {
                    Text("Sign In")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text(employee.signInTime)
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                HStack(spacing: Spacing.xs) {
                    Text("Sign Out")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)
                    if employee.signOutStatus.isBadge {
                        Text(employee.signOutStatus.displayText)
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.primaryNormal)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(AppColors.primaryNormal.opacity(0.08))
                            .cornerRadius(AppRadius.Tablet.xs)
                    } else {
                        Text(employee.signOutStatus.displayText)
                            .font(AppFont.tabletBody3Regular)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }

            // Device / Drawer row
            if employee.device != nil || employee.drawer != nil {
                HStack(spacing: 0) {
                    if let device = employee.device {
                        HStack(spacing: Spacing.xs) {
                            Text("Device")
                                .font(AppFont.tabletBody3Regular)
                                .foregroundColor(AppColors.textSecondary)
                            Text(device)
                                .font(AppFont.tabletBody3Regular)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    Spacer()
                    if let drawer = employee.drawer {
                        HStack(spacing: Spacing.xs) {
                            Text("Drawer")
                                .font(AppFont.tabletBody3Regular)
                                .foregroundColor(AppColors.textSecondary)
                            Text(drawer)
                                .font(AppFont.tabletBody3Regular)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(isSelected ? AppColors.primaryNormal : AppColors.line, lineWidth: isSelected ? 2 : 1)
        )
        .overlay(alignment: .topTrailing) {
            jobTitleBadge(employee.jobTitle)
        }
    }

    // MARK: - Job Title Badge

    private func jobTitleBadge(_ jobTitle: EmployeeJobTitle) -> some View {
        let color: Color = {
            switch jobTitle {
            case .cashier:
                return AppColors.warningNormal
            case .serverBank:
                return AppColors.successNormal
            }
        }()

        return Text(jobTitle.rawValue)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(color.opacity(0.08))
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: AppRadius.Tablet.sm,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: AppRadius.Tablet.sm
                )
                .stroke(color, lineWidth: 1)
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: AppRadius.Tablet.sm,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: AppRadius.Tablet.sm
                )
            )
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
                        .background(AppColors.pageBg)
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
    CashierReportSelectEmployeeView(
        data: .mock,
        onCancel: {},
        onConfirm: { _ in }
    )
    .frame(width: 775, height: 600)
    .padding()
    .background(AppColors.pageBg)
}
