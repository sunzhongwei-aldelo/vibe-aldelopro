//
//  PaymentRefundViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import Foundation

// MARK: - PaymentRefundViewModel

@Observable
final class PaymentRefundViewModel {

    // MARK: - Published State

    private(set) var payments: [PaymentRecord] = []
    private(set) var selectedPaymentID: String?
    private(set) var currentStep: ContextualRefundStep = .idle
    private(set) var processingState: RefundProcessingState = .idle

    var refundReason: String = ""
    private(set) var selectedPresetReason: RefundPresetReason?
    var refundAmountCents: Int = 0

    private(set) var alertError: RefundAlertError?

    // MARK: - Computed

    var selectedPayment: PaymentRecord? {
        payments.first { $0.id == selectedPaymentID }
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

    var maxRefundable: Decimal {
        selectedPayment?.maxRefundable ?? 0
    }

    var formattedMaxRefundable: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: maxRefundable as NSDecimalNumber) ?? "$0.00"
    }

    var canSubmitRefund: Bool {
        refundAmountCents > 0 && refundAmountDecimal <= maxRefundable
    }

    // MARK: - Init

    init(payments: [PaymentRecord] = []) {
        self.payments = payments
    }

    // MARK: - Actions

    func selectPayment(_ id: String) {
        guard id != selectedPaymentID else { return }
        selectedPaymentID = id
        resetWorkspace()

        guard let payment = selectedPayment else { return }
        if payment.isFullyRefunded {
            currentStep = .fullyRefunded
        } else {
            currentStep = .enterReason
        }
    }

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

    func submitRefund() {
        guard canSubmitRefund, let payment = selectedPayment else { return }

        if payment.pmtToken.isEmpty {
            processingState = .waitingForCard(amount: refundAmountDecimal)
        } else {
            processingState = .processing(amount: refundAmountDecimal)
            simulateProcessing(payment: payment)
        }
    }

    func cancelWaiting() {
        processingState = .idle
    }

    func completeRefund(receiptOption: RefundReceiptOption) {
        processingState = .idle
        resetWorkspace()
        if let payment = selectedPayment, payment.isFullyRefunded {
            currentStep = .fullyRefunded
        } else {
            currentStep = .idle
            selectedPaymentID = nil
        }
    }

    func toggleReceiptPopover(entryID: String, in paymentID: String) {
        guard let pIdx = payments.firstIndex(where: { $0.id == paymentID }) else { return }
        for i in payments[pIdx].refundHistory.indices {
            payments[pIdx].refundHistory[i].isReceiptPopoverActive =
                (payments[pIdx].refundHistory[i].id == entryID &&
                 !payments[pIdx].refundHistory[i].isReceiptPopoverActive)
        }
    }

    func dismissAllPopovers() {
        for pIdx in payments.indices {
            for hIdx in payments[pIdx].refundHistory.indices {
                payments[pIdx].refundHistory[hIdx].isReceiptPopoverActive = false
            }
        }
    }

    func dismissAlert() {
        alertError = nil
    }

    // MARK: - Private

    private func resetWorkspace() {
        refundReason = ""
        selectedPresetReason = nil
        refundAmountCents = 0
    }

    private func simulateProcessing(payment: PaymentRecord) {
        let amount = refundAmountDecimal
        let cardTitle = payment.displayTitle

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            let entry = RefundHistoryEntry(
                id: UUID().uuidString,
                timestamp: Date(),
                operatorName: "James",
                amount: amount,
                method: .toCard
            )
            if let idx = self.payments.firstIndex(where: { $0.id == payment.id }) {
                self.payments[idx].refundHistory.append(entry)
            }
            self.processingState = .success(cardTitle: cardTitle, amount: amount)
        }
    }

    // MARK: - Preview

    static func preview() -> PaymentRefundViewModel {
        let vm = PaymentRefundViewModel(payments: [
            PaymentRecord(
                id: "1", cardType: .visa, lastFour: "1234",
                amount: 100.00, pmtToken: "01K1Z0MH9RE82MD63H6YWJBSYR",
                refundHistory: []
            ),
            PaymentRecord(
                id: "2", cardType: .mastercard, lastFour: "1235",
                amount: 10.00, pmtToken: "01K1Z0MH9RE82MD63H6YWJBSYQ",
                refundHistory: []
            ),
            PaymentRecord(
                id: "3", cardType: .cash, lastFour: "",
                amount: 10.00, pmtToken: "",
                refundHistory: []
            )
        ])
        return vm
    }
}

