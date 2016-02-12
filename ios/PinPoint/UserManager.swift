//
//  UserManager.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/11/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import MapKit

class UserManager {
    static let user = UserManager()
    
    var uid: String!
    var pictureURL: String!
    var confirmationCode: String!
    var location: CLLocationCoordinate2D!
    
}