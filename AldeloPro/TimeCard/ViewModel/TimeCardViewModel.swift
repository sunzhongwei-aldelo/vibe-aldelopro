//
//  TimeCardViewModel.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import Foundation

@Observable @MainActor
final class TimeCardViewModel {
    // MARK: - Injected Display Data

    let employeeName: String
    let employeeRole: String
    let loggedInUserName: String
    let loggedInClockTime: String?

    // MARK: - State

    private(set) var flowState: TimeCardFlowState = .clockInAction
    private(set) var currentTime: String = ""
    private(set) var currentDate: String = ""
    private(set) var clockInTimestamp: String = ""
    private(set) var lastClockInfo: String? = nil
    private(set) var countdownSeconds: Int = 10
    var isPaused: Bool = false
    private(set) var cashTipMode: CashTipFieldMode = .required
    private(set) var reportedCashTips: Double = 0

    // MARK: - Navigation

    private let onBack: () -> Void

    // MARK: - Private

    private var countdownTask: Task<Void, Never>?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f
    }()

    // MARK: - Derived

    var showCountdown: Bool { flowState.showsCountdown }

    // MARK: - Init

    init(
        employeeName: String,
        employeeRole: String,
        loggedInUserName: String,
        loggedInClockTime: String?,
        onBack: @escaping () -> Void
    ) {
        self.employeeName = employeeName
        self.employeeRole = employeeRole
        self.loggedInUserName = loggedInUserName
        self.loggedInClockTime = loggedInClockTime
        self.onBack = onBack
    }

    // MARK: - Lifecycle

    func onAppear() {
        refreshTime()
    }

    func onDisappear() {
        countdownTask?.cancel()
    }

    // MARK: - Sidebar Actions

    func handleSidebarTap(_ item: TimeCardMenuItem) {
        switch item {
        case .reportCashTips:
            countdownTask?.cancel()
            flowState = .reportCashTips
        case .clockOut:
            countdownTask?.cancel()
            flowState = .clockOutAction
            refreshTime()
        default:
            break
        }
    }

    // MARK: - Clock Actions

    func handleClockIn() {
        clockInTimestamp = currentTime
        refreshTime()
        flowState = .clockInSuccess
        startCountdown { [weak self] in
            guard let self else { return }
            self.flowState = .clockOutAction
            self.refreshTime()
        }
    }

    func handleClockOut() {
        refreshTime()
        // Based on settings, navigate to Report Cash Tips before completing clock out.
        // cashTipMode should be set to .required or .optional based on configuration.
        flowState = .reportCashTipsOnClockOut
    }

    func reportCashTipsOnClockOut(amount: Double) {
        reportedCashTips = amount
        flowState = .tipSummaryOnClockOut
    }

    func finishTipSummary() {
        flowState = .clockOutSuccess
        startCountdown { [weak self] in
            self?.onBack()
        }
    }

    func requestBack() {
        onBack()
    }

    // MARK: - Helpers

    func computeTotalHours() -> String {
        // Placeholder: in production, compute from actual clock-in timestamp
        "1.00 Hours"
    }

    private func refreshTime() {
        let now = Date()
        currentTime = Self.timeFormatter.string(from: now)
        currentDate = Self.dateFormatter.string(from: now)
    }

    private func startCountdown(onComplete: @escaping () -> Void) {
        countdownTask?.cancel()
        countdownSeconds = 10
        isPaused = false
        countdownTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                guard let self else { return }
                guard !self.isPaused else { continue }
                if self.countdownSeconds > 0 {
                    self.countdownSeconds -= 1
                } else {
                    onComplete()
                    return
                }
            }
        }
    }
}
