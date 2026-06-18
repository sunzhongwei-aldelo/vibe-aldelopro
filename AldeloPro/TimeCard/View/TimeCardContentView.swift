//
//  TimeCardContentView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import SwiftUI

/// Time Card 主内容区：依据 ViewModel 的 flowState 渲染对应卡片。
struct TimeCardContentView: View {
    let viewModel: TimeCardViewModel

    var body: some View {
        VStack {
            Spacer()
            cardForCurrentState
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var cardForCurrentState: some View {
        switch viewModel.flowState {
        case .clockInAction:
            ClockResultCardView(
                mode: .clockIn,
                currentTime: viewModel.currentTime,
                currentDate: viewModel.currentDate,
                employeeName: viewModel.employeeName,
                employeeRole: viewModel.employeeRole,
                lastClockInfo: viewModel.lastClockInfo,
                totalHoursWorked: nil,
                clockInTime: nil,
                clockOutTime: nil,
                isActionState: true,
                showContinueToPOS: false,
                onClockAction: { viewModel.handleClockIn() },
                onContinueToPOS: nil
            )

        case .clockInSuccess:
            ClockResultCardView(
                mode: .clockIn,
                currentTime: viewModel.clockInTimestamp,
                currentDate: viewModel.currentDate,
                employeeName: viewModel.employeeName,
                employeeRole: viewModel.employeeRole,
                lastClockInfo: viewModel.lastClockInfo,
                totalHoursWorked: nil,
                clockInTime: nil,
                clockOutTime: nil,
                isActionState: false,
                showContinueToPOS: false,
                onClockAction: nil,
                onContinueToPOS: nil
            )

        case .clockOutAction:
            ClockResultCardView(
                mode: .clockOut,
                currentTime: viewModel.currentTime,
                currentDate: viewModel.currentDate,
                employeeName: viewModel.employeeName,
                employeeRole: viewModel.employeeRole,
                lastClockInfo: viewModel.clockInTimestamp,
                totalHoursWorked: nil,
                clockInTime: nil,
                clockOutTime: nil,
                isActionState: true,
                showContinueToPOS: false,
                onClockAction: { viewModel.handleClockOut() },
                onContinueToPOS: nil
            )

        case .clockOutSuccess:
            ClockResultCardView(
                mode: .clockOut,
                currentTime: viewModel.currentTime,
                currentDate: viewModel.currentDate,
                employeeName: viewModel.employeeName,
                employeeRole: viewModel.employeeRole,
                lastClockInfo: nil,
                totalHoursWorked: viewModel.computeTotalHours(),
                clockInTime: viewModel.clockInTimestamp,
                clockOutTime: viewModel.currentTime,
                isActionState: false,
                showContinueToPOS: false,
                onClockAction: nil,
                onContinueToPOS: nil
            )

        case .reportCashTips:
            ReportCashTipsView(mode: .amount) { _ in

            }
            .padding(.vertical, Spacing.xl)
            .padding(.horizontal, Spacing.xl)

        case .reportCashTipsOnClockOut:
            ReportCashTipsView(mode: viewModel.cashTipMode) { amount in
                viewModel.reportCashTipsOnClockOut(amount: amount)
            }
            .padding(.vertical, Spacing.xl)
            .padding(.horizontal, Spacing.xl)

        case .tipSummaryOnClockOut:
            TipSummaryView(cashTips: viewModel.reportedCashTips) {
                viewModel.finishTipSummary()
            }
            .padding(.vertical, Spacing.xl)
            .padding(.horizontal, Spacing.xl)
        }
    }
}
