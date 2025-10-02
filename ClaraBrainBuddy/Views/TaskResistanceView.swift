//
//  Views/TaskResistanceView.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.10.25.
//

import SwiftUI

struct TaskResistanceView: View {
    
    let resistance: Int // Widerstandswert zwischen 1 und 11

    var body: some View {
        
        GeometryReader { geometry in
            let resistanceLevel = CGFloat(min(11,resistance)) / 11.0 // Skalierung von 2-10 auf 0-1
            let yellowEnd: CGFloat = 1.0 / 11.0
            let orangeEnd: CGFloat = 3.0 / 11.0
            let redEnd: CGFloat = 6.0 / 11.0
            
            ZStack(alignment: .leading) {
                // backgroun of the bar
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(Color.gray)

                // Gelbes Segment (Widerstand 1)
                resistanceSegment(
                    in: geometry,
                    level: resistanceLevel,
                    segmentStart: 0.0,
                    segmentEnd: yellowEnd,
                    color: Color.theme.yellow
                )

                // Oranges Segment (Widerstand 2-3)
                resistanceSegment(
                    in: geometry,
                    level: resistanceLevel,
                    segmentStart: yellowEnd,
                    segmentEnd: orangeEnd,
                    color: Color.theme.orange
                )

                // Rotes Segment (Widerstand 3-6)
                resistanceSegment(
                    in: geometry,
                    level: resistanceLevel,
                    segmentStart: orangeEnd,
                    segmentEnd: redEnd,
                    color: Color.theme.red
                    
                )

                // Dunkelrotes Segment (Widerstand 6-11)
                resistanceSegment(
                    in: geometry,
                    level: resistanceLevel,
                    segmentStart: redEnd,
                    segmentEnd: 1.0,
                    color: Color.theme.brightred,
                    opacity: 0.7
                )
            }
        }
        .frame(height: 6)
        .cornerRadius(2)
    }
    
    
    @ViewBuilder
    private func resistanceSegment(
        in geometry: GeometryProxy,
        level: CGFloat,
        segmentStart: CGFloat,
        segmentEnd: CGFloat,
        color: Color,
        opacity: Double = 1.0
        
    ) -> some View {
        if level > segmentStart {
            Rectangle()
                .frame(
                    width: min(
                        geometry.size.width * (level - segmentStart),
                        geometry.size.width * (segmentEnd - segmentStart)
                    ),
                    height: geometry.size.height
                )
                .opacity(opacity)
                .foregroundColor(color)
                .offset(x: geometry.size.width * segmentStart, y: 0)
        }
    }
}
