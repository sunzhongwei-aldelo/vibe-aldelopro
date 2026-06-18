//
//  HoldView.swift
//  AldeloPro
//
//  Created by LiZong on 2026/06/11.
//

import SwiftUI

struct HoldView: View {
    let itemName: String
    var maxQuantity: Int?
    @Binding var isPresented: Bool
    @State private var showDatePicker = false
    var getHoldDateTime: ((Double?,Int?) -> Void)?
    
    @Environment(AppUIManager.self) private var uiManager: AppUIManager?

    @State private var holdMode: HoldMode = .time
    @State private var holdDate: Date = Date()
    @State private var hourText: String = "03"
    @State private var minuteText: String = "00"
    @State private var isAM: Bool = true
    @State private var holdQuantity: Int = 1
    @State private var activeField: ActiveField = .hour
    @State private var isFlashingError: Bool = false
    @State private var flashTask: Task<Void, Never>?
    @State private var presets: [String] = []
    @State private var durationText: String = "30"
    @State private var durationUnit: DurationUnit = .minute
    private var isOrderHold :Bool {
        maxQuantity == nil
    }
    
    enum HoldMode: String, CaseIterable {
        case duration = "Duration"
        case time = "Time"
    }

    enum ActiveField {
        case hour, minute, quantity, duration
    }

    enum DurationUnit {
        case minute, hour

        /// The toggled (opposite) unit, used by the "⇄ Hour / Minute" switch button.
        var toggled: DurationUnit {
            self == .minute ? .hour : .minute
        }

        /// Label shown on the unit switch button — names the unit it will switch TO.
        var switchLabel: String {
            self == .minute ? "Hour" : "Minute"
        }
    }

    private var resolvedMaxQuantity: Int {
        max(maxQuantity ?? 1, 1)
    }

    var body: some View {
        dialogCard
            .task { initializeFromCurrentTime() }
            .onAppear {
                uiManager?.coverDismissed =  {
                    isPresented = false
                }
            }
    }

    // MARK: - Dialog Card

    private var dialogCard: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(AppColors.line)
            contentSection
            Divider().background(AppColors.line)
            bottomButtons
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        .frame(maxWidth: 1104, maxHeight: 872)
        .padding(Spacing.lg)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Text("\(itemName) Hold")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Button { isPresented = false } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Content

    private var contentSection: some View {
        HStack(alignment: .top, spacing: Spacing.xl) {
            leftPanel
            numpadPanel
        }
        .padding(Spacing.lg)
    }

    // MARK: - Left Panel

    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            segmentControl
            if holdMode == .time {
                dateRow
                holdUntilTimeSection
                quickPresets
            } else {
                durationSection
                durationPresets
                holdUntilHintRow
            }
            if isOrderHold == false {
                quantitySection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var segmentControl: some View {
        HStack(spacing: 0) {
            ForEach(HoldMode.allCases, id: \.self) { mode in
                Button {
                    holdMode = mode
                    activeField = (mode == .duration) ? .duration : .hour
                } label: {
                    Text(mode.rawValue)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(holdMode == mode ? AppColors.primaryNormal : AppColors.black60)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(holdMode == mode ? AppColors.card : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
                }
            }
        }
        .padding(Spacing.xxs)
        .background(AppColors.segmentBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    private var dateRow: some View {
        HStack {
            Text(formattedDate)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.black80)

            Spacer()

            Button {
//                showDatePicker.toggle()
                uiManager?.showDatePicker(.single(initial: holdDate, onConfirm: { newDate in
                    holdDate = newDate
                }))
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textSecondary)
            }


        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 64)
        .background(AppColors.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    private var holdUntilTimeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Hold Until Time")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: Spacing.sm) {
                timeInputField
                amPmToggle
            }
        }
    }

    private var timeInputField: some View {
        HStack(spacing: Spacing.xs) {
            Button { activeField = .hour } label: {
                Text(hourText)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 56, height: 56)
                    .background(activeField == .hour ? AppColors.primaryLight : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
            }

            Text(":")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)

            Button { activeField = .minute } label: {
                Text(minuteText)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 56, height: 56)
                    .background(activeField == .minute ? AppColors.primaryLight : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
            }
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 63)
        .background(AppColors.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(activeField == .hour || activeField == .minute ? AppColors.primaryNormal : AppColors.line, lineWidth: 1)
        )
    }

