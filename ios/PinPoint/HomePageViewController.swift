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

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        view.sendSubviewToBack(backgroundImage)
        
        UIUtils.styleButton(loginButton, textColor: ThemeText, borderColor: ThemeText.CGColor, borderWidth: BorderWidth, cornerRadius: CornerRadius, backgroundColor: nil)
        
        UIUtils.styleButton(signUpButton, textColor: ThemeText, borderColor: ThemeAccent.CGColor, borderWidth: BorderWidth, cornerRadius: CornerRadius, backgroundColor: ThemeAccent.CGColor)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.hidden = true;
    }
}