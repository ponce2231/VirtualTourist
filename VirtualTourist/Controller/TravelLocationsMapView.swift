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
    static var pin: Pin?
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleOnTap))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
        
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    //MARK: Configures the fetch request
    fileprivate func setupFetchedResultsController() {
        dataController = appDelegate.dataController
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
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
    //MARK:Place annotations
  @objc fileprivate func handleOnTap(tapRecognizer: UILongPressGestureRecognizer) {

        let location = tapRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        try? dataController.viewContext.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let pinLocationVC = TravelLocationsMapView.pin else{
           return
       }
        if let albumeVC = segue.destination as? PhotoAlbumViewController{
                albumeVC.pin = pinLocationVC
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
        TravelLocationsMapView.pin = view.annotation as? Pin
        //create the loop and compare it too
        for location in fetchedResultsController.fetchedObjects!{
            if location.latitude == TravelLocationsMapView.pin?.latitude && location.longitude == TravelLocationsMapView.pin?.longitude{
                TravelLocationsMapView.pin = location
                
                dump(TravelLocationsMapView.pin?.latitude)
            }
        }
    }
}
