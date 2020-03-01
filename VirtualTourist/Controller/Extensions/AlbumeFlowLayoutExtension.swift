//
//  AlbumeFlowLayoutExtension.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 3/1/20.
//  Copyright © 2020 none. All rights reserved.
//

import Foundation
import UIKit

//  MARK:collectionview delegate flow layout functions
extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        print("minimum inter item spacing called")
        return 3.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        print("minimum line spacing called")
        return 3.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("size for item at called")
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        return CGSize(width: dimension, height: dimension)
    }
}
