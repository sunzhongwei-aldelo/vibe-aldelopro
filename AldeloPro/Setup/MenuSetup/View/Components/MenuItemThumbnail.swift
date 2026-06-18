//
//  MenuItemThumbnail.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import SwiftUI

///MenuSetupView-》item的图片显示： 菜单项目卡片左侧的 64×64 缩略图：有封面图时显示封面，否则显示浅蓝占位符。
struct MenuItemThumbnail: View {
    let coverData: Data?
    var size: CGFloat = 64

    var body: some View {
        Group {
            if let coverData, let uiImage = UIImage(data: coverData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.imagePlaceholderStroke, lineWidth: 1)
        )
    }

    // MARK: - 占位符
    private var placeholder: some View {
        AppColors.imagePlaceholderBg
            .overlay(
                Image(systemName: "photo")
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.primaryLightActive)
            )
    }
}

#Preview {
    HStack(spacing: Spacing.lg) {
        MenuItemThumbnail(coverData: nil)
        MenuItemThumbnail(coverData: nil, size: 90)
    }
    .padding()
}
