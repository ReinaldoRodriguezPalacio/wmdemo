//
//  HelpHomeView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 05/07/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class HelpHomeView: UIView {
    
    var logo: UIImageView?
    var searchIcon: UIImageView?
    var shoppingCartIcon: UIImageView?
    var arrowImage: UIImageView?
    var logoLabel: UILabel?
    var searchLabel: UILabel?
    var shoppingCartLabel: UILabel?
    var helloLabel:UILabel?
    var helpLabel:UILabel?
    var continueButton: UIButton?
    var onClose: ((Void) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
       
        self.logo = UIImageView()
        self.logo?.image = UIImage(named:"navBar_logo")
        self.addSubview(self.logo!)
        
        self.arrowImage = UIImageView()
        self.arrowImage?.image = UIImage(named:"arrow_help")
        self.addSubview(self.arrowImage!)
        
        self.logoLabel = UILabel()
        self.logoLabel?.font = WMFont.fontMyriadProLightOfSize(12)
        self.logoLabel?.textColor = UIColor.whiteColor()
        self.logoLabel?.text = NSLocalizedString("home_help.logo", comment: "")
        self.logoLabel?.textAlignment = .Center
        self.addSubview(self.logoLabel!)
        
        self.searchIcon = UIImageView()
        self.searchIcon?.image = UIImage(named:"navBar_search")
        self.addSubview(self.searchIcon!)
        
        self.searchLabel = UILabel()
        self.searchLabel?.font = WMFont.fontMyriadProLightOfSize(12)
        self.searchLabel?.textColor = UIColor.whiteColor()
        self.searchLabel?.text = NSLocalizedString("home_help.search", comment: "")
        self.searchLabel?.textAlignment = .Center
        self.addSubview(self.searchLabel!)
            
        self.shoppingCartIcon = UIImageView()
        self.shoppingCartIcon?.image = UIImage(named:"navBar_cart")
        self.addSubview(self.shoppingCartIcon!)
        
        self.shoppingCartLabel = UILabel()
        self.shoppingCartLabel?.font = WMFont.fontMyriadProLightOfSize(12)
        self.shoppingCartLabel?.textColor = UIColor.whiteColor()
        self.shoppingCartLabel?.text = NSLocalizedString("home_help.shoppingCart", comment: "")
        self.shoppingCartLabel?.textAlignment = .Center
        self.addSubview(self.shoppingCartLabel!)
        
        self.helloLabel = UILabel()
        self.helloLabel?.font = WMFont.fontMyriadProRegularOfSize(30)
        self.helloLabel?.textColor = UIColor.whiteColor()
        self.helloLabel?.text = NSLocalizedString("home_help.hello", comment: "")
        self.helloLabel?.textAlignment = .Center
        self.addSubview(self.helloLabel!)
        
        self.helpLabel = UILabel()
        self.helpLabel?.font = WMFont.fontMyriadProLightOfSize(18)
        self.helpLabel?.textColor = UIColor.whiteColor()
        self.helpLabel?.text = NSLocalizedString("home_help.description", comment: "")
        self.helpLabel?.textAlignment = .Center
        self.addSubview(self.helpLabel!)
        
        self.continueButton = UIButton()
        self.continueButton?.setTitle("Continuar", forState: .Normal)
        self.continueButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.continueButton?.backgroundColor = WMColor.green
        self.continueButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.continueButton?.layer.cornerRadius = 20
        self.continueButton?.addTarget(self, action: #selector(HelpHomeView.closeView), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.continueButton!)
        
        self.createTabBarButtons()
    }
    
    override func layoutSubviews() {
        self.logo?.frame = CGRectMake(104,29,112,28)
        self.arrowImage?.frame = CGRectMake(self.logo!.frame.midX - 4,self.logo!.frame.maxY - 4,9,29)
        self.logoLabel?.frame = CGRectMake(96,self.logo!.frame.maxY + 29,128,14)
        self.searchIcon?.frame = CGRectMake(13,32,20,20)
        self.searchLabel?.frame = CGRectMake(8,self.searchIcon!.frame.maxY + 15,35,14)
        self.shoppingCartIcon?.frame = CGRectMake(269,24,35,35)
        self.shoppingCartLabel?.frame = CGRectMake(269,self.shoppingCartIcon!.frame.maxY + 8,35,14)
        self.continueButton?.frame = CGRectMake((self.frame.width - 140)/2,(self.frame.height - 40)/2,140,40)
        self.helpLabel?.frame = CGRectMake((self.frame.width - 162)/2,self.continueButton!.frame.minY - 42,162,20)
        self.helloLabel?.frame = CGRectMake((self.frame.width - 80)/2,self.helpLabel!.frame.minY - 40,80,32)
    }
    
    class func initView() -> HelpHomeView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let helpView = HelpHomeView(frame:vc!.view.bounds)
        return helpView
    }
    
    func showView() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        self.alpha = 0.0
        vc!.view.addSubview(self)
        UIView.animateWithDuration(0.4, animations: {
            self.alpha = 1.0
            }, completion: nil)
    }
    
    func closeView(){
        UIView.animateWithDuration(0.4, animations: {
                self.alpha = 0.0
            }, completion: {(complete) in
                self.removeFromSuperview()
                self.onClose?()
            })
    }
    
    // MARK: - Create buttons
    
    func retrieveTabBarOptions() -> [String] {
        return ["tabBar_home", "tabBar_mg","tabBar_super", "tabBar_wishlist_list","tabBar_menu"]
    }
    
    func createTabBarButtons() {
        let images = self.retrieveTabBarOptions()
        let spaceLabel: CGFloat = -5
        var xLabel: CGFloat = 8
        let spaceImage: CGFloat = 33.6
        var xImage: CGFloat = 25.4
        for image in images {
            var title = NSString(format: "tabbar.%@", image)
            title = NSLocalizedString(title as String, comment: "")
            let imageLabel = UILabel()
            imageLabel.font = WMFont.fontMyriadProLightOfSize(12)
            imageLabel.textColor = UIColor.whiteColor()
            imageLabel.text = title as String
            imageLabel.frame = CGRectMake(xLabel, self.frame.height - 71, 65, 26)
            imageLabel.numberOfLines = 2
            imageLabel.textAlignment = .Center
            xLabel = CGRectGetMaxX(imageLabel.frame) + spaceLabel
            self.addSubview(imageLabel)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: NSString(format: "%@_active", image) as String)
            imageView.frame = CGRectMake(xImage, self.frame.height - 34.5, 27, 27)
            xImage = CGRectGetMaxX(imageView.frame) + spaceImage
            self.addSubview(imageView)
        }
    }
}