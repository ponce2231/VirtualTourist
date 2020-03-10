//
//  TravelLocationExtension.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 3/8/20.
//  Copyright © 2020 none. All rights reserved.
//

import UIKit
import MapKit
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
        
        selectedAnnotation = view.annotation as? MKPointAnnotation
        
        performFetch()
        for location in fetchedResultsController.fetchedObjects!{
            
            if location.latitude == selectedAnnotation?.coordinate.latitude && location.longitude == selectedAnnotation?.coordinate.longitude{
                
                selectedPin = location
            }
        }
        performSegue(withIdentifier: "albumeVCsegue", sender: nil)
        mapView.deselectAnnotation(selectedAnnotation, animated: false)
    }
    
}
