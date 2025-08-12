//
//  Utilities/ShareTextSheet.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 17.06.25.
//

import SwiftUI
import CoreData

struct ImportExportUtils {
    
    static func exportAllTodosToJSONFile(context: NSManagedObjectContext, fileName: String) -> URL {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            let dtos = entities.map { $0.toDto() }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .formatted(plainDateFormatter)
            
            let jsonFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)
            
            let jsonData = try encoder.encode(dtos)
            try jsonData.write(to: jsonFileURL)
            
            return jsonFileURL
        } catch {
            print("Error exporting todos: \(error)")
            return URL(fileURLWithPath: "")
        }
    }
    
    static func exportListOfTodosToJSONFile(todos: [Todo], fileName: String) -> URL {
        
        do {
            let dtos = todos.map { $0.toDto() }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .formatted(plainDateFormatter)
            
            let jsonFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)
            
            let jsonData = try encoder.encode(dtos)
            try jsonData.write(to: jsonFileURL)
            
            return jsonFileURL
        } catch {
            print("Error exporting todos: \(error)")
            return URL(fileURLWithPath: "")
        }
    }
    
    static func importTodosFromJSONFile(context: NSManagedObjectContext, fileURL: URL) -> [Todo] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found: \(fileURL.path)")
            return []
        }
        
        var entities : [Todo] = []
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(plainDateFormatter)
            
            let dtoList = try decoder.decode([TodoDto].self, from: jsonData)
            let sanitized = Sanitizer.sanitizeTodos(dtoList)
            
            
            for dto in sanitized {
                let entity = Todo(context: context)
                entity.populate(from: dto, context: context)
                entities.append(entity)
            }
        } catch {
            print("Error importing todos: \(error)")
        }
        
        return entities
    }
    
    private static let plainDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // ensures consistent parsing
        formatter.timeZone = TimeZone(secondsFromGMT: 0)     // avoid time zone shifts
        return formatter
    }()
}
