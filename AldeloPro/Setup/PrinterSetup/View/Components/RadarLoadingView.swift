//
//  RadarLoadingView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/15.
//

import SwiftUI

// MARK: - RadarLoadingView

/// 设备搜索时的雷达扫描 loading 动画（内嵌于页面中心区域，不是全屏遮罩）。
///
/// 纯 SwiftUI 实现，作为设计稿雷达扫描视觉的临时替代（同心圆环 + 旋转渐变扫描弧 + 脉冲蓝点），
/// 不依赖外部图片资源。圆环取 `AppColors.pageBg`（比页面底色更亮的浅圈），
/// 扫描弧与脉冲点取主题蓝 `AppColors.primaryNormal`。
///
/// 设计稿外圈半径 130 → 默认直径 260。动画区域为装饰元素，尺寸固定、不随控件高度缩放。
struct RadarLoadingView: View {

    /// 动画区域直径（pt）。
    var diameter: CGFloat = 260

    @State private var isSweeping = false
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            concentricRings
            sweepArc
            dots
        }
        .frame(width: diameter, height: diameter)
        .onAppear {
            isSweeping = true
            isPulsing = true
        }
    }

    // MARK: - 同心圆环（3 圈，由外向内）

    private var concentricRings: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                let ratio = CGFloat(index + 1) / 3.0
                Circle()
                    .stroke(AppColors.pageBg, lineWidth: 1.5)
                    .frame(width: diameter * ratio, height: diameter * ratio)
            }
        }
    }

    // MARK: - 旋转扫描弧（约 1/4 圈，首尾渐隐）

    private var sweepArc: some View {
        Circle()
            .trim(from: 0.0, to: 0.28)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        AppColors.primaryNormal.opacity(0),
                        AppColors.primaryNormal
                    ]),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )
            .frame(width: diameter, height: diameter)
            .rotationEffect(.degrees(isSweeping ? 360 : 0))
            .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: isSweeping)
    }

    // MARK: - 脉冲蓝点（位置参照设计稿三个发光点）

    private var dots: some View {
        ZStack {
            dot(size: 17, angleDegrees: 149, radiusRatio: 0.57)
            dot(size: 7, angleDegrees: -97, radiusRatio: 0.36)
            dot(size: 12, angleDegrees: 7, radiusRatio: 0.77)
        }
    }

    private func dot(size: CGFloat, angleDegrees: Double, radiusRatio: CGFloat) -> some View {
        let radius = diameter / 2 * radiusRatio
        let radians = angleDegrees * .pi / 180
        return Circle()
            .fill(AppColors.primaryNormal)
            .frame(width: size, height: size)
            .offset(x: radius * CGFloat(cos(radians)), y: radius * CGFloat(sin(radians)))
            .opacity(isPulsing ? 1.0 : 0.35)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
    }
}

// MARK: - Preview

#Preview {
    RadarLoadingView()
        .padding(Spacing.xxl)
        .background(AppColors.pageBgDeep)
}
