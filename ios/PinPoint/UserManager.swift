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
    var location: CLLocationCoordinate2D! = CLLocationCoordinate2D(latitude: 43.705435, longitude: -72.2891243) // Baker librry
    var phoneNumber: String!
    var phoneNumberVerified: Bool! = false
    var pictureURL: String!
    private var uid: String!
    
    // TODO refactor login/new user code here; this will probably just take the methods from SignUp- and Login- ViewController
    func login() -> Bool {
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            return false
        }
        setUID(FBSDKAccessToken.currentAccessToken().userID)
        
        print("User logged in with Facebook")
        return true
    }
    
    func alreadyLoggedIn(completion: () -> Void) {
        if (login()) {
            userRef.childByAppendingPath("phone_number_verified").observeSingleEventOfType(.Value, withBlock: { snapshot in
                if (String(snapshot.value) == "1") { // true
                    completion()
                }
            })
        }
    }
  
    // logout; returns true if successful, false otherwise
    // TODO what should be done in the case of unsuccessful logout? is it even possible?
    func logout() -> Bool {
        // Facebook logout
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        return true
    }
    
    func signUp(auth: FAuthData) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error == nil {
                // get user data
                print("fetched user: \(result)") // TODO this should be refactored to UserManager
                let result = result as! NSDictionary
                var data = [String: String]()
                data["uid"] = (auth.uid as String)
                data["name"] = (result["name"] as! String)
                data["email"] = (result["email"] as! String)
                data["phone_number_verified"] = "false"
                
                // get picture data
                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({
                    (connection, result, error: NSError!) -> Void in
                    if error == nil {
                        // get picture data
                        let result = result as! NSDictionary
                        let pictureData = result["data"] as! NSDictionary
//                        print("data result:\n\(pictureData)")
                        data["profile_picture"] = (pictureData["url"] as! String)
                        UserManager.user.pictureURL = pictureData["url"] as! String
                        
                        // get ref and save
                        let userRef = self.ref.childByAppendingPath("users")
                        let user = [UserManager.user.getUID(): data]
                        userRef.setValue(user)
                        
                    } else {
                        print("Error: \(error)")
                        // TODO
                    }
                })
                
            } else {
                print("Error: \(error)")
                // TODO
            }
        })
    }
    
    func setProfileImage(imageView: UIImageView) {
        userRef.childByAppendingPath("profile_picture").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.pictureURL = String(snapshot.value)
            if let url = NSURL(string: self.pictureURL) {
                print("Download for profile picture started")
                print("lastPathComponent: " + (url.lastPathComponent ?? ""))
                self.getDataFromUrl(url) { (data, response, error)  in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        guard let data = data where error == nil else { return }
                        print("Download finished")
                        imageView.image = UIImage(data: data)
                    }
                }
            }
        })
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func haveUserRef() -> Bool {
        if (userRef != nil) {
            return true
        } else {
            print("Error: userRef not set")
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
    
    func getAndSetPhoneNumberVerified() -> Bool {
        // TODO need to get phone number verified
        // first need to set the userRef, which needs to be done in the loggedIn method by whichever thing has already logged the user in
        return true;
    }
    
    // set local and database phone numbers
    func setPhoneNumberVerified(verified: Bool!) {
        self.phoneNumberVerified = verified
        updateUser(["phone_number_verified": self.phoneNumberVerified])
    }
    
    func getUID() -> String! {
        return self.uid
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