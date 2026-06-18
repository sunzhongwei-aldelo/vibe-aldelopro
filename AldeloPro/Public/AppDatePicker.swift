//
//  AppDatePicker.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/03.
//

import SwiftUI

// MARK: - DatePicker Result

/// 日期选择器统一的确认结果。
/// 各 picker 通过 `onConfirm` 回调返回选中的值，调用方不再需要传入 @Binding。
enum DatePickerResult {
    case single(Date)
    case range(start: Date, end: Date)
}

// MARK: - AppDatePicker
struct AppSingleDatePicker: View {
    @State private var selectedDate: Date
    var onConfirm: (Date) -> Void
    var onDismiss: () -> Void

    @State private var displayedYear: Int
    @State private var displayedMonth: Int
    @State private var yearPageIndex: Int = 0

    private let calendar = Calendar.current

    init(
        initialDate: Date = Date(),
        onConfirm: @escaping (Date) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self._selectedDate = State(initialValue: initialDate)
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        let cal = Calendar.current
        self._displayedYear = State(initialValue: cal.component(.year, from: initialDate))
        self._displayedMonth = State(initialValue: cal.component(.month, from: initialDate))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, Spacing.lg)

            HStack(alignment: .top, spacing: Spacing.xxl) {
                yearPanel
                    .frame(maxWidth: .infinity)
                monthPanel
                    .frame(maxWidth: .infinity)
                calendarPanel
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, Spacing.lg)

            bottomBar
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.lg)
        .background(AppColors.card)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppRadius.Tablet.lg,
                topTrailingRadius: AppRadius.Tablet.lg
            )
        )
        .shadow(color: AppColors.black100.opacity(0.08), radius: Spacing.md, x: 0, y: -4)

    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Spacer()
            Text(formattedSelectedDate)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: Spacing.md, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: Spacing.xl, height: Spacing.xl)
            }
        }
    }

    // MARK: - Year Panel

    private var yearPanel: some View {
        DateYearPanel(displayedYear: $displayedYear, yearPageIndex: $yearPageIndex)
    }

    // MARK: - Month Panel

    private var monthPanel: some View {
        DateMonthPanel(displayedMonth: $displayedMonth)
    }

    // MARK: - Calendar Panel

    private var calendarPanel: some View {
        DateCalendarPanel(
            displayedYear: displayedYear,
            displayedMonth: displayedMonth,
            selectionMode: .single(selected: selectedDate),
            onDayTapped: { day in
                selectedDate = day.date
                if !day.isCurrentMonth {
                    displayedMonth = calendar.component(.month, from: day.date)
                    displayedYear = calendar.component(.year, from: day.date)
                }
            }
        )
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: Spacing.lg) {
            Button {
                let now = Date()
                selectedDate = now
                displayedYear = calendar.component(.year, from: now)
                displayedMonth = calendar.component(.month, from: now)
            } label: {
                Text("Today")
                    .font(AppFont.tabletBody1Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 340, height: 64)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            Button {
                onConfirm(selectedDate)
            } label: {
                Text("Confirm")
                    .font(AppFont.tabletBody1Regular)
                    .foregroundColor(AppColors.white100)
                    .frame(width: 340, height: 64)
                    .background(AppColors.primaryNormal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
        }
    }

    // MARK: - Helpers

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: selectedDate)
    }

}

// MARK: - AppDateRangePicker
struct AppDateRangePicker: View {
    @State private var startDate: Date
    @State private var endDate: Date
    var onConfirm: (Date, Date) -> Void
    var onDismiss: () -> Void

    enum ActiveField { case start, end }

    @State private var activeField: ActiveField = .start
    @State private var displayedYear: Int
    @State private var displayedMonth: Int
    @State private var yearPageIndex: Int = 0

    private let calendar = Calendar.current

    init(
        initialStart: Date,
        initialEnd: Date,
        onConfirm: @escaping (Date, Date) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self._startDate = State(initialValue: initialStart)
        self._endDate = State(initialValue: initialEnd)
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        let cal = Calendar.current
        self._displayedYear = State(initialValue: cal.component(.year, from: initialStart))
        self._displayedMonth = State(initialValue: cal.component(.month, from: initialStart))
    }

