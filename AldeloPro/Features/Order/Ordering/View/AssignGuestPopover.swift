//
//  AssignGuestPopover.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import SwiftUI

// MARK: - 分配客人弹窗


/// 将菜品分配给指定客人的弹出选择器
/// 以列表形式展示当前桌位的所有客人，点击即分配
struct AssignGuestPopover: View {
    let guests: [String]
    let onSelect: (String) -> Void
    var maxVisibleCount: Int = 3

    private let itemHeight: CGFloat = 63
    private let itemSpacing: CGFloat = Spacing.md

    private var listHeight: CGFloat {
        let count = CGFloat(min(guests.count, maxVisibleCount))
        return count * itemHeight + (count - 1) * itemSpacing
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Assign Guest")
                .font(AppFont.tabletH5Medium)
                .foregroundColor(AppColors.black100)

            ScrollView(showsIndicators: true) {
                VStack(spacing: Spacing.md) {
                    ForEach(guests, id: \.self) { guest in
                        Button {
                            onSelect(guest)
                        } label: {
                            Text(guest)
                                .font(AppFont.tabletH3Medium)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Spacing.md)
                                .frame(height: itemHeight)
                                .background(AppColors.white100)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                                        .stroke(AppColors.line, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: listHeight)
        }
        .padding(Spacing.md)
        .frame(width: 229)
        .background(AppColors.numpadPanelBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .shadow(color: AppColors.black20, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("Assign Guest Popover") {
    AssignGuestPopover(
        guests: ["Guest 1", "Guest 2", "Guest 3"],
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.pageBg)
}

