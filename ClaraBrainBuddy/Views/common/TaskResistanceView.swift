//
//  Views/common/TaskResistanceView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.10.25.
//

import SwiftUI

struct TaskResistanceView: View {
    
    let resistance: Int // Widerstandswert zwischen 1 und 19
    
    var body: some View {
        
        GeometryReader { geometry in
            let resistanceLevel = CGFloat(min(19,resistance)) / 19.0 // Skalierung von 0-19 auf 0-1
            
            ZStack(alignment: .leading) {
                // backgroun of the bar
                Capsule()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(Color.gray)
                
                resistanceSegment(
                    in: geometry,
                    resistance: resistance,
                    segmentEnd: resistanceLevel
                )
            }
        }
        .frame(height: 6)
        .cornerRadius(2)
    }
    
    private func getResistanceColors(resistance: Int) -> [Color] {
        switch resistance {
            case 1:
                return [
                    Color.theme.resistanceLevel1
                ]
            case 2...3:
                return [
                    Color.theme.resistanceLevel1,
                    Color.theme.resistanceLevel2
                ]
            case 4...6:
                return [
                    Color.theme.resistanceLevel1,
                    Color.theme.resistanceLevel2,
                    Color.theme.resistanceLevel3
                ]
            case 7...11:
                return  [
                    Color.theme.resistanceLevel1,
                    Color.theme.resistanceLevel2,
                    Color.theme.resistanceLevel3,
                    Color.theme.resistanceLevel4
                ]
            case 11...19:
                return  [
                    Color.theme.resistanceLevel1,
                    Color.theme.resistanceLevel2,
                    Color.theme.resistanceLevel3,
                    Color.theme.resistanceLevel4,
                    Color.theme.resistanceLevel5
                ]
            default:
                return  []
        }
    }
        
    @ViewBuilder
    private func resistanceSegment(
        in geometry: GeometryProxy,
        resistance: Int,
        segmentEnd: CGFloat
    ) -> some View {
        if resistance > 0 {
            let gradientColors: [Color] = getResistanceColors(resistance: resistance)
            Capsule()
                .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                .frame(
                    width: geometry.size.width * (segmentEnd),
                    height: geometry.size.height
                )

        }
    }
}
