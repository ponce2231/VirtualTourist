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
   
    //Check Documentation on apple docs
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionAlbumeView.performBatchUpdates(collectionAlbumeView., completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .delete:
//            collectionAlbumeView.deleteItems(at: [indexPath!])
//        case .update:
//            collectionAlbumeView.reloadItems(at: [indexPath!])
//        case .insert, .move:
//          fatalError("Invalid change type in controller(_:didChange anObject:for:). Only .update or .delete should be possible.")
//          }
        }
    }
