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
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com")
    
    //viewDidLoad is things you have to do once. viewWillAppear gets called every
    //time the view appears
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // FB login stuff
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            //TODO
            self.performSegueWithIdentifier("loginSegue", sender: self)
//            let loginView : FBSDKLoginButton = FBSDKLoginButton()
//            self.view.addSubview(loginView)
//            loginView.center = self.view.center
//            loginView.readPermissions = ["public_profile", "email"]
//            loginView.delegate = self
            // User is already logged in, do work such as go to next view controller.
        } else {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email"]
            loginView.delegate = self
        }
        
        navigationController?.navigationBar.hidden = true;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func guestLogin(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { error, authData in
            if error != nil {
                print("ERROR: User unable to login anonymously. (\(error))")
            } else {
                print("User logged in anonymously.")
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        }
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
            if result.grantedPermissions.contains("email") {
                returnUserData()
                // Do work
            }
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString

            ref.authWithOAuthProvider("facebook", token: accessToken,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
//                        print("\(authData.token)")
                    }
            })
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    // Facebook Delegate Method
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out of facebook")
    }
    
    // get facebook user data
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                print("fetched user: \(result)")
            }
        })
    }
    
}