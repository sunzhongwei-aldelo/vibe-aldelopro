//
//  MenuItemCardView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import SwiftUI

enum MenuItemLayout {
    case largeImage   // large image on top, text overlaid at bottom
    case thumbnail    // small image left, text right
    case textTall     // no image, spacious vertical spacing
    case textCompact  // no image, tight vertical spacing
}

struct MenuItemCardView: View {
    let item: MenuItem
    let layout: MenuItemLayout
    let orderedQuantity: Int
    let action: () -> Void

    init(item: MenuItem, layout: MenuItemLayout = .textCompact, orderedQuantity: Int = 0, action: @escaping () -> Void) {
        self.item = item
        self.layout = layout
        self.orderedQuantity = orderedQuantity
        self.action = action
    }

    private var isSoldOut: Bool { item.status == .soldOut }

    var body: some View {
        Button(action: action) {
            Group {
                switch layout {
                case .largeImage:
                    largeImageContent
                case .thumbnail:
                    thumbnailContent
                case .textTall:
                    textTallContent
                case .textCompact:
                    textCompactContent
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(alignment: .topTrailing) { quantityBadge }
            .overlay(alignment: .center) { soldOutStamp }
            .overlay(alignment: .bottomTrailing) { stockBadge }
        }
        .buttonStyle(.plain)
        .disabled(isSoldOut)
    }

    // MARK: - Large Image Layout

    private var largeImageContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageName = item.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppColors.pageBgDeep)
                    .frame(height: 120)
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.name)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textPrimary)
                    .lineLimit(1)

                Text(item.displayPrice)
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
        }
    }

    // MARK: - Thumbnail Layout

    private var thumbnailContent: some View {
        HStack(spacing: Spacing.sm) {
            if let imageName = item.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.name)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textPrimary)
                    .lineLimit(1)

                Text(item.displayPrice)
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.sm)
    }

    // MARK: - Text Tall Layout

    private var textTallContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.name)
                .font(AppFont.tabletH5Medium)
                .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(item.displayPrice)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textSecondary)
                .lineLimit(1)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
    }

    // MARK: - Text Compact Layout

    private var textCompactContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(item.name)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textPrimary)
                .lineLimit(1)

            Text(item.displayPrice)
                .font(AppFont.tabletCaption2Regular)
                .foregroundColor(isSoldOut ? AppColors.textTertiary : AppColors.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Image (legacy helper)

    private func itemImage(_ name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - Quantity Badge

    @ViewBuilder
    private var quantityBadge: some View {
        if orderedQuantity > 0 {
            Text("\u{00D7} \(orderedQuantity)")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.white100)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, 2)
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

    // MARK: - Sold Out Stamp

    @ViewBuilder
    private var soldOutStamp: some View {
        if isSoldOut {
            Text("Sold Out")
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.errorNormal)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(AppColors.white100.opacity(0.9))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.errorNormal, lineWidth: 1.5)
                )
                .rotationEffect(.degrees(-12))
        }
    }

    // MARK: - Stock Badge

    @ViewBuilder
    private var stockBadge: some View {
        if case .lowStock(let count) = item.status {
            Text("In Stock: \(count)")
                .font(AppFont.tabletCaption2Regular)
                .foregroundColor(AppColors.errorNormal)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, 2)
                .background(AppColors.errorLight)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                .offset(x: -Spacing.xs, y: -Spacing.xs)
        }
    }
}

// MARK: - Preview

#Preview("Large Image") {
    MenuItemCardView(
        item: MenuItem(id: "1", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 5),
        layout: .largeImage,
        action: {}
    )
    .frame(width: 200)
    .padding()
    .background(Color(hex: "#E5EAF4"))
}

#Preview("Thumbnail") {
    MenuItemCardView(
        item: MenuItem(id: "1", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 5),
        layout: .thumbnail,
        action: {}
    )
    .frame(width: 200)
    .padding()
    .background(Color(hex: "#E5EAF4"))
}

#Preview("Text Tall") {
    MenuItemCardView(
        item: MenuItem(id: "1", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 5),
        layout: .textTall,
        action: {}
    )
    .frame(width: 200)
    .padding()
    .background(Color(hex: "#E5EAF4"))
}

#Preview("Text Compact") {
    MenuItemCardView(
        item: MenuItem(id: "1", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 5),
        layout: .textCompact,
        action: {}
    )
    .frame(width: 200)
    .padding()
    .background(Color(hex: "#E5EAF4"))
}
