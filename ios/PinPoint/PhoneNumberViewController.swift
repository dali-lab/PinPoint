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

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    // TO DO:
    // 1. Don't allow user to input beyond 10 characters, i.e UI stops reacting after additional button presses
    // 2. Processing as the user inputs digits, adding dashes only after user inputs all 10 characters. Removing all dashes if user deletes (9 chars or less)
    //      (555) 555-5555
    // 3. Error message
    // 4. Only numeric input is accepted
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    // Charley
    @IBOutlet weak var phoneNumbertextField: UITextField!
    
    // Charley
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // delegate to process user input and set keyboard as number pad
        phoneNumbertextField.delegate = self;
        phoneNumbertextField.keyboardType = .NumberPad
        
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
    
    // when the user taps the return button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true;
    }
    
    // log out (of Facebook)
    func logoutButtonPressed() {
        UserManager.user.logout()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // formats string of integers into phone number format
    func formatPhoneNumber(simpleNumber: String) {
    
    }
    
    // Charley
    // process and reformat user input
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        /* credit source: http://stackoverflow.com/questions/27609104/xcode-swift-formatting-text-as-phone-number */

        // check if input is composed of only numbers
        let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
        if let _ = string.rangeOfCharacterFromSet(invalidCharacters, options: [], range:Range<String.Index>(start: string.startIndex, end: string.endIndex)) {
            return false
        }
        if textField == phoneNumbertextField
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
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
        if (text?.characters.count > 10) {
            // TODO need to display some more error warning stuff CHARLEY TODO
            phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            return false
        } else {
            return true
        }
    }
}
