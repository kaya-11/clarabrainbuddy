//
//  Extension/Color.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 21.03.25.
//

import Foundation
import SwiftUI

extension Font {
    static let app = FontList()
}

struct FontList {
    let listItem : Font = Font.system(size: 12, weight: .regular, design: .default)
    let header : Font = Font.system(size: 18, weight: .bold, design: .default)
    let button : Font = Font.system(size: 16, weight: .bold, design: .default)
    let title : Font = Font.system(size: 24, weight: .bold, design: .default)
    let normal : Font = Font.system(size: 16, weight: .regular, design: .default)
    let section : Font = Font.system(size: 14, weight: .regular, design: .default)
    let small : Font = Font.system(size: 14, weight: .regular, design: .default)
    let tiny : Font = Font.system(size: 12, weight: .regular, design: .default)
    let micro : Font = Font.system(size: 8, weight: .regular, design: .default)
}
