//
//  UserManager.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/11/16.
//  Copyright © 2016 DALI. All rights reserved.
//

// User singleton

import FBSDKLoginKit
import Firebase
import MapKit

class UserManager {
    static let user = UserManager()
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    var userRef: Firebase! = nil
    
    var code: String!
    var location: CLLocationCoordinate2D!
    var phoneNumber: String!
    var pictureURL: String!
    private var uid: String!
    
    // TODO refactor login/new user code here; this will probably just take the methods from SignUp- and Login- ViewController
    func login() -> Bool{
        return true
    }
  
    // logout; returns true if successful, false otherwise
    // TODO what should be done in the case of unsuccessful logout? is it even possible?
    func logout() -> Bool {
        // Facebook logout
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        return true
    }
    
    func haveUserRef() -> Bool {
        if (userRef != nil) {
            return true
        } else {
            print("Error: userRef not set)")
            return false
        }
    }
    
    func getCode() -> String! {
        return code
    }
    
    // set local and database code value
    func setCode(code: String!) {
        self.code = code
        updateUser(["confirmation_code": self.code]) // TODO do we really need to store this?
    }
    
    // use Twilio to send the code in a text to the user
    func sendCodeToUser() -> Bool {
        // get twilio keys
        var keys: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("twilio_keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        // send message
        if let _ = keys {
            let twilioSID  = keys?["twilioSID"] as! String
            let twilioSecret = keys?["twilioSecret"] as! String
            let fromNumber = "19784714165"
            let toNumber = self.phoneNumber
            let message = "Your confirmation number is \(UserManager.user.getCode())"
            
            // build the request
            let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
            
            // build the completion block and send the request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let data = data, _ = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    // Success
                    print("Successfully sent Twilio POST request")
                    //                    print("Response: \(responseDetails)")
                } else {
                    // Failure
                    print("Error: \(error)")
                    //TODO how should we handle this?
                }
            }).resume()
            return true
        }
        return false
    }
    
    // set local and database phone numbers
    func setPhoneNumber(phoneNumber: String!) {
        self.phoneNumber = phoneNumber
        updateUser(["phone_number": self.phoneNumber])
    }
    
    // set UID and create userRef
    func setUID(uid: String!) {
        self.uid = uid
        userRef = self.ref.childByAppendingPath("users").childByAppendingPath(self.uid)
    }
    
    func updateUser(data: [String: AnyObject]) {
        if (haveUserRef()) {
            userRef.updateChildValues(data)
        }
    }
    
}