    var body: some View {
        VStack(spacing: 0) {
            rangeHeader
                .padding(.bottom, Spacing.lg)

            HStack(alignment: .top, spacing: Spacing.xxl) {
                rangeYearPanel
                    .frame(maxWidth: .infinity)
                rangeMonthPanel
                    .frame(maxWidth: .infinity)
                rangeCalendarPanel
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, Spacing.lg)

            rangeBottomBar
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.lg)
        .background(AppColors.card)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppRadius.Tablet.lg,
                topTrailingRadius: AppRadius.Tablet.lg
            )
        )
        .shadow(color: AppColors.black100.opacity(0.08), radius: Spacing.md, x: 0, y: -4)
    }

    // MARK: - Range Header

    private var rangeHeader: some View {
        HStack(spacing: 0) {
            Spacer()
            dateField(date: startDate, isActive: activeField == .start)
                .onTapGesture {
                    activeField = .start
                    navigateToDate(startDate)
                }
            Text("-")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, Spacing.sm)
            dateField(date: endDate, isActive: activeField == .end)
                .onTapGesture {
                    activeField = .end
                    navigateToDate(endDate)
                }
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: Spacing.md, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: Spacing.xl, height: Spacing.xl)
            }
        }
    }

    private func dateField(date: Date, isActive: Bool) -> some View {
        Text(formatDate(date))
            .font(AppFont.tabletH2Medium)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: 319, height: 57)
            .background(isActive ? AppColors.optionSelectedFill : AppColors.buttonSecondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(isActive ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
            )
    }

    // MARK: - Range Year Panel

    private var rangeYearPanel: some View {
        DateYearPanel(displayedYear: $displayedYear, yearPageIndex: $yearPageIndex)
    }

    // MARK: - Range Month Panel

    private var rangeMonthPanel: some View {
        DateMonthPanel(displayedMonth: $displayedMonth)
    }

    // MARK: - Range Calendar Panel

    private var rangeCalendarPanel: some View {
        DateCalendarPanel(
            displayedYear: displayedYear,
            displayedMonth: displayedMonth,
            selectionMode: .range(start: startDate, end: endDate),
            onDayTapped: { day in
                let tappedDate = day.date
                switch activeField {
                case .start:
                    startDate = tappedDate
                    if tappedDate > endDate {
                        endDate = tappedDate
                    }
                    activeField = .end
                case .end:
                    if tappedDate < startDate {
                        startDate = tappedDate
                    } else {
                        endDate = tappedDate
                    }
                }
                if !day.isCurrentMonth {
                    navigateToDate(tappedDate)
                }
            }
        )
    }

    // MARK: - Range Bottom Bar

    private var rangeBottomBar: some View {
        HStack(spacing: Spacing.md) {
            presetButton("Past 6 months") {
                applyPreset(months: -6)
            }
            presetButton("Past 3 months") {
                applyPreset(months: -3)
            }
            presetButton("Past month") {
                applyPreset(months: -1)
            }
            presetButton("Today") {
                let now = Date()
                startDate = now
                endDate = now
                navigateToDate(now)
            }
            Button {
                onConfirm(startDate, endDate)
            } label: {
                Text("Confirm")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.white100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.primaryNormal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
        }
    }

    private func presetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.buttonSecondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(AppColors.buttonSecondaryBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }

    private func navigateToDate(_ date: Date) {
        displayedYear = calendar.component(.year, from: date)
        displayedMonth = calendar.component(.month, from: date)
    }

    private func handleDayTap(_ day: DayModel) {
        let tappedDate = day.date
        switch activeField {
        case .start:
            startDate = tappedDate
            if tappedDate > endDate {
                endDate = tappedDate
            }
            activeField = .end
        case .end:
            if tappedDate < startDate {
                startDate = tappedDate
            } else {
                endDate = tappedDate
            }
        }
        if !day.isCurrentMonth {
            navigateToDate(tappedDate)
        }
    }

    private func applyPreset(months: Int) {
        let now = Date()
        endDate = now
        startDate = calendar.date(byAdding: .month, value: months, to: now) ?? now
        navigateToDate(now)
        activeField = .start
    }

    private func rangeBuildDaysGrid() -> [DayModel] {
        var items: [DayModel] = []

        guard let firstOfMonth = calendar.date(from: DateComponents(year: displayedYear, month: displayedMonth, day: 1)) else {
            return items
        }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        if weekdayOfFirst > 0 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth)!
            let daysInPrev = calendar.range(of: .day, in: .month, for: prevMonth)?.count ?? 30
            for i in (daysInPrev - weekdayOfFirst + 1)...daysInPrev {
                let date = calendar.date(byAdding: .day, value: i - daysInPrev - 1, to: firstOfMonth)!
                items.append(DayModel(number: i, isCurrentMonth: false, date: date))
            }
        }

        for i in 1...daysInMonth {
            let date = calendar.date(from: DateComponents(year: displayedYear, month: displayedMonth, day: i))!
            items.append(DayModel(number: i, isCurrentMonth: true, date: date))
        }

        let totalNeeded = items.count <= 35 ? 35 : 42
        let remaining = totalNeeded - items.count
        if remaining > 0 {
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
            for i in 1...remaining {
                let date = calendar.date(byAdding: .day, value: i - 1, to: nextMonthStart)!
                items.append(DayModel(number: i, isCurrentMonth: false, date: date))
            }
        }

        return items
    }
}

