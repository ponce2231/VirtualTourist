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

// resize images or view cell
// add a label that displays no images found
// add a nav bar
// add a bottom bar for new collection
// pass selected pin to the mapview

private let reuseIdentifier = "Cell"

class PhotoAlbumViewController:UIViewController{
    
    @IBOutlet var collectionAlbumeView: UICollectionView!
    @IBOutlet weak var mapViewAlbume: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
    var urlImage: String?
    var urlData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("View did load called")
        setupFetchedResultsController()
        
        FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude) { (success, error, url) in
            
            print("photo search location function called")

            guard let urlArray = url else{
                print("Url is nil")
                return
            }

            print("looping in urlArray")
    
            for photoLink in urlArray{
                let pic = Image(context: self.dataController.viewContext)
                pic.url = photoLink
                self.getData(from: URL(string: pic.url!)!, completionHandler: { (data, urlResponse, error) in
                    guard let data = data, error == nil else{
                        print(error?.localizedDescription)
                        return
                    }
                    self.urlData = data
                    print("this is urlData: \(String(describing: self.urlData))")
                })
                pic.imageData = self.urlData
                pic.pin = self.pin
                

                try? self.dataController.viewContext.save()
                print(photoLink)
                print("pic object\(pic)")
                print("pin image data \(String(describing: pic.imageData))")
                print(" pic url \(String(describing: pic.url))")
                print("pic pin object \(String(describing: pic.pin))")
                
            }
        

            
            self.collectionAlbumeView.reloadData()
        }
       
        let space: CGFloat = 3.0
        setupCollectionViewCell(space: space)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupCollectionViewCell(space:CGFloat) {

        print("setup Collection view cell called")

        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        //ACOMODATES THE CONTENT OF THE VIEW COLLECTION
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
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
    
//  function for getting the data from the url
    func getData(from url: URL, completionHandler: @escaping(Data?, URLResponse?,Error?) -> Void){
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler).resume()
    }
}

//extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout{
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        print("minimum inter item spacing called")
//        return 3.0
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        print("minimum line spacing called")
//        return 3.0
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("size for item at called")
//        return CGSize(width: 120, height: 120)
//    }
//}

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
        if let imageData = anImage.imageData{
            // Configure the cell
            let downloadedImage = UIImage(data: imageData)
            print("downloaded image \(String(describing: downloadedImage))")
            DispatchQueue.main.async {
                collectionView.reloadData()
                cell.imageView.image = downloadedImage
                }
        }else{
            print("data is: \(anImage.imageData)")
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
}
