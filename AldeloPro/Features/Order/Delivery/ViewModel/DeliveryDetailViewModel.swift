//
//  DeliveryDetailViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import Foundation
import CoreLocation

// MARK: - 配送详情视图模型


/// 配送详情页的状态管理器
/// 负责获取配送数据、更新时间线状态、处理司机联系等业务逻辑
@Observable @MainActor
final class DeliveryDetailViewModel {

    // MARK: - Published State

    private(set) var delivery: DeliveryDetail

    // MARK: - Init

    init(delivery: DeliveryDetail) {
        self.delivery = delivery
    }

    // MARK: - Computed Properties

    var statusText: String {
        switch delivery.status {
        case .onRoute:
            return "Estimated Delivery:"
        case .delivered:
            return "Estimated Arrival:"
        case .arrived:
            return "Driver Arrived:"
        }
    }

    var statusTimeText: String {
        switch delivery.status {
        case .onRoute:
            guard let deliveredAt = delivery.deliveredAt else {
                return formatTime(delivery.departedAt.addingTimeInterval(TimeInterval(delivery.estimatedMinutes * 60)))
            }
            return formatTime(deliveredAt)
        case .delivered:
            guard let arrivedAt = delivery.arrivedAt else {
                let estimatedArrival = (delivery.deliveredAt ?? delivery.departedAt)
                    .addingTimeInterval(TimeInterval(delivery.estimatedMinutes * 60))
                return formatTime(estimatedArrival)
            }
            return formatTime(arrivedAt)
        case .arrived:
            return formatTime(delivery.arrivedAt ?? Date())
        }
    }

    var calloutTitle: String {
        "Driver On-Route"
    }

    var calloutDistance: String {
        let formatted = String(format: "%.1f", delivery.distanceValue)
        return "\(formatted) \(delivery.distanceUnit.abbreviation) away"
    }

    var calloutTime: String {
        "\(delivery.estimatedMinutes) minutes"
    }

    var showCallout: Bool {
        delivery.status != .arrived
    }

    var timelineNodes: [DeliveryTimelineNode] {
        [
            DeliveryTimelineNode(
                label: "Departed",
                timestamp: delivery.departedAt,
                isActive: true
            ),
            DeliveryTimelineNode(
                label: "Delivered",
                timestamp: delivery.deliveredAt,
                isActive: delivery.status == .delivered || delivery.status == .arrived
            ),
            DeliveryTimelineNode(
                label: "Arrived",
                timestamp: delivery.arrivedAt,
                isActive: delivery.status == .arrived
            )
        ]
    }

    /// Progress from 0.0 to 1.0 representing truck position on the timeline
    var truckProgress: Double {
        switch delivery.status {
        case .onRoute:
            return 0.25
        case .delivered:
            return 0.75
        case .arrived:
            return 1.0
        }
    }

    // MARK: - Actions

    func callDriver() {
        guard let url = URL(string: "tel://\(delivery.driverPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") else {
            return
        }
        // In production, this would use UIApplication.shared.open(url)
        _ = url
    }

    // MARK: - Private

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Preview Factory

    static func preview(status: DeliveryStatus) -> DeliveryDetailViewModel {
        let calendar = Calendar.current
        let baseDate = calendar.date(bySettingHour: 12, minute: 20, second: 0, of: Date()) ?? Date()
        let deliveredDate = baseDate.addingTimeInterval(600) // +10 min
        let arrivedDate = baseDate.addingTimeInterval(1200) // +20 min

        let delivery = DeliveryDetail(
            id: "delivery-001",
            orderNumber: "#03",
            status: status,
            driverName: "James Lee",
            driverPhone: "(877) 633-8745",
            storeLocation: CLLocationCoordinate2D(latitude: 37.3022, longitude: -120.4830),
            customerLocation: CLLocationCoordinate2D(latitude: 37.3180, longitude: -120.4550),
            driverLocation: CLLocationCoordinate2D(latitude: 37.3100, longitude: -120.4690),
            distanceValue: status == .onRoute ? 1.2 : 1.2,
            distanceUnit: status == .onRoute ? .kilometers : .miles,
            estimatedMinutes: 10,
            departedAt: baseDate,
            deliveredAt: status == .delivered || status == .arrived ? deliveredDate : nil,
            arrivedAt: status == .arrived ? arrivedDate : nil,
            customerName: "Sophia Nguyen",
            customerPhone: "(877) 639-8745",
            deliveryAddress: "123 Main St, Anytown, CA 91234",
            deliveryRemarks: "Please leave it at the door",
            crossStreetInfo: "Between Pine St and Oak Ave"
        )

        return DeliveryDetailViewModel(delivery: delivery)
    }
}

