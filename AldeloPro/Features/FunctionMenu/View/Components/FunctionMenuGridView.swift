import SwiftUI

// MARK: - 功能菜单网格视图
/// 自适应网格布局，根据设备和方向调整列数：
/// - iPad 横屏：6 列
/// - iPad 竖屏：4 列
/// - iPhone 竖屏：2 列

struct FunctionMenuGridView: View {
    let items: [FunctionMenuItem]
    let onItemTap: (FunctionMenuItem) -> Void

    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: columns(for: geo.size), spacing: Spacing.lg) {
                    ForEach(items) { item in
                        FunctionMenuGridItem(item: item) {
                            onItemTap(item)
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.md)
            }
        }
    }

    // MARK: - 自适应列数计算

    private func columns(for size: CGSize) -> [GridItem] {
        let count: Int
        if hSizeClass == .regular {
            // iPad：横屏 6 列，竖屏 4 列
            count = size.width > size.height ? 6 : 4
        } else {
            // iPhone：2 列
            count = 2
        }
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: count)
    }
}
