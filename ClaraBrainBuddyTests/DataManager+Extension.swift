//
//  CoreDate+InMemory.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 02.08.25.
//

import CoreData
@testable import ClaraBrainBuddy

extension DataManager {
    
    static func resetForTests() {
        shared.container.viewContext.reset()
        
        if let store = shared.container.persistentStoreCoordinator.persistentStores.first {
            try? shared.container.persistentStoreCoordinator.remove(store)
            try? shared.container.persistentStoreCoordinator.addPersistentStore(
                ofType: NSInMemoryStoreType,
                configurationName: nil,
                at: nil,
                options: nil
            )
        }
    }
}
