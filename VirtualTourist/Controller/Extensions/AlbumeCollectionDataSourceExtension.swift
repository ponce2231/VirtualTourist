//
//  AlbumeCollectionDataSourceExtension.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 3/1/20.
//  Copyright © 2020 none. All rights reserved.
//

import Foundation
import UIKit

private let reuseIdentifier = "Cell"

//  MARK: Collection view DATA Source functions
extension PhotoAlbumViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![0].numberOfObjects
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //      #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell
        
        let anImage = fetchedResultsController.object(at: indexPath)
        
        //      convert  downloaded data to a images if its not nil
        if let imageData = anImage.imageData{
            
            // Configure the cell
            let downloadedImage = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                cell.imageView.image = downloadedImage
            }
            
        }else{
            
            if let data = try? Data(contentsOf: URL(string: anImage.url!)!){
                
                let savedImage = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.imageView.image = savedImage
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedImage = fetchedResultsController.object(at: indexPath)
        
        dataController.viewContext.delete(selectedImage)
        
    }
}
