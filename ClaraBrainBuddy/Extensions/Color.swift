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
}

struct ColorTheme {
    let primary: Color = Color("AppPrimaryColor")
    let secondary: Color = Color("AppSecondaryColor")
    let accent: Color = Color("AccentColor")
    let background: Color = Color("BackgroundColor")
    
    let listBackground: Color = Color("ListBackgroundColor")
    let listText: Color = Color("ListTextColor")

    let buttonBackground: Color = Color("ListBackgroundColor")
    let buttonText: Color = Color("ListTextColor")
    
    let green: Color = Color("AppGreenColor")
    let red: Color = Color("AppRedColor")
    let brightred: Color = Color("AppBrightRedColor")
    let blue: Color = Color("AppBlueColor")
    let yellow: Color = Color("AppYellowColor")
    let orange: Color = Color("AppOrangeColor")
    let white: Color = Color("AppWhiteColor")
    let gray : Color = Color("AppGrayColor")
    
}
