//
//  MenuGroupCardView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import SwiftUI

struct MenuGroupCardView: View {
    let group: MenuGroup
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(group.name)
                        .font(AppFont.tabletH5Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)

                    Text("\(group.itemCount) Items")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if let imageName = group.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: group.imageName != nil ? 79 : 61)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        isSelected ? AppColors.primaryNormal : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Selected") {
    MenuGroupCardView(
        group: MenuGroup(id: "1", name: "Drinks", itemCount: 12, imageName: nil),
        isSelected: true,
        action: {}
    )
    .frame(width: 215)
    .padding()
    .background(Color(hex: "#E5EAF4"))
}

#Preview("Unselected with Image") {
    MenuGroupCardView(
        group: MenuGroup(id: "2", name: "Hot Dishes", itemCount: 8, imageName: "food_placeholder"),
        isSelected: false,
        action: {}
    )
    .frame(width: 215)
    .padding()
    .background(Color(hex: "#E5EAF4"))
}
