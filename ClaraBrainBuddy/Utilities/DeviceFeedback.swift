//
//  Utilities/DeviceFeedback.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.03.25.
//

import AudioToolbox

struct DeviceFeedback {
    static func vibrateTwice() {
        vibrate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            vibrate()
        }
    }
    
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
