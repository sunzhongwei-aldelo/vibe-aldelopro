//
//  LastSyncStatusModel.swift
//  AldeloPro
//
//  Created by SunZhongwei on 2026/06/18.
//

import Foundation

// MARK: - Device Sync Status

/// 单台设备的同步状态项。
struct DeviceSyncStatus: Identifiable, Equatable {
    let id: String
    /// 设备显示名（如 "Device 1"）
    let deviceName: String
    /// 最近一次同步时间文本（如 "2025-09-08 08:00 PM"）
    let lastSyncTime: String
    /// 是否处于异常状态（异常时列表项右侧显示红色感叹号）
    let hasError: Bool

    /// 列表项展示文本："Device 1 @ 2025-09-08 08:00 PM"
    var displayText: String {
        "\(deviceName) @ \(lastSyncTime)"
    }
}

// MARK: - Last Sync Status Data

/// "Last Sync Status" 弹窗的数据模型。
struct LastSyncStatusData: Equatable {
    let title: String
    let devices: [DeviceSyncStatus]
}

// MARK: - Mock Data

extension LastSyncStatusData {
    static let mock = LastSyncStatusData(
        title: "Last Sync Status",
        devices: [
            DeviceSyncStatus(id: "1", deviceName: "Device 1", lastSyncTime: "2025-09-08 08:00 PM", hasError: false),
            DeviceSyncStatus(id: "2", deviceName: "Device 2", lastSyncTime: "2025-09-07 08:00 PM", hasError: false),
            DeviceSyncStatus(id: "3", deviceName: "Device 3", lastSyncTime: "2025-09-06 08:00 PM", hasError: false),
            DeviceSyncStatus(id: "4", deviceName: "Device 4", lastSyncTime: "2025-09-05 08:00 PM", hasError: false),
            DeviceSyncStatus(id: "5", deviceName: "Device 5", lastSyncTime: "2025-09-04 08:00 PM", hasError: false),
            DeviceSyncStatus(id: "6", deviceName: "Device 6", lastSyncTime: "2025-09-03 08:00 PM", hasError: true),
            DeviceSyncStatus(id: "7", deviceName: "Device 7", lastSyncTime: "2025-09-02 08:00 PM", hasError: true),
            DeviceSyncStatus(id: "8", deviceName: "Device 8", lastSyncTime: "2025-09-01 08:00 PM", hasError: true),
            DeviceSyncStatus(id: "9", deviceName: "Device 9", lastSyncTime: "2025-08-31 08:00 PM", hasError: true),
            DeviceSyncStatus(id: "10", deviceName: "Device 10", lastSyncTime: "2025-08-31 08:00 PM", hasError: true)
        ]
    )
}
