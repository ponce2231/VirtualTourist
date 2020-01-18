//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/26/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "Cell"
class PhotoAlbumViewController:UIViewController{
    
    @IBOutlet weak var mapViewAlbume: MKMapView!
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    
    @IBOutlet var collectionAlbumeView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load called")
        setupFetchedResultsController()
        
        //its not being called
       FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude) { (success, error, url) in
            
            print("photo search location function called")

            guard let urlArray = url else{
                print("Url is nil")
                return
            }
            
//            guard let data = data else{
//                print("error with the data")
//                return
//            }
//            print("data: \(data)")
            print("looping in urlArray")
    
            for photoLink in urlArray{
                let pic = Image(context: self.dataController.viewContext)
                pic.url = photoLink
//                pic.imageData
                pic.pin = self.pin
                try? self.dataController.viewContext.save()
                
                print(photoLink)
//                print("data pic \(String(describing: data))")
                print("pic object\(pic)")
                print("pin image data \(String(describing: pic.imageData))")
                print(" pic url \(String(describing: pic.url))")
                print("pic pin object \(String(describing: pic.pin))")
                
            }
            
            self.collectionAlbumeView.reloadData()
        }
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController = nil
    }
    fileprivate func setupFetchedResultsController() {
        print("setup fetched results called")
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch not be perfomed: \(error.localizedDescription)")
        }
    }
    
        
  
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource{

    //MARK: Collection view DATA Source functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![0].numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            print("cell for row item at called")

        let anImage = fetchedResultsController.object(at: indexPath)
        print("an image indexpath \(anImage)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Cell

        // Configure the cell
        let downloadedImage = UIImage(data: anImage.imageData!)
        print("downloaded image \(String(describing: downloadedImage))")
        DispatchQueue.main.async {
            collectionView.reloadData()
            cell.imageView.image = downloadedImage
            }

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }

}
