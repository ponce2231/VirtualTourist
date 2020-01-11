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
        print("AlbumeVC")
        dump(pin)
        //pass coordinates as static constants
        FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude) { (success, error, url) in
            
//            guard error != nil else{
//                print(error?.localizedDescription)
//                return
//            }
            
            guard let urlArray = url else{
                print("Url is nil")
                return
            }
            
           print("looping in urlArray")
            for photoLink in urlArray{
                let pic = Image(context: self.dataController.viewContext)
                pic.url = photoLink
                pic.pin = self.pin
                try? self.dataController.viewContext.save()
                print(pic.url!)
            }
        self.collectionAlbumeView.reloadData()
           // addImage()
            
        }
       setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController = nil
    }
//    func addImage(){
//        let pic = Image(context: self.dataController.viewContext)
//                   pic.url = url
//                   pic.pin = self.pin
//                   try? self.dataController.viewContext.save()
//    }
    
    fileprivate func setupFetchedResultsController() {
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
            print("Collection view cell")
        
            let anImage = fetchedResultsController.object(at: indexPath)
        print(anImage)
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)as! Cell
        
        // Configure the cell
        let downloadedImage = UIImage(data: anImage.imageData!)
        DispatchQueue.main.async {
             cell.imageView.image = downloadedImage
        }
       
        
    
        return cell
    }
    
         func numberOfSections(in collectionView: UICollectionView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
    
}
