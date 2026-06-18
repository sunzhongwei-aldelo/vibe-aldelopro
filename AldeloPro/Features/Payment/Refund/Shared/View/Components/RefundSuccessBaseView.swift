//
//  RefundSuccessBaseView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundSuccessBaseView

/// Full-screen refund success page with receipt options (图359)
/// Shows: card title + negative amount + green checkmark + "Success" + receipt option cards + CountdownBadge
struct RefundSuccessBaseView: View {

    // MARK: - Parameters

    let cardTitle: String
    let amount: Decimal
    let onSelectReceipt: (RefundReceiptOption) -> Void

    @State private var countdownSeconds: Int = 10
    @State private var isPaused: Bool = false

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: isCompact ? Spacing.md : Spacing.lg) {
                    Spacer().frame(height: Spacing.xxxl)

                    headerSection
                    successBadge
                    receiptOptions

                    Spacer().frame(height: Spacing.xl)
                }
                .frame(maxWidth: isCompact ? .infinity : 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isCompact ? Spacing.md : Spacing.xl)
            }

            // CountdownBadge in bottom-right corner
            countdownBadge
                .padding(Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.pageBg)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("\(cardTitle) Refunded")
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            Text(formattedNegativeAmount)
                .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletDisplay3Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    private var formattedNegativeAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        let str = formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
        return "-\(str)"
    }

    // MARK: - Success Badge

    private var successBadge: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isCompact ? 56 : 64))
                .foregroundColor(AppColors.successNormal)

            Text("Success")
                .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Receipt Options

    private var receiptOptions: some View {
        VStack(spacing: isCompact ? Spacing.sm : Spacing.md) {
            ForEach(RefundReceiptOption.allCases) { option in
                receiptCard(option)
            }
        }
    }

    private func receiptCard(_ option: RefundReceiptOption) -> some View {
        let isNoReceipt = option == .none
        return Button { onSelectReceipt(option) } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: option.iconName)
                    .font(.system(size: isCompact ? 20 : 24))
                    .foregroundColor(isNoReceipt ? AppColors.buttonPrimaryText : AppColors.textPrimary)
                Text(option.title)
                    .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody1Regular)
                    .foregroundColor(isNoReceipt ? AppColors.buttonPrimaryText : AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: isCompact ? 56 : 64)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .fill(isNoReceipt ? AppColors.buttonPrimaryBg : AppColors.card)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Countdown Badge

    private var countdownBadge: some View {
        SelfDrivingCountdownBadge(totalSeconds: 10) {
            onSelectReceipt(.none)
        }
    }
}

// MARK: - Preview

#Preview("Success - Visa") {
    RefundSuccessBaseView(
        cardTitle: "Visa ****1234",
        amount: 60.00,
        onSelectReceipt: { _ in }
    )
}

