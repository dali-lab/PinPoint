//
//  ConfirmPhoneNumberViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/6/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift

class ConfirmPhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    
    // Charley
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // delegate to process user input and set keyboard as number pad
        confirmationCodeTextField.delegate = self;
        
        let rightNavItem = UIBarButtonItem(title: "Confirm", style: .Plain, target: self, action: "confirmConfirmationNumber")
        navigationItem.rightBarButtonItem = rightNavItem
        
        self.navigationItem.title = "Verify Phone Number"
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        confirmationCodeTextField.becomeFirstResponder()
    }
    
    // phone number verification
    func confirmConfirmationNumber() {
        if (textFieldValid() && UserManager.user.getCode() == confirmationCodeTextField.text! as String) {
            print("Confirmation code entered successfully")
            UserManager.user.setPhoneNumberVerified(true)
            segueWithSlideMenu()
//            performSegueWithIdentifier("phoneNumberConfirmedSegue", sender: self)
        } else {
            // TODO need to display some more error warning stuff CHARLEY TODO
            confirmationCodeTextField.text = ""
            confirmationCodeTextField.attributedPlaceholder = NSAttributedString(string:"Confirmation Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
        }
    }
    
    // Charley
    // process and reformat user input
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // check if input is composed of only numbers
        let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
        if let _ = string.rangeOfCharacterFromSet(invalidCharacters, options: [], range:Range<String.Index>(start: string.startIndex, end: string.endIndex)) {
            return false
        }
        
        // don't allow input to exceed 4 characters
        let MAX_LENGTH = 4
        let currentString: NSString = textField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= MAX_LENGTH
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
    
    // perform special segue with the slide menu controller; duplicated with login vc
    func segueWithSlideMenu() {
        SlideMenuOptions.leftViewWidth = self.view.bounds.size.width/2
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leftViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileSlideOut") as! ProfileSlideOutViewController
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("Map") as! MapViewController
        let rightViewController = UIViewController() // unused
        let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
        self.navigationController?.pushViewController(slideMenuController, animated: true)
    }
}