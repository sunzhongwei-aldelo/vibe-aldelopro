//
//  AldeloProApp.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 5/29/26.
//

import SwiftUI

@main
struct AldeloProApp: App {
   var body: some Scene {
       WindowGroup {
           SetupFlowRootView()
               .provideDeviceLayout()
               .provideControlHeightScale(diagnostic: true)
       }
   }
}
