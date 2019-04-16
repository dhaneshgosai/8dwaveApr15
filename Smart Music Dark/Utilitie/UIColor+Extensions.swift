//
//  UIColor+Extensions.swift
//  8DWave
//
//  Created by Abraham Sameer on 11/30/18.
//  Copyright © 2018 Abraham Sameer. All rights reserved.
//

import Foundation

import UIKit

extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    static func themeBaseColor() -> UIColor {
        return UIColor.white
    }
    static func themeTabarColor() -> UIColor {
        return UIColor.white
    }
    static func themeNavbarColor() -> UIColor {
        return rgb(10, green: 34, blue: 67, alpha: 1.0)
    }
    static func themeTopBorder() -> UIColor{
        return rgb(10, green: 34, blue: 67, alpha: 0.1)
    }
    static func themeButtonsColor() -> UIColor {
        return rgb(0, green: 111, blue: 188, alpha: 1)
    }
    static func themeHeaderColor() -> UIColor {
        return rgb(27, green: 27, blue: 27, alpha: 1.0)
    }
    static func themeIndicatorColor() -> UIColor {
        return rgb(17, green: 142, blue: 15, alpha: 1.0)
    }
    static func themeMinimumTrackTintColor() -> UIColor {
        return rgb(10, green: 34, blue: 67, alpha: 1.0)
    }
    static func themeMaximumTrackTintColor() -> UIColor {
        return rgb(151, green: 190, blue: 232, alpha: 1.0)
    }
    
    
    
}
