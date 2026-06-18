import SwiftUI

// MARK: - Cashier Summary View

struct CashierSummaryView: View {
    let data: CashierSummaryData
    var onViewMoreTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.md) {
            headerRow
            contentRow
        }
        .padding(Spacing.md)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text(data.title)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button {
                onViewMoreTapped?()
            } label: {
                Text("View More")
                    .font(AppFont.tabletH5Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
        }
    }

    // MARK: - Content

    private var contentRow: some View {
        HStack(alignment: .center, spacing: Spacing.xl) {
            donutChart
            legendList
        }
    }

    // MARK: - Donut Chart

    private var donutChart: some View {
        ZStack {
            DonutChartShape(items: data.items)
                .frame(width: 180, height: 180)

            VStack(spacing: Spacing.xxs) {
                Text(data.centerLabel)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.centerSubLabel)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.centerAmountFormatted)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }

    // MARK: - Legend

    private var legendList: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            ForEach(data.items) { item in
                legendRow(item: item)
            }
        }
    }

    private func legendRow(item: CashierSummaryItem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(item.color.opacity(0.8))
                    .frame(width: 12, height: 12)
                Text(item.label)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
            Text(item.amountFormatted)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)
                .padding(.leading, Spacing.md + Spacing.xxs)
        }
    }
}

// MARK: - Donut Chart Shape

private struct DonutChartShape: View {
    let items: [CashierSummaryItem]

    private let baseLineWidth: CGFloat = 20
    private let negativeLineWidthBonus: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - baseLineWidth / 2 - negativeLineWidthBonus / 2

            ZStack {
                // Background ring
                Circle()
                    .stroke(AppColors.pageBgDeep, lineWidth: baseLineWidth)
                    .frame(width: radius * 2, height: radius * 2)

                // Data arcs
                ForEach(Array(arcData.enumerated()), id: \.offset) { index, arc in
                    let lineWidth = baseLineWidth
                    let radius = arc.isNegative
                    ? radius + 10 : radius
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(arc.startAngle),
                            endAngle: .degrees(arc.endAngle),
                            clockwise: false
                        )
                    }
                    .stroke(
                        arc.color.opacity(0.8),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                }
            }
        }
    }

    private var arcData: [ArcSegment] {
        let nonZeroItems = items.filter { abs($0.amount) > 0.001 }
        guard !nonZeroItems.isEmpty else { return [] }

        let totalAbsValue = nonZeroItems.reduce(0.0) { $0 + abs($1.amount) }
        guard totalAbsValue > 0 else { return [] }

        var segments: [ArcSegment] = []
        var currentAngle: Double = -90 // Start from top

        for item in nonZeroItems {
            let proportion = abs(item.amount) / totalAbsValue
            let sweepAngle = proportion * 360.0
            let segment = ArcSegment(
                startAngle: currentAngle,
                endAngle: currentAngle + sweepAngle,
                color: item.color,
                isNegative: item.amount < 0
            )
            segments.append(segment)
            currentAngle += sweepAngle
        }

        return segments
    }
}

// MARK: - Arc Segment

private struct ArcSegment {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    let isNegative: Bool
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        CashierSummaryView(data: .mock)
        CashierSummaryView(data: .mockAllPositive)
    }
    .padding(Spacing.md)
    .background(AppColors.pageBg)
}
