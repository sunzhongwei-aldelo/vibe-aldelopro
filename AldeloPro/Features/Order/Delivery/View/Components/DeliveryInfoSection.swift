//
//  DeliveryInfoSection.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - 配送信息展示段落


/// 配送详情页的信息展示区域组件
/// 展示配送地址、预计到达时间、司机联系方式等关键信息
struct DeliveryInfoSection: View {
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let deliveryRemarks: String?
    let crossStreetInfo: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Group 1: Customer name + address
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                customerRow
                addressRow
            }

            // Group 2: Remarks + Cross street
            if deliveryRemarks != nil || crossStreetInfo != nil {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    if let remarks = deliveryRemarks {
                        remarksRow(remarks)
                    }
                    if let crossStreet = crossStreetInfo {
                        crossStreetRow(crossStreet)
                    }
                }
            }
        }
    }

    // MARK: - Customer Row

    private var customerRow: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "person.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 18, alignment: .center)
            Text("\(customerName) \(customerPhone)")
                .font(AppFont.tabletBody3Regular)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Address Row

    private var addressRow: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 18, alignment: .center)
            Text(deliveryAddress)
                .font(AppFont.tabletBody3Regular)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Remarks Row

    private func remarksRow(_ remarks: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "truck.box")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 18, alignment: .center)
            HStack(spacing: 0) {
                Text("Delivery Remarks:")
                    .font(AppFont.tabletH4Medium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(remarks)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Cross Street Row

    private func crossStreetRow(_ crossStreet: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 18, alignment: .center)
            HStack(spacing: 0) {
                Text("Cross Street Info:")
                    .font(AppFont.tabletH4Medium)
                    .foregroundStyle(AppColors.textPrimary)
                Text(crossStreet)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

