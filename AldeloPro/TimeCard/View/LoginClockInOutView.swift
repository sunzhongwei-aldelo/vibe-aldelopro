//
//  LoginClockInOutView.swift
//  AldeloExpressPro
//
//  Created by jiangxia on 2026/06/05.
//

import SwiftUI

// MARK: - Clock In/Out Result Mode

enum TimeCardMode {
    case clockIn
    case clockOut
}

// MARK: - TimeCardResultView (Login Flow)

struct LoginClockInOutView: View {
    // MARK: - Properties

    let mode: TimeCardMode
    let currentTime: String
    let currentDate: String
    let employeeName: String
    let employeeRole: String
    let lastClockInfo: String?
    let totalHoursWorked: String?
    let clockInTime: String?
    let clockOutTime: String?
    let onDone: () -> Void
    let onContinueToPOS: (() -> Void)?

    @State private var countdownSeconds: Int = 10
    @State private var isPaused: Bool = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            AppColors.segmentBg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                Spacer()
                ClockResultCardView(
                    mode: mode,
                    currentTime: currentTime,
                    currentDate: currentDate,
                    employeeName: employeeName,
                    employeeRole: employeeRole,
                    lastClockInfo: lastClockInfo,
                    totalHoursWorked: totalHoursWorked,
                    clockInTime: clockInTime,
                    clockOutTime: clockOutTime,
                    isActionState: false,
                    showContinueToPOS: true,
                    onClockAction: nil,
                    onContinueToPOS: onContinueToPOS
                )
                Spacer()
            }

            countdownBadge
        }
        .onAppear { startCountdown() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                calendarIcon
                Text("Clock In/Out")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            Spacer()
            Button(action: onDone) {
                Text("Done")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(AppColors.buttonSecondaryBg)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 80)
        .background(AppColors.pageBgDeep.opacity(0.5))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.line),
            alignment: .bottom
        )
    }

    // MARK: - Countdown Badge

    private var countdownBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                CountdownBadge(
                    seconds: countdownSeconds,
                    isPaused: isPaused,
                    onTogglePause: { isPaused.toggle() }
                )
                .padding(.trailing, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
    }

    // MARK: - Calendar Icon

    private var calendarIcon: some View {
        Image(systemName: "calendar.badge.checkmark")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Countdown Timer

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !isPaused else { return }
            if countdownSeconds > 0 {
                countdownSeconds -= 1
            } else {
                timer?.invalidate()
                onDone()
            }
        }
    }
}

// MARK: - Preview

#Preview("Clock In") {
    LoginClockInOutView(
        mode: .clockIn,
        currentTime: "09:41 AM",
        currentDate: "Thursday, May 22, 2026",
        employeeName: "John Doe",
        employeeRole: "Server",
        lastClockInfo: "May 21, 2026 at 10:32 PM",
        totalHoursWorked: nil,
        clockInTime: nil,
        clockOutTime: nil,
        onDone: {},
        onContinueToPOS: {}
    )
}

#Preview("Clock Out") {
    LoginClockInOutView(
        mode: .clockOut,
        currentTime: "10:41 AM",
        currentDate: "Thursday, May 22, 2026",
        employeeName: "John Doe",
        employeeRole: "Server",
        lastClockInfo: nil,
        totalHoursWorked: "1.00 Hours",
        clockInTime: "09:41 AM",
        clockOutTime: "10:41 AM",
        onDone: {},
        onContinueToPOS: nil
    )
}
