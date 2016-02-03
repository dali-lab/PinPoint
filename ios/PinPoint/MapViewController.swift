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

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, searchResultDelegate {
    
    @IBOutlet weak var locationBar: UILabel!
    
    var mapView: MGLMapView!
    let locationManager = CLLocationManager()
    let defaultCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 43.705435, longitude: -72.2891243) // Baker librry
    var currCoordinate: CLLocationCoordinate2D!
    var gotUserLocation = false
    var searchViewController: SearchLocationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.hidden = true;
        
        initMapView()
        
        // set default location; should probably do this better/differently
        currCoordinate = defaultCoordinate
        
        searchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchLocationViewController
        searchViewController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO better way to set default location behavior?
        setLocation()
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        self.presentViewController(searchViewController, animated: true, completion: nil) //TODO completion
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
    
    func searchResultSelected(sender: AnyObject) {
        let cell = sender as! ResultTableViewCell
        currCoordinate = cell.placemark.location?.coordinate
        setLocation()
    }
    
    // Set location for top bar, map center
    func setLocation() {
        // update top bar
        let location: CLLocation = CLLocation(latitude: currCoordinate.latitude, longitude: currCoordinate.longitude)
        LocationUtils.reverseGeocoding(location, completion: updateResultBar)
        
        // update map location by setting center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(
            latitude: currCoordinate.latitude,
            longitude: currCoordinate.longitude),
            zoomLevel: 16, animated: false)
        
        let lat = String(format: "%f", arguments: [currCoordinate.latitude])
        let long = String(format: "%f", arguments: [currCoordinate.longitude])
        print("set map location = \(lat) \(long)")
    }
    
    func updateResultBar(placemark: CLPlacemark) {
        self.locationBar.text = LocationUtils.addressFromPlacemark(placemark)
    }
    
    // get user's current location once
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO manager not nil?
        if (!gotUserLocation) {
            self.currCoordinate = manager.location!.coordinate
            setLocation()
            gotUserLocation = true
            locationManager.stopUpdatingLocation()
        }
    }
    
    // get screen center point
    func getScreenCenterPoint() {
        let centerScreenPoint: CGPoint = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: mapView)
        currCoordinate = mapView.convertPoint(centerScreenPoint, toCoordinateFromView: mapView)
    }
}