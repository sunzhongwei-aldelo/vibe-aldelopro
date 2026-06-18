import SwiftUI

// MARK: - Data Models

enum WaitlistStatus {
    case texting(String)
    case waiting

    var color: Color {
        switch self {
        case .texting: return AppColors.successNormal
        case .waiting: return AppColors.warningNormal
        }
    }

    var text: String {
        switch self {
        case .texting(let time): return "Texting  \(time)"
        case .waiting: return "Waiting"
        }
    }
}

struct WaitlistItem: Identifiable {
    let id: String
    let name: String
    let partySize: Int
    let waitTime: String
    let note: String?
    let status: WaitlistStatus
}

enum WaitlistTab: String, CaseIterable {
    case waitlist = "Waitlist"
    case reservation = "Reservation"
}

enum TableFilter: String, CaseIterable {
    case all = "All"
    case smallTable = "Small Table"
    case bigTable = "Big Table"
    case roundTable = "Round Table"
}

// MARK: - WaitlistView

struct WaitlistView: View {
    @State private var isFolded = false
    @State private var selectedTab: WaitlistTab = .waitlist
    @State private var selectedFilter: TableFilter = .all
    @State private var selectedItemId: String? = nil
    var onBack: (() -> Void)? = nil

    private let sampleItems: [WaitlistItem] = [
        WaitlistItem(id: "#S01", name: "Malina Chanbers", partySize: 4, waitTime: "1h 32m", note: "Today is a birthday party", status: .texting("36s")),
        WaitlistItem(id: "#B01", name: "New Customer", partySize: 12, waitTime: "45m", note: "Prepare drinks in advance", status: .waiting),
        WaitlistItem(id: "#S02", name: "Malina Chanbers", partySize: 2, waitTime: "39m", note: nil, status: .waiting),
        WaitlistItem(id: "#S03", name: "Malina Chanbers", partySize: 2, waitTime: "33m", note: nil, status: .waiting),
        WaitlistItem(id: "#S04", name: "Malina Chanbers", partySize: 1, waitTime: "10m", note: nil, status: .waiting),
    ]

    var body: some View {
        if isFolded {
            foldedView
        } else {
            expandedView
        }
    }

    // MARK: - Expanded View (Normal)

    private var expandedView: some View {
        VStack(spacing: 0) {
            headerSection
            filterSection
            cellListSection
            Spacer()
            addButton
        }
        .background(AppColors.white100.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Folded View

    private var foldedView: some View {
        VStack(spacing: 0) {
            foldedHeader
            foldedCellList
            Spacer()
            foldedAddButton
        }
        .frame(width: 120)
        .background(AppColors.white100.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { onBack?() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(width: Spacing.xxxl, height: Spacing.xxxl)

                segmentControl

                Spacer()

                foldButton
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)

            HStack(spacing: Spacing.xs) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textPrimary)
                Text("7/19")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.md)
        }
        .background(AppColors.white100)
    }

