//
//  PaymentRefundMainView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - PaymentRefundMainView

/// Left panel for Payment Refund tab
/// Shows payment card list with nested refund history rows
struct PaymentRefundMainView: View {

    // MARK: - Parameters

    let payments: [PaymentRecord]
    let selectedPaymentID: String?
    let onSelectPayment: (String) -> Void
    let onReceiptTap: (String, String) -> Void
    /// Called when receipt icon is tapped — passes entry ID, payment ID, and button screen rect
    let onReceiptIconTap: ((String, String, CGRect) -> Void)?

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionTitle

            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(payments) { payment in
                        paymentCardSection(payment)
                    }
                }
            }
        }
    }

    // MARK: - Section Title

    private var sectionTitle: some View {
        Text("Select Payment to Refund")
            .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Payment Card + Nested History

    private func paymentCardSection(_ payment: PaymentRecord) -> some View {
        let isSelected = payment.id == selectedPaymentID
        let hasActivePopover = payment.refundHistory.contains { $0.isReceiptPopoverActive }
        return VStack(spacing: 0) {
            originalPaymentCard(payment)

            if !payment.refundHistory.isEmpty {
                VStack(spacing: 0) {
                    ForEach(payment.refundHistory) { entry in
                        nestedRefundHistoryRow(entry, paymentID: payment.id)
                            .zIndex(entry.isReceiptPopoverActive ? 10 : 0)
                    }
                }
                .padding(.leading, Spacing.sm)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(isSelected ? AppColors.theme.opacity(0.08) : Color.clear)
        )
        .zIndex(hasActivePopover ? 10 : 1)
    }

    // MARK: - Original Payment Card

    private func originalPaymentCard(_ payment: PaymentRecord) -> some View {
        let isSelected = payment.id == selectedPaymentID
        let hasHistory = !payment.refundHistory.isEmpty
        return Button { onSelectPayment(payment.id) } label: {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(payment.displayTitle)
                        .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
                        .foregroundColor(AppColors.textPrimary)
                    if !payment.pmtToken.isEmpty {
                        Text("PMT: \(payment.pmtToken)")
                            .font(AppFont.tabletCaption2Regular)
                            .foregroundColor(AppColors.textTertiary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Text(formatCurrency(payment.amount))
                    .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? Color.clear : AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        isSelected && !hasHistory ? AppColors.theme : (isSelected ? Color.clear : AppColors.line),
                        lineWidth: isSelected && !hasHistory ? 1.5 : 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Nested Refund History Row

    private func nestedRefundHistoryRow(_ entry: RefundHistoryEntry, paymentID: String) -> some View {
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

            // Receipt icon button — captures global position on tap
            receiptIconButton(entry: entry, paymentID: paymentID)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Receipt Icon Button

    private func receiptIconButton(entry: RefundHistoryEntry, paymentID: String) -> some View {
        GeometryReader { geo in
            Button {
                let rect = geo.frame(in: .global)
                onReceiptIconTap?(entry.id, paymentID, rect)
            } label: {
                Image(systemName: "doc.text")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .frame(width: 32, height: 32)
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

#Preview("Payment List with History") {
    PaymentRefundMainView(
        payments: [
            PaymentRecord(
                id: "1", cardType: .visa, lastFour: "1234",
                amount: 100.00, pmtToken: "01K1Z0MH9RE82MD63H6YWJBSYR",
                refundHistory: [
                    RefundHistoryEntry(id: "r1", timestamp: Date(), operatorName: "James", amount: 60.00, method: .toCard),
                    RefundHistoryEntry(id: "r2", timestamp: Date(), operatorName: "James", amount: 20.00, method: .toCard)
                ]
            ),
            PaymentRecord(
                id: "2", cardType: .mastercard, lastFour: "1235",
                amount: 10.00, pmtToken: "01K1Z0MH9RE82MD63H6YWJBSYQ",
                refundHistory: []
            ),
            PaymentRecord(
                id: "3", cardType: .cash, lastFour: "",
                amount: 10.00, pmtToken: "",
                refundHistory: []
            )
        ],
        selectedPaymentID: "1",
        onSelectPayment: { _ in },
        onReceiptTap: { _, _ in },
        onReceiptIconTap: nil
    )
    .padding()
    .frame(width: 400)
    .background(AppColors.pageBg)
}
