//
//  OrderCardView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import SwiftUI

struct OrderCardView: View {
    let order: OrderInfo
    let isSelected: Bool

    private var isVoided: Bool { order.orderStatus == .voided }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topSection
            middleSection
            Spacer(minLength: Spacing.xs)
            bottomSection
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .overlay(alignment: .topTrailing, content: {
            OrderStatusBadge(status: order.orderStatus)
        })
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(
                    isSelected ? AppColors.primaryNormal : Color.clear,
                    lineWidth: isSelected ? 3 : 0
                )
        )
    }

    // MARK: - Top Section (TicketNum left + Status Badge right)

    private var topSection: some View {
        HStack(alignment: .top) {
            HStack(spacing: Spacing.xs) {
                Text(order.ticketNum)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)

                if order.orderType == .dineIn, let table = order.tableNumber {
                    tableNumberBadge(table)
                }
            }

            Spacer()
        }
        .opacity(isVoided ? 0.5 : 1)
        .padding(.bottom, Spacing.xs)
    }

    // MARK: - Middle Section

    private var middleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Row 1: [OrderType icon+name+orderNum] ... [GuestCount] ... [Server]
            HStack(spacing: 0) {
                orderTypeRow

                Spacer()

                guestCountView

                Spacer()

                serverInfoView
            }
            .opacity(isVoided ? 0.5 : 1)

            // Row 2: Customer info
            if let name = order.customerName {
                customerRow(name: name, phone: order.customerPhone)
                    .opacity(isVoided ? 0.5 : 1)
            }

            // Delivery address
            if let address = order.deliveryAddress {
                Text(address)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .opacity(isVoided ? 0.5 : 1)
            }

            // Drive Thru vehicle
            if order.vehicleDescription != nil || order.vehicleColor != nil {
                vehicleBadge
                    .opacity(isVoided ? 0.5 : 1)
            }
        }
    }

    // MARK: - Bottom Section (Total left + Time/Hold right)

    private var bottomSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                if let authAmount = order.limitedAuthAmount {
                    HStack(spacing: Spacing.xs) {
                        Text("Limited Auth")
                            .font(AppFont.tabletH6Medium)
                            .foregroundColor(AppColors.textSecondary)
                        Text(formatCurrency(authAmount))
                            .font(AppFont.tabletH6Medium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                HStack(spacing: Spacing.xs) {
                    Text("Total")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Text(formatCurrency(order.totalAmount))
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .overlay(alignment: .center) {
                if isVoided {
                    Rectangle()
                        .fill(Color(hex: "#808080"))
                        .frame(height: 1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                timeRow

                if order.hasHold, let holdTime = order.holdTime {
                    HoldBadge(time: holdTime)
                }
            }
        }
        .opacity(isVoided ? 0.5 : 1)
        .padding(.top, Spacing.xs)
    }

    // MARK: - Sub-components

    private var orderTypeRow: some View {
        HStack(spacing: Spacing.xs) {
            Image(order.orderType.assetImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 0) {
                Text(order.orderType.rawValue)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textPrimary)
                Text(order.orderNum)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private var guestCountView: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "person")
                .font(.system(size: 11))
                .foregroundColor(AppColors.textPrimary)
            Text("\(order.guestCount)")
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    private var serverInfoView: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: Spacing.xxs) {
                Text(order.serverLabel)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(order.serverName)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textPrimary)
            }

            if let driver = order.driverName {
                HStack(spacing: Spacing.xxs) {
                    Text("Driver")
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text(driver)
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textPrimary)
                }

                if let status = order.driverStatus {
                    Text(status.rawValue)
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(status.color)
                }
            }
        }
    }

    private func customerRow(name: String, phone: String?) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(name)
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textPrimary)
            if let phone = phone {
                Text(phone)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private var timeRow: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: Spacing.xxs) {
                Text("Opened")
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(timeFormatter.string(from: order.openedTime))
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(AppColors.textPrimary)
            }

            if let closed = order.closedTime {
                HStack(spacing: Spacing.xxs) {
                    Text("Closed")
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text(timeFormatter.string(from: closed))
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }

    private func tableNumberBadge(_ number: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "table.furniture")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textPrimary)
            Text(number)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                .fill(Color(hex: "#F8F8F8"))
        )
    }

    private var vehicleBadge: some View {
        HStack(spacing: Spacing.xxs) {
            if let color = order.vehicleColor {
                Image(color)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            if let desc = order.vehicleDescription {
                Text(desc)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                .fill(AppColors.primaryLight)
        )
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview {
    let orders = RecallListViewModel.demoOrders()
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: Spacing.md), GridItem(.flexible(), spacing: Spacing.md)], spacing: Spacing.md) {
            ForEach(orders) { order in
                OrderCardView(order: order, isSelected: order.ticketNum == "#01")
                    .frame(height: 200)
            }
        }
        .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
