//
//  Utilities/ShareTextSheet.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 17.06.25.
//

import SwiftUI

struct ImportExportUtils {
    
    static func exportTodosToJSONFile(todos: [Todo], fileName: String) -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .formatted(plainDateFormatter)
        
        let jsonFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        do {
            let jsonData = try encoder.encode(todos)
            try jsonData.write(to: jsonFileURL)
            return jsonFileURL
        } catch {
            print("Error exporting Todos: \(error)")
            return URL(fileURLWithPath: "")
        }
    }
    
    static func importTodosFromJSONFile(fileURL: URL) -> [Todo] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at path: \(fileURL.path)")
            return []
        }

        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()

            decoder.dateDecodingStrategy = .formatted(plainDateFormatter)

            let todos = try decoder.decode([Todo].self, from: jsonData)

            return Sanitizer.sanitizeTodos(todos)
        } catch {
            print("Error importing Todos: \(error)")
            return []
        }
    }
    
    private static let plainDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent parsing
        formatter.timeZone = TimeZone(secondsFromGMT: 0)     // avoid time zone shifts
        return formatter
    }()
}
