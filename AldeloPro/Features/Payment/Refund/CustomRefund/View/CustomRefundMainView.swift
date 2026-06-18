//
//  CustomRefundMainView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - CustomRefundMainView

/// Left panel for Custom Refund tab (图370, 384, 385)
/// Shows: Paid Total + Refund Records list with nested history rows
struct CustomRefundMainView: View {

    // MARK: - Parameters

    let formattedPaidTotal: String
    let refundRecords: [RefundHistoryEntry]
    let onReceiptTap: (String) -> Void

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            paidTotalSection

            if !refundRecords.isEmpty {
                Divider().foregroundColor(AppColors.line)
                refundRecordsSection
            }

            Spacer()
        }
    }

    // MARK: - Paid Total

    private var paidTotalSection: some View {
        Text("Paid Total: \(formattedPaidTotal)")
            .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Refund Records

    private var refundRecordsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Refund Records")
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            ForEach(refundRecords) { entry in
                refundRecordRow(entry)
            }
        }
    }

    private func refundRecordRow(_ entry: RefundHistoryEntry) -> some View {
        VStack(spacing: 0) {
            // Card header (shows card type info)
            if entry == refundRecords.first {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Visa ****1234")
                            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
                            .foregroundColor(AppColors.textPrimary)
                        Text("PMT: 01K1Z0MH9RE82MD63H6YWJBSYG")
                            .font(AppFont.tabletCaption2Regular)
                            .foregroundColor(AppColors.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            }

            // History detail row
            HStack(spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(formatTimestamp(entry.timestamp))
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text("By \(entry.operatorName)")
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.displayMethod)
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("-\(formatCurrency(entry.amount))")
                        .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.errorNormal)
                }

                Button { onReceiptTap(entry.id) } label: {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(entry.isReceiptPopoverActive ? AppColors.theme : AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            entry.isReceiptPopoverActive
                                ? AppColors.theme.opacity(0.1)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
    }

    // MARK: - Formatting

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd  hh:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("With Records") {
    CustomRefundMainView(
        formattedPaidTotal: "$120.00",
        refundRecords: [
            RefundHistoryEntry(id: "r1", timestamp: Date(), operatorName: "James", amount: 60.00, method: .toCard)
        ],
        onReceiptTap: { _ in }
    )
    .padding()
    .frame(width: 450)
    .background(AppColors.pageBg)
}

