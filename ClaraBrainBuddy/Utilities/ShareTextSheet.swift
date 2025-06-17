//
//  Utilities/ShareTextSheet.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 17.06.25.
//

import SwiftUI
import UIKit

struct ShareTextSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}
