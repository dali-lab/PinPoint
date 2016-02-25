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
import SlideMenuControllerSwift

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let ref = Firebase(url: "https://pinpoint-app.firebaseio.com/")
    
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
        navigationController?.navigationBarHidden = false
        navigationController?.interactivePopGestureRecognizer?.enabled = false
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
                        UserManager.user.setUID(authData.uid)
                    }
            })
        }
    }
    
    // Facebook Delegate Method
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("Logged out of Facebook")
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
            UserManager.user.pictureURL = String(snapshot.childSnapshotForPath("profile_picture").value)
            self.segueWithSlideMenu()
        })
    }
    
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