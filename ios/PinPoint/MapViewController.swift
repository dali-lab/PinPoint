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
//import SlideMenuControllerSwift

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var deliverHereButton: UIButton!
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    let user = UserManager.user
    
    var mapView: MGLMapView!
//    var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var gotUserLocation = false
    var searchViewController: SearchLocationViewController!
    
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
        

        // TODO better picture url fetch; put in db
//        if let url = user.pictureURL {
//            if let checkedUrl = NSURL(string: url) {
//                downloadImage(checkedUrl)
//            }
//        }
//        
        profileImage.contentMode = .ScaleAspectFit
        print("did load")
        UserManager.user.setProfileImage(profileImage)
        
        // profile picture setup
        let profileTap = UITapGestureRecognizer(target: self, action:"profileImagePressed")
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(profileTap)
        
        setMapCenterToUserLocationWithZoom(16)
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        slideMenuController()?.navigationController?.navigationBarHidden = true
        slideMenuController()?.removeRightGestures()
        slideMenuController()?.removeLeftGestures()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        print("did appear")
//        UserManager.user.setProfileImage(profileImage)
        
        // TODO better way to set default location behavior?
        // set default location each view is presented
//        setMapCenterToUserLocationWithZoom(16)
        
//        navigationController?.navigationBar.hidden = true
//        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    // respond to profile image press
    func profileImagePressed() {
        print("profile image pressed")
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
    
    // action for "deliver here" button
    @IBAction func deliverHere(sender: AnyObject) {
        setUserLocationToScreenCenter()
        setMapCenterToUserLocation()
    }
    
    // Set location for top bar and map while using the default zoom value
    func setMapCenterToUserLocation() {
        // update top bar
        let location: CLLocation = CLLocation(latitude: UserManager.user.location.latitude, longitude: UserManager.user.location.longitude)
        LocationUtils.reverseGeocoding(location, completion: updateResultBar)
        
        // update map location by setting center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(
            latitude: UserManager.user.location.latitude,
            longitude: UserManager.user.location.longitude),
            animated: true)
    }
    
    // Set location for top bar and map but take in a zoom level
    func setMapCenterToUserLocationWithZoom(zoom: Double) {
        // update top bar
        let location: CLLocation = CLLocation(latitude: UserManager.user.location.latitude, longitude: UserManager.user.location.longitude)
        LocationUtils.reverseGeocoding(location, completion: updateResultBar)
        
        // update map location by setting center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(
            latitude: UserManager.user.location.latitude,
            longitude: UserManager.user.location.longitude),
            zoomLevel: zoom,
            animated: true)
    }
    
    func updateResultBar(placemark: CLPlacemark) {
        locationButton.setTitle(LocationUtils.addressFromPlacemark(placemark), forState: .Normal)
    }
    
    // get user's current location once
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO manager not nil?
        if (!gotUserLocation) {
            print("Getting and setting map to user location")
            UserManager.user.location = manager.location!.coordinate
            setMapCenterToUserLocationWithZoom(16)
            gotUserLocation = true
            locationManager.stopUpdatingLocation()
        }
    }
    
    // get screen center point and set the user's location
    func setUserLocationToScreenCenter() {
        let centerScreenPoint: CGPoint = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: mapView)
        UserManager.user.location = mapView.convertPoint(centerScreenPoint, toCoordinateFromView: mapView)
    }
}

// handle returns from user's searching
extension MapViewController: SearchResultDelegate {
    
    func searchResultSelected(sender: AnyObject) {
        let cell = sender as! ResultTableViewCell
        UserManager.user.location = cell.placemark.location?.coordinate
        setMapCenterToUserLocationWithZoom(16)
    }
    
    func setToCurrentLocation(sender: AnyObject) {
        gotUserLocation = false
        locationManager.startUpdatingLocation()
    }
}