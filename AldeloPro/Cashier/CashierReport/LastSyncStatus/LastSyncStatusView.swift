//
//  LastSyncStatusView.swift
//  AldeloPro
//
//  Created by SunZhongwei on 2026/06/18.
//

import SwiftUI

/// "Last Sync Status" 弹窗：展示各设备最近一次同步时间，异常设备右侧标红色感叹号。
/// 自适应：不固定宽高，行宽随容器拉伸，行高随内容自适应。
struct LastSyncStatusView: View {
    let data: LastSyncStatusData
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleBar
            deviceList
        }
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }

    // MARK: - Title Bar

    private var titleBar: some View {
        HStack(alignment: .center) {
            Text(data.title)
                .font(AppFont.tabletDisplay7Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Device List

    private var deviceList: some View {
        ScrollView {
            VStack(spacing: Spacing.sm) {
                ForEach(data.devices) { device in
                    deviceRow(device)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
    }

    // MARK: - Device Row

    private func deviceRow(_ device: DeviceSyncStatus) -> some View {
        HStack(spacing: Spacing.sm) {
            Text(device.displayText)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer(minLength: Spacing.sm)
            if device.hasError {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.errorNormal)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .controlHeight(69)
        .background(AppColors.pageBg)
        .cornerRadius(AppRadius.Tablet.sm)
    }
}

#Preview {
    LastSyncStatusView(data: .mock, onClose: {})
        .frame(width: 920, height: 760)
        .padding()
        .background(AppColors.pageBgDeep)
}
