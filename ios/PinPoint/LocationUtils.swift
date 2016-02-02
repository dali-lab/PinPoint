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
    
    class func addressFromPlacemark(placemarks: [CLPlacemark]) -> String {
        var address: String = ""
        let pm = placemarks[0] as CLPlacemark
        print("placemarks: " + String(placemarks.count))
        if let addressPart = pm.subThoroughfare {
            address = addressPart + " "
        }
        if let addressPart = pm.thoroughfare {
            address.appendContentsOf(addressPart + ", ")
        }
        if let addressPart = pm.locality {
            address.appendContentsOf(addressPart)
        }
        return address
    }
    
    class func forwardGeocoding(address: String, completion: ([CLPlacemark]) -> Void ) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Error while searching \(error)")
                return
            }
            if placemarks?.count > 0 {
                completion(placemarks!)
            }
        })
    }
}