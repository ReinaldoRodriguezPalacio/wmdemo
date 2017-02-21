//
//  IPOEmptyView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/2/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//



import Foundation

let IS_IPAD = (UIDevice.current.model.lowercased().uppercased().range(of: "IPAD") == nil ? false : true )
let IS_IPHONE = (UIDevice.current.model.lowercased().uppercased().range(of: "IPHONE") == nil ? false : true )
let IS_IPOD = (UIDevice.current.model.lowercased().uppercased().range(of: "IPOD") == nil ? false : true )
let IS_RETINA = (UIScreen.main.scale >= 2.0)
let IS_IPAD_MINI = (UIDevice.current.modelName.lowercased().uppercased().range(of: "IPAD MINI") == nil ? false : true)

let SCREEN_WIDTH =  UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_MAX_LENGTH = (max(SCREEN_WIDTH, SCREEN_HEIGHT))
let SCREEN_MIN_LENGTH = (min(SCREEN_WIDTH, SCREEN_HEIGHT))

let IS_IPHONE_4_OR_LESS = (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
let IS_IPHONE_5 = (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
let IS_IPHONE_6 = (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
let IS_IPHONE_6P = (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

let IS_IOS8_OR_LESS = (NSString(string: UIDevice.current.systemVersion).doubleValue < 9.0)


class IPOEmptyView : UIView {
    
    var iconImageView : UIImageView!
    var descLabel : UILabel!
    var returnButton : UIButton!
    var returnAction : (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setup() {
        self.backgroundColor = WMColor.light_gray
        iconImageView = UIImageView()
        
        descLabel = UILabel()
        descLabel.font = WMFont.fontMyriadProLightOfSize(14)
        descLabel.textColor = WMColor.light_blue
        descLabel.textAlignment = NSTextAlignment.center
        
        returnButton = UIButton()
        returnButton.titleLabel?.textColor = UIColor.white
        returnButton.layer.cornerRadius = 20
        returnButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        returnButton.backgroundColor = WMColor.light_blue
        returnButton.setTitle(NSLocalizedString("empty.return",comment:""), for: UIControlState())
        returnButton.addTarget(self, action: #selector(IPOEmptyView.returnActionSel), for: UIControlEvents.touchUpInside)
        
        self.addSubview(iconImageView)
        self.addSubview(descLabel)
        
        //if IS_IPHONE_4_OR_LESS == false {
            self.addSubview(returnButton)
        //}
        
        self.insertSubview(iconImageView, at: 0)
    }
    
    override func layoutSubviews() {
        if iconImageView != nil && iconImageView.image != nil {
         iconImageView.frame = CGRect(x: 0.0, y: 0.0,  width: self.bounds.width,  height: self.bounds.height)//  self.bounds.height)
        }
        self.descLabel.frame = CGRect(x: 0.0, y: 28.0, width: self.bounds.width, height: 16.0)
        self.returnButton.frame = CGRect(x: (self.bounds.width - 160 ) / 2, y: self.bounds.size.height - 100, width: 160 , height: 40)
    }

    func returnActionSel() {
        if returnAction != nil {
            returnAction!()
        }
    }
}

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
}
}
