//
//  FileUploadLoadingView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

struct FileUploadLoadingView: View {

    // MARK: - Properties

    let progress: Double
    let fileName: String

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(AppColors.line, lineWidth: 6)
                    .frame(width: 94, height: 94)

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppColors.primaryNormal, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 94, height: 94)
                    .rotationEffect(.degrees(-90))

                // Percentage text
                Text("\(Int(progress * 100))%")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }

            // File name
            Text("Uploading \(fileName)...")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.buttonSecondaryBg)
        .cornerRadius(AppRadius.Tablet.md)
    }
}
