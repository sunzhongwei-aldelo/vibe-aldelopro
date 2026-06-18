import SwiftUI

// MARK: - Cashier Report Filter Bar View

struct CashierReportFilterBarView: View {
    let data: CashierReportFilterBarData
    var onStatusChanged: ((CashierStatus) -> Void)?
    var onDateTapped: (() -> Void)?
    var onEmployeeTapped: (() -> Void)?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f
    }()

    var body: some View {
        HStack(spacing: Spacing.sm) {
            statusSection
            dateSection
            employeeSection
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        HStack(spacing: Spacing.sm) {
            Text("Cashier Status")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)

            Button {
                onStatusChanged?(data.selectedStatus)
            } label: {
                Text(data.selectedStatus.rawValue)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(height: 36)
                    .padding(.horizontal, Spacing.lg)
                    .background(AppColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 42)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - Date Section

    private var dateSection: some View {
        Button {
            onDateTapped?()
        } label: {
            HStack(spacing: Spacing.sm) {
                Text(dateFormatter.string(from: data.selectedDate))
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .frame(height: 36)
                    .background(AppColors.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, Spacing.xs)
            .frame(height: 42)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
    }

    // MARK: - Employee Section

    private var employeeSection: some View {
        Button {
            onEmployeeTapped?()
        } label: {
            HStack {
                Text(data.selectedEmployee?.name ?? "Select An Employee")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(
                        data.selectedEmployee != nil
                            ? AppColors.textPrimary
                            : AppColors.textMuted
                    )
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, Spacing.sm)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
    }
}

// MARK: - Preview

#Preview {
    CashierReportFilterBarView(data: .mock)
        .padding(Spacing.md)
        .background(AppColors.pageBg)
}
