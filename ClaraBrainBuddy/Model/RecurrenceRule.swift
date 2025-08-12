//
//  Model/RecurrenceRule.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.08.25.
//
import SwiftUI

enum RecurrenceRule: Codable, Hashable {
    case daily
    case weekly(weekday: Int) // 1=Sunday ... 7=Saturday
    case monthly(day: Int) // z.B. 15. jeden Monats
    case evenDays 
    case oddDays
}

extension RecurrenceRule {
    func encoded() -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    static func decode(from string: String) -> RecurrenceRule? {
        let decoder = JSONDecoder()
        if let data = string.data(using: .utf8),
           let rule = try? decoder.decode(RecurrenceRule.self, from: data) {
            return rule
        }
        return nil
    }
}
