//
//  ScannedPage.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/05.
//

import Foundation
import UIKit

struct ScannedPage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    let timestamp = Date()

    static func == (lhs: ScannedPage, rhs: ScannedPage) -> Bool {
        lhs.id == rhs.id
    }
}
