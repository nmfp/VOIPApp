//
//  CoreDataManager.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 13/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VoipAppCoreDataModel")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, err) in
            if let err = err {
                fatalError("Failed loading the store: \(err)")
            }
        })
        return container
    }()
    
    func fetchDataFromCoreData<T: NSFetchRequestResult>() -> [T] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        
        do {
            let array = try context.fetch(fetchRequest)
            return array
        }
        catch let fetchTErr {
            print("Failed to fetch generics from CoreData: ", fetchTErr)
            return []
        }
    }
}
