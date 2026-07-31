//
//  Extension/Color.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 21.03.25.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit, z. B. "FF5733")
            (r, g, b) = (
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default: // Fallback auf Schwarz, falls der String nicht passt
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0 // Immer undurchsichtig
        )
    }

    func toHex() -> String {
        guard let components = self.cgColor?.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

struct ColorTheme {
    let primary: Color = Color("AppPrimaryColor")
    let secondary: Color = Color("AppSecondaryColor")
    let accent: Color = Color("AccentColor")
    let background: Color = Color("BackgroundColor")
    
    let surfaceGlassColor: Color = Color("SurfaceGlassColor")
    let surfaceGlassTextColor: Color = Color("SurfaceGlassTextColor")
    
    let buttonBackground: Color = Color("SurfaceGlassColor")
    let buttonText: Color = Color("SurfaceGlassTextColor")
    
    let green: Color = Color("AppGreenColor")
    let red: Color = Color("AppRedColor")
    let blue: Color = Color("AppBlueColor")
    let yellow: Color = Color("AppYellowColor")
    let orange: Color = Color("AppOrangeColor")
    let white: Color = Color("AppWhiteColor")
    let gray : Color = Color("AppGrayColor")
    
    let resistanceLevel1 : Color = Color("resistanceLevel1")
    let resistanceLevel2 : Color = Color("resistanceLevel2")
    let resistanceLevel3 : Color = Color("resistanceLevel3")
    let resistanceLevel4 : Color = Color("resistanceLevel4")
    let resistanceLevel5 : Color = Color("resistanceLevel5")

    let brown : Color = Color("AppBrownColor")
    let darkerBrown : Color = Color("AppDarkerBrownColor")
    let graybrown : Color = Color("AppGrayBrownColor")
    let mauve : Color = Color("AppMauveColor")
}
