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
        
        print("cell for row item at called")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell
        let anImage = fetchedResultsController.object(at: indexPath)
        
//      convert  downloaded data to a images if its not nil
//        if let imageData = anImage.imageData {
        if let imageData = anImage.imageData {
            // Configure the cell
            let downloadedImage = UIImage(data: imageData)
            
            print("downloaded image \(String(describing: downloadedImage))")

            DispatchQueue.main.async {
                cell.imageView.image = downloadedImage
            }
        }else{
            print("else called")
                if let data = try? Data(contentsOf: URL(string: anImage.url!)!){
                    
                let savedImage = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imageView.image = savedImage
                    }
                }
            print("anImage data is: \(String(describing: anImage.imageData))")
        }
        return cell
    }
}
