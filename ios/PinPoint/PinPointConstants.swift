//
//  Constants.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/5/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit

let ExampleColor = UIColor(red: 0, green: 0xFF, blue: 0x0F)
let ExampleColorTwo = UIColor(hex:0x00FF0F)

// Colors

let White = UIColor(hex:0xffffff)
let Black = UIColor(hex:0x000000)
let Grey = UIColor(hex:0x959595)
let Red = UIColor(hex:0xf3372a)
let PlaceholderColor = UIColor(hex:0xC7C7CD)


// Theme colors

let ThemeText = White
let ThemeTextBorder = White
let ThemeAccent = Red
let ThemeAccentBorder = Red

// UI element constants
let BorderWidth: CGFloat = 3.0
let CornerRadius: CGFloat = 6.0


// let UIColors to be instantiated via hex
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}