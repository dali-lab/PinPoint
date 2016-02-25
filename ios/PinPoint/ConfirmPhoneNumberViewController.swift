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
    
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let rightNavItem = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "confirmConfirmationNumber")
        navigationItem.rightBarButtonItem = rightNavItem
        
        self.navigationItem.title = "Verify Phone Number"
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // phone number verification
    func confirmConfirmationNumber() {
        if (textFieldValid() && UserManager.user.getCode() == confirmationCodeTextField.text! as String) {
            print("Confirmation code successful")
            performSegueWithIdentifier("phoneNumberConfirmedSegue", sender: self)
        } else {
            // TODO need to display some more error warning stuff CHARLEY TODO
            confirmationCodeTextField.text = ""
            confirmationCodeTextField.attributedPlaceholder = NSAttributedString(string:"Confirmation Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
        }
    }
    
    // check validity of text entry CHARLEY TODO
    func textFieldValid() -> Bool {
        let text = confirmationCodeTextField.text
        if (text?.characters.count != 4){ // TODO more checking/user response?
            return false
        } else {
            return true
        }
    }
    
    // TODO text input handling
    
}