import SwiftUI

// MARK: - Gift Card Sold Data

struct GiftCardSoldData {
    let title: String
    let rows: [GiftCardRow]
    let faceValueTotal: Double
    let paidAmountTotal: Double

    var faceValueTotalFormatted: String { CurrencyFormat.grouped(faceValueTotal) }
    var paidAmountTotalFormatted: String { CurrencyFormat.grouped(paidAmountTotal) }
}

// MARK: - Card Type

enum GiftCardType {
    case physical
    case digital

    var displayText: String {
        switch self {
        case .physical: return "Physical"
        case .digital: return "Digital"
        }
    }

    var badgeColor: Color {
        switch self {
        case .physical: return AppColors.primaryNormal
        case .digital: return AppColors.successNormal
        }
    }
}

// MARK: - Table Row

struct GiftCardRow: Identifiable {
    let id: String
    let giftCard: String
    let cardType: GiftCardType
    let customer: String
    let count: Int
    let faceValue: Double
    let paidAmount: Double

    var faceValueFormatted: String { CurrencyFormat.grouped(faceValue) }
    var paidAmountFormatted: String { CurrencyFormat.grouped(paidAmount) }
}

// MARK: - Mock Data

extension GiftCardSoldData {
    /// Full-page records detail mock matching `GiftCardSoldDetail.svg` (8 rows).
    static let recordsDetailMock = GiftCardSoldData(
        title: "Gift Card Sold Records",
        rows: [
            GiftCardRow(id: "1", giftCard: "Gift Card 1", cardType: .physical, customer: "Mike Smith", count: 9, faceValue: 10.00, paidAmount: 370.00),
            GiftCardRow(id: "2", giftCard: "Gift Card 2", cardType: .digital, customer: "Emily Anderson", count: 5, faceValue: 20.00, paidAmount: 400.00),
            GiftCardRow(id: "3", giftCard: "Gift Card 3", cardType: .digital, customer: "Alex Brown", count: 32, faceValue: 100.00, paidAmount: 700.00),
            GiftCardRow(id: "4", giftCard: "Gift Card 4", cardType: .physical, customer: "Ben Jones", count: 1, faceValue: 50.00, paidAmount: 450.00),
            GiftCardRow(id: "5", giftCard: "Gift Card 5", cardType: .physical, customer: "Eva Miller", count: 2, faceValue: 5.00, paidAmount: 50.00),
            GiftCardRow(id: "6", giftCard: "Gift Card 6", cardType: .physical, customer: "Eva Miller", count: 2, faceValue: 5.00, paidAmount: 50.00),
            GiftCardRow(id: "7", giftCard: "Gift Card 7", cardType: .physical, customer: "Eva Miller", count: 2, faceValue: 5.00, paidAmount: 50.00),
            GiftCardRow(id: "8", giftCard: "Gift Card 8", cardType: .physical, customer: "Eva Miller", count: 2, faceValue: 5.00, paidAmount: 50.00)
        ],
        faceValueTotal: 200.00,
        paidAmountTotal: 41370.00
    )

    static let mock = GiftCardSoldData(
        title: "Gift Card Sold",
        rows: [
            GiftCardRow(id: "1", giftCard: "Gift Card 1", cardType: .physical, customer: "Mike Smith", count: 9, faceValue: 10.00, paidAmount: 370.00),
            GiftCardRow(id: "2", giftCard: "Gift Card 2", cardType: .digital, customer: "Emily Anderson", count: 5, faceValue: 20.00, paidAmount: 400.00),
            GiftCardRow(id: "3", giftCard: "Gift Card 3", cardType: .digital, customer: "Alex Brown", count: 32, faceValue: 100.00, paidAmount: 700.00),
            GiftCardRow(id: "4", giftCard: "Gift Card 4", cardType: .physical, customer: "Ben Jones", count: 1, faceValue: 50.00, paidAmount: 450.00),
            GiftCardRow(id: "5", giftCard: "Gift Card 5", cardType: .physical, customer: "Eva Miller", count: 2, faceValue: 5.00, paidAmount: 50.00)
        ],
        faceValueTotal: 200.00,
        paidAmountTotal: 41370.00
    )
}
