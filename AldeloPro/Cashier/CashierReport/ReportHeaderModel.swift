import SwiftUI

// MARK: - Report Header Data Model

struct ReportHeaderData {
    let cashierNumber: String
    let employeeName: String
    let expectedDrawerCash: Double
    let drawerNumber: String
    let signInTime: String
    let deviceNumber: String
    let signOutStatus: SignOutStatus
    let lastSyncEntries: [SyncEntry]
    let selectedSyncIndex: Int

    var selectedSyncEntry: SyncEntry? {
        guard selectedSyncIndex >= 0, selectedSyncIndex < lastSyncEntries.count else {
            return nil
        }
        return lastSyncEntries[selectedSyncIndex]
    }
}

// MARK: - Sign Out Status

enum SignOutStatus {
    case stillSignedIn
    case signedOut(time: String)

    var displayText: String {
        switch self {
        case .stillSignedIn:
            return "Still Signed In"
        case .signedOut(let time):
            return time
        }
    }

    var isBadge: Bool {
        switch self {
        case .stillSignedIn:
            return true
        case .signedOut:
            return false
        }
    }
}

// MARK: - Sync Entry

struct SyncEntry: Identifiable {
    let id: String
    let deviceName: String
    let syncTime: String

    var displayTitle: String {
        "\(deviceName) @ \(syncTime)"
    }
}

// MARK: - Mock Data

extension ReportHeaderData {
    static let mock = ReportHeaderData(
        cashierNumber: "787-32",
        employeeName: "Zhang San",
        expectedDrawerCash: 900.00,
        drawerNumber: "1",
        signInTime: "2025-09-09  07:58 PM",
        deviceNumber: "787",
        signOutStatus: .stillSignedIn,
        lastSyncEntries: [
            SyncEntry(
                id: "1",
                deviceName: "Device 1",
                syncTime: "2025-09-08 08:00 PM"
            ),
            SyncEntry(
                id: "2",
                deviceName: "Device 2",
                syncTime: "2025-09-08 06:30 PM"
            ),
            SyncEntry(
                id: "3",
                deviceName: "Device 1",
                syncTime: "2025-09-07 09:15 PM"
            )
        ],
        selectedSyncIndex: 0
    )

    static let mockSignedOut = ReportHeaderData(
        cashierNumber: "787-32",
        employeeName: "Zhang San",
        expectedDrawerCash: 900.00,
        drawerNumber: "1",
        signInTime: "2025-09-09  07:58 PM",
        deviceNumber: "787",
        signOutStatus: .signedOut(time: "2025-09-09  10:30 PM"),
        lastSyncEntries: [
            SyncEntry(
                id: "1",
                deviceName: "Device 1",
                syncTime: "2025-09-08 08:00 PM"
            )
        ],
        selectedSyncIndex: 0
    )
}
