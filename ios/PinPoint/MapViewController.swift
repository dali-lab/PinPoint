//
//  MapViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 1/30/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.hidden = true;
        
        // initialize the map view
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 43.7070798,
            longitude: -72.2867714),
            zoomLevel: 15, animated: false)
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    @IBAction func deliverHere(sender: AnyObject) {
        // convert `mapView.centerCoordinate` (CLLocationCoordinate2D)
        // to screen location (CGPoint)
        let centerScreenPoint: CGPoint = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: mapView)
        print("Screen center: \(centerScreenPoint) = \(mapView.center)")
        let location: CLLocationCoordinate2D = mapView.convertPoint(centerScreenPoint, toCoordinateFromView: mapView)
        print("You tapped at: \(location.latitude), \(location.longitude)")
        
    }
}