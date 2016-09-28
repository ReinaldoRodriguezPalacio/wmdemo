//
//  WMColor.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

struct WMColor {
    //Color palette
    static var dark_gray: UIColor{return UIColorFromRGB(0x525A66)}
    static var reg_gray: UIColor{return UIColorFromRGB(0x787F88)}
    static var empty_gray: UIColor{return UIColorFromRGB(0xB8B8C0)}
    static var empty_gray_btn: UIColor{return UIColorFromRGB(0xDCDCDF)}
    static var light_gray: UIColor{return UIColorFromRGB(0xEDEDEE)}
    static var light_light_gray: UIColor{return UIColorFromRGB(0xF8F7F7)}
    static var light_blue: UIColor{return UIColorFromRGB(0x2870C9)}
    static var light_light_blue: UIColor{return UIColorFromRGB(0x76B3E5)}
    static var light_light_light_blue: UIColor{return UIColorFromRGB(0x79B1E0)}
    static var blue: UIColor{return UIColorFromRGB(0x005AA2)}
    static var dark_blue: UIColor{return UIColorFromRGB(0x004D86)}
    static var yellow: UIColor{return UIColorFromRGB(0xFFB300)}
    static var orange: UIColor{return UIColorFromRGB(0xF27B20)}
    static var green: UIColor{return UIColorFromRGB(0x8EBB36)}
    static var red: UIColor{return UIColorFromRGB(0xC9361C)}
    static var light_red: UIColor{return UIColorFromRGB(0xE43331)}
    static var regular_blue: UIColor{return UIColorFromRGB(0x005AA5)}
    

    
    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func UIColorFromRGB(rgbValue: UInt, alpha: Double) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    static func UIColorFromRGB(wmcolor: UIColor, alpha: Double) -> UIColor {
        return wmcolor.colorWithAlphaComponent(CGFloat(alpha))
    }
    
}

extension UInt {
    init?(_ string: String, radix: UInt) {
        let str = string.stringByReplacingOccurrencesOfString("#", withString: "")
        let digits = "0123456789abcdefghijklmnopqrstuvwxyz"
        var result = UInt(0)
        for digit in str.lowercaseString.characters {
            if let range = digits.rangeOfString(String(digit)) {
                let val = UInt(digits.startIndex.distanceTo(range.startIndex))
                if val >= radix {
                    return nil
                }
                result = result * radix + val
            } else {
                return nil
            }
        }
        self = result
    }
}