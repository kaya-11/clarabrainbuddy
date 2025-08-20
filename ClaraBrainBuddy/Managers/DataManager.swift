//
//  Managers/DataManager.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 12.08.25.
//


import CoreData

class DataManager {
    static let shared = {
        let env = ProcessInfo.processInfo.environment
        let isUnitTestMode = env["XCTestConfigurationFilePath"] != nil
        return DataManager(inMemory: isUnitTestMode)
    }()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ClaraDataModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        context = container.viewContext
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
