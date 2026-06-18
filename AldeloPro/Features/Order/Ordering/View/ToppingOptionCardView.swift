//
//  ToppingOptionCardView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/09.
//

import SwiftUI

struct ToppingOptionCardView: View {
    let option: PizzaOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let imageName = option.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 66, height: 66)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: AppRadius.Tablet.sm,
                                bottomLeadingRadius: AppRadius.Tablet.sm,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 0
                            )
                        )
                }

                Text(option.name)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(height: 72)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        option.isSelected ? AppColors.primaryNormal : Color.clear,
                        lineWidth: option.isSelected ? 3 : 0
                    )
            )
            .overlay(alignment: .topTrailing) {
                if option.isSelected {
                    badgeGroup
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Badge Group

    @ViewBuilder
    private var badgeGroup: some View {
        ZStack(alignment: .topTrailing) {
            if let title = option.actionTitle {
                actionTitleBadge(title)
                    .alignmentGuide(.trailing) { $0[.trailing] }
                    .alignmentGuide(.top) { $0[.top] }
            }

            checkmarkBadge
                .offset(x: 8, y: -8)
        }
    }

    // MARK: - Checkmark Badge

    private var checkmarkBadge: some View {
        Circle()
            .fill(AppColors.primaryNormal)
            .frame(width: 20, height: 20)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.white100)
            )
            .overlay(
                Circle()
                    .stroke(AppColors.pageBgDeep, lineWidth: 1.5)
            )
    }

    // MARK: - Action Title Badge

    private func actionTitleBadge(_ title: String) -> some View {
        Text(title)
            .font(AppFont.tabletCaption2Regular)
            .foregroundColor(AppColors.white100)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(AppColors.primaryNormal)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: AppRadius.Tablet.sm,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: AppRadius.Tablet.sm
                )
            )
    }
}
