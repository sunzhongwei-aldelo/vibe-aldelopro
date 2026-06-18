//
//  TipSummaryView.swift
//  AldeloExpressPro
//
//  Created by jiangxia on 2026/06/08.
//

import SwiftUI

struct TipSummaryView: View {
    // MARK: - Properties

    let cashTips: Double
    let onNext: () -> Void

    private var totalNetTips: Double {
        cashTips
    }

    var body: some View {
        VStack(spacing: 0) {
            titleSection
                .padding(.bottom, Spacing.xl)
            tipItemsSection
            divider
                .padding(.vertical, Spacing.lg)
            totalSection
                .padding(.bottom, Spacing.xl)
            nextButton
        }
        .padding(Spacing.xl)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
        .frame(maxWidth: 700)
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Tip Summary")
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Tip Items

    private var tipItemsSection: some View {
        VStack(spacing: Spacing.md) {
            tipRow(label: "Order Gratuities:", amount: 0)
            tipRow(label: "Integrated Payment Tips:", amount: 0)
            tipRow(label: "Cash Tips:", amount: cashTips)
            tipRow(label: "Tip Fee:", amount: 0)
            tipRow(label: "Bank Surcharge:", amount: 0)
        }
    }

    private func tipRow(label: String, amount: Double) -> some View {
        HStack {
            Text(label)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(String(format: "$%.2f", amount))
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(AppColors.line)
            .frame(height: 1)
    }

    // MARK: - Total

    private var totalSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("Total Net Tips")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
            Text(String(format: "$%.2f", totalNetTips))
                .font(AppFont.tabletDisplay6Medium)
                .foregroundColor(AppColors.primaryNormal)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button(action: onNext) {
            Text("Next")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .contentShape(Rectangle())
        }
        .background(AppColors.buttonPrimaryBg)
        .cornerRadius(AppRadius.Tablet.lg)
    }
}

// MARK: - Preview

#Preview {
    TipSummaryView(cashTips: 10.0, onNext: {})
        .padding(Spacing.xl)
        .background(AppColors.pageBg)
}
