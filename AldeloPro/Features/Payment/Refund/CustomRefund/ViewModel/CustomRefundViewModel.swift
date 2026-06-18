//
//  CustomRefundViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import Foundation

// MARK: - CustomRefundViewModel

@Observable
final class CustomRefundViewModel {

    // MARK: - Published State

    private(set) var paidTotal: Decimal
    private(set) var refundRecords: [RefundHistoryEntry] = []
    private(set) var currentStep: ContextualRefundStep = .enterReason
    private(set) var processingState: RefundProcessingState = .idle

    var refundReason: String = ""
    private(set) var selectedPresetReason: RefundPresetReason?
    var refundAmountCents: Int = 0

    private(set) var alertError: RefundAlertError?

    // MARK: - Computed

    var totalRefunded: Decimal {
        refundRecords.reduce(0) { $0 + $1.amount }
    }

    var maxRefundable: Decimal {
        paidTotal - totalRefunded
    }

    var isFullyRefunded: Bool {
        maxRefundable <= 0
    }

    var displayedReason: String {
        if let preset = selectedPresetReason {
            return preset.rawValue
        }
        return refundReason
    }

    var hasValidReason: Bool {
        !displayedReason.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var refundAmountDecimal: Decimal {
        Decimal(refundAmountCents) / 100
    }

    var formattedRefundAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: refundAmountDecimal as NSDecimalNumber) ?? "$0.00"
    }

    var formattedMaxRefundable: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: maxRefundable as NSDecimalNumber) ?? "$0.00"
    }

    var formattedPaidTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: paidTotal as NSDecimalNumber) ?? "$0.00"
    }

    var canSubmitRefund: Bool {
        refundAmountCents > 0 && refundAmountDecimal <= maxRefundable
    }

    // MARK: - Init

    init(paidTotal: Decimal = 120.00, refundRecords: [RefundHistoryEntry] = []) {
        self.paidTotal = paidTotal
        self.refundRecords = refundRecords
        if isFullyRefunded {
            currentStep = .fullyRefunded
        }
    }

    // MARK: - Actions

    func selectPresetReason(_ reason: RefundPresetReason) {
        if selectedPresetReason == reason {
            selectedPresetReason = nil
            refundReason = ""
        } else {
            selectedPresetReason = reason
            refundReason = reason.rawValue
            // 延迟 0.4 秒自动进入金额输入，让用户看到 Chip 高亮反馈
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.confirmReason()
            }
        }
    }

    func confirmReason() {
        guard hasValidReason else { return }
        currentStep = .enterAmount
        refundAmountCents = 0
    }

    func editReason() {
        currentStep = .enterReason
    }

    func appendDigit(_ digit: Int) {
        let newCents = refundAmountCents * 10 + digit
        let newDecimal = Decimal(newCents) / 100
        guard newDecimal <= maxRefundable else { return }
        refundAmountCents = newCents
    }

    func appendDoubleZero() {
        let newCents = refundAmountCents * 100
        let newDecimal = Decimal(newCents) / 100
        guard newDecimal <= maxRefundable else { return }
        refundAmountCents = newCents
    }

    func deleteLastDigit() {
        refundAmountCents /= 10
    }

    func clearAmount() {
        refundAmountCents = 0
    }

    func submitRefundToMethodSelection() {
        guard canSubmitRefund else { return }
        currentStep = .selectCustomMethod
    }

    func selectMethod(_ method: CustomRefundMethod) {
        let amount = refundAmountDecimal
        if method == .creditCard || method == .debitCard {
            processingState = .waitingForCard(amount: amount)
        } else if method == .cash {
            // Cash requires intermediate "Cash Refund Total" screen
            processingState = .cashRefundTotal(amount: amount)
        } else {
            recordRefund(method: method.refundMethodType, amount: amount)
        }
    }

    func cancelWaiting() {
        processingState = .idle
    }

    func confirmCashRefund() {
        if case .cashRefundTotal(let amount) = processingState {
            let entry = RefundHistoryEntry(
                id: UUID().uuidString,
                timestamp: Date(),
                operatorName: "James",
                amount: amount,
                method: .cash
            )
            refundRecords.append(entry)
            processingState = .success(cardTitle: "Cash", amount: amount)
        }
    }

    func goBackFromMethodSelection() {
        currentStep = .enterAmount
    }

    func startNewRefund() {
        refundReason = ""
        selectedPresetReason = nil
        refundAmountCents = 0
        currentStep = .enterReason
    }

    func completeRefund(receiptOption: RefundReceiptOption) {
        processingState = .idle
        if isFullyRefunded {
            currentStep = .fullyRefunded
        } else {
            currentStep = .fullyRefunded
        }
    }

    func toggleReceiptPopover(entryID: String) {
        for i in refundRecords.indices {
            refundRecords[i].isReceiptPopoverActive =
                (refundRecords[i].id == entryID &&
                 !refundRecords[i].isReceiptPopoverActive)
        }
    }

    func dismissAllPopovers() {
        for i in refundRecords.indices {
            refundRecords[i].isReceiptPopoverActive = false
        }
    }

    func dismissAlert() {
        alertError = nil
    }

    // MARK: - Private

    private func recordRefund(method: RefundMethodType, amount: Decimal) {
        let entry = RefundHistoryEntry(
            id: UUID().uuidString,
            timestamp: Date(),
            operatorName: "James",
            amount: amount,
            method: method
        )
        refundRecords.append(entry)
        processingState = .success(
            cardTitle: method == .toCard ? "Card" : method.rawValue.capitalized,
            amount: amount
        )
    }

    // MARK: - Preview

    static func preview() -> CustomRefundViewModel {
        CustomRefundViewModel(paidTotal: 120.00)
    }

    static func previewWithRecords() -> CustomRefundViewModel {
        let vm = CustomRefundViewModel(paidTotal: 120.00, refundRecords: [
            RefundHistoryEntry(
                id: "r1", timestamp: Date(),
                operatorName: "James", amount: 60.00, method: .toCard
            )
        ])
        vm.currentStep = .fullyRefunded
        return vm
    }
}

