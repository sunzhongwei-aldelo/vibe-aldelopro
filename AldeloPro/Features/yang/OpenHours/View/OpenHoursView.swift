import SwiftUI

struct OpenHoursView: View {
    @State private var viewModel = OpenHoursViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            scrollContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
        .background(AppColors.pageBg) 
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "clock")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Open Hours")
                    .font(AppFont.tabletH4Medium)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            HeaderActionButtons(
                onBack: { dismiss() },
                onConfirm: { viewModel.confirm() }
            )
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                settingsSection
                contentSection
            }
            .padding(.horizontal, Spacing.xx166)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.lg)
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Open Hours Settings")
                .font(AppFont.tabletH6Medium)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: Spacing.sm) {
                Text("Uniform Weekly Open Hours")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundStyle(AppColors.textSecondary)
                Toggle("", isOn: $viewModel.isUniformWeekly)
                    .labelsHidden()
                    .tint(AppColors.primaryNormal)
            }
        }
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(viewModel.isUniformWeekly ? "Default Weekly Open Hours" : "Daily Open Hours")
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)

            if viewModel.isUniformWeekly {
                uniformCard
            } else {
                ForEach(Array(viewModel.daySchedules.enumerated()), id: \.element.id) { index, schedule in
                    DayScheduleCard(
                        schedule: schedule,
                        onToggleDay: { viewModel.toggleDay(at: index) },
                        onToggleExpanded: { viewModel.toggleExpanded(at: index) },
                        onAddTimeRange: { viewModel.addTimeRange(at: index) },
                        onRemoveTimeRange: { rangeIndex in
                            viewModel.removeTimeRange(at: index, rangeIndex: rangeIndex)
                        },
                        onSetOpenTime: { rangeIndex, time in
                            viewModel.setOpenTime(at: index, rangeIndex: rangeIndex, time: time)
                        },
                        onSetCloseTime: { rangeIndex, time in
                            viewModel.setCloseTime(at: index, rangeIndex: rangeIndex, time: time)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Uniform Card

    private var uniformCard: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(Array(viewModel.uniformTimeRanges.enumerated()), id: \.element.id) { rangeIndex, range in
                TimeRangeRow(
                    range: range,
                    onSetOpen: { time in viewModel.setUniformOpenTime(rangeIndex: rangeIndex, time: time) },
                    onSetClose: { time in viewModel.setUniformCloseTime(rangeIndex: rangeIndex, time: time) },
                    onDelete: { viewModel.removeUniformTimeRange(rangeIndex: rangeIndex) },
                    canDelete: viewModel.uniformTimeRanges.count > 1
                )
            }
            addButton { viewModel.addUniformTimeRange() }
        }
        .padding(Spacing.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    private func addButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                Text("Add")
                    .font(AppFont.tabletCaption1Regular)
            }
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(AppColors.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(AppColors.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Day Schedule Card

private struct DayScheduleCard: View {
    let schedule: DaySchedule
    let onToggleDay: () -> Void
    let onToggleExpanded: () -> Void
    let onAddTimeRange: () -> Void
    let onRemoveTimeRange: (Int) -> Void
    let onSetOpenTime: (Int, Date) -> Void
    let onSetCloseTime: (Int, Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            dayHeader
            if schedule.isOpen && schedule.isExpanded {
                timeRangesContent
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    private var dayHeader: some View {
        HStack(spacing: Spacing.xs) {
            Text(schedule.weekday.displayName)
                .font(AppFont.tabletH6Medium)
                .foregroundStyle(AppColors.textPrimary)

            Text(schedule.isOpen ? "Open" : "Close")
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)

            Toggle("", isOn: Binding(
                get: { schedule.isOpen },
                set: { _ in onToggleDay() }
            ))
                .labelsHidden()
                .tint(AppColors.primaryNormal)

            Spacer()

            if schedule.isOpen {
                Button(action: onToggleExpanded) {
                    Image(systemName: schedule.isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
    }

    private var timeRangesContent: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(Array(schedule.timeRanges.enumerated()), id: \.element.id) { rangeIndex, range in
                TimeRangeRow(
                    range: range,
                    onSetOpen: { time in onSetOpenTime(rangeIndex, time) },
                    onSetClose: { time in onSetCloseTime(rangeIndex, time) },
                    onDelete: { onRemoveTimeRange(rangeIndex) },
                    canDelete: schedule.timeRanges.count > 1
                )
            }

            Button(action: onAddTimeRange) {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                    Text("Add")
                        .font(AppFont.tabletCaption1Regular)
                }
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.bottom, Spacing.sm)
    }
}

// MARK: - Time Range Row

private struct TimeRangeRow: View {
    let range: TimeRange
    let onSetOpen: (Date) -> Void
    let onSetClose: (Date) -> Void
    let onDelete: () -> Void
    let canDelete: Bool

    @State private var showOpenPicker = false
    @State private var showClosePicker = false

    var body: some View {
        HStack(spacing: Spacing.xs) {
            timeField(
                placeholder: "Open Time",
                time: range.openTime,
                showPicker: $showOpenPicker
            )

            Text("-")
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)

            timeField(
                placeholder: "Close Time",
                time: range.closeTime,
                showPicker: $showClosePicker
            )

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(width: 34, height: 34)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .opacity(canDelete ? 1 : 0.3)
            .disabled(!canDelete)
        }
        .sheet(isPresented: $showOpenPicker) {
            TimePickerSheet(selectedTime: range.openTime) { time in
                onSetOpen(time)
            }
            .presentationDetents([.height(320)])
            .presentationBackground(.white)
        }
        .sheet(isPresented: $showClosePicker) {
            TimePickerSheet(selectedTime: range.closeTime) { time in
                onSetClose(time)
            }
            .presentationDetents([.height(320)])
            .presentationBackground(.white)
        }
    }

    private func timeField(placeholder: String, time: Date?, showPicker: Binding<Bool>) -> some View {
        Button { showPicker.wrappedValue = true } label: {
            HStack {
                if let time {
                    Text(time.formatted(date: .omitted, time: .shortened))
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundStyle(AppColors.textPrimary)
                } else {
                    Text(placeholder)
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundStyle(AppColors.inputPlaceholder)
                }
                Spacer()
                Image(systemName: "clock")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.inputPlaceholder)
            }
            .padding(.horizontal, Spacing.sm)
            .frame(height: 34)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
    }
}

// MARK: - Time Picker Sheet

private struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    @State private var isAM: Bool
    let onConfirm: (Date) -> Void

    init(selectedTime: Date?, onConfirm: @escaping (Date) -> Void) {
        let calendar = Calendar.current
        if let time = selectedTime {
            let hour = calendar.component(.hour, from: time)
            let minute = calendar.component(.minute, from: time)
            _selectedHour = State(initialValue: hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour))
            _selectedMinute = State(initialValue: minute)
            _isAM = State(initialValue: hour < 12)
        } else {
            _selectedHour = State(initialValue: 8)
            _selectedMinute = State(initialValue: 0)
            _isAM = State(initialValue: true)
        }
        self.onConfirm = onConfirm
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text(formattedTime)
                    .font(AppFont.tabletH5Medium)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.primaryNormal)
            }
            .padding(.horizontal, Spacing.sm)
            .frame(height: 36)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.primaryNormal, lineWidth: 1.5)
            )

            HStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: Spacing.xxs) {
                            ForEach(1...12, id: \.self) { hour in
                                Text("\(hour)")
                                    .font(AppFont.tabletCaption1Regular)
                                    .foregroundStyle(selectedHour == hour ? AppColors.primaryNormal : AppColors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(
                                        selectedHour == hour ? AppColors.primaryLight : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
                                    .id(hour)
                                    .onTapGesture { selectedHour = hour }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear { proxy.scrollTo(selectedHour, anchor: .center) }
                }

                Text(":")
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, Spacing.xxs)

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: Spacing.xxs) {
                            ForEach(Array(stride(from: 0, through: 59, by: 5)), id: \.self) { minute in
                                minuteCell(minute)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear { proxy.scrollTo(selectedMinute, anchor: .center) }
                }

                VStack(spacing: Spacing.xxs) {
                    ampmButton(label: "AM", selected: isAM) { isAM = true }
                    ampmButton(label: "PM", selected: !isAM) { isAM = false }
                }
                .frame(width: 44)
            }
            .frame(height: 150)

            HStack {
                Button("Now") { setNow() }
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(AppColors.pageBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))

                Spacer()

                Button("Cancel") { dismiss() }
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, Spacing.sm)

                Button("Confirm") { confirmSelection() }
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(AppColors.primaryNormal)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            }
        }
        .padding(Spacing.md)
        .background(.white)
    }


    private func minuteCell(_ minute: Int) -> some View {
        let label = String(format: "%02d", minute)
        let isSelected = selectedMinute == minute
        return Text(label)
            .font(AppFont.tabletCaption1Regular)
            .foregroundStyle(isSelected ? AppColors.primaryNormal : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xxs)
            .background(isSelected ? AppColors.primaryLight : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
            .id(minute)
            .onTapGesture { selectedMinute = minute }
    }
    private var formattedTime: String {
        let suffix = isAM ? "AM" : "PM"
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(suffix)"
    }

    private func ampmButton(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(selected ? AppColors.primaryNormal : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.xxs)
                .background(selected ? AppColors.primaryLight : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
        }
    }

    private func setNow() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        isAM = hour < 12
        selectedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        selectedMinute = (minute / 5) * 5
    }

    private func confirmSelection() {
        var hour = selectedHour
        if !isAM && hour != 12 { hour += 12 }
        if isAM && hour == 12 { hour = 0 }

        var components = DateComponents()
        components.hour = hour
        components.minute = selectedMinute
        if let date = Calendar.current.date(from: components) {
            onConfirm(date)
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    OpenHoursView()
}
