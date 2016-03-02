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
    // Phone number input constraints:
    // 1. Don't allow user to input beyond 10 characters, i.e UI stops reacting after additional button presses
    // 2. Processing as the user inputs digits, adding dashes only after user inputs all 10 characters. Removing all dashes if user deletes (9 chars or less)
    //      (555) 555-5555
    // 3. Error message
    // 4. Only numeric input is accepted
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneNumbertextField: UITextField!
    @IBOutlet weak var explanationTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // delegate to process user input and set keyboard as number pad
        phoneNumbertextField.delegate = self;
        
        // setup custom nav bar items
        let leftNavItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutButtonPressed")
        navigationItem.leftBarButtonItem = leftNavItem
        let rightNavItem = UIBarButtonItem(title: "Continue", style: .Plain, target: self, action: "confirmPhoneNumber")
        navigationItem.rightBarButtonItem = rightNavItem
        
        self.navigationItem.title = "Add Phone Number"
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        // dynamic movement with keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reset phone number placeholder color
        phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: PlaceholderColor])
        
        // get and set new confirmation code
        UserManager.user.setCode()
    }
    
    // log out (of Facebook)
    func logoutButtonPressed() {
        UserManager.user.logout()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumbertextField.becomeFirstResponder()
    }
    
    // move stuff when keyboard shows
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    // move stuff when keyboard hides
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
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
        if (textField == phoneNumbertextField) {
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
            
            if (hasLeadingOne) {
                formattedString.appendString("1 ")
                index += 1
            }
            if ((length - index) > 3) {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if (length - index > 3) {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func bigNextButtonPressed(sender: AnyObject) {
        phoneNumbertextField.resignFirstResponder()
        confirmPhoneNumber()
    }
    
    // Charley
    func confirmPhoneNumber() {
        let phoneNo = stripNumber()
        if (phoneNo.characters.count == 10) { // valid entry
            UserManager.user.setPhoneNumber(phoneNo as String!)
            if (UserManager.user.sendCodeToUser()) {
                self.performSegueWithIdentifier("basicInfoEnteredSegue", sender: self)
            }
        }
        else { // invalid entry
            phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            explanationTextField.attributedText = NSAttributedString(string:"Invalid phone number", attributes:[NSForegroundColorAttributeName: ThemeAccent])
            _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "revertErrorMessages", userInfo: nil, repeats: false)
        }
    }
    
    func revertErrorMessages() {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.phoneNumbertextField.attributedPlaceholder = NSAttributedString(string:"Phone Number", attributes:[NSForegroundColorAttributeName: PlaceholderColor])
            self.explanationTextField.attributedText = NSAttributedString(string:"Please enter your phone number", attributes:[NSForegroundColorAttributeName: Black])
        })
    }
    
    // Charley
    // return stripped phone number string
    func stripNumber() -> String {
        let text = phoneNumbertextField.text
        
        // strip non-numerical characters from textField
        let arr = text!.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let strippedPhoneNumber = arr.joinWithSeparator("")

        return strippedPhoneNumber//strippedPhoneNumber
    }
}
