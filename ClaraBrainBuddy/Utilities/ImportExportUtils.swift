//
//  Utilities/ShareTextSheet.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 17.06.25.
//

import SwiftUI
import CoreData


struct ImportExportUtils {
    
    static let export_extension = "clara"

    static func exportAllTodosToJSONFile(context: NSManagedObjectContext, fileName: String) -> URL {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            let dtos = entities.map { $0.toDto() }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .formatted(plainDateFormatter)
            
            let jsonData = try encoder.encode(dtos)
            
            let binURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)
                .appendingPathExtension(export_extension)
            
            try jsonData.write(to: binURL)

            return binURL
            
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
            
            let jsonData = try encoder.encode(dtos)
            
            let binURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(fileName)
                .appendingPathExtension(export_extension)
            
            try jsonData.write(to: binURL)

            return binURL
            
        } catch {
            print("Error exporting todos: \(error)")
            return URL(fileURLWithPath: "")
        }
    }
    
    static func importTodosFromJSONFile(fileURL: URL) throws -> [TodoDto] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found: \(fileURL.path)")
            throw ImportExportError.fileNotFound
        }
        
        guard fileURL.pathExtension == ImportExportUtils.export_extension else {
            print("Invalid file type: \(fileURL.path)")
            throw ImportExportError.invalidFileType
        }
        
        let jsonData = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(plainDateFormatter)
        
        do {
            let dtoList = try decoder.decode([TodoDto].self, from: jsonData)
            let sanitized = Sanitizer.sanitizeTodos(dtoList)
            if (sanitized.isEmpty) {
                throw ImportExportError.emptyFile
            }
            return sanitized
        } catch {
            throw ImportExportError.invalidJSON
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

enum ImportExportError: Error, LocalizedError {
    case fileNotFound
    case invalidJSON
    case emptyFile
    case invalidFileType

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return NSLocalizedString(Localization.errors.fileNotFound, comment: "File not found error")
        case .invalidJSON:
            return NSLocalizedString(Localization.errors.invalidJSON, comment: "Invalid JSON error")
        case .emptyFile:
            return NSLocalizedString(Localization.errors.emptyFile, comment: "Empty file error")
        case .invalidFileType:
            return NSLocalizedString(Localization.errors.invalidFiletype, comment: "Invalid file type")
        }
    }
}
