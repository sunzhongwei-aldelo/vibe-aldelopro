//
//  ItemDetailMainView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 餐品详情主视图

/// 统一主框架视图：根据图片数量自动切换单图/多图版式
/// - 单图版式（图97）：标题+价格同行 → 全宽大图 → 文本段落
/// - 多图版式（图96）：标题 "Details" → 左大图+右缩略导轨 → 文本段落
struct ItemDetailMainView: View {
    @Bindable var viewModel: ItemDetailViewModel
    /// 是否为 iPad 环境（控制字体/间距/圆角 Token 分支）
    let isPad: Bool
    /// 关闭按钮回调（iPad 有，iPhone 为 nil 隐藏关闭按钮）
    let onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.hasSingleImage {
                singleImageLayout
            } else {
                multiImageLayout
            }
        }
    }

    // MARK: - 单图版式布局（图97）

    /// 顶部标题行（餐品名 + 价格 + X关闭）→ 全宽主图 → 描述/口味段落
    private var singleImageLayout: some View {
        VStack(spacing: 0) {
            // 标题栏：餐品名与价格同行显示
            ItemDetailHeaderView(
                title: viewModel.itemName,
                price: viewModel.itemPrice,
                isPad: isPad,
                layoutMode: .singleImage,
                onDismiss: onDismiss
            )

            // 可滚动内容区
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    singleImageSection
                    contentSections
                }
            }
        }
    }

    // MARK: - 多图版式布局（图96）

    /// 顶部标题 "Details" → 左右分布画廊（大图+缩略导轨）→ 描述/口味/促销段落
    private var multiImageLayout: some View {
        VStack(spacing: 0) {
            // 标题栏：固定显示 "Details"
            ItemDetailHeaderView(
                title: "Details",
                price: nil,
                isPad: isPad,
                layoutMode: .multiImage,
                onDismiss: onDismiss
            )

            // 可滚动内容区
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    mediaGallerySection
                    contentSections
                }
            }
        }
    }

    // MARK: - 单图区域

    /// 全宽主图，填满卡片宽度，高度按设备适配
    private var singleImageSection: some View {
        Group {
            if let firstURL = viewModel.imageURLs.first {
                Image(firstURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: isPad ? 420 : 240)
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg))
                    .padding(.horizontal, isPad ? Spacing.lg : Spacing.md)
                    .padding(.top, Spacing.md)
            }
        }
    }

    // MARK: - 多图画廊区域

    /// 左侧大图预览 + 右侧纵向缩略导轨 + 餐品名/价格右置
    private var mediaGallerySection: some View {
        HStack(alignment: .top, spacing: isPad ? Spacing.md : Spacing.sm) {
            // 画廊组件（大图 75% + 缩略图 25%）
            ItemMediaGalleryView(
                imageURLs: viewModel.imageURLs,
                currentIndex: viewModel.currentImageIndex,
                isPad: isPad,
                onSelectImage: { viewModel.selectImage(at: $0) }
            )

            // 餐品名称与价格（紧贴画廊右侧）
            VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
                Text(viewModel.itemName)
                    .font(isPad ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                    .foregroundStyle(AppColors.textPrimary)

                Text(viewModel.itemPrice)
                    .font(isPad ? AppFont.tabletH4Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.top, isPad ? Spacing.md : Spacing.sm)
        }
        .padding(.horizontal, isPad ? Spacing.lg : Spacing.md)
        .padding(.top, Spacing.md)
    }

    // MARK: - 结构化文本段落

    /// 商品描述 + 口味定制 + 促销信息（按需渲染）
    private var contentSections: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.xl : Spacing.lg) {
            // 分割线
            Divider()
                .foregroundStyle(AppColors.line)
                .padding(.horizontal, isPad ? Spacing.lg : Spacing.md)

            // 商品描述段落
            SectionDescriptionView(
                description: viewModel.productDescription,
                isPad: isPad
            )

            // 口味与备餐定制列表
            SectionTastePreparationView(
                items: viewModel.tastePreparation,
                isPad: isPad
            )

            // 促销信息（仅在有数据时显示）
            if viewModel.hasPromotions {
                SectionPromotionsView(
                    items: viewModel.promotions,
                    isPad: isPad
                )
            }

            Spacer(minLength: isPad ? Spacing.xl : Spacing.lg)
        }
        .padding(.top, isPad ? Spacing.lg : Spacing.md)
    }
}
