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
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let helpView = IPAHelpHomeView(frame:vc!.view.bounds)
        return helpView
    }

    
    override func layoutSubviews() {
        self.logo?.frame = CGRectMake(457,29,112,28)
        self.arrowImage?.frame = CGRectMake(self.logo!.frame.maxX,self.logo!.frame.minY + 7,30,10)
        self.logoLabel?.frame = CGRectMake(self.logo!.frame.maxX + 58,self.logo!.frame.minY + 8,128,14)
        self.searchIcon?.frame = CGRectMake(12,33,20,20)
        self.searchLabel?.frame = CGRectMake(8,self.searchIcon!.frame.maxY + 15,35,14)
        self.shoppingCartIcon?.frame = CGRectMake(self.frame.width - 51,26,35,35)
        self.shoppingCartLabel?.frame = CGRectMake(self.frame.width - 51,self.shoppingCartIcon!.frame.maxY + 8,35,14)
        self.continueButton?.frame = CGRectMake((self.frame.width - 140)/2,(self.frame.height - 40)/2,140,40)
        self.helpLabel?.frame = CGRectMake((self.frame.width - 162)/2,self.continueButton!.frame.minY - 42,162,20)
        self.helloLabel?.frame = CGRectMake((self.frame.width - 80)/2,self.helpLabel!.frame.minY - 40,80,32)
    }
    
    override func retrieveTabBarOptions() -> [String] {
        return ["home_ipad", "mg_ipad","wishlist_ipad","super_ipad","list_ipad","ubicacion_ipad","more_menu_ipad"]
    }
    
    override func createTabBarButtons() {
        let images = self.retrieveTabBarOptions()
        let spaceLabel: CGFloat = -5
        var xLabel: CGFloat = 300
        let spaceImage: CGFloat = 32.4
        var xImage: CGFloat = 317
        for image in images {
            var title = NSString(format: "tabbar.%@", image)
            title = NSLocalizedString(title as String, comment: "")
            let imageLabel = UILabel()
            imageLabel.font = WMFont.fontMyriadProLightOfSize(12)
            imageLabel.textColor = UIColor.whiteColor()
            imageLabel.text = title as String
            imageLabel.frame = CGRectMake(xLabel, 110, 65, 26)
            imageLabel.numberOfLines = 2
            imageLabel.textAlignment = .Center
            xLabel = CGRectGetMaxX(imageLabel.frame) + spaceLabel
            self.addSubview(imageLabel)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: NSString(format: "%@_active", image) as String)
            imageView.frame = CGRectMake(xImage, 75, 27, 27)
            xImage = CGRectGetMaxX(imageView.frame) + spaceImage
            self.addSubview(imageView)
        }
    }
}