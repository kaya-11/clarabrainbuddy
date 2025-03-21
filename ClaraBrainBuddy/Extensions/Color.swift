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
    let primary: Color = Color("PrimaryColor")
    let secondary: Color = Color("SecondaryColor")
    let accent: Color = Color("AccentColor")
    let background: Color = Color("BackgroundColor")
    
    let listBackground: Color = Color("ListBackgroundColor")
    let listText: Color = Color("ListTextColor")

    let buttonBackground: Color = Color("ListBackgroundColor")
    let buttonText: Color = Color("ListTextColor")
    
    let green: Color = Color("GreenColor")
    let red: Color = Color("RedColor")
    let blue: Color = Color("BlueColor")
    let yellow: Color = Color("YellowColor")
    let white: Color = Color("WhiteColor")
    
}
