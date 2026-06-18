//
//  AldeloHeaderAppModeProgressView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderAppModeProgressView
//
// 【作用】
// D 族「App Mode 状态栏」(`AldeloAppModeHeaderView`) 右侧的蓝色进度线原子。
// 表达后台加载 / 同步进度，对应设计稿 35% → 50% → 70% → 100% 的多帧切换。
//
// 【设计要点】
// - 语义参数为 progress（0...1 的进度值），而非"线宽比例"——调用方传业务真实进度即可。
// - 轨道（未完成部分）用 `AppColors.progressTrack`（浅灰，Token 内字面值，不随暗色自适应）。
// - 进度（已完成部分）用 `AppColors.theme`（品牌蓝）。
// - 自动 clamp 到 0...1，调用方无需自己防越界。
// - 固定高度 4pt，宽度由父容器决定（通常外层再 `.frame(width:)` 限定可视长度）。
//
// 【使用案例】
// ```swift
// // 1) 基础用法：传入 0...1 的进度
// AldeloHeaderAppModeProgressView(progress: 0.35)
//     .frame(width: 240)            // 外层限定可视长度
//
// // 2) 绑定 ViewModel 的同步进度
// AldeloHeaderAppModeProgressView(progress: viewModel.syncProgress)
//     .frame(width: isCompact ? 120 : 240)
//
// // 3) 越界值自动收敛：传 1.5 等价于 1.0（填满），传 -0.2 等价于 0（空）
// AldeloHeaderAppModeProgressView(progress: 1.5)   // 安全，渲染为满格
// ```

struct AldeloHeaderAppModeProgressView: View {

    /// 进度值，有效区间 0...1（越界会被自动 clamp）。
    let progress: CGFloat

    /// 收敛到 0...1 的安全进度值。
    private var clamped: CGFloat { min(max(progress, 0), 1) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 轨道：整条浅灰底
                Capsule()
                    .fill(AppColors.progressTrack)
                    .frame(height: 4)
                // 进度：按 clamped 比例填充品牌蓝
                Capsule()
                    .fill(AppColors.theme)
                    .frame(width: geo.size.width * clamped, height: 4)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 4)
    }
}
