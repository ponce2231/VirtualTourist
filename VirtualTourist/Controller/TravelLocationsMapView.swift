//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/26/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin: Pin?
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupFetchedResultsController()
        
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleOnTap))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
        mapView.reloadInputViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        fetchedResultsController = nil
    }
    
    //MARK: Configures the fetch request
    fileprivate func setupFetchedResultsController() {
        print("setup Fetched results controller functions")
        
        dataController = appDelegate.dataController
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        print("configured the fetchedResults controller")
        performFetch()
        loadAnnotations()
    }
    
//MARK:Loads annotation
    fileprivate func loadAnnotations() {
        print("load annotations function")
        var annotations = [MKAnnotation]()
        var counter = 0
        for pin in fetchedResultsController.fetchedObjects!{
            print("pin objects count: \(counter)")
            counter += 1
            
            let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
//MARK:Place annotations
  @objc fileprivate func handleOnTap(longTapRecognizer: UILongPressGestureRecognizer) {
   
    print("Handle on tap function")
    if longTapRecognizer.state == UIGestureRecognizer.State.began{
        print("tap began")
        let location = longTapRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            try? dataController.viewContext.save()
        }else if longTapRecognizer.state == UIGestureRecognizer.State.ended{
            print("tap ended")
            return
        }
        
    }
//  MARK: Perform fetch Objects
    func performFetch() {
//        guard fetchedResultsController.fetchedObjects != nil else{
//            print("fetch is nil")
//            return
//        }
        print("perform fetch called")
        do{
            try fetchedResultsController.performFetch()
            print("fetch performed")
        }catch{
            fatalError("fetch could not be performed \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let pin = selectedPin else{
            return
        }
        
        if let albumeVC = segue.destination as? PhotoAlbumViewController{
            albumeVC.pin = pin
            albumeVC.dataController = self.dataController
        }
    }

}

// MARK: MapKit Delegate Functions
extension TravelLocationsMapView: MKMapViewDelegate{
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        var selectedAnnotation: MKPointAnnotation?
        var counter = 0
        print("did select function")
        selectedAnnotation = view.annotation as? MKPointAnnotation
        print("perform fetch on did select function")
        performFetch()
        for location in fetchedResultsController.fetchedObjects!{
            print("Comparing location with selected pin coordinates")
            print("fetched locations:\(counter)")
            counter += 1
            if location.latitude == selectedAnnotation?.coordinate.latitude && location.longitude == selectedAnnotation?.coordinate.longitude{
                selectedPin = location
                print("halleluya")
                print(location)
            }
        }
        performSegue(withIdentifier: "albumeVCsegue", sender: nil)
        mapView.deselectAnnotation(selectedAnnotation, animated: false)
    }
    

}
