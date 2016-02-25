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
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.slideMenuController()?.addLeftGestures() // to allow for dismissal by gesture
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