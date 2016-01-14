//
//  MercuryFont.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/7/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class MercuryFont {
    
    class func fontSFUIRegularOfSize (size:CGFloat) -> UIFont!{
        return UIFont(name:"SFUIDisplay-Regular", size: size)
    }
    
    class func fontSFUIMediumOfSize (size:CGFloat) -> UIFont!{
        return UIFont(name:"SFUIDisplay-Medium", size: size)
    }
    
    class func fontSFUILightOfSize (size:CGFloat) -> UIFont!{
        return UIFont(name:"SFUIDisplay-Light", size: size)
    }
    
}