import SwiftUI

// MARK: - Layout Models (from backend JSON)

enum DiningTableShape: String, Codable {
    case square
    case round
}

struct DiningTableLayoutItem: Identifiable, Codable {
    let id: String
    var name: String
    var shape: DiningTableShape
    var seats: Int
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
}

struct DiningTableGroupLayout: Identifiable, Codable {
    let id: String
    var name: String
    var tables: [DiningTableLayoutItem]
}

struct DiningTableLayout: Codable {
    var groups: [DiningTableGroupLayout]
}

// MARK: - Display Models (runtime state, not from JSON)

enum DiningTableStatus: String {
    case empty
    case reserved
    case toBeCleared
    case dining
    case alert
    
    var color: Color {
        switch self {
        case .empty: return .globalCardBackground
        case .reserved: return Color(hex: "D1D3D7")
        case .toBeCleared: return Color(hex: "007CFF")
        case .dining: return Color(hex: "FFB33F")
        case .alert: return Color(hex: "FF3F3F")
        }
    }
    
    var label: String {
        switch self {
        case .empty: return "Empty"
        case .reserved: return "Reserved"
        case .toBeCleared: return "To Be Cleared"
        case .dining: return "Dining"
        case .alert: return "Alert"
        }
    }
}

struct DiningTableDisplayInfo {
    var status: DiningTableStatus = .empty
    var guestCount: Int?
    var elapsedTime: String?
    var customerName: String?
    var reservationTime: String?
}

// MARK: - View Mode

enum DiningTableViewMode {
    case preview
    case edit
}

// MARK: - Main View

struct DiningTableView: View {
    @State private var layout: DiningTableLayout
    @State private var selectedGroupId: String
    @State private var viewMode: DiningTableViewMode = .preview
    
    // Canvas scroll view
    @State private var scrollViewResetId: UUID = UUID()
    @State private var currentZoomScale: CGFloat = 1.0
    @State private var contentOffset: CGPoint = .zero
    @State private var viewportSize: CGSize = .zero
    
    // Edit mode drag
    @State private var draggingTableId: String?
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartPosition: CGPoint = .zero
    
    // Display info binding
    var displayInfoProvider: (String) -> DiningTableDisplayInfo
    var onTableTap: ((_ groupId: String, _ tableId: String) -> Void)?
    
    private let minimumTableSpacing: CGFloat = 30
    private let canvasPadding: CGFloat = 50
    
    
    private var canvasSize: CGSize {
        guard let group = currentGroup, !group.tables.isEmpty else {
            return CGSize(width: 1000, height: 1000)
        }
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        for table in group.tables {
            let tableRight = table.x + table.width + seatExtension * 2
            let tableBottom = table.y + table.height + seatExtension * 2
            maxX = max(maxX, tableRight)
            maxY = max(maxY, tableBottom)
        }
        return CGSize(
            width: maxX + canvasPadding,
            height: maxY + canvasPadding
        )
    }
    
    init(
        layout: DiningTableLayout,
        displayInfoProvider: @escaping (String) -> DiningTableDisplayInfo = { _ in DiningTableDisplayInfo() },
        onTableTap: ((_ groupId: String, _ tableId: String) -> Void)? = nil
    ) {
        _layout = State(initialValue: layout)
        _selectedGroupId = State(initialValue: layout.groups.first?.id ?? "")
        self.displayInfoProvider = displayInfoProvider
        self.onTableTap = onTableTap
    }
    