// MARK: - AppTabDatePicker
struct AppTabDatePicker: View {
    enum TabMode { case date, dateRange }

    @State private var selectedDate: Date
    @State private var startDate: Date
    @State private var endDate: Date
    var onConfirm: (DatePickerResult) -> Void
    var onDismiss: () -> Void

    @State private var activeTab: TabMode = .date
    @State private var displayedYear: Int
    @State private var displayedMonth: Int
    @State private var yearPageIndex: Int = 0
    @State private var activeField: RangeField = .start

    enum RangeField { case start, end }

    private let calendar = Calendar.current
    init(
        initialDate: Date = Date(),
        initialStart: Date,
        initialEnd: Date,
        onConfirm: @escaping (DatePickerResult) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self._selectedDate = State(initialValue: initialDate)
        self._startDate = State(initialValue: initialStart)
        self._endDate = State(initialValue: initialEnd)
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        let cal = Calendar.current
        self._displayedYear = State(initialValue: cal.component(.year, from: initialDate))
        self._displayedMonth = State(initialValue: cal.component(.month, from: initialDate))
    }

    var body: some View {
        VStack(spacing: 0) {
            tabHeaderRow
                .padding(.bottom, Spacing.md)

            Group {
                if activeTab == .dateRange {
                    rangeDateFields
                } else {
                    dateTitleRow
                }
            }
            .frame(height: 64)
            .padding(.bottom, Spacing.md)

            HStack(alignment: .top, spacing: Spacing.xxl) {
                tabYearPanel
                    .frame(maxWidth: .infinity)
                tabMonthPanel
                    .frame(maxWidth: .infinity)
                tabCalendarPanel
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, Spacing.lg)

            if activeTab == .date {
                dateBottomBar
            } else {
                rangeBottomBar
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.lg)
        .background(AppColors.card)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppRadius.Tablet.lg,
                topTrailingRadius: AppRadius.Tablet.lg
            )
        )
        .shadow(color: AppColors.black100.opacity(0.08), radius: Spacing.md, x: 0, y: -4)
    }

    // MARK: - Tab Header Row

    private var tabHeaderRow: some View {
        HStack {
            tabBar
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: Spacing.md, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: Spacing.xl, height: Spacing.xl)
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem(title: "Date", isActive: activeTab == .date)
                .onTapGesture { activeTab = .date }
            tabItem(title: "Date Range", isActive: activeTab == .dateRange)
                .onTapGesture { activeTab = .dateRange }
        }
        .padding(Spacing.xxs)
        .background(AppColors.pageBgDeep)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    private func tabItem(title: String, isActive: Bool) -> some View {
        Text(title)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(isActive ? AppColors.primaryNormal : AppColors.textTertiary)
            .frame(width: 195, height: Spacing.xxxxl)
            .background(isActive ? AppColors.card : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    // MARK: - Date Title Row

    private var dateTitleRow: some View {
        HStack {
            Spacer()
            Text(formatDate(selectedDate))
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
    }

    // MARK: - Range Date Fields

    private var rangeDateFields: some View {
        HStack(spacing: 0) {
            rangeDateField(date: startDate, isActive: activeField == .start)
                .onTapGesture {
                    activeField = .start
                    navigateToDate(startDate)
                }
            Text("-")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, Spacing.sm)
            rangeDateField(date: endDate, isActive: activeField == .end)
                .onTapGesture {
                    activeField = .end
                    navigateToDate(endDate)
                }
        }
    }

    private func rangeDateField(date: Date, isActive: Bool) -> some View {
        Text(formatDate(date))
            .font(AppFont.tabletH2Medium)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: 319, height: 57)
            .background(isActive ? AppColors.optionSelectedFill : AppColors.buttonSecondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(isActive ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
            )
    }

    // MARK: - Year Panel

    private var tabYearPanel: some View {
        DateYearPanel(displayedYear: $displayedYear, yearPageIndex: $yearPageIndex)
    }

    // MARK: - Month Panel

    private var tabMonthPanel: some View {
        DateMonthPanel(displayedMonth: $displayedMonth)
    }

    // MARK: - Calendar Panel

    private var tabCalendarPanel: some View {
        let mode: DateSelectionMode = activeTab == .date
            ? .single(selected: selectedDate)
            : .range(start: startDate, end: endDate)
        return DateCalendarPanel(
            displayedYear: displayedYear,
            displayedMonth: displayedMonth,
            selectionMode: mode,
            onDayTapped: { day in
                handleTabDayTap(day)
            }
        )
    }

    // MARK: - Date Bottom Bar

    private var dateBottomBar: some View {
        HStack(spacing: Spacing.md) {
            Button {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
                selectedDate = yesterday
                navigateToDate(yesterday)
            } label: {
                Text("Yesterday")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.buttonSecondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            Button {
                let now = Date()
                selectedDate = now
                navigateToDate(now)
            } label: {
                Text("Today")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.buttonSecondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            Button {
                onConfirm(.single(selectedDate))
            } label: {
                Text("Confirm")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.white100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.primaryNormal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
        }
        .padding(.horizontal, Spacing.xxxl)
    }

    // MARK: - Range Bottom Bar

    private var rangeBottomBar: some View {
        HStack(spacing: Spacing.md) {
            tabPresetButton("All Dates") {
                let cal = calendar
                startDate = cal.date(from: DateComponents(year: 2019, month: 1, day: 1)) ?? Date()
                endDate = Date()
                navigateToDate(endDate)
            }
            tabPresetButton("This Month") {
                let now = Date()
                let cal = calendar
                startDate = cal.date(from: DateComponents(
                    year: cal.component(.year, from: now),
                    month: cal.component(.month, from: now),
                    day: 1
                )) ?? now
                endDate = now
                navigateToDate(now)
            }
            tabPresetButton("Last 7 Days") {
                let now = Date()
                endDate = now
                startDate = calendar.date(byAdding: .day, value: -6, to: now) ?? now
                navigateToDate(now)
            }
            Button {
                onConfirm(.range(start: startDate, end: endDate))
            } label: {
                Text("Confirm")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.white100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.primaryNormal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
        }
        .padding(.horizontal, Spacing.xxxl)
    }

    private func tabPresetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.buttonSecondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(AppColors.buttonSecondaryBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }

    private func navigateToDate(_ date: Date) {
        displayedYear = calendar.component(.year, from: date)
        displayedMonth = calendar.component(.month, from: date)
    }

    private func handleTabDayTap(_ day: DateDayModel) {
        if activeTab == .date {
            selectedDate = day.date
            if !day.isCurrentMonth {
                navigateToDate(day.date)
            }
        } else {
            let tappedDate = day.date
            switch activeField {
            case .start:
                startDate = tappedDate
                if tappedDate > endDate {
                    endDate = tappedDate
                }
                activeField = .end
            case .end:
                if tappedDate < startDate {
                    startDate = tappedDate
                } else {
                    endDate = tappedDate
                }
            }
            if !day.isCurrentMonth {
                navigateToDate(tappedDate)
            }
        }
    }



    private func tabBuildDaysGrid() -> [TabDayModel] {
        var items: [TabDayModel] = []

        guard let firstOfMonth = calendar.date(from: DateComponents(year: displayedYear, month: displayedMonth, day: 1)) else {
            return items
        }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        if weekdayOfFirst > 0 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth)!
            let daysInPrev = calendar.range(of: .day, in: .month, for: prevMonth)?.count ?? 30
            for i in (daysInPrev - weekdayOfFirst + 1)...daysInPrev {
                let date = calendar.date(byAdding: .day, value: i - daysInPrev - 1, to: firstOfMonth)!
                items.append(TabDayModel(number: i, isCurrentMonth: false, date: date))
            }
        }

        for i in 1...daysInMonth {
            let date = calendar.date(from: DateComponents(year: displayedYear, month: displayedMonth, day: i))!
            items.append(TabDayModel(number: i, isCurrentMonth: true, date: date))
        }

        let totalNeeded = items.count <= 35 ? 35 : 42
        let remaining = totalNeeded - items.count
        if remaining > 0 {
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
            for i in 1...remaining {
                let date = calendar.date(byAdding: .day, value: i - 1, to: nextMonthStart)!
                items.append(TabDayModel(number: i, isCurrentMonth: false, date: date))
            }
        }

        return items
    }
}

// MARK: - AppTimePicker， 24h和12h制的time picker
struct AppTimePicker: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    var is24Hour: Bool
    var onConfirm: () -> Void
    var onDismiss: () -> Void

    @State private var isPM: Bool

    private let calendar = Calendar.current
    private let rowHeight: CGFloat = 54
    private let cellHeight: CGFloat = 48

    init(
        selectedHour: Binding<Int>,
        selectedMinute: Binding<Int>,
        is24Hour: Bool = true,
        onConfirm: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self._selectedHour = selectedHour
        self._selectedMinute = selectedMinute
        self.is24Hour = is24Hour
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        self._isPM = State(initialValue: selectedHour.wrappedValue >= 12)
    }

    private var displayHour12: Int {
        let h = selectedHour % 12
        return h == 0 ? 12 : h
    }

    private var formattedTime: String {
        if is24Hour {
            return String(format: "%02d:%02d", selectedHour, selectedMinute)
        } else {
            return "\(displayHour12):\(String(format: "%02d", selectedMinute)) \(isPM ? "PM" : "AM")"
        }
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            timeHeader

            VStack(spacing: 0) {
                pickerColumns
                    .padding(.top, Spacing.xxxl)
                    .padding(.horizontal, Spacing.md)

                Spacer()

                AppColors.line
                    .frame(height: 1)
                    .padding(.horizontal, Spacing.md)

                timeBottomBar
                    .padding(.vertical, Spacing.md)
            }
            .frame(height: 510)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
    }

    // MARK: - Header

    private var timeHeader: some View {
        HStack {
            Text(formattedTime)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary.opacity(0.85))
            Spacer()
            Image(systemName: "clock")
                .font(.system(size: Spacing.lg))
                .foregroundColor(AppColors.primaryNormal)
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 63)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.primaryNormal, lineWidth: 1)
        )
    }

    // MARK: - Picker Columns

    private var pickerColumns: some View {
        HStack(spacing: 0) {
            if is24Hour {
                TimeWheelColumn(
                    selection: $selectedHour,
                    range: 0...23,
                    zeroPadded: true
                )

                Text(":")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: Spacing.lg, height: 54 * 7)

                TimeWheelColumn(
                    selection: $selectedMinute,
                    range: 0...59,
                    zeroPadded: true
                )
            } else {
                TimeWheelColumn(
                    selection: Binding(
                        get: { displayHour12 },
                        set: { newVal in
                            if isPM {
                                selectedHour = newVal == 12 ? 12 : newVal + 12
                            } else {
                                selectedHour = newVal == 12 ? 0 : newVal
                            }
                        }
                    ),
                    range: 1...12,
                    zeroPadded: false
                )

                Text(":")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: Spacing.lg, height: 54 * 7)

                TimeWheelColumn(
                    selection: $selectedMinute,
                    range: 0...59,
                    zeroPadded: true
                )

                Spacer()
                    .frame(width: Spacing.md)

                TimeAMPMColumn(isPM: $isPM) {
                    if isPM && selectedHour < 12 {
                        selectedHour += 12
                    } else if !isPM && selectedHour >= 12 {
                        selectedHour -= 12
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bottom Bar

    private var timeBottomBar: some View {
        HStack(spacing: Spacing.md) {
            Button {
                let now = Date()
                selectedHour = calendar.component(.hour, from: now)
                selectedMinute = calendar.component(.minute, from: now)
                isPM = selectedHour >= 12
            } label: {
                Text("Now")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.buttonSecondaryText)
                    .frame(width: 106, height: 48)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }
            Spacer()
            Button(action: onDismiss) {
                Text("Cancel")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.buttonSecondaryText)
                    .frame(width: 106, height: 48)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }
            Button(action: onConfirm) {
                Text("Confirm")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.white100)
                    .frame(width: 106, height: 48)
                    .background(AppColors.primaryNormal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - TimeWheelColumn

private struct TimeWheelColumn: View {
    @Binding var selection: Int
    let range: ClosedRange<Int>
    let zeroPadded: Bool

    private let visibleCount = 7
    private let rowHeight: CGFloat = 54
    private let cellHeight: CGFloat = 48

    var body: some View {
        VStack(spacing: 0) {
            ForEach(visibleValues(), id: \.self) { value in
                let isSelected = value == selection
                Text(formatValue(value))
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: rowHeight)
                    .background(
                        Group {
                            if isSelected {
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                                    .fill(AppColors.optionSelectedFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                                            .stroke(AppColors.primaryNormal, lineWidth: 1)
                                    )
                                    .frame(height: cellHeight)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selection = value
                    }
            }
        }
    }

    private func formatValue(_ value: Int) -> String {
        zeroPadded ? String(format: "%02d", value) : "\(value)"
    }

    private func visibleValues() -> [Int] {
        let count = range.count
        let offset = visibleCount / 2
        var values: [Int] = []
        for i in -offset...offset {
            var v = selection + i
            while v < range.lowerBound {
                v += count
            }
            while v > range.upperBound {
                v -= count
            }
            values.append(v)
        }
        return values
    }
}

// MARK: - TimeAMPMColumn

private struct TimeAMPMColumn: View {
    @Binding var isPM: Bool
    var onChange: () -> Void

    private let rowHeight: CGFloat = 54
    private let cellHeight: CGFloat = 48

    var body: some View {
        VStack(spacing: 0) {
            if isPM {
                ForEach(0..<2, id: \.self) { _ in
                    Color.clear.frame(height: rowHeight)
                }
                ampmCell("AM", isSelected: false)
                    .onTapGesture {
                        isPM = false
                        onChange()
                    }
                ampmCell("PM", isSelected: true)
                ForEach(0..<3, id: \.self) { _ in
                    Color.clear.frame(height: rowHeight)
                }
            } else {
                ForEach(0..<3, id: \.self) { _ in
                    Color.clear.frame(height: rowHeight)
                }
                ampmCell("AM", isSelected: true)
                ampmCell("PM", isSelected: false)
                    .onTapGesture {
                        isPM = true
                        onChange()
                    }
                ForEach(0..<2, id: \.self) { _ in
                    Color.clear.frame(height: rowHeight)
                }
            }
        }
    }

    private func ampmCell(_ text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(AppFont.tabletBody2Regular)
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                            .fill(AppColors.optionSelectedFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                                    .stroke(AppColors.primaryNormal, lineWidth: 1)
                            )
                            .frame(height: cellHeight)
                    }
                }
            )
            .contentShape(Rectangle())
    }
}

// MARK: - Shared Date Components
struct DateDayModel: Identifiable {
    let id = UUID()
    let number: Int
    let isCurrentMonth: Bool
    let date: Date
}

private typealias DayModel = DateDayModel
private typealias TabDayModel = DateDayModel

enum DateSelectionMode {
    case single(selected: Date)
    case range(start: Date, end: Date)
}

struct DateYearPanel: View {
    @Binding var displayedYear: Int
    @Binding var yearPageIndex: Int
    var totalYearPages: Int = 3

    private var yearsForCurrentPage: [Int] {
        let base = 2019 + yearPageIndex * 12
        return Array(base...(base + 11))
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 4)
            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                ForEach(yearsForCurrentPage, id: \.self) { year in
                    yearCell(year)
                }
            }
            yearPageDots
        }
    }

    private func yearCell(_ year: Int) -> some View {
        let isSelected = year == displayedYear
        let color: Color = {
            if isSelected { return AppColors.white100 }
            if year < displayedYear { return AppColors.textTertiary }
            return AppColors.textPrimary
        }()

        return Text(verbatim: "\(year)")
            .font(AppFont.tabletH5Regular)
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isSelected ? AppColors.primaryNormal : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .onTapGesture {
                displayedYear = year
            }
    }

    private var yearPageDots: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(0..<totalYearPages, id: \.self) { index in
                Circle()
                    .fill(index == yearPageIndex ? AppColors.textPrimary : AppColors.textTertiary)
                    .frame(width: Spacing.xs, height: Spacing.xs)
            }
        }
        .onTapGesture {
            yearPageIndex = (yearPageIndex + 1) % totalYearPages
        }
    }
}

