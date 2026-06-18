//
//  RecallListViewModel.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import Foundation

@Observable
@MainActor
final class RecallListViewModel {
    var orders: [OrderInfo] = []
    var selectedOrderId: UUID?

    func loadDemoOrders() {
        orders = Self.demoOrders()
    }

    func selectOrder(_ order: OrderInfo) {
        selectedOrderId = order.id
    }

    // MARK: - Demo Data

    static func demoOrders() -> [OrderInfo] {
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let holdTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: now)?.timeIntervalSince1970

        return [
            OrderInfo(
                id: UUID(),
                ticketNum: "#01",
                orderNum: "1200001",
                orderType: .takeOut,
                orderStatus: .open,
                guestCount: 4,
                serverName: "Zhang San",
                customerName: "Sophia Nguyen",
                customerPhone: "(877) 639-8745",
                totalAmount: 61.50,
                openedTime: now,
                closedTime: nil,
                holdTime: nil,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#02",
                orderNum: "1200002",
                orderType: .dineIn,
                orderStatus: .open,
                guestCount: 6,
                serverName: "Li Wei",
                customerName: "Marcus Johnson",
                customerPhone: "(415) 555-0123",
                totalAmount: 128.75,
                openedTime: now.addingTimeInterval(-1800),
                closedTime: nil,
                holdTime: holdTime,
                tableNumber: "06",
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#03",
                orderNum: "1200003",
                orderType: .bar,
                orderStatus: .open,
                guestCount: 2,
                serverName: "Zhang San",
                customerName: "Emily Davis",
                customerPhone: "(310) 555-0456",
                totalAmount: 45.00,
                openedTime: now.addingTimeInterval(-2400),
                closedTime: nil,
                holdTime: holdTime,
                tableNumber: nil,
                limitedAuthAmount: 100.00,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#04",
                orderNum: "1200004",
                orderType: .delivery,
                orderStatus: .open,
                guestCount: 3,
                serverName: "Wang Fang",
                customerName: "Robert Chen",
                customerPhone: "(650) 555-0789",
                totalAmount: 89.25,
                openedTime: now.addingTimeInterval(-900),
                closedTime: nil,
                holdTime: holdTime,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: "123 Main St, Anytown, CA 91234, USA",
                driverName: "James Lee",
                driverStatus: .departed,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#05",
                orderNum: "1200005",
                orderType: .retail,
                orderStatus: .settled,
                guestCount: 1,
                serverName: "Chen Mei",
                customerName: "Sarah Williams",
                customerPhone: "(213) 555-0321",
                totalAmount: 34.99,
                openedTime: oneHourAgo,
                closedTime: now.addingTimeInterval(-1200),
                holdTime: nil,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#06",
                orderNum: "1200006",
                orderType: .driveThru,
                orderStatus: .voided,
                guestCount: 2,
                serverName: "Zhang San",
                customerName: "Michael Brown",
                customerPhone: "(408) 555-0654",
                totalAmount: 22.50,
                openedTime: oneHourAgo,
                closedTime: now.addingTimeInterval(-600),
                holdTime: nil,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: "Blue Convertible",
                vehicleColor: "blueCar"
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#01",
                orderNum: "1200001",
                orderType: .takeOut,
                orderStatus: .open,
                guestCount: 4,
                serverName: "Zhang San",
                customerName: "Sophia Nguyen",
                customerPhone: "(877) 639-8745",
                totalAmount: 61.50,
                openedTime: now,
                closedTime: nil,
                holdTime: nil,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#02",
                orderNum: "1200002",
                orderType: .dineIn,
                orderStatus: .open,
                guestCount: 6,
                serverName: "Li Wei",
                customerName: "Marcus Johnson",
                customerPhone: "(415) 555-0123",
                totalAmount: 128.75,
                openedTime: now.addingTimeInterval(-1800),
                closedTime: nil,
                holdTime: holdTime,
                tableNumber: "06",
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#03",
                orderNum: "1200003",
                orderType: .bar,
                orderStatus: .open,
                guestCount: 2,
                serverName: "Zhang San",
                customerName: "Emily Davis",
                customerPhone: "(310) 555-0456",
                totalAmount: 45.00,
                openedTime: now.addingTimeInterval(-2400),
                closedTime: nil,
                holdTime: holdTime,
                tableNumber: nil,
                limitedAuthAmount: 100.00,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#04",
                orderNum: "1200004",
                orderType: .delivery,
                orderStatus: .open,
                guestCount: 3,
                serverName: "Wang Fang",
                customerName: "Robert Chen",
                customerPhone: "(650) 555-0789",
                totalAmount: 89.25,
                openedTime: now.addingTimeInterval(-900),
                closedTime: nil,
                holdTime: holdTime,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: "123 Main St, Anytown, CA 91234, USA",
                driverName: "James Lee",
                driverStatus: .departed,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#05",
                orderNum: "1200005",
                orderType: .retail,
                orderStatus: .settled,
                guestCount: 1,
                serverName: "Chen Mei",
                customerName: "Sarah Williams",
                customerPhone: "(213) 555-0321",
                totalAmount: 34.99,
                openedTime: oneHourAgo,
                closedTime: now.addingTimeInterval(-1200),
                holdTime: nil,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: nil,
                vehicleColor: nil
            ),
            OrderInfo(
                id: UUID(),
                ticketNum: "#06",
                orderNum: "1200006",
                orderType: .driveThru,
                orderStatus: .voided,
                guestCount: 2,
                serverName: "Zhang San",
                customerName: "Michael Brown",
                customerPhone: "(408) 555-0654",
                totalAmount: 22.50,
                openedTime: oneHourAgo,
                closedTime: now.addingTimeInterval(-600),
                holdTime: nil,
                tableNumber: nil,
                limitedAuthAmount: nil,
                deliveryAddress: nil,
                driverName: nil,
                driverStatus: nil,
                vehicleDescription: "Blue Convertible",
                vehicleColor: "blueCar"
            )
        ]
    }
}