    private var currentGroup: DiningTableGroupLayout? {
        layout.groups.first { $0.id == selectedGroupId }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            tableGroupTabs
                .background {
                    Color.globalCardBackground
                }
            ZStack {
                canvasBackground
                tableCanvas
                statusLegend
                if showMinimap {
                    minimapView
                }
            }
        }
    }
    
    private var showMinimap: Bool {
        guard viewportSize != .zero else { return false }
        let scaledCanvasWidth = canvasSize.width * currentZoomScale
        let scaledCanvasHeight = canvasSize.height * currentZoomScale
        return scaledCanvasWidth > viewportSize.width || scaledCanvasHeight > viewportSize.height
    }
    
    // MARK: - Table Group Tabs
    
    private var tableGroupTabs: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(layout.groups) { group in
                        tableGroupTab(group: group)
                    }
                }
            }
            .frame(height: 64)
            .background(Color.red)
            
            zoomControls
        }
    }
    
    private func tableGroupTab(group: DiningTableGroupLayout) -> some View {
        let isSelected = group.id == selectedGroupId
        return Button {
            selectedGroupId = group.id
            currentZoomScale = 1.0
            contentOffset = .zero
            scrollViewResetId = UUID()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02, execute: {
                selectedGroupId = group.id
                currentZoomScale = 1.0
                contentOffset = .zero
                scrollViewResetId = UUID()
            })
        } label: {
            Text(group.name)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "007CFF") : Color(hex: "595959"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minWidth: 120, minHeight: 64)
                .background(
                    isSelected
                    ? Color(hex: "007CFF").opacity(0.08)
                    : Color.globalCardBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Canvas
    
    private var canvasBackground: some View {
        Color.globalBackgroudDarker
//            .ignoresSafeArea()
    }
    
    private var tableCanvas: some View {
        ZoomableCanvasView(
            canvasSize: canvasSize,
            resetId: scrollViewResetId,
            isScrollEnabled: draggingTableId == nil,
            zoomScale: $currentZoomScale,
            contentOffset: $contentOffset,
            viewportSize: $viewportSize
        ) {
            ZStack(alignment: .topLeading) {
                Color.clear
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .coordinateSpace(name: "canvas")
                
                if let group = currentGroup {
                    ForEach(group.tables) { table in
                        let info = displayInfoProvider(table.id)
                        tableView(table: table, info: info)
                            .position(
                                x: table.x + table.width / 2 + 20 + (draggingTableId == table.id ? dragOffset.width : 0),
                                y: table.y + table.height / 2 + (draggingTableId == table.id ? dragOffset.height : 0)
                            )
                    }
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
        }
        .clipped()
    }
    
    // MARK: - Table View
    
    private func tableView(table: DiningTableLayoutItem, info: DiningTableDisplayInfo) -> some View {
        let content = ZStack {
            tableBackground(table: table, status: info.status)
            tableContent(table: table, info: info)
        }
            .frame(width: table.width, height: table.height)
        
        return ZStack {
            seatsView(table: table)
            content
        }
        .frame(
            width: table.width + seatExtension * 2,
            height: table.height + seatExtension * 2
        )
//        .if(viewMode == .edit) { view in
//            view.gesture(
//                
//                LongPressDragGesture(minimumDuration: 0.3, onBegan: { translation in
//                    if draggingTableId != table.id {
//                        draggingTableId = table.id
//                    }
//                }, onChanged: { translation in
//                    dragOffset = translation
//                }, onEnded: { translation in
//                    if let groupIndex = layout.groups.firstIndex(where: { $0.id == selectedGroupId }),
//                       let tableIndex = layout.groups[groupIndex].tables.firstIndex(where: { $0.id == table.id }) {
//                        let newX = table.x + dragOffset.width
//                        let newY = table.y + dragOffset.height
//                        if !hasCollision(
//                            tableId: table.id, newX: newX, newY: newY,
//                            width: table.width, height: table.height,
//                            in: layout.groups[groupIndex].tables
//                        ) {
//                            layout.groups[groupIndex].tables[tableIndex].x = max(0, min(newX, canvasSize.width - table.width))
//                            layout.groups[groupIndex].tables[tableIndex].y = max(0, min(newY, canvasSize.height - table.height))
//                        }
//                    }
//                    draggingTableId = nil
//                    dragOffset = .zero
//                })
//            )
//            
//        }
        .shadow(
            color: draggingTableId == table.id ? Color.black.opacity(0.3) : Color.clear,
            radius: 8, x: 0, y: 4
        )
        .scaleEffect(draggingTableId == table.id ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: draggingTableId)
        .onTapGesture {
            guard viewMode != .edit else { return }
            onTableTap?(selectedGroupId, table.id)
        }
    }
    
    private func tableBackground(table: DiningTableLayoutItem, status: DiningTableStatus) -> some View {
        Group {
            switch table.shape {
            case .square:
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(status.color)
            case .round:
                Circle()
                    .fill(status.color)
            }
        }
    }
    
    private func tableContent(table: DiningTableLayoutItem, info: DiningTableDisplayInfo) -> some View {
        VStack(spacing: 4) {
            Text(table.name)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
            
            if info.status == .dining || info.status == .toBeCleared {
                HStack(spacing: 8) {
                    if let guests = info.guestCount {
                        HStack(spacing: 2) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 9))
                            Text("\(guests)")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "262626"))
                    }
                    if let time = info.elapsedTime {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.system(size: 9))
                            Text(time)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(Color(hex: "262626"))
                    }
                }
            }
            
            if info.status == .reserved, let reservationTime = info.reservationTime {
                HStack(spacing: 2) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                    Text("\(table.seats)")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(Color(hex: "262626"))
                Text(reservationTime)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "262626"))
            }
            
            if let customer = info.customerName {
                Text(customer)
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .padding(8)
    }
    
    // MARK: - Seats
    
    private let seatExtension: CGFloat = 10
    
    private func seatsView(table: DiningTableLayoutItem) -> some View {
        let seatPositions = computeSeatPositions(table: table)
        return ZStack {
            ForEach(Array(seatPositions.enumerated()), id: \.offset) { _, position in
                seatShape(position: position)
            }
        }
        .frame(
            width: table.width + seatExtension * 2,
            height: table.height + seatExtension * 2
        )
    }
    
    private struct SeatPosition {
        let x: CGFloat
        let y: CGFloat
        let rotation: Angle
    }
    
    private func computeSeatPositions(table: DiningTableLayoutItem) -> [SeatPosition] {
        let seats = table.seats
        let ext = seatExtension
        let centerX = (table.width + ext * 2) / 2
        let centerY = (table.height + ext * 2) / 2
        
        switch table.shape {
        case .round:
            let radius = table.width / 2 + ext
            return (0..<seats).map { i in
                let angle = (2 * .pi / Double(seats)) * Double(i) - .pi / 2
                return SeatPosition(
                    x: centerX + radius * cos(angle),
                    y: centerY + radius * sin(angle),
                    rotation: .radians(angle + .pi / 2)
                )
            }
        case .square:
            var positions: [SeatPosition] = []
            let perSide = distributeSeats(total: seats, width: table.width, height: table.height)
            
            for i in 0..<perSide.top {
                let spacing = table.width / CGFloat(perSide.top + 1)
                positions.append(SeatPosition(x: ext + spacing * CGFloat(i + 1), y: 0, rotation: .zero))
            }
            for i in 0..<perSide.bottom {
                let spacing = table.width / CGFloat(perSide.bottom + 1)
                positions.append(SeatPosition(x: ext + spacing * CGFloat(i + 1), y: table.height + ext * 2, rotation: .degrees(180)))
            }
            for i in 0..<perSide.left {
                let spacing = table.height / CGFloat(perSide.left + 1)
                positions.append(SeatPosition(x: 0, y: ext + spacing * CGFloat(i + 1), rotation: .degrees(-90)))
            }
            for i in 0..<perSide.right {
                let spacing = table.height / CGFloat(perSide.right + 1)
                positions.append(SeatPosition(x: table.width + ext * 2, y: ext + spacing * CGFloat(i + 1), rotation: .degrees(90)))
            }
            return positions
        }
    }
    
    private func distributeSeats(total: Int, width: CGFloat, height: CGFloat) -> (top: Int, bottom: Int, left: Int, right: Int) {
        guard total > 0 else { return (0, 0, 0, 0) }
        let isWide = width > height
        switch total {
        case 1: return (1, 0, 0, 0)
        case 2: return (1, 1, 0, 0)
        case 3: return isWide ? (1, 1, 0, 1) : (1, 1, 1, 0)
        case 4: return (1, 1, 1, 1)
        case 5: return isWide ? (2, 2, 0, 1) : (1, 1, 1, 2)
        case 6: return isWide ? (2, 2, 1, 1) : (2, 2, 1, 1)
        case 7: return isWide ? (2, 2, 1, 2) : (2, 2, 2, 1)
        case 8: return isWide ? (2, 2, 2, 2) : (2, 2, 2, 2)
        default:
            let perSide = total / 4
            let remainder = total % 4
            return (
                perSide + (remainder > 0 ? 1 : 0),
                perSide + (remainder > 1 ? 1 : 0),
                perSide + (remainder > 2 ? 1 : 0),
                perSide
            )
        }
    }
    
    private func seatShape(position: SeatPosition) -> some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 7.5,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 7.5,
            style: .continuous
        )
        .fill(Color.globalCardBackground.opacity(0.7))
        .frame(width: 37, height: 15)
        .rotationEffect(position.rotation)
        .position(x: position.x, y: position.y)
    }
    
    // MARK: - Status Legend
    
    private var statusLegend: some View {
        VStack {
            Spacer()
            HStack {
                HStack(spacing: 16) {
                    ForEach([DiningTableStatus.reserved, .toBeCleared, .dining, .alert], id: \.rawValue) { status in
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(status.color)
                                .frame(width: 14, height: 14)
                            Text(status.label)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "595959"))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.globalBackground)
                )
                .clipShape(Capsule())
                .padding(.bottom, 16)
                .padding(.leading, 16)
                Spacer()
            }
        }
    }
    
    // MARK: - Minimap
    
    private let minimapMaxWidth: CGFloat = 160
    private let minimapMaxHeight: CGFloat = 120
    
    private var minimapScale: CGFloat {
        let scaleX = minimapMaxWidth / canvasSize.width
        let scaleY = minimapMaxHeight / canvasSize.height
        return min(scaleX, scaleY)
    }
    
    private var minimapSize: CGSize {
        CGSize(
            width: canvasSize.width * minimapScale,
            height: canvasSize.height * minimapScale
        )
    }
    
    private var minimapViewportRect: CGRect {
        let vpWidth = viewportSize.width / currentZoomScale * minimapScale
        let vpHeight = viewportSize.height / currentZoomScale * minimapScale
        let vpX = contentOffset.x / currentZoomScale * minimapScale
        let vpY = contentOffset.y / currentZoomScale * minimapScale
        return CGRect(x: vpX, y: vpY, width: vpWidth, height: vpHeight)
    }
    
    private var minimapView: some View {
        VStack {
            HStack {
                Spacer()
                ZStack(alignment: .topLeading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.globalBackground.opacity(0.92))
                        .frame(width: minimapSize.width, height: minimapSize.height)
                    
                    // Tables
                    if let group = currentGroup {
                        ForEach(group.tables) { table in
                            let info = displayInfoProvider(table.id)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(info.status.color.opacity(0.8))
                                .frame(
                                    width: max(4, table.width * minimapScale),
                                    height: max(4, table.height * minimapScale)
                                )
                                .offset(
                                    x: table.x * minimapScale,
                                    y: table.y * minimapScale
                                )
                        }
                    }
                    
                    // Viewport indicator
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color(hex: "007CFF"), lineWidth: 1.5)
                        .frame(width: minimapViewportRect.width, height: minimapViewportRect.height)
                        .offset(x: minimapViewportRect.origin.x, y: minimapViewportRect.origin.y)
                }
                .frame(width: minimapSize.width, height: minimapSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                .gesture(minimapDragGesture)
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            Spacer()
        }
    }
    
    private var minimapDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let location = value.location
                let canvasX = location.x / minimapScale
                let canvasY = location.y / minimapScale
                let targetOffsetX = (canvasX - viewportSize.width / currentZoomScale / 2) * currentZoomScale
                let targetOffsetY = (canvasY - viewportSize.height / currentZoomScale / 2) * currentZoomScale
                let maxOffsetX = canvasSize.width * currentZoomScale - viewportSize.width
                let maxOffsetY = canvasSize.height * currentZoomScale - viewportSize.height
                Task { @MainActor in
                    contentOffset = CGPoint(
                        x: max(0, min(targetOffsetX, maxOffsetX)),
                        y: max(0, min(targetOffsetY, maxOffsetY))
                    )
                }
            }
    }
    
    // MARK: - Zoom Controls
    
    private func zoomIn() {
        Task { @MainActor in
            currentZoomScale = min(currentZoomScale + 0.1, 3.0)
        }
    }
    
    private func zoomOut() {
        Task { @MainActor in
            currentZoomScale = max(currentZoomScale - 0.1, 0.3)
        }
    }
    
    private func zoomReset() {
        Task { @MainActor in
            currentZoomScale = 1.0
        }
    }
    
    private var zoomControls: some View {
        HStack(spacing: 0) {
            Button(action: zoomIn) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            
            Button(action: zoomReset) {
                Text("\(Int(currentZoomScale * 100))%")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 56, height: 44)
                    .contentShape(Rectangle())
            }
            
            Button(action: zoomOut) {
                Image(systemName: "minus")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .buttonStyle(.borderless)
        .foregroundColor(Color(hex: "595959"))
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.globalBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.top, 12)
        .padding(.trailing, 12)
        .allowsHitTesting(true)
    }
    
    
    
    // MARK: - Collision Detection
    
    private func hasCollision(tableId: String, newX: CGFloat, newY: CGFloat, width: CGFloat, height: CGFloat, in tables: [DiningTableLayoutItem]) -> Bool {
        let proposedRect = CGRect(
            x: newX - minimumTableSpacing,
            y: newY - minimumTableSpacing,
            width: width + minimumTableSpacing * 2,
            height: height + minimumTableSpacing * 2
        )
        for other in tables where other.id != tableId {
            let otherRect = CGRect(x: other.x, y: other.y, width: other.width, height: other.height)
            if proposedRect.intersects(otherRect) {
                return true
            }
        }
        return false
    }
}