struct DateMonthPanel: View {
    @Binding var displayedMonth: Int

    private let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 4)
        LazyVGrid(columns: columns, spacing: Spacing.lg) {
            ForEach(0..<12, id: \.self) { index in
                monthCell(index)
            }
        }
    }

    private func monthCell(_ index: Int) -> some View {
        let monthNum = index + 1
        let isSelected = monthNum == displayedMonth
        let color: Color = {
            if isSelected { return AppColors.white100 }
            if monthNum < displayedMonth { return AppColors.textTertiary }
            return AppColors.textPrimary
        }()

        return Text(monthNames[index])
            .font(AppFont.tabletH5Regular)
            .foregroundColor(color)
            .frame(width: Spacing.xxxxl, height: Spacing.xxxxl)
            .background(isSelected ? AppColors.primaryNormal : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .onTapGesture {
                displayedMonth = monthNum
            }
    }
}

struct DateCalendarPanel: View {
    var displayedYear: Int
    var displayedMonth: Int
    var selectionMode: DateSelectionMode
    var onDayTapped: (DateDayModel) -> Void

    private let calendar = Calendar.current
    private let weekdayNames = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        VStack(spacing: 0) {
            weekdayHeader
            dayGrid
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdayNames, id: \.self) { name in
                Text(name)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        let days = buildDaysGrid()
        let rowCount = days.count / 7
        let extraPadding = CGFloat(6 - rowCount) * (Spacing.xxl + Spacing.xxs)
        return LazyVGrid(columns: columns, spacing: Spacing.xxs) {
            ForEach(days) { day in
                dayCell(day)
            }
        }
        .padding(.bottom, extraPadding)
    }