    private var amPmToggle: some View {
        HStack(spacing: 0) {
            Button { isAM = true } label: {
                Text("AM")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(isAM ? AppColors.primaryNormal : AppColors.black60)
                    .frame(width: 88, height: 56)
                    .background(isAM ? AppColors.card : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
            }

            Button { isAM = false } label: {
                Text("PM")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(!isAM ? AppColors.primaryNormal : AppColors.black60)
                    .frame(width: 88, height: 56)
                    .background(!isAM ? AppColors.card : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
            }
        }
        .padding(Spacing.xxs)
        .background(AppColors.segmentBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    private var quickPresets: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(presets, id: \.self) { preset in
                Button {
                    applyPreset(preset)
                } label: {
                    Text(preset)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .frame(height: 43)
                        .background(AppColors.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.line, lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Duration Mode (Left Panel)

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Hold Time (\(durationUnit == .minute ? "Minute" : "Hour"))")
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button {
                    durationUnit = durationUnit.toggled
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textPrimary)
                        Text(durationUnit.switchLabel)
                            .font(AppFont.tabletH4Medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .frame(height: 43)
                    .background(AppColors.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.line, lineWidth: 1))
                }
            }

            Button { activeField = .duration } label: {
                Text(durationText.isEmpty ? "0" : durationText)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md)
                    .frame(height: 63)
                    .background(AppColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .stroke(activeField == .duration ? AppColors.primaryNormal : AppColors.line, lineWidth: 1)
                    )
            }
        }
    }

    private var durationPresets: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(durationPresetValues, id: \.self) { value in
                Button {
                    durationText = String(value)
                    activeField = .duration
                } label: {
                    Text(String(value))
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(minWidth: 65)
                        .frame(height: 43)
                        .background(AppColors.card)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.line, lineWidth: 1))
                }
            }
        }
    }

    private var holdUntilHintRow: some View {
        HStack(spacing: 0) {
            Text("Hold Until ")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(durationHoldUntilText)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Qty to Apply Item Hold On")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: Spacing.sm) {
                Button {
                    if holdQuantity > 1 { holdQuantity -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 64, height: 64)
                        .background(AppColors.inputBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }

                Button { activeField = .quantity } label: {
                    Text("\(holdQuantity)")
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 63)
                        .background(AppColors.inputBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                .stroke(activeField == .quantity ? AppColors.primaryNormal : AppColors.line, lineWidth: 1)
                        )
                }

                Button {
                    if holdQuantity < resolvedMaxQuantity { holdQuantity += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(holdQuantity >= resolvedMaxQuantity ? AppColors.black20 : AppColors.textPrimary)
                        .frame(width: 64, height: 64)
                        .background(AppColors.inputBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }
            }
        }
    }

    // MARK: - Numpad

    private var numpadPanel: some View {
        VStack(spacing: Spacing.lg) {
            ForEach(0..<4) { row in
                HStack(spacing: Spacing.lg) {
                    ForEach(0..<3) { col in
                        numpadButton(row: row, col: col)
                    }
                }
            }
        }
        .frame(width: 494)
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(isFlashingError ? AppColors.errorLight : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .stroke(AppColors.errorNormal.opacity(isFlashingError ? 1 : 0), lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.18), value: isFlashingError)
    }

    @ViewBuilder
    private func numpadButton(row: Int, col: Int) -> some View {
        let keys: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["delete", "0", "Clear"]
        ]
        let key = keys[row][col]

        Button {
            handleNumpadInput(key)
        } label: {
            Group {
                if key == "delete" {
                    Image(systemName: "delete.backward")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.textPrimary)
                } else if key == "Clear" {
                    Text(key)
                        .font(AppFont.tabletDisplay3Medium)
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    Text(key)
                        .font(AppFont.tabletDisplay1Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            bottomButton(title: "Cancel", style: .secondary) {
                isPresented = false
            }
            bottomButton(title: "Remove Hold", style: .secondary) {
                // TODO: Remove hold action
                isPresented = false
                getHoldDateTime?(nil,holdQuantity)
            }
            bottomButton(title: "Manual Hold", style: .secondary) {
                // TODO: Manual hold action
                isPresented = false
                getHoldDateTime?(Double(Int64.max),holdQuantity)
            }
            bottomButton(title: "Confirm", style: .primary) {
                getHoldDateTime?(resolvedHoldDate.timeIntervalSince1970, holdQuantity)
                isPresented = false
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private enum ButtonStyle {
        case primary, secondary
    }

    private func bottomButton(title: String, style: ButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(style == .primary ? AppColors.buttonPrimaryText : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(style == .primary ? AppColors.buttonPrimaryBg : AppColors.inputBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    // MARK: - Logic

    /// Seeds the time fields and quick presets from the current time when the
    /// dialog appears: the hour/minute fields show "now", and the three presets
    /// offer now +30 / +60 / +90 minutes.
    private func initializeFromCurrentTime() {
        let now = Date()
        holdDate = now
        let (h, m, am) = Self.clockComponents(from: now)
        hourText = String(format: "%02d", h)
        minuteText = String(format: "%02d", m)
        isAM = am

        let calendar = Calendar.current
        presets = [30, 60, 90].map { minutes in
            let target = calendar.date(byAdding: .minute, value: minutes, to: now) ?? now
            return Self.presetFormatter.string(from: target)
        }
    }

    /// Converts a `Date` into 12-hour clock components (hour 1...12, minute, isAM).
    private static func clockComponents(from date: Date) -> (hour: Int, minute: Int, isAM: Bool) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour24 = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let isAM = hour24 < 12
        var hour12 = hour24 % 12
        if hour12 == 0 { hour12 = 12 }
        return (hour12, minute, isAM)
    }

    private static let presetFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()

    /// Resolves the absolute hold target `Date` for the current mode.
    /// - Time mode: the selected day combined with the entered 12-hour clock time.
    /// - Duration mode: now plus the entered duration.
    private var resolvedHoldDate: Date {
        if holdMode == .duration {
            return Calendar.current.date(byAdding: .minute, value: durationMinutes, to: Date()) ?? Date()
        }
        let hour12 = Int(hourText) ?? 0
        let minute = Int(minuteText) ?? 0
        var hour24 = hour12 % 12
        if !isAM { hour24 += 12 }
        return Calendar.current.date(
            bySettingHour: hour24,
            minute: minute,
            second: 0,
            of: holdDate
        ) ?? holdDate
    }

    // MARK: - Duration Mode Logic

    /// Quick-pick values for the duration presets, depending on the active unit.
    private var durationPresetValues: [Int] {
        durationUnit == .minute ? [15, 30, 45, 60, 90] : [1, 2, 3, 4, 6]
    }

    /// The entered duration normalized to minutes.
    private var durationMinutes: Int {
        let value = Int(durationText) ?? 0
        return durationUnit == .hour ? value * 60 : value
    }

    /// Formatted "hold until" clock time = now + the entered duration.
    private var durationHoldUntilText: String {
        let target = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: Date()) ?? Date()
        return Self.presetFormatter.string(from: target)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM / dd"
        let dateStr = formatter.string(from: holdDate)
        let calendar = Calendar.current
        if calendar.isDateInToday(holdDate) {
            return "\(dateStr) (Today)"
        }
        return dateStr
    }

    private func applyPreset(_ preset: String) {
        let parts = preset.split(separator: " ")
        guard parts.count == 2 else { return }
        let timeParts = parts[0].split(separator: ":")
        guard timeParts.count == 2 else { return }
        hourText = String(timeParts[0])
        minuteText = String(timeParts[1])
        isAM = parts[1] == "AM"
    }

    private func handleNumpadInput(_ key: String) {
        switch activeField {
        case .hour:
            handleTimeInput(key: key, text: &hourText, maxValue: 12)
        case .minute:
            handleTimeInput(key: key, text: &minuteText, maxValue: 59)
        case .quantity:
            handleQuantityInput(key: key)
        case .duration:
            handleDurationInput(key: key)
        }
    }

    private func handleDurationInput(key: String) {
        switch key {
        case "delete":
            if !durationText.isEmpty { durationText.removeLast() }
        case "Clear":
            durationText = ""
        default:
            let newText = durationText == "0" ? key : durationText + key
            // Cap at 4 digits to keep the value sane (e.g. minutes/hours).
            if newText.count <= 4, Int(newText) != nil {
                durationText = newText
            } else {
                triggerErrorFlash()
            }
        }
    }

    private func handleTimeInput(key: String, text: inout String, maxValue: Int) {
        switch key {
        case "delete":
            if !text.isEmpty {
                text.removeLast()
            }
        case "Clear":
            text = "00"
        default:
            let newText = text == "00" ? key : text + key
            if newText.count <= 2, let val = Int(newText), val <= maxValue {
                text = newText
            } else {
                triggerErrorFlash()
            }
        }
    }

    private func handleQuantityInput(key: String) {
        switch key {
        case "delete":
            let str = String(holdQuantity)
            if str.count > 1 {
                holdQuantity = Int(String(str.dropLast())) ?? 1
            } else {
                holdQuantity = 0
            }
        case "Clear":
            holdQuantity = 1
        default:
            if let digit = Int(key) {
                let newVal = holdQuantity * 10 + digit
                if newVal <= resolvedMaxQuantity {
                    holdQuantity = newVal
                } else {
                    triggerErrorFlash()
                }
            }
        }
    }

    /// Flash the numpad background red briefly to signal that the last input
    /// was rejected for exceeding the allowed maximum value.
    private func triggerErrorFlash() {
        flashTask?.cancel()
        isFlashingError = true
        flashTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            if !Task.isCancelled {
                isFlashingError = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HoldView(
        itemName: "Cocktail",
        maxQuantity: 10,
        isPresented: .constant(true)
    )
}