    private var segmentControl: some View {
        HStack(spacing: 0) {
            ForEach(WaitlistTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    Text(tab.rawValue)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(selectedTab == tab ? AppColors.primaryNormal : AppColors.textSecondary)
                        .frame(height: 44)
                        .padding(.horizontal, Spacing.md)
                        .background(
                            selectedTab == tab
                                ? RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                                    .fill(AppColors.white100)
                                : nil
                        )
                }
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.segmentBg)
        )
    }

    private var foldButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isFolded = true
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .fill(Color(hex: "#F8F8F8"))
                    .frame(width: Spacing.xxxl, height: Spacing.xxxl)
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.black100)
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                filterChip(filter: .all, badgeText: nil, badgeColor: .clear)
                filterChip(filter: .smallTable, badgeText: "Wait: <5m", badgeColor: AppColors.errorNormal)
                filterChip(filter: .bigTable, badgeText: "3 Tables", badgeColor: AppColors.successNormal)
                filterChip(filter: .roundTable, badgeText: "6 Tables", badgeColor: AppColors.successNormal)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.md)
    }

    private func filterChip(filter: TableFilter, badgeText: String?, badgeColor: Color) -> some View {
        Button(action: { selectedFilter = filter }) {
            VStack(spacing: Spacing.xxs) {
                Text(filter.rawValue)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(selectedFilter == filter ? AppColors.primaryNormal : AppColors.black100)

                if let badge = badgeText {
                    Text(badge)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 11)
                                .fill(badgeColor.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .stroke(badgeColor, lineWidth: 1)
                        )
                }
            }
            .frame(minWidth: 78, minHeight: 70)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .fill(selectedFilter == filter ? AppColors.white100 : Color(hex: "#F8F8F8"))
            )
            .overlay(
                selectedFilter == filter
                    ? RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.primaryNormal, lineWidth: 2)
                    : nil
            )
        }
    }

    // MARK: - Cell List

    private var cellListSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sampleItems) { item in
                    WaitlistCell(
                        item: item,
                        isSelected: selectedItemId == item.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedItemId = selectedItemId == item.id ? nil : item.id
                            }
                        },
                        onDelete: {},
                        onNoShow: {},
                        onText: {},
                        onSeat: {}
                    )
                }
            }
        }
    }

    // MARK: - Add Button

    private var addButton: some View {
        VStack(spacing: 0) {
            Button(action: {}) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock.badge.plus")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.buttonPrimaryText)
                    Text("Add Waitlist")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.xxxxxl)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonPrimaryBg)
                )
            }
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xs)
        }
        .background(AppColors.white100)
    }

    // MARK: - Folded Header

    private var foldedHeader: some View {
        VStack(spacing: Spacing.md) {
            Button(action: { onBack?() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: Spacing.xxxl, height: Spacing.xxxl)
            .padding(.top, Spacing.md)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFolded = false
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(Color(hex: "#F8F8F8"))
                        .frame(width: Spacing.xxxl, height: Spacing.xxxl)
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.black100)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Spacing.md)
        .background(AppColors.white100)
    }

    // MARK: - Folded Cell List

    private var foldedCellList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sampleItems) { item in
                    foldedCell(item: item)
                }
            }
        }
    }

    private func foldedCell(item: WaitlistItem) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(item.status.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(item.id)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.black100)

                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "person")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(item.partySize)")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textPrimary)
                }

                Text(item.waitTime)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
            .padding(.leading, Spacing.xs)
            .padding(.vertical, Spacing.sm)

            Spacer()
        }
        .frame(height: 68)
        .background(AppColors.white100)
    }

    // MARK: - Folded Add Button

    private var foldedAddButton: some View {
        VStack(spacing: 0) {
            Button(action: {}) {
                Text("Add")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.xxxxxl)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .fill(AppColors.buttonPrimaryBg)
                    )
            }
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xs)
        }
        .background(AppColors.white100)
    }
}

// MARK: - WaitlistCell

