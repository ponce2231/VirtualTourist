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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet var collectionAlbumeView: UICollectionView!
    @IBOutlet weak var mapViewAlbume: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollectionButton: UIButton!
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
        
        selectingImagesToDelete()
        pageCounter += 1
        coreDataFetch()
        
        print("page counter new collection: \(pageCounter)")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        print("back button pressed Action was called")
        self.dismiss(animated: true, completion: nil)
    }
    
    //    MARK:fetch images from coredata and reloads the collection view
    fileprivate func coreDataFetch() {
        
        print("core data fetched Function called")
        
        setupFetchedResultsController()
        getImages()
        setupFetchedResultsController()
        collectionAlbumeView.reloadData()
        
    }
    
    //    MARK: Delete the images from the datacontroller context and the fetched results controller
    fileprivate func selectingImagesToDelete() {
        
        if let indexPath = fetchedResultsController.fetchedObjects {
            
            for index in indexPath {
                
                dataController.viewContext.delete(index)
                
            }
        }
    }
    
    //    MARK: Get images from coredata and saves them
    fileprivate func getImages() {
        
        if !fetchedResultsController.fetchedObjects!.isEmpty && fetchedResultsController.fetchedObjects != nil {
            setActivityView(false)
            
        }else{
            print("fetched results controller count: \(String(describing: fetchedResultsController.fetchedObjects?.count))")
            setActivityView(true)
            FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude, completionHandler: photoSearchLocationHandler(success:error:url:))
        }
        
    }
    
    func photoSearchLocationHandler(success: Bool,  error: Error?,url: [String]?) {
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
        
        for photoLink in urlArray{
            
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
        
    }
    
    //  MARK: Setup the fetched results controller
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
    
    //  MARK:function for getting the data from the url
    func getData(from url: URL, completionHandler: @escaping(Data?, URLResponse?,Error?) -> Void){
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler).resume()
    }
    
    //    MARK: setup the pin and disable any user interaction
    fileprivate func pinSetup() {
        
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
    
    func setActivityView(_ loading: Bool) {
        if loading {
            self.activityView.startAnimating()
        } else {
            self.activityView.stopAnimating()
        }
        self.newCollectionButton.isEnabled = !loading
    }
}
