//
//  ItemImagesSection.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import SwiftUI

/// 菜单项「图片」区块（最多 5 张，可设封面）。从 AddItemView 抽出的纯展示组件。
struct ItemImagesSection: View {
    @Binding var imageDataList: [Data]
    @Binding var coverImageIndex: Int?
    @FocusState.Binding var focusedField: FocusedField?

    /// 本组件内部的上传弹层开关（仅 UI 局部状态）。
    @State private var showUploadImage: Bool = false

    typealias FocusedField = AddItemView.FocusedField
    
    /// 最多可上传的图片数量。
    private let maxImageCount = 5

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Item Images")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(imageDataList.enumerated()), id: \.offset) { index, data in
                        imageThumbnail(data: data, index: index)
                    }
                    if imageDataList.count < maxImageCount {
                        addImageButton
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showUploadImage) {
            UploadItemImageView { image, useAsCover in
                addImage(image, useAsCover: useAsCover)
            }
            .presentationBackground(.clear)
        }
    }

    private func imageThumbnail(data: Data, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        if coverImageIndex == index {
                            coverBadge
                        }
                    }
                    .cornerRadius(AppRadius.Tablet.sm)
                    .onTapGesture {
                        focusedField = nil
                        setCover(at: index)
                    }
            }
            Button(action: {
                focusedField = nil
                removeImage(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textTertiary)
                    .background(Circle().fill(AppColors.card))
            }
            .padding(Spacing.xxs)
        }
    }

    /// 封面标志：缩略图底部深色半透明条，左对齐 "Cover Image"（对齐 addmenuitem.svg）。
    private var coverBadge: some View {
        Text("Cover Image")
            .font(AppFont.tabletBody4Regular)
            .foregroundColor(AppColors.white100)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xxs)
            .frame(height: 24)
            .background(AppColors.coverBadgeBg)
    }

    private var addImageButton: some View {
        Button(action: {
            focusedField = nil
            showUploadImage = true
        }) {
            VStack {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.primaryNormal)
            }
            .frame(width: 90, height: 90)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.sm)
        }
    }

    // MARK: - Image Actions
    /// 追加一张图片；useAsCover 为真时将其设为封面。
    private func addImage(_ image: UIImage, useAsCover: Bool) {
        guard imageDataList.count < maxImageCount,
              let data = image.jpegData(compressionQuality: 0.8) else { return }
        imageDataList.append(data)
        if useAsCover {
            coverImageIndex = imageDataList.count - 1
        } else if coverImageIndex == nil {
            coverImageIndex = 0
        }
    }

    /// 将指定下标的图片设为封面（封面唯一，点任意图即切换）。
    private func setCover(at index: Int) {
        guard imageDataList.indices.contains(index) else { return }
        coverImageIndex = index
    }

    /// 移除指定下标的图片，并修正封面下标。
    private func removeImage(at index: Int) {
        guard imageDataList.indices.contains(index) else { return }
        imageDataList.remove(at: index)
        if let cover = coverImageIndex {
            if cover == index {
                coverImageIndex = imageDataList.isEmpty ? nil : 0
            } else if cover > index {
                coverImageIndex = cover - 1
            }
        }
    }
}
