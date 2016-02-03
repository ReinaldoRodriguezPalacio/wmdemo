//
//  WMColor.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

struct WMColor {
    static var gotosuperBgColor: UIColor{return UIColorFromRGB(0x62C900)}//Green
    static var cellSeparatorHomeCollor: UIColor{return UIColorFromRGB(0xdcdddf)} // light_gray
    static var categorySelectorHomeBgColor: UIColor{return UIColorFromRGB(0x005AA2)} //Dark_Blue
    static var categorySelectorIndicatorHomeBgColor: UIColor{return UIColorFromRGB(0xFFB500)}//Yellow
    //iPad Colors
    static var IPATabBarBgColor: UIColor{return UIColorFromRGB(0x005aa2)}
    //Product detall
    static var productDetailBarButtonBgColor: UIColor{return UIColorFromRGB(0x2F3947)}
    static var productDetailBarButtonBorder: UIColor{return UIColorFromRGB(0xDCDDDF)}
    static var titleDetailProductTextColor: UIColor{return UIColorFromRGB(0x737983)}
    static var priceDetailProductTextColor: UIColor{return UIColorFromRGB(0xF47B20)}
    static var priceProductTextColor: UIColor{return UIColorFromRGB(0xF47B20)}
    static var productDetailShoppingCartBtnBGColor: UIColor{return UIColorFromRGB(0xFFB500)}
    static var productDetailShoppingCartNDBtnBGColor: UIColor{return UIColorFromRGB(0xE3E3E5)}
    //Category
    static var lineTextColor: UIColor{return UIColorFromRGB(0x2F3946)}
    static var productProductPromotionsTextColor: UIColor{return UIColorFromRGB(0xF47B20)}
    static var categoryLineSeparatorColor: UIColor{return UIColorFromRGB(0xC4C7CB)}
    //Add to cart
    static var productAddToCartBorderSelectQuantity: UIColor{return UIColorFromRGB(0x8EBB37)}
    static var productAddToCartPriceSelect: UIColor{return UIColorFromRGB(0x8EBB37)}
    static var productAddToCartGoToShoppingBg: UIColor{return UIColorFromRGB(0x8EBB37)}
    static var productAddToCartKeepShoppingBg: UIColor{return UIColorFromRGB(0x005AA2)}
    //ShoppingCart
    static var shoppingCartReturnBgColor: UIColor{return UIColorFromRGB(0x005AA2)}
    static var shoppingCartShopBgColor: UIColor{return UIColorFromRGB(0x8EBB37)}
    static var shoppingCartPromotionsTextColor: UIColor{return UIColorFromRGB(0xF47B20)}
    static var shoppingCartEndEditButtonBgColor: UIColor{return UIColorFromRGB(0x005AA2)}
    static var shoppingCartBeforeLeaveTextColor: UIColor{return UIColorFromRGB(0xF47B20)}
    static var shoppingCartFooter: UIColor{return UIColorFromRGB(0xFFFFFF,alpha:0.92)}
    //WishList
    static var wishlistDeleteAllButtonBgColor: UIColor{return UIColorFromRGB(0xc9361c)}
    static var wishlistEndEditButtonBgColor: UIColor{return UIColorFromRGB(0x005AA2)}
    static var wishlistDeleteButtonBgColor: UIColor{return UIColorFromRGB(0xC9361C)}
    static var wishlistSeparatorBgColor: UIColor{return UIColorFromRGB(0xDCDDDF)}
    // login
    static var loginTypePersonDisabled: UIColor{return UIColorFromRGB(0xd0d2d5)}
    static var loginSignInButonBgColor: UIColor{return UIColorFromRGB(0x77BC1F)}
    static var loginSignOutButonBgColor: UIColor{return UIColorFromRGB(0x005AA2)}
    static var loginProfileLineColor: UIColor{return UIColorFromRGB(0xDCDDDF)}
    static var loginProfileTextColor: UIColor{return UIColorFromRGB(0x487DCF)}
    static var profileErrorColor: UIColor{return UIColorFromRGB(0xE93313)}
    static var loginProfileSelectedColor: UIColor{return UIColorFromRGB(0x005AA2)}
    // Address
    static var searchProductoSeparatorCell: UIColor{return UIColorFromRGB(0xe7e7e9)}
    static var searchProductCellTextColor: UIColor{return UIColorFromRGB(0x5c646f)}
    static var searchProductHeaderViewColor: UIColor{return UIColorFromRGB(0x005aa2)}
    static var searchProductFieldTextColor: UIColor{return UIColorFromRGB(0x5c646f)}
    static var searchProductHeaderTableViewColor: UIColor{return UIColorFromRGB(0xf3f3f3)}
    static var searchProductPriceThroughLineColor: UIColor{return UIColorFromRGB(0xaeb2b8)}
    static var searchProductFieldBarCodeColor: UIColor{return UIColorFromRGB(0xB9BCC1)}
    static var navigationFilterTextColor: UIColor{return UIColorFromRGB(0xffffff)}
    //Waiting
    static var gotosuperipad: UIColor{return UIColorFromRGB(0xFFFFFF,alpha:0.8)}
    //PreShopping Cart
    static var superBG: UIColor{return UIColorFromRGB(0x8ebb37,alpha:1)}
    //Confirm
    static var confirmTitleItem: UIColor{return UIColorFromRGB(0x89a5df)}
    static var lineSaparatorColor: UIColor{return UIColorFromRGB(0xEFEFF0)}
    static var error: UIColor{return UIColorFromRGB(0xE93313)}
    
    //Color palette
    static var dark_gray: UIColor{return UIColorFromRGB(0x525B66)}
    static var gray: UIColor{return UIColorFromRGB(0x797F89)}
    static var light_gray: UIColor{return UIColorFromRGB(0xEDEDEE)}
    static var light_light_gray: UIColor{return UIColorFromRGB(0xF8F7F7)}
    static var light_blue: UIColor{return UIColorFromRGB(0x2870C9)}
    static var blue: UIColor{return UIColorFromRGB(0x335A9D)}
    static var dark_blue: UIColor{return UIColorFromRGB(0x2C4E86)}
    static var yellow: UIColor{return UIColorFromRGB(0xFFB300)}
    static var orange: UIColor{return UIColorFromRGB(0xD87A2D)}
    static var green: UIColor{return UIColorFromRGB(0x8EBB36)}
    
   
    
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