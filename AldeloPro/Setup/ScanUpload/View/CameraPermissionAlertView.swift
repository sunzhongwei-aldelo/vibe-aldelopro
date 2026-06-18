//
//  CameraPermissionAlertView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

struct CameraPermissionAlertView: View {

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Callbacks

    var onCancel: () -> Void
    var onGoToSettings: () -> Void

    // MARK: - Computed

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack(spacing: Spacing.md) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.98, green: 0.68, blue: 0.08))

                        Text("Camera Permission Required")
                            .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH1Medium)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Text("To use this feature, please enable camera access in your device settings.")
                        .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Spacing.xxxl)
                .padding(.top, Spacing.xxxl)
                .padding(.bottom, Spacing.xxl)

                HStack(spacing: Spacing.md) {
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(AppColors.buttonSecondaryBg)
                            .cornerRadius(AppRadius.Tablet.lg)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onGoToSettings()
                    } label: {
                        Text("Go to Settings")
                            .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                            .foregroundColor(AppColors.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(AppColors.buttonPrimaryBg)
                            .cornerRadius(AppRadius.Tablet.lg)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.xxxl)
                .padding(.bottom, Spacing.xxxl)
            }
            .frame(width: isCompact ? nil : 660)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.lg)
            .padding(.horizontal, isCompact ? Spacing.md : 0)
        }
    }
}
