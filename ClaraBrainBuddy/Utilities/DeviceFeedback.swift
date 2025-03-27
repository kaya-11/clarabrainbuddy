//
//  Utilities/Untitled.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 27.03.25.
//

import AudioToolbox

struct DeviceFeedback {
    static func vibrateTwice() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
