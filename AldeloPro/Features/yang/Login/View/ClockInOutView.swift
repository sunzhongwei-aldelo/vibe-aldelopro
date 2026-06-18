import SwiftUI

// MARK: - ClockInOut View

struct ClockInOutView: View {
    @StateObject private var viewModel = ClockInOutViewModel()

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#E5EAF4")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                topBar

                // Divider
                Rectangle()
                    .fill(Color(hex: "#E0E0E0"))
                    .frame(height: 1)

                // Tab Selector
                tabSelector
                    .padding(.top, 12)

                // Content
                contentArea
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Left: Clock In/Out
            HStack(spacing: 12) {
                calendarIcon
                Text("Clock In/Out")
                    .font(AppFont.tabletDisplay5Semibold)
                    .foregroundColor(Color(hex: "#262626"))
            }
            .padding(.leading, 24)

            Spacer()
 
            // Right: Back Button
            Button {
                viewModel.back()
            } label: {
                Text("Back")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 120, height: 40)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }
            .padding(.trailing, 24)
        }
        .frame(height: 80)
        .padding(.top, 32)
    }

    // MARK: - Calendar Icon

    private var calendarIcon: some View {
        Image(systemName: "calendar")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color(hex: "#262626"))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabItem(tab: .passcode, icon: "passcode")
            tabItem(tab: .faceRecognition, icon: "faceRecognition")
        }
        .padding(4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#6B7785"), lineWidth: 1)
        )
        .padding(.horizontal, 170)
    }

    private func tabItem(tab: ClockInOutTab, icon: String) -> some View {
        let isSelected = viewModel.selectedTab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedTab = tab
            }
        } label: {
            HStack(spacing: 8) {
                tabIcon(tab: tab, isSelected: isSelected)
                Text(tab.rawValue)
                    .font(
                        isSelected ? AppFont.tabletButton3Medium : AppFont.tabletButton3Regular)
                    .foregroundColor(isSelected ? AppColors.primaryNormal : Color(hex: "#808080"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(isSelected ? Color.white : Color.clear)
            .cornerRadius(4)
        }
    }

    @ViewBuilder
    private func tabIcon(tab: ClockInOutTab, isSelected: Bool) -> some View {
        let color = isSelected ? AppColors.primaryNormal : Color(hex: "#808080")

        switch tab {
        case .passcode:
            passcodeIcon(color: color)
        case .faceRecognition:
            faceIcon(color: color)
        }
    }

    // MARK: - Passcode Icon

    private func passcodeIcon(color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .stroke(color, lineWidth: 1.8)
                .frame(width: 19, height: 14)
            VStack(spacing: 3) {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 0.5)
                            .fill(color)
                            .frame(width: i == 2 ? 4 : 1, height: 1.5)
                    }
                }
                RoundedRectangle(cornerRadius: 0.5)
                    .fill(color)
                    .frame(width: 11, height: 1.5)
            }
        }
    }

    // MARK: - Face Icon

    private func faceIcon(color: Color) -> some View {
        ZStack {
            // Corner brackets
            faceCornerBrackets(color: color)

            // Face outline (oval)
            Ellipse()
                .stroke(color, lineWidth: 1.8)
                .frame(width: 14, height: 16)

            // Eye line
            Rectangle()
                .fill(color)
                .frame(width: 20, height: 1.5)

            // Smile
            smilePath(color: color)
        }
        .frame(width: 22, height: 22)
    }

    private func faceCornerBrackets(color: Color) -> some View {
        ZStack {
            // Top-left
            Path { p in
                p.move(to: CGPoint(x: 0, y: 6))
                p.addLine(to: CGPoint(x: 0, y: 2))
                p.addQuadCurve(to: CGPoint(x: 2, y: 0), control: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 6, y: 0))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))

            // Top-right
            Path { p in
                p.move(to: CGPoint(x: 16, y: 0))
                p.addLine(to: CGPoint(x: 20, y: 0))
                p.addQuadCurve(to: CGPoint(x: 22, y: 2), control: CGPoint(x: 22, y: 0))
                p.addLine(to: CGPoint(x: 22, y: 6))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))

            // Bottom-left
            Path { p in
                p.move(to: CGPoint(x: 0, y: 16))
                p.addLine(to: CGPoint(x: 0, y: 20))
                p.addQuadCurve(to: CGPoint(x: 2, y: 22), control: CGPoint(x: 0, y: 22))
                p.addLine(to: CGPoint(x: 6, y: 22))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))

            // Bottom-right
            Path { p in
                p.move(to: CGPoint(x: 22, y: 16))
                p.addLine(to: CGPoint(x: 22, y: 20))
                p.addQuadCurve(to: CGPoint(x: 20, y: 22), control: CGPoint(x: 22, y: 22))
                p.addLine(to: CGPoint(x: 16, y: 22))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
        }
    }

    private func smilePath(color: Color) -> some View {
        Path { p in
            p.move(to: CGPoint(x: 9, y: 15))
            p.addQuadCurve(
                to: CGPoint(x: 13, y: 15),
                control: CGPoint(x: 11, y: 17)
            )
        }
        .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.selectedTab {
        case .passcode:
            PasscodeView(viewModel: viewModel)
        case .faceRecognition:
            FaceRecognitionView(viewModel: viewModel)
        }
    }
}

// MARK: - Preview

#Preview {
    ClockInOutView()
}