struct WaitlistCell: View {
    let item: WaitlistItem
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onNoShow: () -> Void
    let onText: () -> Void
    let onSeat: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            cellContent
            if isSelected {
                actionButtons
            }
        }
        .background(
            isSelected
                ? AppColors.primaryLight
                : AppColors.white100
        )
        .overlay(
            isSelected
                ? RoundedRectangle(cornerRadius: 0)
                    .stroke(AppColors.primaryNormal, lineWidth: 3)
                : nil
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private var cellContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack {
                Text(item.id)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.black100)

                Spacer()

                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "person")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(item.partySize)")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                Text(item.waitTime)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
            }

            HStack {
                Text(item.name)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                statusLabel
            }

            if let note = item.note {
                Text(note)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.primaryNormal)
                    .padding(.top, Spacing.xxs)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    private var statusLabel: some View {
        HStack(spacing: Spacing.xxs) {
            switch item.status {
            case .texting(let time):
                Text("Texting")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.successNormal)
                Text(time)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.successNormal)
            case .waiting:
                Text("Waiting")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.warningNormal)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            Button(action: onDelete) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(AppColors.errorNormal)
                        .frame(width: Spacing.xxxl, height: Spacing.xxxl)
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.white100)
                }
            }

            Spacer()

            Button(action: onNoShow) {
                Text("No Show")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.black100)
                    .frame(width: 113, height: Spacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                            .fill(Color(hex: "#F8F8F8"))
                    )
            }

            Button(action: onText) {
                Text("Text")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.black100)
                    .frame(width: 93, height: Spacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                            .fill(Color(hex: "#F8F8F8"))
                    )
            }

            Button(action: onSeat) {
                Text("Seat")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.white100)
                    .frame(width: 93, height: Spacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                            .fill(AppColors.buttonPrimaryBg)
                    )
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    let sampleLayout = DiningTableLayout(groups: [
        DiningTableGroupLayout(id: "lobby", name: "Lobby Area", tables: [
            DiningTableLayoutItem(id: "t01", name: "T01", shape: .square, seats: 4, x: 20, y: 120, width: 75, height: 75),
            DiningTableLayoutItem(id: "t02", name: "T02", shape: .round, seats: 4, x: 166, y: 120, width: 75, height: 75),
            DiningTableLayoutItem(id: "t03", name: "T03", shape: .square, seats: 4, x: 312, y: 120, width: 75, height: 75),
            DiningTableLayoutItem(id: "t04", name: "T04", shape: .square, seats: 4, x: 458, y: 120, width: 75, height: 75),
            DiningTableLayoutItem(id: "t05", name: "T05", shape: .square, seats: 6, x: 20, y: 284, width: 122, height: 75),
            DiningTableLayoutItem(id: "t06", name: "T06", shape: .square, seats: 4, x: 191, y: 284, width: 122, height: 75),
            DiningTableLayoutItem(id: "t07", name: "T07", shape: .square, seats: 4, x: 346, y: 284, width: 122, height: 75),
            DiningTableLayoutItem(id: "t08", name: "T08", shape: .round, seats: 8, x: 517, y: 254, width: 136, height: 136),
            DiningTableLayoutItem(id: "t09", name: "T09", shape: .square, seats: 6, x: 731, y: 282, width: 122, height: 75),
            DiningTableLayoutItem(id: "t10", name: "T10", shape: .square, seats: 6, x: 919, y: 282, width: 122, height: 75),
        ]),
        DiningTableGroupLayout(id: "2nd", name: "2nd Floor", tables: [
            DiningTableLayoutItem(id: "t30", name: "T30", shape: .round, seats: 6, x: 100, y: 100, width: 120, height: 120),
            DiningTableLayoutItem(id: "t31", name: "T31", shape: .square, seats: 4, x: 300, y: 100, width: 75, height: 75),
            DiningTableLayoutItem(id: "t32", name: "T32", shape: .square, seats: 2, x: 450, y: 100, width: 75, height: 75),
        ]),
        DiningTableGroupLayout(id: "3rd", name: "3rd Floor", tables: [
            DiningTableLayoutItem(id: "t40", name: "T40", shape: .square, seats: 8, x: 80, y: 80, width: 122, height: 75),
            DiningTableLayoutItem(id: "t41", name: "T41", shape: .round, seats: 10, x: 300, y: 80, width: 150, height: 150),
        ]),
//        DiningTableGroupLayout(id: "outdoor", name: "Outdoor Terrace", tables: []),
//        DiningTableGroupLayout(id: "private", name: "Private Room", tables: []),
//        DiningTableGroupLayout(id: "booth", name: "Booth Area", tables: []),
//        DiningTableGroupLayout(id: "bar", name: "Bar Area", tables: []),
    ])
    
    // Simulated display info - in production this comes from a different data source
    let displayData: [String: DiningTableDisplayInfo] = [
        "t03": DiningTableDisplayInfo(status: .toBeCleared, elapsedTime: "1h 01m"),
        "t04": DiningTableDisplayInfo(status: .reserved, reservationTime: "12:30 PM"),
        "t06": DiningTableDisplayInfo(status: .dining, guestCount: 4, elapsedTime: "42m", customerName: "Chris Washington"),
        "t07": DiningTableDisplayInfo(status: .dining, guestCount: 2, elapsedTime: "1h 01m", customerName: "Chris Washington"),
        "t31": DiningTableDisplayInfo(status: .dining, guestCount: 3, elapsedTime: "25m", customerName: "John Doe"),
        "t32": DiningTableDisplayInfo(status: .reserved, reservationTime: "2:00 PM"),
        "t41": DiningTableDisplayInfo(status: .alert),
    ]
    HStack {
        WaitlistView()
            .frame(maxWidth: 351)
        DiningTableView(layout: sampleLayout) { tableId in
            displayData[tableId] ?? DiningTableDisplayInfo()
        } onTableTap: { groupId, tableId in
            print("Tapped table: \(tableId) in group: \(groupId)")
        }
        
    }
    .background(Color.gray.opacity(0.2))
}
