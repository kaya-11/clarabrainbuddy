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

        // Use the provided fileName parameter to create the file URL
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
}
