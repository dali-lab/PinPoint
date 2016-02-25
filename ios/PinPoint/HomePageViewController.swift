//
//  HomePageViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/5/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
//import SlideMenuControllerSwift

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // user already logged in
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            print("User already logged in with Facebook")
            performSegueWithIdentifier("toMapSegue", sender: self)
        }
        
        view.sendSubviewToBack(backgroundImage)
        
        loginButton.setTitleColor(ThemeText, forState: .Normal)
        loginButton.layer.borderColor = ThemeText.CGColor
        loginButton.layer.borderWidth = BorderWidth
        loginButton.layer.cornerRadius = CornerRadius
        loginButton.layer.backgroundColor = UIColor.clearColor().CGColor
        loginButton.clipsToBounds = true
        
        signUpButton.setTitleColor(ThemeText, forState: .Normal)
        signUpButton.layer.borderColor = ThemeAccent.CGColor
        signUpButton.layer.borderWidth = BorderWidth
        signUpButton.layer.cornerRadius = CornerRadius
        signUpButton.layer.backgroundColor = ThemeAccent.CGColor
        signUpButton.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.hidden = true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Slide menu controller setup
//        if segue.identifier == "toMapSegue" {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let leftViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileSlideOut") as! ProfileSlideOutViewController
//            let mainViewController = storyboard.instantiateViewControllerWithIdentifier("Map") as! MapViewController
//            let rightViewController = UIViewController()
//            let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
//            self.presentViewController(slideMenuController, animated: false, completion: nil)
//    //        self.window?.rootViewController = slideMenuController
//    //        self.window?.makeKeyAndVisible()
//        }
    }
}