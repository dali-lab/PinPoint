//
//  PhoneNumberViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 1/30/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import Firebase

class PhoneNumberViewController: UIViewController {
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    @IBOutlet weak var phoneNumbertextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // setup custom nav bar items
        let leftNavItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonPressed")
        navigationItem.leftBarButtonItem = leftNavItem
        let rightNavItem = UIBarButtonItem(title: "Continue", style: .Plain, target: self, action: "nextButtonPressed")
        navigationItem.rightBarButtonItem = rightNavItem

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reset phone number placeholder color
        phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: PlaceholderColor])
        
        // get new confirmation code
        let code = String(arc4random_uniform(UInt32(9000)) + 1000)
        UserManager.user.confirmationCode = code
        
        // update confirmation code in database
        var userRef = self.ref.childByAppendingPath("users")
        userRef = userRef.childByAppendingPath(UserManager.user.uid)
        userRef.updateChildValues(["confirmation_code": code])
        
    }
    
    // log out (of Facebook)
    func logoutButtonPressed() {
        print("Logging out")
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func nextButtonPressed() {
        if (checkTextFields()) {
            var userRef = self.ref.childByAppendingPath("users")
            userRef = userRef.childByAppendingPath(UserManager.user.uid)
            userRef.updateChildValues(["phone_number": phoneNumbertextField.text!])
            
            // build Twilio POST request
            var keys: NSDictionary?
            if let path = NSBundle.mainBundle().pathForResource("twilio_keys", ofType: "plist") {
                keys = NSDictionary(contentsOfFile: path)
            }
            if let _ = keys {
                let twilioSID  = keys?["twilioSID"] as! String
                let twilioSecret = keys?["twilioSecret"] as! String
                let fromNumber = "19784714165"
                let toNumber = phoneNumbertextField.text as String!
                let message = "Your confirmation number is \(UserManager.user.confirmationCode)"
                
                // Build the request
                let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")!)
                request.HTTPMethod = "POST"
                request.HTTPBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(message)".dataUsingEncoding(NSUTF8StringEncoding)
                
                // Build the completion block and send the request
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                    print("Finished")
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
                // segue!
                self.performSegueWithIdentifier("basicInfoEnteredSegue", sender: self)
            }
            
        }
    }
    
    func checkTextFields() -> Bool {
        if (phoneNumbertextField.text?.characters.count != 10) {
            // TODO need to display some more stuff
            phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            return false
        } else {
            return true
        }
    }
}