    private func dayCell(_ day: DateDayModel) -> some View {
        let textColor: Color
        let bgColor: Color
        let cornerRadius: CGFloat

        switch selectionMode {
        case .single(let selected):
            let isSelected = calendar.isDate(day.date, inSameDayAs: selected) && day.isCurrentMonth
            textColor = {
                if isSelected { return AppColors.white100 }
                if !day.isCurrentMonth { return AppColors.textTertiary }
                return AppColors.textPrimary
            }()
            bgColor = isSelected ? AppColors.primaryNormal : Color.clear
            cornerRadius = AppRadius.Tablet.sm

        case .range(let start, let end):
            let isStart = calendar.isDate(day.date, inSameDayAs: start) && day.isCurrentMonth
            let isEnd = calendar.isDate(day.date, inSameDayAs: end) && day.isCurrentMonth
            let isInRange: Bool = {
                guard day.isCurrentMonth else { return false }
                let startOfStart = calendar.startOfDay(for: start)
                let startOfEnd = calendar.startOfDay(for: end)
                let startOfDay = calendar.startOfDay(for: day.date)
                return startOfDay > startOfStart && startOfDay < startOfEnd
            }()
            textColor = {
                if isStart || isEnd { return AppColors.white100 }
                if !day.isCurrentMonth { return AppColors.textTertiary }
                return AppColors.textPrimary
            }()
            bgColor = {
                if isStart || isEnd { return AppColors.primaryNormal }
                if isInRange { return AppColors.primaryNormal.opacity(0.12) }
                return Color.clear
            }()
            cornerRadius = (isStart || isEnd) ? AppRadius.Tablet.sm : 0
        }

        return Text(verbatim: "\(day.number)")
            .font(AppFont.tabletH5Regular)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.xxl)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle())
            .onTapGesture {
                onDayTapped(day)
            }
    }

    private func buildDaysGrid() -> [DateDayModel] {
        var items: [DateDayModel] = []

        guard let firstOfMonth = calendar.date(from: DateComponents(year: displayedYear, month: displayedMonth, day: 1)) else {
            return items
        }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        if weekdayOfFirst > 0 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth)!
            let daysInPrev = calendar.range(of: .day, in: .month, for: prevMonth)?.count ?? 30
            for i in (daysInPrev - weekdayOfFirst + 1)...daysInPrev {
                let date = calendar.date(byAdding: .day, value: i - daysInPrev - 1, to: firstOfMonth)!
                items.append(DateDayModel(number: i, isCurrentMonth: false, date: date))
            }
        }

        for i in 1...daysInMonth {
            let date = calendar.date(from: DateComponents(year: displayedYear, month: displayedMonth, day: i))!
            items.append(DateDayModel(number: i, isCurrentMonth: true, date: date))
        }

        let totalNeeded = items.count <= 35 ? 35 : 42
        let remaining = totalNeeded - items.count
        if remaining > 0 {
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
            for i in 1...remaining {
                let date = calendar.date(byAdding: .day, value: i - 1, to: nextMonthStart)!
                items.append(DateDayModel(number: i, isCurrentMonth: false, date: date))
            }
        }

        return items
    }
}


