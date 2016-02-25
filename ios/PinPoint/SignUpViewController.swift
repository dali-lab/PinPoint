//
//  SignUpViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/5/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import Firebase

class SignUpViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
        
        self.navigationItem.title = "Sign Up"
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = false
    }
    
    // Facebook Delegate Method
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil) {
            print("ERROR: User unable to login with Facebook. (\(error))")
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            print("User logged in with Facebook")
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if !result.grantedPermissions.contains("email") {
                print("Permission error when logging in with facebook")
            }
            
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString

            ref.authWithOAuthProvider("facebook", token: accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        self.signUpUser(authData)
                        UserManager.user.setUID(authData.uid)
                    }
            })
        }
    }
    
    // Facebook Delegate Method
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out of facebook")
    }
    
    // save the user to firebase with facebook data
    func signUpUser(auth: FAuthData) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error == nil {
                // get user data
                print("fetched user: \(result)") // TODO this should be refactored to UserManager
                let result = result as! NSDictionary
                var data = [String: String]()
                data["uid"] = (auth.uid as String)
                data["name"] = (result["name"] as! String)
                data["email"] = (result["email"] as! String)
                
                // get picture data
                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
                pictureRequest.startWithCompletionHandler({
                    (connection, result, error: NSError!) -> Void in
                    if error == nil {
                        // get picture data
                        let result = result as! NSDictionary
                        let pictureData = result["data"] as! NSDictionary
//                        print("data result:\n\(pictureData)")
                        data["profile_picture"] = (pictureData["url"] as! String)
                        UserManager.user.pictureURL = (pictureData["url"] as! String)
                        
                        // get ref and save
                        let userRef = self.ref.childByAppendingPath("users")
                        let user = [auth.uid: data]
                        userRef.setValue(user)
                        
                        // segue
                        self.performSegueWithIdentifier("getBasicInfoSegue", sender: self)
                    } else {
                        print("Error: \(error)")
                        // TODO
                    }
                })
                
            } else {
                print("Error: \(error)")
                // TODO
            }
        })
    }
}