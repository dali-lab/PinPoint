//
//  ConfirmPhoneNumberViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/6/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ConfirmPhoneNumberViewController: UIViewController {
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    var uid: String!
    var pictureURL: String!
    var confirmationCode: String!
    
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let rightNavItem = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "confirmConfirmationNumber")
        navigationItem.rightBarButtonItem = rightNavItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // phone number verification
    func confirmConfirmationNumber() {
        if let _ = confirmationCode, _ = confirmationCodeTextField.text {
            if confirmationCode == confirmationCodeTextField.text {
                print("Confirmation code successful")
                performSegueWithIdentifier("phoneNumberConfirmedSegue", sender: self)
            } else {
                // TODO need to display some more stuff
                confirmationCodeTextField.text = ""
                confirmationCodeTextField.attributedPlaceholder = NSAttributedString(string:"Confirmation Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            }
        } else {
            // TODO need to display some more stuff
            confirmationCodeTextField.text = ""
            confirmationCodeTextField.attributedPlaceholder = NSAttributedString(string:"Confirmation Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
        }
    }
    
    // send user info to next VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? MapViewController {
            destination.uid = self.uid
            destination.pictureURL = self.pictureURL
        }
    }
}