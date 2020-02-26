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
    var urlImage: String?
  

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load called")
        print(pin.latitude, pin.longitude)
        
        pinSetup()
        coreDataFetch()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
                fetchedResultsController = nil
    }
    

    
    @IBAction func newCollectionWasPressed(_ sender: Any) {
        
        print("new collection was called")
        
            deleteAndFetch()
            pageCounter += 1
       

        print("page counter new collection: \(pageCounter)")
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        print("back button pressed was called")
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func selectingImagesToDelete() {
        print("selecting images to delete called")
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
        print("core data fetched called")
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
        print("get images called")
        if fetchedResultsController.fetchedObjects!.isEmpty == false && fetchedResultsController.fetchedObjects != nil {
            print("fetched results controller is \(String(describing: fetchedResultsController.fetchedObjects))")
            for image in fetchedResultsController.fetchedObjects!{
                urlData = image.imageData
                print(urlData)
            }
        }else{
            print("fetched results controller is \(String(describing: fetchedResultsController.fetchedObjects))")
            
            FlickerClient.photoSearchLocation(latitude: pin.latitude, longitude: pin.longitude) {(success, error, url) in
                
                print("photo search location function called")
                
                guard let urlArray = url else{
                    print("Url is nil")
                    return
                }
                self.saveImageDataToCoreData(urlArray,pin: self.pin)
            }
        }
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

                print("this is Data: \(String(describing: data))")

            })
        
            print("pic object\(pic)")
            print("pin image data \(String(describing: pic.imageData))")
            print(" pic url \(String(describing: pic.url))")
            print("pic pin object \(String(describing: pic.pin))")
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
    
//  MARK:function for getting the data from the url
    func getData(from url: URL, completionHandler: @escaping(Data?, URLResponse?,Error?) -> Void){
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler).resume()
    }
}
// MARK: Fetched Results Controller delegate Functions
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
   
    //Check Documentation on apple docs
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionAlbumeView.EndUpdate()
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
        if let imageData = anImage.imageData {
            // Configure the cell
            let downloadedImage = UIImage(data: imageData)
            print("downloaded image \(String(describing: downloadedImage))")

            DispatchQueue.main.async {
                cell.imageView.image = downloadedImage
            }
        }else{
            print("anImage data is: \(String(describing: anImage.imageData))")
        }
        return cell
    }
}

//  MARK:collectionview delegate flow layout functions
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

//  MARK:Map delegate functions
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


