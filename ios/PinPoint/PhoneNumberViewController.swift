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
    var uid: String!
    var pictureURL: String!
    var confirmationCode: String!
    
    @IBOutlet weak var phoneNumbertextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let leftNavItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonPressed")
        navigationItem.leftBarButtonItem = leftNavItem
        
        let rightNavItem = UIBarButtonItem(title: "Continue", style: .Plain, target: self, action: "nextButtonPressed")
        navigationItem.rightBarButtonItem = rightNavItem

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: PlaceholderColor])
    }
    
    func logoutButtonPressed() {
        print("Logging out")
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func nextButtonPressed() {
        // Use your own details here
        var keys: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("twilio_keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let _ = keys {
            let twilioSID  = keys?["twilioSID"] as! String
            let twilioSecret = keys?["twilioSecret"] as! String
            let fromNumber = "19784714165"
            let toNumber = phoneNumbertextField.text as String!
            let message = "Your confirmation number is \(self.confirmationCode)"
            
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
                    //TODO
                }
            }).resume()
            self.performSegueWithIdentifier("basicInfoEnteredSegue", sender: self)
        }
//        if (checkTextFields()) {
//            var userRef = self.ref.childByAppendingPath("users")
//            userRef = userRef.childByAppendingPath(uid)
//            userRef.updateChildValues(["phone_number": phoneNumbertextField.text!])
//            self.performSegueWithIdentifier("basicInfoCompleteSegue", sender: self)
//        }
    }
    
    func checkTextFields() -> Bool {
        if (phoneNumbertextField.text?.characters.count != 10) {
            phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            return false
        } else {
            return true
        }
    }
    
    // send uid to next VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ConfirmPhoneNumberViewController {
            destination.uid = self.uid
            destination.pictureURL = self.pictureURL
            destination.confirmationCode = self.confirmationCode
        }
    }
}
