//
//  AppDelegate.swift
//  PinPoint
//
//  Created by Patrick Xu on 1/16/16.
//  Copyright © 2016 DALI. All rights reserved.
//
//  Copied some code from a setup file from Parse.

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Stripe
import CoreLocation
import SlideMenuControllerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Stripe setup
        Stripe.setDefaultPublishableKey("pk_test_6s0hJZGtff7hM05a0VZwJXOk")
        
        // Location
        // Ask for authorization from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
//        // Skip sign in if user is signed in
//        if (FBSDKAccessToken.currentAccessToken() != nil) {
//            // get the storyboard
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            
//            // instantiate the desired ViewController
//            // TODO this should only be done if we have the user's basic info
//            let rootController = storyboard.instantiateViewControllerWithIdentifier("Map")
//            
//            // Because self.window is an optional you should check it's value first and assign your rootViewController
//            if self.window != nil {
//                self.window!.rootViewController = rootController
//            }
//        }
        
//        // Slide menu controller setup
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let leftViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileSlideOut") as! ProfileSlideOutViewController
//        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("Map") as! MapViewController
//        let rightViewController = UIViewController()
//        let slideMenuController = SlideMenuController(mainViewController: mainViewController, leftMenuViewController: leftViewController, rightMenuViewController: rightViewController)
//        self.window?.rootViewController = slideMenuController
//        self.window?.makeKeyAndVisible()
// 
        
        // FBSDK handle redirects
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp() // FBSDK tracking
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // FBSDK stuff
    func application(application: UIApplication, openURL url: NSURL,
        sourceApplication: String?, annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance()
                .application(application, openURL: url,
                    sourceApplication: sourceApplication, annotation: annotation)
    }
    
}