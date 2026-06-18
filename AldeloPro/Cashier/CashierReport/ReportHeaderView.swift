import SwiftUI

// MARK: - Report Header View

struct ReportHeaderView: View {
    let data: ReportHeaderData
    var onSyncEntrySelected: ((Int) -> Void)?

    @State private var isSyncDropdownExpanded = false

    var body: some View {
        VStack(spacing: Spacing.md) {
            syncStatusBar
            infoGrid
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Sync Status Bar

    private var syncStatusBar: some View {
        HStack(spacing: Spacing.sm) {
            syncIcon
            Text("Last Sync Status")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)

            syncDropdown
        }
    }

    private var syncIcon: some View {
        ZStack {
            Circle()
                .stroke(AppColors.errorNormal, lineWidth: 1.5)
                .frame(width: 18, height: 18)
            VStack(spacing: 1) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 6, weight: .bold))
                Image(systemName: "arrow.down")
                    .font(.system(size: 6, weight: .bold))
            }
            .foregroundColor(AppColors.errorNormal)
        }
    }

    private var syncDropdown: some View {
        Button {
            isSyncDropdownExpanded.toggle()
        } label: {
            HStack {
                Text(data.selectedSyncEntry?.displayTitle ?? "")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, Spacing.sm)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(AppColors.pageBgDeep)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
        .overlay(alignment: .top) {
            if isSyncDropdownExpanded {
                syncDropdownList
                    .offset(y: 40)
            }
        }
        .zIndex(1)
    }

    private var syncDropdownList: some View {
        VStack(spacing: 0) {
            ForEach(Array(data.lastSyncEntries.enumerated()), id: \.element.id) { index, entry in
                Button {
                    onSyncEntrySelected?(index)
                    isSyncDropdownExpanded = false
                } label: {
                    Text(entry.displayTitle)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            index == data.selectedSyncIndex
                                ? AppColors.primaryLight
                                : Color.clear
                        )
                }
            }
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .shadow(color: AppColors.black8, radius: 4, x: 0, y: 2)
    }

    // MARK: - Info Grid

    private var infoGrid: some View {
        HStack(alignment: .top, spacing: 0) {
            leftColumn
            Spacer()
            middleColumn
            Spacer()
            rightColumn
        }
    }

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            infoRow(label: "Cashier #", value: data.cashierNumber)
            infoRow(label: "Employee", value: data.employeeName)
            expectedCashRow
        }
    }

    private var middleColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            infoRow(label: "Drawer #", value: data.drawerNumber)
            infoRow(label: "Sign In", value: data.signInTime)
        }
    }

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            infoRow(label: "Device #", value: data.deviceNumber)
            signOutRow
        }
    }

    // MARK: - Info Rows

    private func infoRow(label: String, value: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(label)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    private var expectedCashRow: some View {
        HStack(spacing: Spacing.xs) {
            Text("Expected Drawer Cash")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(formattedCash)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.primaryNormal)
        }
    }

    private var signOutRow: some View {
        HStack(spacing: Spacing.xs) {
            Text("Sign Out")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)

            switch data.signOutStatus {
            case .stillSignedIn:
                signOutBadge
            case .signedOut(let time):
                Text(time)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }

    private var signOutBadge: some View {
        Text(data.signOutStatus.displayText)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(AppColors.primaryNormal)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(
                AppColors.primaryNormal.opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    // MARK: - Helpers

    private var formattedCash: String {
        String(format: "$%.2f", data.expectedDrawerCash)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        ReportHeaderView(data: .mock)
        ReportHeaderView(data: .mockSignedOut)
    }
    .padding(Spacing.md)
    .background(AppColors.pageBg)
}
