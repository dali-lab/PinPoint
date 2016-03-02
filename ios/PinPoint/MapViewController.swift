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
import MapKit
import Firebase

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var textCenterPoint: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var deliverHereButton: UIButton!
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    var mapView: MGLMapView!
    let locationManager = CLLocationManager()
    var searchViewController: SearchLocationViewController!
    
//    var timer: NSTimer!
    var gotLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initMapView()
        
        // set search delegate
        searchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchLocationViewController
        searchViewController.delegate = self
        
        profileImage.layer.borderColor = ThemeAccent.CGColor
        profileImage.layer.borderWidth = BorderWidthSmall
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        // TODO corner radius
//        locationBar.backgroundColor = White
        locationButton.layer.backgroundColor = White.CGColor
        locationButton.layer.borderColor = Grey.CGColor
        locationButton.layer.borderWidth = BorderWidth
        locationButton.layer.cornerRadius = CornerRadius
        locationButton.layer.backgroundColor = White.CGColor
        locationButton.clipsToBounds = true
        
        deliverHereButton.layer.borderColor = ThemeAccent.CGColor
        deliverHereButton.layer.borderWidth = BorderWidth
        deliverHereButton.layer.cornerRadius = CornerRadius
        deliverHereButton.layer.backgroundColor = ThemeAccent.CGColor
        deliverHereButton.clipsToBounds = true
        
        profileImage.contentMode = .ScaleAspectFit
        UserManager.user.setProfileImage(profileImage)
        
        // profile picture setup
        let profileTap = UITapGestureRecognizer(target: self, action:"profileImagePressed")
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(profileTap)
        
        setMapCenterToUserLocationWithZoom(16)
        navigationController?.interactivePopGestureRecognizer?.enabled = false // disable left swipe
        
        slideMenuController()?.navigationController?.navigationBarHidden = true
        slideMenuController()?.removeRightGestures()
        slideMenuController()?.removeLeftGestures()
        
        textCenterPoint.text = "" //remove ><, which is stil used to center the pin
    }
    
    // respond to profile image press
    func profileImagePressed() {
        self.slideMenuController()?.openLeft()
    }
    
    // show search view controller
    @IBAction func searchButtonPressed(sender: AnyObject) {
        self.presentViewController(searchViewController, animated: true, completion: nil) //TODO completion; modal?
    }
    
    // initializes the map
    func initMapView() {
        // initialize the map view
        mapView = MGLMapView(frame: view.bounds,
                             styleURL: MGLStyle.streetsStyleURL())
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        mapView.rotateEnabled = false
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
        // Location service
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            locationManager.distanceFilter = 15
        }
    }
    
//    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//        if let timer = timer { // stop old timer
//            timer.invalidate()
//        }
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "deliverHere:", userInfo: nil, repeats: false)
//    }
    
    // action for "deliver here" button
    @IBAction func deliverHere(sender: AnyObject) {
        setUserLocationToScreenCenter()
        setMapCenterToUserLocation()
    }
    
    // Set location for top bar and map while using the default zoom value
    func setMapCenterToUserLocation() {
        // update top bar
        LocationUtils.reverseGeocoding(UserManager.user.location, completion: updateResultBar)
        
        // update map location by setting center coordinate
        mapView.setCenterCoordinate(UserManager.user.location.coordinate, animated: true)
    }
    
    // Set location for top bar and map but take in a zoom level
    func setMapCenterToUserLocationWithZoom(zoom: Double) {
        // update top bar
        LocationUtils.reverseGeocoding(UserManager.user.location, completion: updateResultBar)
        
        // update map location by setting center coordinate
        mapView.setCenterCoordinate(UserManager.user.location.coordinate,
            zoomLevel: zoom,
            animated: true)
    }
    
    func updateResultBar(placemark: CLPlacemark) {
        locationButton.setTitle(LocationUtils.addressFromPlacemark(placemark), forState: .Normal)
    }
    
    // get user's current location once
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let dist = manager.location!.distanceFromLocation(UserManager.user.location)
        if (dist > 15 || !gotLocation) { // significant change in location reading
            print("Getting and setting map to user location (distance: \(dist))")
            UserManager.user.location = manager.location
            setMapCenterToUserLocationWithZoom(16)
            gotLocation = true
        }
    }
    
    // get screen center point and set the user's location
    func setUserLocationToScreenCenter() {
        UserManager.user.setLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
    }
}

// handle returns from user's searching
extension MapViewController: SearchResultDelegate {
    func searchResultSelected(sender: AnyObject) {
        let cell = sender as! ResultTableViewCell
        UserManager.user.location = cell.placemark.location
        setMapCenterToUserLocationWithZoom(16)
    }
    
    func setToCurrentLocation(sender: AnyObject) {
        UserManager.user.setLocation(locationManager.location!)
    }
}