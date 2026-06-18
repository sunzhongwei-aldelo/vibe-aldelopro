//
//  SelectEmployeeFilterView.swift
//  AldeloPro
//
//  Created by SunZhongwei on 2026/06/18.
//

import SwiftUI

/// 订单/员工筛选弹窗：按分组（Bank / Source）展示可单选的 chips，底部 Back / Save 按钮。
/// 自适应：不固定宽高，chips 用 ChipFlowLayout 自动换行，按钮行均分宽度。
struct SelectEmployeeFilterView: View {
    let data: SelectEmployeeFilterData
    let onBack: () -> Void
    let onSave: ([String: String]) -> Void

    /// 当前选中：分组 id -> 选项 id
    @State private var selection: [String: String]

    init(
        data: SelectEmployeeFilterData,
        onBack: @escaping () -> Void,
        onSave: @escaping ([String: String]) -> Void
    ) {
        self.data = data
        self.onBack = onBack
        self.onSave = onSave
        _selection = State(initialValue: data.defaultSelection)
    }

    var body: some View {
        VStack(spacing: 0) {
            groupsSection
            bottomBar
        }
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
    }

    // MARK: - Groups Section

    private var groupsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                ForEach(data.groups) { group in
                    filterGroup(group)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func filterGroup(_ group: FilterGroup) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(group.title)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)

            ChipFlowLayout(spacing: Spacing.sm, lineSpacing: Spacing.sm) {
                ForEach(group.options) { option in
                    chip(group: group, option: option)
                }
            }
        }
    }

    // MARK: - Chip

    private func chip(group: FilterGroup, option: FilterChipOption) -> some View {
        let isSelected = selection[group.id] == option.id

        return Text(option.label)
            .font(AppFont.tabletH5Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .controlHeight(48)
            .background(isSelected ? AppColors.primaryNormal.opacity(0.08) : AppColors.pageBg)
            .cornerRadius(AppRadius.Tablet.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(AppColors.primaryNormal, lineWidth: isSelected ? 1.5 : 0)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selection[group.id] = option.id
            }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppColors.line)
            HStack(spacing: Spacing.md) {
                Button(action: onBack) {
                    Text("Back")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .controlHeight(56)
                        .background(AppColors.pageBg)
                        .cornerRadius(AppRadius.Tablet.md)
                }

                Button {
                    onSave(selection)
                } label: {
                    Text("Save")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.white100)
                        .frame(maxWidth: .infinity)
                        .controlHeight(56)
                        .background(AppColors.primaryNormal)
                        .cornerRadius(AppRadius.Tablet.md)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
    }
}

// MARK: - Flow Layout

/// 简单的流式布局：子视图按行排列，超出宽度自动换行。用于 chips 自适应换行。
struct ChipFlowLayout: Layout {
    var spacing: CGFloat = Spacing.sm
    var lineSpacing: CGFloat = Spacing.sm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: maxWidth, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.reduce(into: CGFloat.zero) { partial, row in
            partial += row.height
        } + lineSpacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    // MARK: Row Computation

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needsNewLine = !current.indices.isEmpty
                && current.width + spacing + size.width > maxWidth
            if needsNewLine {
                rows.append(current)
                current = Row()
            }
            if current.indices.isEmpty {
                current.width = size.width
            } else {
                current.width += spacing + size.width
            }
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty {
            rows.append(current)
        }
        return rows
    }
}

#Preview {
    SelectEmployeeFilterView(
        data: .mock,
        onBack: {},
        onSave: { _ in }
    )
    .frame(width: 600, height: 400)
    .padding()
    .background(AppColors.pageBgDeep)
}
