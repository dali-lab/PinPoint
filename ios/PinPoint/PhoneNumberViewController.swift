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
        if (checkTextFields()) {
            var userRef = self.ref.childByAppendingPath("users")
            userRef = userRef.childByAppendingPath(uid)
            userRef.updateChildValues(["phone_number": phoneNumbertextField.text!])
            self.performSegueWithIdentifier("basicInfoEnteredSegue", sender: self)
        }
    }
    
    func checkTextFields() -> Bool {
        if (phoneNumbertextField.text?.characters.count != 10) {
            phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            return false
        } else {
            return true
        }
    }
}
