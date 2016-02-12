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
import SlideMenuControllerSwift

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, SearchResultDelegate{
    
    
    @IBOutlet weak var searchButton: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var locationBar: UILabel!
    @IBOutlet weak var deliverHereButton: UIButton!
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    let user = UserManager.user
    
    var mapView: MGLMapView!
//    var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let defaultCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 43.705435, longitude: -72.2891243) // Baker librry
    var gotUserLocation = false
    var searchViewController: SearchLocationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.hidden = true;
        navigationController?.hidesBarsOnSwipe = true;
        
        initMapView()
        
        // set default location; should probably do this better/differently
        UserManager.user.location = defaultCoordinate
        
        searchViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchLocationViewController
        searchViewController.delegate = self
        
        UIUtils.styleImage(profileImage, borderColor: ThemeAccent.CGColor, borderWidth: BorderWidth, cornerRadius: profileImage.frame.height/2)
        
        
        UIUtils.styleButton(deliverHereButton, textColor: ThemeText, borderColor: nil, borderWidth: 0, cornerRadius: 0, backgroundColor: ThemeAccent.CGColor)
        

        if let checkedUrl = NSURL(string: user.pictureURL) {
            profileImage.contentMode = .ScaleAspectFit
            downloadImage(checkedUrl)
        }
        
        
        // profile picture setup
        var singleTap = UITapGestureRecognizer(target: self, action:"profileImagePressed")
        singleTap.numberOfTapsRequired = 1
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(singleTap)
        
        // search button setup
        singleTap = UITapGestureRecognizer(target: self, action:"searchButtonPressed")
        searchButton.userInteractionEnabled = true
        searchButton.addGestureRecognizer(singleTap)
    }
    
    override func awakeFromNib() {
//        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Map") {
//            self.slideMenuController()?.mainViewController = controller
//        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileSlideOut") {
            self.slideMenuController()?.leftViewController = controller
        }
        super.awakeFromNib()
    }
    
    func profileImagePressed() {
        self.slideMenuController()?.openLeft()
    }
    
    func downloadImage(url: NSURL){
        print("attempting to download image: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print("downloaded profile image: " + (response?.suggestedFilename)!)
                self.profileImage.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func viewProfile(recognizer: UITapGestureRecognizer){
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO better way to set default location behavior?
        setLocation()
    }
    
    func searchButtonPressed() {
        self.presentViewController(searchViewController, animated: true, completion: nil) //TODO completion
    }
    
    // initializes the map
    func initMapView() {
        // TODO allow rotation?
        // initialize the map view
        mapView = MGLMapView(frame: view.bounds)
//        mapView = MKMapView(frame: view.bounds)
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
    
//    func mapView(mapView: MKMapView, annotationCanShowCallout annotation: MKAnnotation) -> Bool {
//        return true
//    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    @IBAction func deliverHere(sender: AnyObject) {
        getScreenCenterPoint()
        setLocation()
    }
    
    func searchResultSelected(sender: AnyObject) {
        let cell = sender as! ResultTableViewCell
        UserManager.user.location = cell.placemark.location?.coordinate
        setLocation()
    }
    
    // Set location for top bar, map center
    func setLocation() {
        // update top bar
        let location: CLLocation = CLLocation(latitude: UserManager.user.location.latitude, longitude: UserManager.user.location.longitude)
        LocationUtils.reverseGeocoding(location, completion: updateResultBar)
        
        // update map location by setting center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(
            latitude: UserManager.user.location.latitude,
            longitude: UserManager.user.location.longitude),
            zoomLevel: 16,
            animated: false)
//        mapView.setCenterCoordinate(CLLocationCoordinate2D(
//            latitude: currCoordinate.latitude,
//            longitude: currCoordinate.longitude),
//            animated: false)
        
        let lat = String(format: "%f", arguments: [UserManager.user.location.latitude])
        let long = String(format: "%f", arguments: [UserManager.user.location.longitude])
        print("set map location = \(lat) \(long)")
    }
    
    func updateResultBar(placemark: CLPlacemark) {
        self.locationBar.text = LocationUtils.addressFromPlacemark(placemark)
    }
    
    // get user's current location once
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO manager not nil?
        if (!gotUserLocation) {
            UserManager.user.location = manager.location!.coordinate
            setLocation()
            gotUserLocation = true
            locationManager.stopUpdatingLocation()
        }
    }
    
    // get screen center point
    func getScreenCenterPoint() {
        let centerScreenPoint: CGPoint = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: mapView)
        UserManager.user.location = mapView.convertPoint(centerScreenPoint, toCoordinateFromView: mapView)
    }
}