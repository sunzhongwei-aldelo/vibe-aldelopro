import SwiftUI

@Observable
final class OpenHoursViewModel {
    var isUniformWeekly: Bool = false
    var daySchedules: [DaySchedule]
    var uniformTimeRanges: [TimeRange] = [TimeRange()]

    init() {
        self.daySchedules = Weekday.allCases.map { weekday in
            let open = weekday != .tuesday
            return DaySchedule(
                weekday: weekday,
                isOpen: open,
                timeRanges: [TimeRange()],
                isExpanded: open
            )
        }
    }

    func toggleDay(at index: Int) {
        var updated = daySchedules[index]
        updated.isOpen.toggle()
        if !updated.isOpen {
            updated.isExpanded = false
        } else {
            updated.isExpanded = true
        }
        daySchedules[index] = updated
    }

    func toggleExpanded(at index: Int) {
        var updated = daySchedules[index]
        updated.isExpanded.toggle()
        daySchedules[index] = updated
    }

    func addTimeRange(at dayIndex: Int) {
        var updated = daySchedules[dayIndex]
        updated.timeRanges.append(TimeRange())
        daySchedules[dayIndex] = updated
    }

    func removeTimeRange(at dayIndex: Int, rangeIndex: Int) {
        var updated = daySchedules[dayIndex]
        guard updated.timeRanges.count > 1 else { return }
        updated.timeRanges.remove(at: rangeIndex)
        daySchedules[dayIndex] = updated
    }

    func setOpenTime(at dayIndex: Int, rangeIndex: Int, time: Date) {
        var updated = daySchedules[dayIndex]
        updated.timeRanges[rangeIndex] = TimeRange(
            id: updated.timeRanges[rangeIndex].id,
            openTime: time,
            closeTime: updated.timeRanges[rangeIndex].closeTime
        )
        daySchedules[dayIndex] = updated
    }

    func setCloseTime(at dayIndex: Int, rangeIndex: Int, time: Date) {
        var updated = daySchedules[dayIndex]
        updated.timeRanges[rangeIndex] = TimeRange(
            id: updated.timeRanges[rangeIndex].id,
            openTime: updated.timeRanges[rangeIndex].openTime,
            closeTime: time
        )
        daySchedules[dayIndex] = updated
    }

    // MARK: - Uniform Mode

    func addUniformTimeRange() {
        uniformTimeRanges.append(TimeRange())
    }

    func removeUniformTimeRange(rangeIndex: Int) {
        guard uniformTimeRanges.count > 1 else { return }
        uniformTimeRanges.remove(at: rangeIndex)
    }

    func setUniformOpenTime(rangeIndex: Int, time: Date) {
        uniformTimeRanges[rangeIndex] = TimeRange(
            id: uniformTimeRanges[rangeIndex].id,
            openTime: time,
            closeTime: uniformTimeRanges[rangeIndex].closeTime
        )
    }

    func setUniformCloseTime(rangeIndex: Int, time: Date) {
        uniformTimeRanges[rangeIndex] = TimeRange(
            id: uniformTimeRanges[rangeIndex].id,
            openTime: uniformTimeRanges[rangeIndex].openTime,
            closeTime: time
        )
    }

    func confirm() {
        // TODO: Save open hours to backend
    }
}
