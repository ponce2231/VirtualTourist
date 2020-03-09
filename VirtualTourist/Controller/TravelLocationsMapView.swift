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
    }
    
    //MARK: Configures the fetch request
    fileprivate func setupFetchedResultsController() {
        
        dataController = appDelegate.dataController
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
    
        performFetch()
        loadAnnotations()
    }
    
//MARK:Loads annotation
    fileprivate func loadAnnotations() {
        
        var annotations = [MKAnnotation]()
        
        for pin in fetchedResultsController.fetchedObjects!{
         
            let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
//MARK: Place annotations
  @objc fileprivate func handleOnTap(longTapRecognizer: UILongPressGestureRecognizer) {
   
    if longTapRecognizer.state == UIGestureRecognizer.State.began{
    
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

            return
        }
        
    }
//  MARK: Perform fetch Objects
    func performFetch() {
       
        do{
            try fetchedResultsController.performFetch()
            
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
