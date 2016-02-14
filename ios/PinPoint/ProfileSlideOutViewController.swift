//
//  ProfileSlideOutViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/11/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation
import SlideMenuControllerSwift

class ProfileSlideOutViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        UserManager.user.logout()
        self.navigationController?.popToRootViewControllerAnimated(true)
        self.slideMenuController()?.closeLeft()
    }
}