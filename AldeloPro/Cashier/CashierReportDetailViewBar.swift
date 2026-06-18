//
//  CashierReportDetailViewBar.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 6/16/26.
//

import SwiftUI

struct CashierReportDetailViewBar: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let dateString: String
    
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.backward")
                    Text(title)
                }
                .font(AppFont.tabletH3Medium)
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("Generated")
                    .foregroundColor(.secondary)
                Text(dateString)
            }
            .font(AppFont.tabletH6Medium)
        }
        .padding(.horizontal)
        .frame(height: 50)
    }
}

#Preview {
    CashierReportDetailViewBar(title: "Discount Activities", dateString: "06/16/26 12:00:00")
}
