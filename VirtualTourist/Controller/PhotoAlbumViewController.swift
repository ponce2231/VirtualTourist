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

//MARK: page variable for increment
public  var pageCounter:Int = 1

class PhotoAlbumViewController:UIViewController{
//MARK: Outlets
    @IBOutlet var collectionAlbumeView: UICollectionView!
    @IBOutlet weak var mapViewAlbume: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
//MARK: variables
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Image>!
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View did load called")
        print("pin latitude and longitude: \(pin.latitude),\( pin.longitude)")
        
        pinSetup()
        coreDataFetch()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
                fetchedResultsController = nil
    }
    
    @IBAction func newCollectionWasPressed(_ sender: Any) {
        print("new collection Action was called")
        
            deleteAndFetch()
            pageCounter += 1
       
        print("page counter new collection: \(pageCounter)")
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        print("back button pressed Action was called")
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func selectingImagesToDelete() {
        print("selecting images to delete Function was called")
        let indexPath = collectionAlbumeView.indexPathsForVisibleItems
        
        for index in indexPath{
            
            deleteImages(at: index)
        }
        try? dataController.viewContext.save()
    }
    
    fileprivate func deleteAndFetch() {
        print("delete and fetch called")
        selectingImagesToDelete()
        coreDataFetch()
    }
    
    //    MARK:fetch images from coredata and reloads the collection view
    fileprivate func coreDataFetch() {
        print("core data fetched Function called")
//        was of type data
        var urlData: Data?
        setupFetchedResultsController()
        getImages(&urlData)
        setupFetchedResultsController()
        collectionAlbumeView.reloadData()
    }
    
//    MARK: Delete the images from the datacontroller context
    fileprivate func deleteImages(at indexPath: IndexPath) {
        print("delete images called")
        if !fetchedResultsController.fetchedObjects!.isEmpty{
            let imagesToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(imagesToDelete)
        }
        print(fetchedResultsController.fetchedObjects!.isEmpty)
    }
    
//    MARK: Get images from coredata and saves them
    fileprivate func getImages(_ urlData: inout Data?) {
        
        print("get images Function called")
        
        if fetchedResultsController.fetchedObjects!.isEmpty == false && fetchedResultsController.fetchedObjects != nil {
            
            print("fetched results controller count: \(String(describing: fetchedResultsController.fetchedObjects?.count))")
            
            for image in fetchedResultsController.fetchedObjects!{
                urlData = image.imageData
            }
            
            print("this url data from get images \(urlData)")
        }else{
            print("fetched results controller count: \(String(describing: fetchedResultsController.fetchedObjects?.count))")
            FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude, completionHandler: photoSearchLocationHandler(success:error:url:))
//            FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude) {(success, error, url) in
//
//                print("photo search location Function was called")
//
//                guard let urlArray = url else{
//                    print("Url is nil")
//                    return
//                }
//
//                self.saveImageDataToCoreData(urlArray,pin: self.pin)
//            }
        }
    }

    func photoSearchLocationHandler(success: Bool,  error: Error?,url: [String]?) {
        print("photoSearchLocationHandler called")
        if success{
                guard let urlArray = url else{
                    print("Url is nil")
                    return
                }
                
            self.saveImageDataToCoreData(urlArray,pin: self.pin)
        
        }else{
            print(error!.localizedDescription)
        }
    }

    
//  MARK: save image data to core data
    fileprivate func saveImageDataToCoreData(_ urlArray: [String], pin:Pin) {
        
        print("saveImageDataToCoreData called")
        
        for photoLink in urlArray{
            print("looping in urlArray")
            let pic = Image(context: self.dataController.viewContext)
            pic.url = photoLink
            pic.pin = pin
            
            
                
            self.getData(from: URL(string: pic.url!)!, completionHandler: { (data, urlResponse, error) in
                
                guard let data = data, error == nil else{
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                pic.imageData = data

            })
            
            do{
                try self.dataController.viewContext.save()
                coreDataFetch()
            }catch{
                fatalError("view contex could not be saved \(error.localizedDescription)")
            }
        }
        print("fetched results controller after save context: \(fetchedResultsController.fetchedObjects)")
    }
    
//  MARK: Setup the fetched results controller
    fileprivate func setupFetchedResultsController() {
        print("setup fetched results function called")
        
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
    
//  MARK:function for getting the data from the url
    func getData(from url: URL, completionHandler: @escaping(Data?, URLResponse?,Error?) -> Void){
        print("get data Function was called")
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler).resume()
    }
    
    //    MARK: setup the pin and disable any user interaction
    fileprivate func pinSetup() {
        print("pinSetup was called")
        
        //Setting up region
        let distance: CLLocationDistance = 30000
        let location = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        let mapCoordinates = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
    
        //Setting up annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
        mapViewAlbume.addAnnotation(annotation)
        mapViewAlbume.setRegion(mapCoordinates, animated: true)
        //Disabled any type of user interface to the mapview
        mapViewAlbume.isPitchEnabled = false
        mapViewAlbume.isZoomEnabled = false
        mapViewAlbume.isScrollEnabled = false
        mapViewAlbume.isUserInteractionEnabled = false
    }
}
