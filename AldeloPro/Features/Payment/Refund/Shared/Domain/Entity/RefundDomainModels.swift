//
//  RefundDomainModels.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import Foundation

// MARK: - Module Tab

/// Top-level tab selector for the Refund module
enum RefundModuleTab: String, CaseIterable, Equatable {
    case paymentRefund
    case customRefund

    var title: String {
        switch self {
        case .paymentRefund: return "Payment Refund"
        case .customRefund: return "Custom Refund"
        }
    }
}

// MARK: - Contextual Refund Step

/// Right-side workspace state machine
enum ContextualRefundStep: Equatable {
    case idle
    case enterReason
    case enterAmount
    case selectCustomMethod
    case fullyRefunded
}

// MARK: - Payment Record

/// A single original payment transaction record
struct PaymentRecord: Identifiable, Equatable {
    let id: String
    let cardType: PaymentCardType
    let lastFour: String
    let amount: Decimal
    let pmtToken: String
    var refundHistory: [RefundHistoryEntry]

    var displayTitle: String {
        switch cardType {
        case .cash: return "Cash"
        default: return "\(cardType.displayName) ****\(lastFour)"
        }
    }

    var totalRefunded: Decimal {
        refundHistory.reduce(0) { $0 + $1.amount }
    }

    var maxRefundable: Decimal {
        amount - totalRefunded
    }

    var isFullyRefunded: Bool {
        maxRefundable <= 0
    }
}

// MARK: - Payment Card Type

enum PaymentCardType: String, Equatable {
    case visa
    case mastercard
    case amex
    case discover
    case cash
    case other

    var displayName: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "Mastercard"
        case .amex: return "Amex"
        case .discover: return "Discover"
        case .cash: return "Cash"
        case .other: return "Card"
        }
    }
}

// MARK: - Refund History Entry

/// A completed refund record nested under a payment card
struct RefundHistoryEntry: Identifiable, Equatable {
    let id: String
    let timestamp: Date
    let operatorName: String
    let amount: Decimal
    let method: RefundMethodType
    var isReceiptPopoverActive: Bool = false

    var displayMethod: String {
        switch method {
        case .toCard: return "Refunded to Card"
        case .cash: return "Refunded to Cash"
        case .storeCredit: return "Refunded to Store Credit"
        case .houseAccount: return "Refunded to House Account"
        }
    }
}

// MARK: - Refund Method Type

/// The method used for custom refund settlement
enum RefundMethodType: String, CaseIterable, Equatable {
    case toCard
    case cash
    case storeCredit
    case houseAccount
}

// MARK: - Custom Refund Method

/// Selectable method options in the Custom Refund flow
enum CustomRefundMethod: String, CaseIterable, Identifiable, Equatable {
    case creditCard
    case debitCard
    case cash
    case storeCredit
    case houseAccount

    var id: String { rawValue }

    var title: String {
        switch self {
        case .creditCard: return "Credit Card"
        case .debitCard: return "Debit Card"
        case .cash: return "Cash"
        case .storeCredit: return "Store Credit"
        case .houseAccount: return "House Account"
        }
    }

    var iconName: String {
        switch self {
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard.trianglebadge.exclamationmark"
        case .cash: return "banknote"
        case .storeCredit: return "person.2.circle"
        case .houseAccount: return "person.2"
        }
    }

    var refundMethodType: RefundMethodType {
        switch self {
        case .creditCard, .debitCard: return .toCard
        case .cash: return .cash
        case .storeCredit: return .storeCredit
        case .houseAccount: return .houseAccount
        }
    }
}

// MARK: - Preset Refund Reasons

enum RefundPresetReason: String, CaseIterable, Identifiable {
    case itemNotAsExpected = "Item Not As Expected"
    case orderCancellation = "Order Cancellation"
    case orderMistake = "Order Mistake"
    case waitTimeTooLong = "Wait Time Too Long"

    var id: String { rawValue }
}

// MARK: - Receipt Option

enum RefundReceiptOption: String, CaseIterable, Identifiable {
    case email
    case print
    case text
    case none

    var id: String { rawValue }

    var title: String {
        switch self {
        case .email: return "Email Receipt"
        case .print: return "Print Receipt"
        case .text: return "Text Receipt"
        case .none: return "No Receipt"
        }
    }

    var iconName: String {
        switch self {
        case .email: return "envelope"
        case .print: return "printer"
        case .text: return "iphone"
        case .none: return "doc.on.clipboard"
        }
    }
}

// MARK: - Processing State

enum RefundProcessingState: Equatable {
    case idle
    case processing(amount: Decimal)
    case waitingForCard(amount: Decimal)
    case cashRefundTotal(amount: Decimal)
    case success(cardTitle: String, amount: Decimal)
    case failed(message: String)
}

// MARK: - Alert Error

struct RefundAlertError: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String

    static func == (lhs: RefundAlertError, rhs: RefundAlertError) -> Bool {
        lhs.id == rhs.id
    }
}

