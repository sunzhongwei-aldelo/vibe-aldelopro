import SwiftUI

// MARK: - Tip 选项网格
/// 第一排：固定百分比卡片（15% / 10% / 5%）高约 120pt
/// 第二排：No Tip + Custom 高约 80pt
struct TipOptionsGrid: View {
    let options: [TipOption]
    @Binding var selectedTip: TipOption?

    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: Spacing.md) {
            // 第一排：百分比
            HStack(spacing: Spacing.md) {
                ForEach(options) { option in
                    TipOptionCard(
                        option: option,
                        isSelected: isSelected(option),
                        action: { selectedTip = option }
                    )
                }
            }

            // 第二排：No Tip + Custom（更矮）
            HStack(spacing: Spacing.md) {
                TipOptionCard(
                    option: .noTip,
                    isSelected: selectedTip?.id == TipOption.noTip.id,
                    action: { selectedTip = .noTip }
                )
                TipOptionCard(
                    option: .custom(0),
                    isSelected: isCustomSelected,
                    action: { selectedTip = .custom(0) }
                )
            }
        }
    }

    private func isSelected(_ option: TipOption) -> Bool {
        guard let selected = selectedTip else { return false }
        return selected.id == option.id
    }

    private var isCustomSelected: Bool {
        guard let selected = selectedTip else { return false }
        if case .custom = selected { return true }
        return false
    }
}
