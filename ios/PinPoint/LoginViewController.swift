//
//  LoginViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 1/29/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com/")
    var uid: String!
    var pictureURL: String!
    
    //viewDidLoad is things you have to do once. viewWillAppear gets called every
    //time the view appears
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let loginButton : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginButton)
        loginButton.center = self.view.center
//        loginButton.readPermissions = ["public_profile", "email"] //TODO need any?
        loginButton.delegate = self
        
        self.navigationItem.title = "Log In"
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
                        self.loginUser(authData)
                        self.uid = authData.uid
                    }
            })
        }
    }
    
    // Facebook Delegate Method
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out of facebook")
    }
    
    //get the user
    func loginUser(auth: FAuthData) {
        let userExistsRef = self.ref.childByAppendingPath("users" + auth.uid)
        userExistsRef.observeEventType(.Value, withBlock: { snap in
            if snap.value is NSNull {
                //TODO handle user account doesn't exist
                let loginManager = FBSDKLoginManager.init()
                loginManager.logOut()
            }
        })
        let userRef = self.ref.childByAppendingPath("users")
        userRef.queryOrderedByChild("uid").queryEqualToValue(auth.uid).observeEventType(.ChildAdded, withBlock: { snapshot in
            print("logging in: ")
            self.pictureURL = String(snapshot.childSnapshotForPath("profile_picture").value)
            self.performSegueWithIdentifier("loginCompleteSegue", sender: self)
        })
    }
    
    // send uid to next VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? MapViewController{
            destination.uid = self.uid
            destination.pictureURL = self.pictureURL
        }
    }
}