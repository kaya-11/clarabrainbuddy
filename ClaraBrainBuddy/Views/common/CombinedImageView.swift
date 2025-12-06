//
//  Views/common/CombinedImage.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 06.12.25.
//

import SwiftUI

struct CombinedImageView: View {
    
    let imageMain: String
    let imageSmall: String

    init(imageMain: String, imageSmall: String) {
        self.imageMain = imageMain
        self.imageSmall = imageSmall
    }
    
    var body: some View {
        ZStack {
            Image(systemName: imageMain)
                .font(Font.app.small)
            Image(systemName: imageSmall)
                .font(Font.app.micro)
                .offset(x: 14, y: -4)
        }
    }
}
