//
//  EmptyView.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 6/5/26.
//

import SwiftUI


struct AldeloEmptyView: View {
    @State var icon: Image
    @State var title: String
    var body: some View {
        VStack(spacing: Spacing.xs) {
            icon
                .resizable()
                .frame(width: 106, height: 106)
            Ellipse()
                .fill(
                    LinearGradient(colors: [Color(hex: "A4D1FF"), Color.clear], startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.4)))
                .opacity(0.25)
                .frame(width: 324, height: 116)
                .overlay {
                    VStack {
                        Text(title)
                            .font(AppFont.tabletBody2Regular)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.top,36)
                        Spacer()
                    }
                }
        }
    }
}

#Preview {
    AldeloEmptyView(icon: Image(.noPaymentsToTipAdjust), title: "No payments to tip")
}
