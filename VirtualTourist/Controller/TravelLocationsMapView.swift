//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/26/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapView: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOnTap))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
        
    }
    
  @objc fileprivate func handleOnTap(tapRecognizer: UILongPressGestureRecognizer) {
        
        let location = tapRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        
        FlickerClient.photoSearchLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, completionHandler: photoSearchHandler(success:error:))
    }
    
    func photoSearchHandler(success:Bool, error: Error?){
        if success{
            print("watermelon")
        }else{
            print(error?.localizedDescription)
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
              // pinView!.canShowCallout = true
               pinView!.pinTintColor = .red
               pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
           }
           else {
               pinView!.annotation = annotation
           }
           
           return pinView
       }
}
