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


// add a label that displays no images found
// add functionality to the new collection button
//Done:
// pass selected pin to the mapview
// add a nav bar with a back button
// add a button at the bottom for new collection
// resize images or view cell

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
        pinSetup()
        print("View did load called")
        setupFetchedResultsController()
        
        FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude) { (success, error, url) in
            
            print("photo search location function called")

            guard let urlArray = url else{
                print("Url is nil")
                return
            }
//            || self.fetchedResultsController.fetchedObjects != nil

            if self.fetchedResultsController.fetchedObjects != nil {
                
                print("fetched Results Controller count: \(String(describing: self.fetchedResultsController.fetchedObjects?.count))")
                
                do{
                    try self.fetchedResultsController.performFetch()
                }catch{
                    fatalError("fetch could not be performed: \(error.localizedDescription)")
                }
                
//                for images  in self.fetchedResultsController.fetchedObjects!{
//                    images.pin = self.pin
//                    images.imageData = self.urlData
//                    print("from fetched results pin: \(String(describing: images.pin))")
//                    print("from fetched results image: \(images.imageData)")
//                }
                
            }else{
                self.saveImageDataToCoreData(urlArray)
                self.collectionAlbumeView.reloadData()
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController = nil
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        print("back button pressed was called")
        self.dismiss(animated: true, completion: nil)
    }
    fileprivate func pinSetup() {
        //      Setting up region
        let distance: CLLocationDistance = 30000
        let location = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        let mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        //        Setting up annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
        mapViewAlbume.addAnnotation(annotation)
        mapViewAlbume.setRegion(mapCoordinates, animated: true)
        //      Disabled any type of user interface to the mapview
        mapViewAlbume.isPitchEnabled = false
        mapViewAlbume.isZoomEnabled = false
        mapViewAlbume.isScrollEnabled = false
        mapViewAlbume.isUserInteractionEnabled = false
        
    }
    
    fileprivate func saveImageDataToCoreData(_ urlArray: [String]) {
        
        print("saveImageDataToCoreData called")
        
        for photoLink in urlArray{
            print("looping in urlArray")
            let pic = Image(context: self.dataController.viewContext)
            pic.url = photoLink
            self.getData(from: URL(string: pic.url!)!, completionHandler: { (data, urlResponse, error) in
                guard let data = data, error == nil else{
                    print(error?.localizedDescription as Any)
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
        print("this is an image data: \(anImage.imageData)")
        if let imageData = anImage.imageData{
            // Configure the cell
            let downloadedImage = UIImage(data: imageData)
            print("downloaded image \(String(describing: downloadedImage))")
            DispatchQueue.main.async {
                cell.imageView.image = downloadedImage
                collectionView.reloadData()
            }
        }else{
            print("anImage data is: \(String(describing: anImage.imageData))")
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        print("minimum inter item spacing called")
        return 3.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("minimum line spacing called")
        return 3.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size for item at called")
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        return CGSize(width: dimension, height: dimension)
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
}
extension PhotoAlbumViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
           let reuseID = "pin"
           
           var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView

           if pinView == nil {
               pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
               pinView!.pinTintColor = .red
               pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
           }
           else {
               pinView!.annotation = annotation
           }
           
           return pinView
       }
}


