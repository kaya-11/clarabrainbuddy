//
//  ClaraBrainBuddyApp.swift
//  Clara - Your Buddy for your Brain Chaos
//
//  Created by Karen on 17.03.25.
//

import SwiftUI

@main
struct ClaraBrainBuddyApp: App {
    let context = DataManager.shared.context
    
    var body: some Scene {
        WindowGroup {
            ContentView(context: context)
        }
    }
}
