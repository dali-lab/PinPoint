//
//  HomePageViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/5/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    let borderWidth: float = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationController?.navigationBar.hidden = true;
        
        view.sendSubviewToBack(backgroundImage)
        
        loginButton.setTitleColor(ExampleColor, forState: .Normal)
        loginButton.layer.borderWidth = self.borderWidth
        loginButton.layer.borderColor = ExampleColor.CGColor
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}