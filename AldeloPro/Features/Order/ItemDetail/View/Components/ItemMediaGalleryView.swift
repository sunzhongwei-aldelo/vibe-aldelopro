//
//  ItemMediaGalleryView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 多图媒体画廊组件

/// 核心媒体展示舱：左侧大图预览 + 右侧纵向缩略图滑动导轨
/// - 左侧大图占约 75% 宽度，展示当前选中的高清主预览图
/// - 右侧缩略导轨占约 25% 宽度，垂直排列所有图片缩略图
/// - 选中项四周套 2pt 品牌蓝框（AppColors.theme），未选中项半透明
struct ItemMediaGalleryView: View {
    /// 所有图片资源名数组
    let imageURLs: [String]
    /// 当前激活的主图索引
    let currentIndex: Int
    /// 是否为 iPad 环境
    let isPad: Bool
    /// 缩略图点击回调（传回被点击的索引）
    let onSelectImage: (Int) -> Void

    /// 主预览图尺寸（正方形）
    private var mainImageSize: CGFloat {
        isPad ? 213 : 160
    }

    /// 缩略图尺寸（正方形）
    private var thumbnailSize: CGFloat {
        isPad ? 47 : 40
    }

    var body: some View {
        HStack(alignment: .top, spacing: isPad ? Spacing.sm : Spacing.xs) {
            mainPreviewImage
            thumbnailRail
        }
    }

    // MARK: - 左侧主预览大图

    /// 当前选中图片的高清放大展示，带弹性切换动画
    private var mainPreviewImage: some View {
        Group {
            if currentIndex < imageURLs.count {
                Image(imageURLs[currentIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: mainImageSize, height: mainImageSize)
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg))
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentIndex)
            }
        }
    }

    // MARK: - 右侧缩略图纵向滑动导轨

    /// 垂直 ScrollView 包裹的缩略图列表，支持溢出时滑动
    private var thumbnailRail: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: isPad ? Spacing.xs : Spacing.xxs) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, url in
                    thumbnailCard(url: url, index: index)
                }
            }
        }
        .frame(width: thumbnailSize + (isPad ? 4 : 4))
        .frame(height: mainImageSize)
    }

    // MARK: - 单个缩略图卡片

    /// 微型正方形缩略图
    /// - 选中态：不透明 + 品牌蓝色 2pt 外框
    /// - 未选中态：半透明 + 极细灰色框线
    private func thumbnailCard(url: String, index: Int) -> some View {
        let isSelected = index == currentIndex
        return Image(url)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: thumbnailSize, height: thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.sm : AppRadius.Mobile.sm))
            .opacity(isSelected ? 1.0 : 0.5)
            .overlay(
                RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.sm : AppRadius.Mobile.sm)
                    .stroke(
                        isSelected ? AppColors.theme : AppColors.line,
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .onTapGesture {
                onSelectImage(index)
            }
    }
}
