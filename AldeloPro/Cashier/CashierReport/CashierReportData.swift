import SwiftUI

// MARK: - Cashier Report Data (Unified Codable Model)

struct CashierReportData: Codable {
    let generatedAt: String
    let filter: CashierReportFilterData
    let header: ReportHeaderCodable
    let settledRevenueSummary: SettledRevenueSummaryCodable
    let cashierSummary: CashierSummaryCodable
    let cashCount: CashCountCodable
    let paymentActivities: PaymentActivitiesCodable
    let gratuityPayable: GratuityPayableCodable
    let gratuitySummary: GratuitySummaryCodable
    let giftCardSold: GiftCardSoldCodable
    let storeCreditSold: StoreCreditSoldCodable
    let discountActivities: DiscountActivitiesCodable
    let voidActivities: VoidActivitiesCodable
}

// MARK: - Filter

struct CashierReportFilterData: Codable {
    let selectedStatus: String
    let selectedDate: String
    let selectedEmployeeId: String?
    let employees: [FilterEmployeeCodable]
}

struct FilterEmployeeCodable: Codable, Identifiable {
    let id: String
    let name: String
}

// MARK: - Report Header

struct ReportHeaderCodable: Codable {
    let cashierNumber: String
    let employeeName: String
    let expectedDrawerCash: Double
    let drawerNumber: String
    let signInTime: String
    let deviceNumber: String
    let signOutStatus: String // "Still Signed In" or a time string
    let syncEntries: [SyncEntryCodable]
    let selectedSyncIndex: Int
}

struct SyncEntryCodable: Codable, Identifiable {
    let id: String
    let deviceName: String
    let syncTime: String
}

// MARK: - Settled Revenue Summary

struct SettledRevenueSummaryCodable: Codable {
    let upperSection: RevenueSectionCodable
    let lowerSection: RevenueSectionCodable
}

struct RevenueSectionCodable: Codable {
    let items: [RevenueLineItemCodable]
    let totalLabel: String
    let totalAmount: Double
}

struct RevenueLineItemCodable: Codable {
    let label: String
    let amount: Double
    let subtitle: String?
}

// MARK: - Cashier Summary

struct CashierSummaryCodable: Codable {
    let title: String
    let centerLabel: String
    let centerSubLabel: String
    let centerAmount: Double
    let items: [CashierSummaryItemCodable]
}

struct CashierSummaryItemCodable: Codable {
    let id: String
    let label: String
    let amount: Double
    let colorHex: String
}

// MARK: - Cash Count

struct CashCountCodable: Codable {
    let startAmount: Double
    let actualCashTotal: Double
    let cashOwed: Double
    let denominations: [CashDenominationCodable]
}

struct CashDenominationCodable: Codable {
    let denomination: String
    let count: Int
    let totalAmount: Double
}

// MARK: - Payment Activities

