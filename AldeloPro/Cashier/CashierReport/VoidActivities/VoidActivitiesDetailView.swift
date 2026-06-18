//
//  VoidActivitiesDetailView.swift
//  AldeloPro
//

import SwiftUI

struct VoidActivitiesDetailView: View {
    var body: some View {
        Text("Void Activities Detail")
            .navigationBarHidden(true)
            .background(SwipeBackGestureEnabler())
    }
}

#Preview {
    VoidActivitiesDetailView()
}