// MARK: - Preview
private struct DatePickerPreview: View {
    @State private var date = Date()
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                Spacer()
                AppSingleDatePicker(
                    initialDate: date,
                    onConfirm: { date = $0 },
                    onDismiss: {}
                )
            }
        }
    }
}

private struct DateRangePickerPreview: View {
    @State private var start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var end = Date()
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                Spacer()
                AppDateRangePicker(
                    initialStart: start,
                    initialEnd: end,
                    onConfirm: { start = $0; end = $1 },
                    onDismiss: {}
                )
            }
        }
    }
}

// MARK: - AppTabDatePicker Preview
private struct TabDatePickerPreview: View {
    @State private var date = Date()
    @State private var start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var end = Date()
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                Spacer()
                AppTabDatePicker(
                    initialDate: date,
                    initialStart: start,
                    initialEnd: end,
                    onConfirm: { result in
                        switch result {
                        case .single(let d): date = d
                        case .range(let s, let e): start = s; end = e
                        }
                    },
                    onDismiss: {}
                )
            }
        }
    }
}

// MARK: - AppTimePicker Preview
private struct TimePickerPreview: View {
    @State private var hour = 8
    @State private var minute = 15
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            HStack(spacing: Spacing.xl) {
                AppTimePicker(
                    selectedHour: $hour,
                    selectedMinute: $minute,
                    is24Hour: false,
                    onConfirm: {},
                    onDismiss: {}
                )
                .frame(width: 461)
                AppTimePicker(
                    selectedHour: $hour,
                    selectedMinute: $minute,
                    is24Hour: true,
                    onConfirm: {},
                    onDismiss: {}
                )
                .frame(width: 461)
            }
            .padding()
        }
    }
}

#Preview("AppDatePicker") {
    DatePickerPreview()
}

#Preview("AppDateRangePicker") {
    DateRangePickerPreview()
}

#Preview("AppTabDatePicker") {
    TabDatePickerPreview()
}

#Preview("AppTimePicker") {
    TimePickerPreview()
}
