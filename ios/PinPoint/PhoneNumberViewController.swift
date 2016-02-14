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
        
        self.navigationItem.title = "Add Phone Number"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reset phone number placeholder color
        phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: PlaceholderColor])
        
        // get and set new confirmation code
        let code = String(arc4random_uniform(UInt32(9000)) + 1000) // 4 digit code
        UserManager.user.setCode(code)
    }
    
    // log out (of Facebook)
    func logoutButtonPressed() {
        UserManager.user.logout()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func nextButtonPressed() {
        if (textFieldValid()) { // valid text entry
            UserManager.user.setPhoneNumber(phoneNumbertextField.text as String!)
            
            if (UserManager.user.sendCodeToUser()) {
                self.performSegueWithIdentifier("basicInfoEnteredSegue", sender: self)
            }
        }
    }
    
    // check validity of text entry
    func textFieldValid() -> Bool {
        let text = phoneNumbertextField.text
        if (text?.characters.count != 10) {
            // TODO need to display some more error warning stuff CHARLEY TODO
            phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            return false
        } else {
            return true
        }
    }
}