struct PaymentActivitiesCodable: Codable {
    let title: String
    let rows: [PaymentActivityRowCodable]
    let summary: PaymentActivitiesSummaryCodable
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

struct PaymentActivityRowCodable: Codable, Identifiable {
    let id: String
    let time: String
    let orderNumber: String
    let tenderTitle: String
    let tenderSubtitle: String?
    let payment: Double
    let tipAmount: Double
    let total: Double
}

struct PaymentActivitiesSummaryCodable: Codable {
    let orderPayment: Double
    let orderRefunds: Double
    let tip: Double
    let totalOrderPayment: Double
    let refunds: Double
    let netPayments: Double
}

// MARK: - Gratuity Payable

struct GratuityPayableCodable: Codable {
    let title: String
    let rows: [GratuityPayableRowCodable]
    let summary: GratuityPayableSummaryCodable
}

struct GratuityPayableRowCodable: Codable, Identifiable {
    let id: String
    let employee: String
    let gratuity: Double
    let lessFees: Double
    let netPayable: Double
}

struct GratuityPayableSummaryCodable: Codable {
    let gratuityTotal: Double
    let lessFeesTotal: Double
    let netPayableTotal: Double
}

// MARK: - Gratuity Summary

struct GratuitySummaryCodable: Codable {
    let chartItems: [GratuitySummaryChartItemCodable]
    let summary: GratuitySummarySummaryCodable
}

struct GratuitySummaryChartItemCodable: Codable {
    let label: String
    let amount: Double
}

struct GratuitySummarySummaryCodable: Codable {
    let tipsAdded: Double
    let orderGratuity: Double
    let tipFee: Double
    let bankSurcharge: Double
    let gratuityPayable: Double
    let gratuityPaid: Double
    let gratuityBalance: Double
}

// MARK: - Gift Card Sold

struct GiftCardSoldCodable: Codable {
    let title: String
    let rows: [GiftCardRowCodable]
    let faceValueTotal: Double
    let paidAmountTotal: Double
}

struct GiftCardRowCodable: Codable, Identifiable {
    let id: String
    let giftCard: String
    let cardType: String // "physical" or "digital"
    let customer: String
    let count: Int
    let faceValue: Double
    let paidAmount: Double
}

// MARK: - Store Credit Sold

struct StoreCreditSoldCodable: Codable {
    let title: String
    let rows: [StoreCreditRowCodable]
    let faceValueTotal: Double
    let paidAmountTotal: Double
}

struct StoreCreditRowCodable: Codable, Identifiable {
    let id: String
    let storeCredit: String
    let count: Int
    let faceValue: Double
    let paidAmount: Double
}

// MARK: - Discount Activities

struct DiscountActivitiesCodable: Codable {
    let title: String
    let sections: [DiscountSectionCodable]
    let totalAmount: Double
}

struct DiscountSectionCodable: Codable, Identifiable {
    let id: String
    let name: String
    let discountCount: Int
    let discountsTotal: Double
    let orders: [DiscountOrderRowCodable]
}

struct DiscountOrderRowCodable: Codable, Identifiable {
    let id: String
    let orderNumber: String
    let discountAmount: Double
}

// MARK: - Void Activities

struct VoidActivitiesCodable: Codable {
    let title: String
    let items: [VoidActivityItemCodable]
    let totalAmount: Double
}

struct VoidActivityItemCodable: Codable, Identifiable {
    let id: String
    let orderNumber: String
    let voidAction: String // "voidItem" or "voidOrder"
    let voidItemName: String
    let itemQty: Int
    let subTotal: Double
    let employee: String
    let manager: String
    let voidReason: String
}

// MARK: - Conversion Extensions (Codable → View Models)

extension CashierReportData {

    var filterBarData: CashierReportFilterBarData {
        let status = CashierStatus(rawValue: filter.selectedStatus) ?? .open
        let emps = filter.employees.map { FilterEmployee(id: $0.id, name: $0.name) }
        let selectedEmp = filter.selectedEmployeeId.flatMap { empId in
            emps.first { $0.id == empId }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from: filter.selectedDate) ?? Date()

        return CashierReportFilterBarData(
            statusOptions: CashierStatus.allCases,
            selectedStatus: status,
            selectedDate: date,
            employees: emps,
            selectedEmployee: selectedEmp
        )
    }

    var reportHeaderData: ReportHeaderData {
        let entries = header.syncEntries.map {
            SyncEntry(id: $0.id, deviceName: $0.deviceName, syncTime: $0.syncTime)
        }
        let signOut: SignOutStatus = header.signOutStatus == "Still Signed In"
            ? .stillSignedIn
            : .signedOut(time: header.signOutStatus)

        return ReportHeaderData(
            cashierNumber: header.cashierNumber,
            employeeName: header.employeeName,
            expectedDrawerCash: header.expectedDrawerCash,
            drawerNumber: header.drawerNumber,
            signInTime: header.signInTime,
            deviceNumber: header.deviceNumber,
            signOutStatus: signOut,
            lastSyncEntries: entries,
            selectedSyncIndex: header.selectedSyncIndex
        )
    }

    var settledRevenueSummaryData: SettledRevenueSummaryData {
        SettledRevenueSummaryData(
            upperSection: revenueSectionFrom(settledRevenueSummary.upperSection),
            lowerSection: revenueSectionFrom(settledRevenueSummary.lowerSection)
        )
    }

    private func revenueSectionFrom(_ s: RevenueSectionCodable) -> RevenueSummarySection {
        RevenueSummarySection(
            items: s.items.map { RevenueLineItem(label: $0.label, amount: $0.amount, subtitle: $0.subtitle) },
            totalLabel: s.totalLabel,
            totalAmount: s.totalAmount
        )
    }

    var cashierSummaryData: CashierSummaryData {
        let items = cashierSummary.items.map { item in
            CashierSummaryItem(
                id: item.id,
                label: item.label,
                amount: item.amount,
                color: Color(hex: item.colorHex)
            )
        }
        return CashierSummaryData(
            title: cashierSummary.title,
            centerLabel: cashierSummary.centerLabel,
            centerSubLabel: cashierSummary.centerSubLabel,
            centerAmount: cashierSummary.centerAmount,
            items: items
        )
    }

