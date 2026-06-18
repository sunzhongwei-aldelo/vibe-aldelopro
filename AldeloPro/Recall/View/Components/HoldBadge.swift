//
//  HoldBadge.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import SwiftUI

struct HoldBadge: View {
    let time: Double
    var isManual :Bool {
        time == Double(Int64.max)
    }
    private var timeString: String {
        if isManual {  return "" }
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(.hold)
                .resizable()
                .frame(width: 16,height: 16)
            Text("Hold \(timeString)")
                .font(AppFont.tabletBody5Regular)
        }
        .foregroundColor(AppColors.white100)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                .fill(isManual ?  AppColors.errorNormal : AppColors.warningNormal)
        )
    }
}

#Preview {
    HoldBadge(time: Date().timeIntervalSince1970)
        .padding()
}