// MARK: - Conditional Modifier

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

// MARK: - Zoomable Canvas (UIScrollView wrapper)

struct ZoomableCanvasView<Content: View>: UIViewRepresentable {
    let canvasSize: CGSize
    let resetId: UUID
    var isScrollEnabled: Bool
    @Binding var zoomScale: CGFloat
    @Binding var contentOffset: CGPoint
    @Binding var viewportSize: CGSize
    @ViewBuilder let content: () -> Content
    
    private let minZoom: CGFloat = 0.3
    private let maxZoom: CGFloat = 3.0
    
    func makeCoordinator() -> Coordinator {
        Coordinator(zoomScale: $zoomScale, contentOffset: $contentOffset, viewportSize: $viewportSize)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minZoom
        scrollView.maximumZoomScale = maxZoom
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = CGRect(origin: .zero, size: canvasSize)
        
        scrollView.addSubview(hostingController.view)
        scrollView.contentSize = canvasSize
        context.coordinator.hostedView = hostingController.view
        context.coordinator.hostingController = hostingController
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content()
        scrollView.isScrollEnabled = isScrollEnabled
        scrollView.pinchGestureRecognizer?.isEnabled = isScrollEnabled
        
        if context.coordinator.lastResetId != resetId {
            context.coordinator.lastResetId = resetId
            context.coordinator.isUpdatingFromSwiftUI = true
            context.coordinator.isUpdatingOffset = true
            context.coordinator.hostedView?.frame = CGRect(origin: .zero, size: canvasSize)
            print(canvasSize)
            scrollView.contentSize = canvasSize
            scrollView.zoomScale = 1.0
            scrollView.contentOffset = .zero
            DispatchQueue.main.async {
                context.coordinator.isUpdatingFromSwiftUI = false
                context.coordinator.isUpdatingOffset = false
                self.zoomScale = 1.0
                self.contentOffset = .zero
            }
        } else if abs(scrollView.zoomScale - zoomScale) > 0.001 {
            context.coordinator.isUpdatingFromSwiftUI = true
            scrollView.setZoomScale(zoomScale, animated: false)
            context.coordinator.isUpdatingFromSwiftUI = false
        } else {
            let currentOffset = scrollView.contentOffset
            if abs(currentOffset.x - contentOffset.x) > 1 || abs(currentOffset.y - contentOffset.y) > 1 {
                context.coordinator.isUpdatingOffset = true
                scrollView.setContentOffset(contentOffset, animated: false)
                context.coordinator.isUpdatingOffset = false
            }
        }
        
        // Update viewport size
        DispatchQueue.main.async {
            let size = scrollView.bounds.size
            if size != .zero && size != self.viewportSize {
                self.viewportSize = size
            }
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostedView: UIView?
        var hostingController: UIHostingController<Content>?
        var lastResetId: UUID?
        var zoomScale: Binding<CGFloat>
        var contentOffset: Binding<CGPoint>
        var viewportSize: Binding<CGSize>
        var isUpdatingFromSwiftUI = false
        var isUpdatingOffset = false
        
        init(zoomScale: Binding<CGFloat>, contentOffset: Binding<CGPoint>, viewportSize: Binding<CGSize>) {
            self.zoomScale = zoomScale
            self.contentOffset = contentOffset
            self.viewportSize = viewportSize
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostedView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard !isUpdatingFromSwiftUI else { return }
            // 提取当前值，避免在异步闭包中捕获 scrollView 导致时序问题
                    let currentZoom = scrollView.zoomScale
                    let currentOffset = scrollView.contentOffset
                    
                    // 使用 async 异步修改状态，避开 SwiftUI 的主更新循环
                    DispatchQueue.main.async { [weak self] in
                        self?.zoomScale.wrappedValue = currentZoom
                        self?.contentOffset.wrappedValue = currentOffset
                    }
            
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard !isUpdatingFromSwiftUI && !isUpdatingOffset else { return }
            let currentOffset = scrollView.contentOffset
                    
                    // 同理，异步更新位移
                    DispatchQueue.main.async { [weak self] in
                        self?.contentOffset.wrappedValue = currentOffset
                    }
        }
    }
}

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
    VStack {
        Color.globalBackground.frame(height: 90)
        DiningTableView(layout: sampleLayout) { tableId in
            displayData[tableId] ?? DiningTableDisplayInfo()
        } onTableTap: { groupId, tableId in
            print("Tapped table: \(tableId) in group: \(groupId)")
        }
        DiningTableBottomBar().frame(height: 40)
    }
    
    
}