    var cashCountData: CashCountData {
        CashCountData(
            summary: CashCountSummary(
                startAmount: cashCount.startAmount,
                actualCashTotal: cashCount.actualCashTotal,
                cashOwed: cashCount.cashOwed
            ),
            denominations: cashCount.denominations.map {
                CashDenominationItem(denomination: $0.denomination, count: $0.count, totalAmount: $0.totalAmount)
            }
        )
    }

    var paymentActivitiesData: PaymentActivitiesData {
        PaymentActivitiesData(
            title: paymentActivities.title,
            rows: paymentActivities.rows.map {
                PaymentActivityRow(
                    id: $0.id, time: $0.time, orderNumber: $0.orderNumber,
                    tenderTitle: $0.tenderTitle, tenderSubtitle: $0.tenderSubtitle,
                    payment: $0.payment, tipAmount: $0.tipAmount, total: $0.total
                )
            },
            summary: PaymentActivitiesSummary(
                orderPayment: paymentActivities.summary.orderPayment,
                orderRefunds: paymentActivities.summary.orderRefunds,
                tip: paymentActivities.summary.tip,
                totalOrderPayment: paymentActivities.summary.totalOrderPayment,
                refunds: paymentActivities.summary.refunds,
                netPayments: paymentActivities.summary.netPayments
            ),
            totalCount: paymentActivities.totalCount,
            currentPage: paymentActivities.currentPage,
            totalPages: paymentActivities.totalPages
        )
    }

    var gratuityPayableData: GratuityPayableData {
        GratuityPayableData(
            title: gratuityPayable.title,
            rows: gratuityPayable.rows.map {
                GratuityPayableRow(
                    id: $0.id, employee: $0.employee,
                    gratuity: $0.gratuity, lessFees: $0.lessFees, netPayable: $0.netPayable
                )
            },
            summary: GratuityPayableSummary(
                gratuityTotal: gratuityPayable.summary.gratuityTotal,
                lessFeesTotal: gratuityPayable.summary.lessFeesTotal,
                netPayableTotal: gratuityPayable.summary.netPayableTotal
            )
        )
    }

    var gratuitySummaryData: GratuitySummaryData {
        GratuitySummaryData(
            chartItems: gratuitySummary.chartItems.map {
                RevenueLineItem(label: $0.label, amount: $0.amount)
            },
            summary: GratuitySummarySummary(
                tipsAdded: gratuitySummary.summary.tipsAdded,
                orderGratuity: gratuitySummary.summary.orderGratuity,
                tipFee: gratuitySummary.summary.tipFee,
                bankSurcharge: gratuitySummary.summary.bankSurcharge,
                gratuityPayable: gratuitySummary.summary.gratuityPayable,
                gratuityPaid: gratuitySummary.summary.gratuityPaid,
                gratuityBalance: gratuitySummary.summary.gratuityBalance
            )
        )
    }

    var giftCardSoldData: GiftCardSoldData {
        GiftCardSoldData(
            title: giftCardSold.title,
            rows: giftCardSold.rows.map {
                GiftCardRow(
                    id: $0.id, giftCard: $0.giftCard,
                    cardType: $0.cardType == "digital" ? .digital : .physical,
                    customer: $0.customer, count: $0.count,
                    faceValue: $0.faceValue, paidAmount: $0.paidAmount
                )
            },
            faceValueTotal: giftCardSold.faceValueTotal,
            paidAmountTotal: giftCardSold.paidAmountTotal
        )
    }

    var storeCreditSoldData: StoreCreditSoldData {
        StoreCreditSoldData(
            title: storeCreditSold.title,
            rows: storeCreditSold.rows.map {
                StoreCreditRow(
                    id: $0.id, storeCredit: $0.storeCredit,
                    count: $0.count, faceValue: $0.faceValue, paidAmount: $0.paidAmount
                )
            },
            faceValueTotal: storeCreditSold.faceValueTotal,
            paidAmountTotal: storeCreditSold.paidAmountTotal
        )
    }

    var discountActivitiesData: DiscountActivitiesData {
        DiscountActivitiesData(
            title: discountActivities.title,
            sections: discountActivities.sections.map { s in
                DiscountSection(
                    id: s.id, name: s.name, discountCount: s.discountCount,
                    discountsTotal: s.discountsTotal,
                    orders: s.orders.map {
                        DiscountOrderRow(id: $0.id, orderNumber: $0.orderNumber, discountAmount: $0.discountAmount)
                    }
                )
            },
            totalAmount: discountActivities.totalAmount
        )
    }

