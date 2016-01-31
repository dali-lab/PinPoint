//
//  MapViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 1/30/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.hidden = false;
        navigationItem.hidesBackButton = true;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
}