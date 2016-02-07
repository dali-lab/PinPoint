//
//  UIUtils.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/5/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit

class UIUtils {
    
    class func styleButton(button: UIButton, textColor: UIColor, borderColor: CGColor?, borderWidth: CGFloat, cornerRadius: CGFloat, backgroundColor: CGColor?) {
        
        button.setTitleColor(textColor, forState: .Normal)
        if let color = borderColor {
            button.layer.borderColor = color
        }
        button.layer.borderWidth = borderWidth
        button.layer.cornerRadius = cornerRadius
        if let color = backgroundColor {
            button.layer.backgroundColor = color
        }
    }
    
    class func styleImage(image: UIImageView, borderColor: CGColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        
        image.layer.borderColor = borderColor
        image.layer.borderWidth = borderWidth
        image.layer.cornerRadius = cornerRadius
        image.layer.masksToBounds = false
        image.clipsToBounds = true
    }
}