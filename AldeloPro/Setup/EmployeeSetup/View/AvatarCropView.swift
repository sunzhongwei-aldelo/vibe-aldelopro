//
//  AvatarCropView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/05.
//

import SwiftUI

// MARK: - 头像裁剪视图（圆形裁剪 + 缩放/拖拽）

struct AvatarCropView: View {
    let image: UIImage
    var onConfirm: (UIImage) -> Void
    var onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let cropSize: CGFloat = 280

    var body: some View {
        ZStack {
            AppColors.card.ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()

                // Crop area
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cropSize, height: cropSize)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(dragGesture)
                        .gesture(magnificationGesture)
                        .clipShape(Circle())

                    // Circle border
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: cropSize, height: cropSize)
                }
                .frame(width: cropSize, height: cropSize)

                Text("Pinch to zoom, drag to reposition")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textTertiary)

                Spacer()

                // Buttons
                HStack(spacing: Spacing.lg) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(AppFont.tabletButton3Medium)
                            .foregroundColor(AppColors.textEmphasis)
                            .frame(maxWidth: .infinity)
                            .controlHeight(64)
                            .background(AppColors.buttonSecondaryBg)
                            .cornerRadius(AppRadius.Tablet.lg)
                    }

                    Button(action: cropAndConfirm) {
                        Text("Confirm")
                            .font(AppFont.tabletButton3Medium)
                            .foregroundColor(AppColors.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .controlHeight(64)
                            .background(AppColors.buttonPrimaryBg)
                            .cornerRadius(AppRadius.Tablet.lg)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, 1.0), 4.0)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    // MARK: - Crop

    private func cropAndConfirm() {
        let outputSize: CGFloat = 400
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: outputSize, height: outputSize))
        let cropped = renderer.image { ctx in
            let context = ctx.cgContext

            // Circle clip
            context.addEllipse(in: CGRect(x: 0, y: 0, width: outputSize, height: outputSize))
            context.clip()

            // scaledToFill: shorter side fills the crop area
            let imageAspect = image.size.width / image.size.height
            let drawWidth: CGFloat
            let drawHeight: CGFloat
            if imageAspect > 1 {
                // Landscape: height fills
                drawHeight = outputSize
                drawWidth = outputSize * imageAspect
            } else {
                // Portrait: width fills
                drawWidth = outputSize
                drawHeight = outputSize / imageAspect
            }

            let scaledWidth = drawWidth * scale
            let scaledHeight = drawHeight * scale
            let center = outputSize / 2

            let drawRect = CGRect(
                x: center - scaledWidth / 2 + offset.width * (outputSize / cropSize),
                y: center - scaledHeight / 2 + offset.height * (outputSize / cropSize),
                width: scaledWidth,
                height: scaledHeight
            )

            image.draw(in: drawRect)
        }
        onConfirm(cropped)
    }
}
