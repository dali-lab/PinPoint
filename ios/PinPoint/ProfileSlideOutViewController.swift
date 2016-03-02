//
//  ProfileSlideOutViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/11/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation

class ProfileSlideOutViewController: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.slideMenuController()?.addLeftGestures() // to allow for dismissal by gesture
        
        profileImage.layer.borderColor = ThemeAccent.CGColor
        profileImage.layer.borderWidth = BorderWidthSmall
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .ScaleAspectFit
        UserManager.user.setProfileImage(profileImage)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        slideMenuController()?.removeLeftGestures() // to prevent accidental opening while scrolling map
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        UserManager.user.logout()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}