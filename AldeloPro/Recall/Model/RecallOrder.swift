//
//  OrderInfo.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import Foundation
import SwiftUI

// MARK: - Order Status

enum OrderStatus: String, CaseIterable, Identifiable {
    case open = "Open"
    case settled = "Settled"
    case voided = "Voided"

    var id: String { rawValue }
}

// MARK: - Driver Status

enum DriverStatus: String, CaseIterable {
    case assigned = "Assigned"
    case departed = "Departed"
    case arrived = "Arrived"
    case delivered = "Delivered"

    var color: Color {
        switch self {
        case .assigned: return Color(hex: "#595959")
        case .departed: return AppColors.primaryNormal
        case .arrived: return AppColors.warningNormal
        case .delivered: return AppColors.successNormal
        }
    }
}

// MARK: - Order Info

struct OrderInfo: Identifiable, Equatable {
    let id: UUID
    let ticketNum: String
    let orderNum: String
    let orderType: OrderType
    let orderStatus: OrderStatus
    let guestCount: Int
    let serverName: String
    let customerName: String?
    let customerPhone: String?
    let totalAmount: Decimal
    let openedTime: Date
    let closedTime: Date?
    let holdTime: Double?

    // Dine In specific
    let tableNumber: String?

    // Bar specific
    let limitedAuthAmount: Decimal?

    // Delivery specific
    let deliveryAddress: String?
    let driverName: String?
    let driverStatus: DriverStatus?

    // Drive Thru specific
    let vehicleDescription: String?
    let vehicleColor: String?

    var serverLabel: String {
        orderType == .retail ? "Clerk" : "Server"
    }

    var hasHold: Bool {
        orderType != .takeOut && orderStatus == .open && holdTime != nil
    }
}
