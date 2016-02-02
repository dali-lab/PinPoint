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

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationBar: UILabel!
    
    var mapView: MGLMapView!
    let locationManager = CLLocationManager()
    let defaultCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 43.705435, longitude: -72.2891243) // Baker librry
    var userCoordinate: CLLocationCoordinate2D!
    var gotUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.hidden = true;
        
        initMapView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO better way to set default location behavior?
        userCoordinate = defaultCoordinate
        setLocation()
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        
    }
    
    // initializes the Mapbox map
    func initMapView() {
        // initialize the map view
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
        // Location service
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    @IBAction func deliverHere(sender: AnyObject) {
        getScreenCenterPoint()
        setLocation()
    }
    
    // Set location for top bar, map center
    func setLocation() {
        // top bar
        let location: CLLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with an error" + error!.localizedDescription)
            } else if placemarks!.count > 0 {
                self.locationBar.text = LocationUtils.addressFromPlacemark(placemarks!)
            } else {
                print("Problems with the data received from geocoder.")
            }
        })
        
        // map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(
            latitude: userCoordinate.latitude,
            longitude: userCoordinate.longitude),
            zoomLevel: 16, animated: false)
        
        let lat = String(format: "%f", arguments: [userCoordinate.latitude])
        let long = String(format: "%f", arguments: [userCoordinate.longitude])
        print("set map location = \(lat) \(long)")
    }
    
    // get user's current location once
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO manager not nil?
        if (!gotUserLocation) {
            self.userCoordinate = manager.location!.coordinate
            setLocation()
            gotUserLocation = true
            locationManager.stopUpdatingLocation()
        }
    }
    
    // get screen center point
    func getScreenCenterPoint() {
        let centerScreenPoint: CGPoint = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: mapView)
        userCoordinate = mapView.convertPoint(centerScreenPoint, toCoordinateFromView: mapView)
    }
}