//
//  DeliveryDetail.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import Foundation
import CoreLocation

// MARK: - 外卖配送详情领域模型


// MARK: - Delivery Status

enum DeliveryStatus: Equatable, Sendable {
    case onRoute
    case delivered
    case arrived
}

// MARK: - Delivery Detail Entity

/// 外卖配送订单的详细信息实体
/// 包含配送地址、司机信息、时间线节点等核心数据
struct DeliveryDetail: Identifiable, Equatable, Sendable {
    let id: String
    let orderNumber: String
    let status: DeliveryStatus

    // Driver
    let driverName: String
    let driverPhone: String

    // Location
    let storeLocation: CLLocationCoordinate2D
    let customerLocation: CLLocationCoordinate2D
    let driverLocation: CLLocationCoordinate2D

    // Distance & ETA
    let distanceValue: Double
    let distanceUnit: DistanceUnit
    let estimatedMinutes: Int

    // Timestamps
    let departedAt: Date
    let deliveredAt: Date?
    let arrivedAt: Date?

    // Customer Info
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let deliveryRemarks: String?
    let crossStreetInfo: String?

    static func == (lhs: DeliveryDetail, rhs: DeliveryDetail) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
}

// MARK: - Distance Unit

enum DistanceUnit: Equatable, Sendable {
    case kilometers
    case miles

    var abbreviation: String {
        switch self {
        case .kilometers: return "km"
        case .miles: return "miles"
        }
    }
}

// MARK: - Timeline Node

struct DeliveryTimelineNode: Equatable, Sendable {
    let label: String
    let timestamp: Date?
    let isActive: Bool
}

