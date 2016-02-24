//
//  ContainerViewController.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/24/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftContainer: UIView!
    
    var embeddedViewController: MapViewController!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        closeMenu()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MapViewController
            where segue.identifier == "mapEmbedSegue" {
                
                vc.containerVC = self
            
        }
    }
    
    @IBAction func closeMenu(sender: UISwipeGestureRecognizer) {
        closeMenu()
    }
    
    func closeMenu() {
        leftConstraint.constant = -leftContainer.frame.size.width
        UIView.animateWithDuration(0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    func openMenu() {
        leftConstraint.constant = 0
        UIView.animateWithDuration(0.3){
            self.view.layoutIfNeeded()
        }
    }
}
