//
//  ClockResultCardView.swift
//  AldeloExpressPro
//
//  Created by jiangxia on 2026/06/05.
//

import SwiftUI

// MARK: - ClockResultCardView (Shared)

struct ClockResultCardView: View {
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
    let isActionState: Bool
    let showContinueToPOS: Bool
    let onClockAction: (() -> Void)?
    let onContinueToPOS: (() -> Void)?

    private var employeeInitials: String {
        employeeName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }

    var body: some View {
        VStack(spacing: 0) {
            timeSection
            divider
            if isActionState {
                actionSection
            } else {
                successSection
            }
        }
        .frame(maxWidth: 700)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
        .shadow(color: AppColors.black100.opacity(0.04), radius: 12, y: 4)
    }

    // MARK: - Time Section

    private var timeSection: some View {
        VStack(spacing: Spacing.sm) {
            if !isActionState && mode == .clockOut {
                Text("Total Hours Worked")
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
            }

            Text((!isActionState && mode == .clockOut) ? (totalHoursWorked ?? "0.00 Hours") : currentTime)
                .font(AppFont.tabletDisplay1Medium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            if isActionState || mode == .clockIn {
                Text(currentDate)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.top, Spacing.xxl)
        .padding(.bottom, Spacing.xl)
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(AppColors.line)
            .frame(height: 1)
            .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Action Section (Pre-action: avatar + button)

    private var actionSection: some View {
        VStack(spacing: Spacing.lg) {
            blueAvatar
            employeeInfo
            actionButton
            lastClockInfoLabel
        }
        .padding(.top, Spacing.xl)
        .padding(.bottom, Spacing.lg)
    }

    private var blueAvatar: some View {
        ZStack {
            Circle()
                .fill(AppColors.primaryNormal)
                .frame(width: 80, height: 80)
            Text(employeeInitials)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.white100)
        }
    }

    private var actionButton: some View {
        Button(action: { onClockAction?() }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: mode == .clockIn ? "arrow.right.to.line" : "arrow.left.to.line")
                    .font(.system(size: 18, weight: .medium))
                Text(mode == .clockIn ? "Clock In" : "Clock Out")
                    .font(AppFont.tabletH3Medium)
            }
            .foregroundColor(AppColors.buttonPrimaryText)
            .frame(maxWidth: 480)
            .frame(height: 64)
            .background(AppColors.buttonPrimaryBg)
            .cornerRadius(AppRadius.Tablet.lg)
        }
        .buttonStyle(.plain)
    }

    private var lastClockInfoLabel: some View {
        Group {
            if let info = lastClockInfo {
                HStack(spacing: Spacing.xxs) {
                    Text(mode == .clockIn ? "Last clock out:" : "Last clock in:")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textMuted)
                    Text(info)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }

    // MARK: - Success Section (Post-action: checkmark + result)

    private var successSection: some View {
        VStack(spacing: Spacing.md) {
            Text(mode == .clockIn ? "Clocked in successful" : "Clock Out Successful")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, Spacing.xl)

            successCheckmark

            employeeInfo

            if mode == .clockIn {
                clockInBottomSection
            } else {
                clockOutShiftDetail
            }
        }
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Green Checkmark

    private var successCheckmark: some View {
        ZStack {
            Circle()
                .fill(AppColors.successNormal)
                .frame(width: 80, height: 80)
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(AppColors.white100)
        }
    }

    // MARK: - Employee Info

    private var employeeInfo: some View {
        VStack(spacing: Spacing.xs) {
            Text(employeeName)
                .font(AppFont.tabletH3Medium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            Text(employeeRole)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Clock In Bottom

    private var clockInBottomSection: some View {
        VStack(spacing: Spacing.md) {
            if showContinueToPOS, let continueToPOS = onContinueToPOS {
                Button(action: continueToPOS) {
                    Text("Continue to POS")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(maxWidth: 480)
                        .frame(height: 64)
                        .background(AppColors.buttonPrimaryBg)
                        .cornerRadius(AppRadius.Tablet.lg)
                }
                .buttonStyle(.plain)
            }

            if let info = lastClockInfo {
                HStack(spacing: Spacing.xxs) {
                    Text("Last clock out: ")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textMuted)
                    Text(info)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Clock Out Shift Detail

    private var clockOutShiftDetail: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.line)
                .frame(height: 1)
                .padding(.top, Spacing.lg)

            HStack {
                shiftColumn(header: "Shift", value: employeeRole)
                Spacer()
                shiftColumn(header: "Clocked In", value: clockInTime ?? "--")
                Spacer()
                shiftColumn(header: "Clocked Out", value: clockOutTime ?? "--")
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.md)
        }
    }

    private func shiftColumn(header: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(header)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview("Action - Clock In") {
    ClockResultCardView(
        mode: .clockIn,
        currentTime: "09:41 AM",
        currentDate: "Thursday, May 22, 2026",
        employeeName: "John Doe",
        employeeRole: "Server",
        lastClockInfo: "May 21, 2026 at 10:32 PM",
        totalHoursWorked: nil,
        clockInTime: nil,
        clockOutTime: nil,
        isActionState: true,
        showContinueToPOS: false,
        onClockAction: {},
        onContinueToPOS: nil
    )
    .padding()
    .background(AppColors.segmentBg)
}

#Preview("Action - Clock Out") {
    ClockResultCardView(
        mode: .clockOut,
        currentTime: "10:41 AM",
        currentDate: "Thursday, May 22, 2026",
        employeeName: "John Doe",
        employeeRole: "Server",
        lastClockInfo: "May 21, 2026 at 09:41 PM",
        totalHoursWorked: nil,
        clockInTime: nil,
        clockOutTime: nil,
        isActionState: true,
        showContinueToPOS: false,
        onClockAction: {},
        onContinueToPOS: nil
    )
    .padding()
    .background(AppColors.segmentBg)
}

#Preview("Result - Clock In") {
    ClockResultCardView(
        mode: .clockIn,
        currentTime: "09:41 AM",
        currentDate: "Thursday, May 22, 2026",
        employeeName: "John Doe",
        employeeRole: "Server",
        lastClockInfo: "May 21, 2026 at 10:32 PM",
        totalHoursWorked: nil,
        clockInTime: nil,
        clockOutTime: nil,
        isActionState: false,
        showContinueToPOS: true,
        onClockAction: nil,
        onContinueToPOS: {}
    )
    .padding()
    .background(AppColors.segmentBg)
}

#Preview("Result - Clock Out") {
    ClockResultCardView(
        mode: .clockOut,
        currentTime: "10:41 AM",
        currentDate: "Thursday, May 22, 2026",
        employeeName: "John Doe",
        employeeRole: "Server",
        lastClockInfo: nil,
        totalHoursWorked: "1.00 Hours",
        clockInTime: "09:41 AM",
        clockOutTime: "10:41 AM",
        isActionState: false,
        showContinueToPOS: false,
        onClockAction: nil,
        onContinueToPOS: nil
    )
    .padding()
    .background(AppColors.segmentBg)
}
