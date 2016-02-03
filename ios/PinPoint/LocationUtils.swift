//
//  LocationUtils.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/1/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import Foundation
import Mapbox
import CoreLocation

class LocationUtils {
    
    class func addressFromPlacemark(placemark: CLPlacemark) -> String {
        var address: String = ""
        if let addressPart = placemark.subThoroughfare {
            address = addressPart + " "
        }
        if let addressPart = placemark.thoroughfare {
            address.appendContentsOf(addressPart + ", ")
        }
        if let addressPart = placemark.locality {
            address.appendContentsOf(addressPart)
        }
        return address
    }
    
    // Given an address string returns an array of placemarks
    class func forwardGeocoding(address: String, completion: ([CLPlacemark]) -> Void ) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Forward geocoder failed with an error" + error!.localizedDescription)
                return
            } else if placemarks?.count > 0 {
                completion(placemarks!)
            } else {
                print("Forward geocoding returned no placemarks.")
            }
        })
    }
    
    // Given a location returns a single placemark
    class func reverseGeocoding(location: CLLocation, completion: (CLPlacemark) -> Void ) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with an error" + error!.localizedDescription)
                return
            } else if placemarks!.count > 0 {
                completion(placemarks![0]) // return the top result
            } else {
                print("Rerverse geocoding returned no placemarks.")
            }
        })
    }
}