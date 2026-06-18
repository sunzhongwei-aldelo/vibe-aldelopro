//
//  CropImagePreview.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/15.
//

import SwiftUI

/// 静态图裁切预览：裁切框固定居中（16:9 最大内接），图片可单指平移 + 双指捏合缩放（系统相册裁切风格）。
/// 图片充满整个容器（四边均被图覆盖），框外区域统一加半透明暗色蒙版；四角蓝色 L 形角标 + 上/下短横标示裁切边界。
/// 手势结束后将已钳制的 offset/scale 通过 `onTransformCommit` 回传，由 ViewModel 反算裁切区域。
struct CropImagePreview: View {
    // MARK: - Props
    let image: UIImage
    /// 报告裁切框尺寸 + 充满容器的基准比例（scale=1 时图恰好覆盖容器），供 ViewModel 反算 cropRect。
    let onGeometryResolved: (_ frameSize: CGSize, _ baseFillScale: CGFloat) -> Void
    /// 手势结束后回传已钳制的 (offset, scale)。
    let onTransformCommit: (CGSize, CGFloat) -> Void

    // MARK: - UI State
    @State private var committedOffset: CGSize = .zero
    @State private var committedScale: CGFloat = 1
    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1

    // MARK: - Constants
    private static let minScale: CGFloat = 1
    private static let maxScale: CGFloat = 4
    private static let frameInset = Spacing.md
    private static let cropStrokeWidth: CGFloat = 3
    private static let cropCornerArm: CGFloat = 32
    private let aspectRatio: CGFloat = 16.0 / 9.0

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let frameSize = cropFrameSize(in: geo.size)
            let fillScale = baseFillScale(containerSize: geo.size)
            ZStack {
                imageLayer(fillScale: fillScale, containerSize: geo.size)
                scrim(frameSize: frameSize)
                cropFrame(width: frameSize.width, height: frameSize.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(combinedGesture(frameSize: frameSize, fillScale: fillScale))
            .onAppear { onGeometryResolved(frameSize, fillScale) }
            .onChange(of: geo.size) { _, newValue in
                onGeometryResolved(cropFrameSize(in: newValue), baseFillScale(containerSize: newValue))
            }
        }
    }

    // MARK: - Layers

    /// 图片层：按「充满容器」基准比例渲染并居中，平移/缩放后裁到容器大小（四边均有图，框外由蒙版压暗）。
    private func imageLayer(fillScale: CGFloat, containerSize: CGSize) -> some View {
        let imageSize = image.size
        let displayWidth = max(1, imageSize.width * fillScale)
        let displayHeight = max(1, imageSize.height * fillScale)
        return Image(uiImage: image)
            .resizable()
            .frame(width: displayWidth, height: displayHeight)
            .scaleEffect(committedScale * magnifyBy)
            .offset(x: committedOffset.width + dragTranslation.width,
                    y: committedOffset.height + dragTranslation.height)
            .frame(width: containerSize.width, height: containerSize.height)
            .clipped()
    }

    /// 框外半透明暗色蒙版（even-odd 挖出 16:9 透明窗口），四边一致。
    private func scrim(frameSize: CGSize) -> some View {
        GeometryReader { g in
            Path { path in
                path.addRect(CGRect(origin: .zero, size: g.size))
                let frame = CGRect(
                    x: (g.size.width - frameSize.width) / 2,
                    y: (g.size.height - frameSize.height) / 2,
                    width: frameSize.width,
                    height: frameSize.height
                )
                path.addRoundedRect(
                    in: frame,
                    cornerSize: CGSize(width: AppRadius.Tablet.sm, height: AppRadius.Tablet.sm)
                )
            }
            .fill(AppColors.black40, style: FillStyle(eoFill: true))
        }
        .allowsHitTesting(false)
    }

    // MARK: - 16:9 Crop Frame（蓝色四角 + 上/下短横）