    var voidActivitiesData: VoidActivitiesData {
        VoidActivitiesData(
            title: voidActivities.title,
            items: voidActivities.items.map {
                VoidActivityItem(
                    id: $0.id, orderNumber: $0.orderNumber,
                    voidAction: $0.voidAction == "voidOrder" ? .voidOrder : .voidItem,
                    voidItemName: $0.voidItemName, itemQty: $0.itemQty, subTotal: $0.subTotal,
                    employee: $0.employee, manager: $0.manager, voidReason: $0.voidReason
                )
            },
            totalAmount: voidActivities.totalAmount
        )
    }
}

// MARK: - Mock

extension CashierReportData {
    static let mock = CashierReportData(
        generatedAt: "2026-01-01 11:00AM",
        filter: CashierReportFilterData(
            selectedStatus: "Open",
            selectedDate: "01/16/2026",
            selectedEmployeeId: nil,
            employees: [
                FilterEmployeeCodable(id: "1", name: "Mike Smith"),
                FilterEmployeeCodable(id: "2", name: "Zhang San"),
                FilterEmployeeCodable(id: "3", name: "Emily Anderson")
            ]
        ),
        header: ReportHeaderCodable(
            cashierNumber: "787-32", employeeName: "Zhang San",
            expectedDrawerCash: 900.00, drawerNumber: "1",
            signInTime: "2025-09-09  07:58 PM", deviceNumber: "787",
            signOutStatus: "Still Signed In",
            syncEntries: [
                SyncEntryCodable(id: "1", deviceName: "Device 1", syncTime: "2025-09-08 08:00 PM")
            ],
            selectedSyncIndex: 0
        ),
        settledRevenueSummary: SettledRevenueSummaryCodable(
            upperSection: RevenueSectionCodable(
                items: [
                    RevenueLineItemCodable(label: "All Categories Sales", amount: 2215.93, subtitle: nil),
                    RevenueLineItemCodable(label: "Non-Inclusive Taxes Collected", amount: 1429.65, subtitle: nil),
                    RevenueLineItemCodable(label: "Order Surcharges", amount: 1244.25, subtitle: nil),
                    RevenueLineItemCodable(label: "Order Discounts", amount: -263.49, subtitle: nil),
                    RevenueLineItemCodable(label: "Total Order Refunds", amount: -1235.75, subtitle: nil)
                ],
                totalLabel: "Total Settled Revenue",
                totalAmount: 2242.70
            ),
            lowerSection: RevenueSectionCodable(
                items: [
                    RevenueLineItemCodable(label: "Gift Cards Sold", amount: 41370.00, subtitle: "(Face Value: $41,370.00)"),
                    RevenueLineItemCodable(label: "Store Credit Issued", amount: 10200.00, subtitle: "(Face Value: $10,200.00)"),
                    RevenueLineItemCodable(label: "Driver Compensations", amount: -42.00, subtitle: nil)
                ],
                totalLabel: "Net Settled Revenue",
                totalAmount: 53928.31
            )
        ),
        cashierSummary: CashierSummaryCodable(
            title: "Server Bank Summary",
            centerLabel: "Cash Owed", centerSubLabel: "To Employee", centerAmount: -400.00,
            items: [
                CashierSummaryItemCodable(id: "1", label: "Net Payments", amount: 4444.63, colorHex: "#007CFF"),
                CashierSummaryItemCodable(id: "2", label: "Begin Cash Expected", amount: 0.00, colorHex: "#3E9314"),
                CashierSummaryItemCodable(id: "3", label: "Safe Drop", amount: 0.00, colorHex: "#FFB33F"),
                CashierSummaryItemCodable(id: "4", label: "Begin Cash Shortage", amount: 0.00, colorHex: "#FF403F"),
                CashierSummaryItemCodable(id: "5", label: "Driver Compensation", amount: -400.00, colorHex: "#AC55F7"),
                CashierSummaryItemCodable(id: "6", label: "Non-Cash Tenders Total", amount: -4444.63, colorHex: "#FF5500")
            ]
        ),
        cashCount: CashCountCodable(
            startAmount: 100.00, actualCashTotal: 240.00, cashOwed: 140.00,
            denominations: [
                CashDenominationCodable(denomination: "1¢", count: 40, totalAmount: 0.40),
                CashDenominationCodable(denomination: "$1", count: 10, totalAmount: 10.00),
                CashDenominationCodable(denomination: "$5", count: 2, totalAmount: 10.00),
                CashDenominationCodable(denomination: "$10", count: 2, totalAmount: 20.00),
                CashDenominationCodable(denomination: "$20", count: 1, totalAmount: 20.00),
                CashDenominationCodable(denomination: "$100", count: 1, totalAmount: 100.00)
            ]
        ),
        paymentActivities: PaymentActivitiesCodable(
            title: "Payment Activities",
            rows: [
                PaymentActivityRowCodable(id: "1", time: "2022-12-30 10:42 AM", orderNumber: "787-238", tenderTitle: "MasterCard xxxx4422", tenderSubtitle: "PMT: E9C18C6A", payment: 11.36, tipAmount: 2.00, total: 13.36),
                PaymentActivityRowCodable(id: "2", time: "2022-12-30 01:59 PM", orderNumber: "787-237", tenderTitle: "Cash", tenderSubtitle: nil, payment: 3.43, tipAmount: 2.00, total: 5.43)
            ],
            summary: PaymentActivitiesSummaryCodable(
                orderPayment: 53972.61, orderRefunds: -2.30, tip: 0.00,
                totalOrderPayment: 53970.31, refunds: -49.54, netPayments: 53970.31
            ),
            totalCount: 48,
            currentPage: 1,
            totalPages: 6
        ),
        gratuityPayable: GratuityPayableCodable(
            title: "Gratuity Payable",
            rows: [
                GratuityPayableRowCodable(id: "1", employee: "Masa Online Order", gratuity: 30.32, lessFees: -1.98, netPayable: 28.34),
                GratuityPayableRowCodable(id: "2", employee: "Zhang San", gratuity: 9.21, lessFees: -0.92, netPayable: 28.34)
            ],
            summary: GratuityPayableSummaryCodable(gratuityTotal: 241.92, lessFeesTotal: -34.73, netPayableTotal: 207.19)
        ),
        gratuitySummary: GratuitySummaryCodable(
            chartItems: [
                GratuitySummaryChartItemCodable(label: "Masa E-Gift Card", amount: 135.26),
                GratuitySummaryChartItemCodable(label: "MasterCard", amount: 51.12),
                GratuitySummaryChartItemCodable(label: "Masa Reward Card", amount: 29.07),
                GratuitySummaryChartItemCodable(label: "Debit Card", amount: 19.19),
                GratuitySummaryChartItemCodable(label: "Gratuities Payable At Other\nCashier / Server Bank", amount: -2.54)
            ],
            summary: GratuitySummarySummaryCodable(
                tipsAdded: 232.09, orderGratuity: 9.83, tipFee: -13.55,
                bankSurcharge: -21.18, gratuityPayable: 207.19, gratuityPaid: 0.00, gratuityBalance: 207.19
            )
        ),
        giftCardSold: GiftCardSoldCodable(
            title: "Gift Card Sold",
            rows: [
                GiftCardRowCodable(id: "1", giftCard: "Gift Card 1", cardType: "physical", customer: "Mike Smith", count: 9, faceValue: 10.00, paidAmount: 370.00),
                GiftCardRowCodable(id: "2", giftCard: "Gift Card 2", cardType: "digital", customer: "Emily Anderson", count: 5, faceValue: 20.00, paidAmount: 400.00)
            ],
            faceValueTotal: 200.00, paidAmountTotal: 41370.00
        ),
        storeCreditSold: StoreCreditSoldCodable(
            title: "Store Credit Sold",
            rows: [
                StoreCreditRowCodable(id: "1", storeCredit: "Store Credit 1", count: 9, faceValue: 10.00, paidAmount: 370.00),
                StoreCreditRowCodable(id: "2", storeCredit: "Store Credit 2", count: 5, faceValue: 20.00, paidAmount: 400.00)
            ],
            faceValueTotal: 200.00, paidAmountTotal: 41370.00
        ),
        discountActivities: DiscountActivitiesCodable(
            title: "Discount Activities",
            sections: [
                DiscountSectionCodable(id: "1", name: "Discount 1", discountCount: 1, discountsTotal: -236.89, orders: [
                    DiscountOrderRowCodable(id: "1-1", orderNumber: "787-101", discountAmount: -236.89)
                ])
            ],
            totalAmount: -263.49
        ),
        voidActivities: VoidActivitiesCodable(
            title: "Void Activities",
            items: [
                VoidActivityItemCodable(id: "1", orderNumber: "787-261", voidAction: "voidItem", voidItemName: "Grilled Chicken", itemQty: 1, subTotal: 10.00, employee: "Mike Smith", manager: "Manager A", voidReason: "System Auto Void"),
                VoidActivityItemCodable(id: "2", orderNumber: "787-123", voidAction: "voidOrder", voidItemName: "All Items", itemQty: 4, subTotal: 100.00, employee: "Mike Smith", manager: "Manager A", voidReason: "System Auto Void")
            ],
            totalAmount: 10200.00
        )
    )
}
