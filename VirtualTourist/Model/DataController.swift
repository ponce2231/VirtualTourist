//
//  DataController.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 12/5/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    //need to refresh to understand it better
    func configureContext() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                
                fatalError(error!.localizedDescription)
            }
            
            self.autoSaveViewContext()
            self.configureContext()
            
            completion?()
            
        }
    }
    
}
extension DataController{
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else{
            print("cannot set a negative auto save interval")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext()
        }
    }
    
}
