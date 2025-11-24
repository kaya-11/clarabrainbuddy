//
//  Extensions/Comparable.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 13.08.25.
//


extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