    private func cropFrame(width: CGFloat, height: CGFloat) -> some View {
        Color.clear
            .frame(width: width, height: height)
            .overlay(alignment: .topLeading) { cornerBracket(rotation: 0) }
            .overlay(alignment: .topTrailing) { cornerBracket(rotation: 90) }
            .overlay(alignment: .bottomTrailing) { cornerBracket(rotation: 180) }
            .overlay(alignment: .bottomLeading) { cornerBracket(rotation: 270) }
            .overlay(alignment: .top) { edgeBar().offset(y: -Self.cropStrokeWidth / 2) }
            .overlay(alignment: .bottom) { edgeBar().offset(y: Self.cropStrokeWidth / 2) }
            .allowsHitTesting(false)
    }

    private func cornerBracket(rotation: Double) -> some View {
        CornerMarkShape()
            .stroke(AppColors.primaryNormal, lineWidth: Self.cropStrokeWidth)
            .frame(width: Self.cropCornerArm, height: Self.cropCornerArm)
            .rotationEffect(.degrees(rotation))
    }

    private func edgeBar() -> some View {
        Rectangle()
            .fill(AppColors.primaryNormal)
            .frame(width: Self.cropCornerArm, height: Self.cropStrokeWidth)
    }

    // MARK: - Geometry

    /// 容器内居中、最大内接的 16:9 裁切框尺寸（四周留 inset）。
    private func cropFrameSize(in container: CGSize) -> CGSize {
        let inset = Self.frameInset
        let availableWidth = max(0, container.width - inset * 2)
        let availableHeight = max(0, container.height - inset * 2)
        var width = availableWidth
        var height = availableWidth / aspectRatio
        if height > availableHeight {
            height = availableHeight
            width = availableHeight * aspectRatio
        }
        return CGSize(width: width, height: height)
    }

    /// 「充满容器」基准比例：scale=1 时图片恰好覆盖整个容器（四边均有图，框一定被覆盖）。
    private func baseFillScale(containerSize: CGSize) -> CGFloat {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return 1 }
        return max(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
    }

    // MARK: - Gestures

    private func combinedGesture(frameSize: CGSize, fillScale: CGFloat) -> some Gesture {
        let drag = DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let raw = CGSize(
                    width: committedOffset.width + value.translation.width,
                    height: committedOffset.height + value.translation.height
                )
                commit(offset: raw, scale: committedScale, frameSize: frameSize, fillScale: fillScale)
            }

        let magnify = MagnifyGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                commit(offset: committedOffset, scale: committedScale * value.magnification,
                       frameSize: frameSize, fillScale: fillScale)
            }

        return SimultaneousGesture(drag, magnify)
    }

    private func commit(offset rawOffset: CGSize, scale rawScale: CGFloat, frameSize: CGSize, fillScale: CGFloat) {
        let scale = min(max(rawScale, Self.minScale), Self.maxScale)
        let offset = clampedOffset(rawOffset, scale: scale, frameSize: frameSize, fillScale: fillScale)
        committedScale = scale
        committedOffset = offset
        onTransformCommit(offset, scale)
    }

    /// 钳制平移量，保证裁切框内始终是图（与 ViewModel 反算口径一致）。
    private func clampedOffset(_ raw: CGSize, scale: CGFloat, frameSize: CGSize, fillScale: CGFloat) -> CGSize {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let contentWidth = imageSize.width * fillScale * scale
        let contentHeight = imageSize.height * fillScale * scale
        let slackX = max(0, (contentWidth - frameSize.width) / 2)
        let slackY = max(0, (contentHeight - frameSize.height) / 2)
        return CGSize(
            width: min(max(raw.width, -slackX), slackX),
            height: min(max(raw.height, -slackY), slackY)
        )
    }
}

// MARK: - Corner Mark Shape

/// 单角 L 形取景角标（顶点在左上，配合旋转复用到四角）。
private struct CornerMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}
