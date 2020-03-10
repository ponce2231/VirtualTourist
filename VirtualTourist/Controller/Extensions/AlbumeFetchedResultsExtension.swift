//
//  AlbumeFetchedResultsExtension.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 3/1/20.
//  Copyright © 2020 none. All rights reserved.
//

import Foundation
import CoreData

// MARK: Fetched Results Controller delegate Functions
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionAlbumeView.performBatchUpdates(self.collectionAlbumeView.reloadData, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionAlbumeView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionAlbumeView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionAlbumeView.reloadItems(at:[indexPath!])
            
        case .move:
            collectionAlbumeView.moveItem(at: indexPath!, to: newIndexPath!)
            
        }
        
    }
}
