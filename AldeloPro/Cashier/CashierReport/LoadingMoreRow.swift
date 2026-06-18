//
//  LoadingMoreRow.swift
//  AldeloPro
//

import SwiftUI

/// Shared "Loading More" footer used by the Cashier Report detail screens,
/// matching the spinner + label treatment in the record-detail SVGs.
struct LoadingMoreRow: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            ProgressView()
                .controlSize(.small)
            Text("Loading More")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, Spacing.md)
    }
}

#Preview {
    LoadingMoreRow()
}
