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

class PhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var phoneNumbertextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: PlaceholderColor])
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let loginManager = FBSDKLoginManager.init()
        loginManager.logOut()
        performSegueWithIdentifier("returnHomeSegue", sender: self)
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        if (checkTextFields()) {
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