// 自定义同时支持长按+拖拽的手势
struct LongPressDragGesture: UIGestureRecognizerRepresentable {
    
    var minimumDuration: Double = 0.3
    var onBegan: (CGPoint) -> Void
    var onChanged: (CGSize) -> Void
    var onEnded: (CGSize) -> Void
    
    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = minimumDuration
        return recognizer
    }
    
    func handleUIGestureRecognizerAction(
        _ recognizer: UILongPressGestureRecognizer,
        context: Context
    ) {
        switch recognizer.state {
        case .began:
            let location = recognizer.location(in: recognizer.view)
            onBegan(location)
        case .changed:
            let location = recognizer.location(in: recognizer.view)
            // 需要自行记录起点
            let translation = context.coordinator.translationFrom(location)
            onChanged(translation)
        case .ended, .cancelled:
            let location = recognizer.location(in: recognizer.view)
            let translation = context.coordinator.translationFrom(location)
            onEnded(translation)
            context.coordinator.reset()
        default:
            break
        }
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        private var startLocation: CGPoint? = nil
        
        func translationFrom(_ location: CGPoint) -> CGSize {
            if startLocation == nil {
                startLocation = location
            }
            let start = startLocation!
            return CGSize(
                width: location.x - start.x,
                height: location.y - start.y
            )
        }
        
        func reset() {
            startLocation = nil
        }
    }
}
