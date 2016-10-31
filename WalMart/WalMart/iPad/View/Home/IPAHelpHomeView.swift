//
//  IPAHelpHomeView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 06/07/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPAHelpHomeView: HelpHomeView {

    override class func initView() -> IPAHelpHomeView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let helpView = IPAHelpHomeView(frame:vc!.view.bounds)
        return helpView
    }

    
    override func layoutSubviews() {
        self.logo?.frame = CGRect(x: 457,y: 29,width: 112,height: 28)
        self.arrowImage?.frame = CGRect(x: self.logo!.frame.maxX + 8,y: self.logo!.frame.minY + 7,width: 30,height: 10)
        self.logoLabel?.frame = CGRect(x: self.logo!.frame.maxX + 48,y: self.logo!.frame.minY + 6,width: 128,height: 14)
        self.searchIcon?.frame = CGRect(x: 12,y: 33,width: 20,height: 20)
        self.searchLabel?.frame = CGRect(x: 8,y: self.searchIcon!.frame.maxY + 15,width: 35,height: 14)
        self.shoppingCartIcon?.frame = CGRect(x: self.frame.width - 51,y: 26,width: 35,height: 35)
        self.shoppingCartLabel?.frame = CGRect(x: self.frame.width - 51,y: self.shoppingCartIcon!.frame.maxY + 8,width: 35,height: 14)
        self.continueButton?.frame = CGRect(x: (self.frame.width - 140)/2,y: (self.frame.height - 40)/2,width: 140,height: 40)
        self.helpLabel?.frame = CGRect(x: (self.frame.width - 162)/2,y: self.continueButton!.frame.minY - 42,width: 162,height: 20)
        self.helloLabel?.frame = CGRect(x: (self.frame.width - 80)/2,y: self.helpLabel!.frame.minY - 40,width: 80,height: 32)
    }
    
    override func retrieveTabBarOptions() -> [String] {
        return ["home_ipad", "mg_ipad","super_ipad","list_ipad","ubicacion_ipad","more_menu_ipad"]
    }
    
    override func createTabBarButtons() {
        let images = self.retrieveTabBarOptions()
        let spaceLabel: CGFloat = -5
        var xLabel: CGFloat = self.frame.midX  - ((6 * 60 )  / 2 )
        let spaceImage: CGFloat = 32.4
        var xImage: CGFloat = self.frame.midX  - ((((6 * 27 ) + (32 * 5))) / 2 )
        for image in images {
            var title = NSString(format: "tabbar.%@", image)
            title = NSLocalizedString(title as String, comment: "") as NSString
            let imageLabel = UILabel()
            imageLabel.font = WMFont.fontMyriadProLightOfSize(12)
            imageLabel.textColor = UIColor.white
            imageLabel.text = title as String
            imageLabel.frame = CGRect(x: xLabel, y: 110, width: 65, height: 26)
            imageLabel.numberOfLines = 2
            imageLabel.textAlignment = .center
            xLabel = imageLabel.frame.maxX + spaceLabel
            self.addSubview(imageLabel)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: NSString(format: "%@_active", image) as String)
            imageView.frame = CGRect(x: xImage, y: 75, width: 27, height: 27)
            xImage = imageView.frame.maxX + spaceImage
            self.addSubview(imageView)
        }
    }
}
