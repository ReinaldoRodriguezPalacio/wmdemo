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
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
       
        self.logo = UIImageView()
        self.logo?.image = UIImage(named:"navBar_logo")
        self.addSubview(self.logo!)
        
        self.arrowImage = UIImageView()
        self.arrowImage?.image = UIImage(named:"arrow_help")
        self.addSubview(self.arrowImage!)
        
        self.logoLabel = UILabel()
        self.logoLabel?.font = WMFont.fontMyriadProLightOfSize(12)
        self.logoLabel?.textColor = UIColor.white
        self.logoLabel?.text = NSLocalizedString("home_help.logo", comment: "")
        self.logoLabel?.textAlignment = .center
        self.addSubview(self.logoLabel!)
        
        self.searchIcon = UIImageView()
        self.searchIcon?.image = UIImage(named:"navBar_search")
        self.addSubview(self.searchIcon!)
        
        self.searchLabel = UILabel()
        self.searchLabel?.font = WMFont.fontMyriadProLightOfSize(12)
        self.searchLabel?.textColor = UIColor.white
        self.searchLabel?.text = NSLocalizedString("home_help.search", comment: "")
        self.searchLabel?.textAlignment = .center
        self.addSubview(self.searchLabel!)
            
        self.shoppingCartIcon = UIImageView()
        self.shoppingCartIcon?.image = UIImage(named:"navBar_cart")
        self.addSubview(self.shoppingCartIcon!)
        
        self.shoppingCartLabel = UILabel()
        self.shoppingCartLabel?.font = WMFont.fontMyriadProLightOfSize(12)
        self.shoppingCartLabel?.textColor = UIColor.white
        self.shoppingCartLabel?.text = NSLocalizedString("home_help.shoppingCart", comment: "")
        self.shoppingCartLabel?.textAlignment = .center
        self.addSubview(self.shoppingCartLabel!)
        
        self.helloLabel = UILabel()
        self.helloLabel?.font = WMFont.fontMyriadProRegularOfSize(30)
        self.helloLabel?.textColor = UIColor.white
        self.helloLabel?.text = NSLocalizedString("home_help.hello", comment: "")
        self.helloLabel?.textAlignment = .center
        self.addSubview(self.helloLabel!)
        
        self.helpLabel = UILabel()
        self.helpLabel?.font = WMFont.fontMyriadProLightOfSize(18)
        self.helpLabel?.textColor = UIColor.white
        self.helpLabel?.text = NSLocalizedString("home_help.description", comment: "")
        self.helpLabel?.textAlignment = .center
        self.addSubview(self.helpLabel!)
        
        self.continueButton = UIButton()
        self.continueButton?.setTitle("Continuar", for: UIControlState())
        self.continueButton?.setTitleColor(UIColor.white, for: UIControlState())
        self.continueButton?.backgroundColor = WMColor.green
        self.continueButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.continueButton?.layer.cornerRadius = 20
        self.continueButton?.addTarget(self, action: #selector(HelpHomeView.closeView), for: UIControlEvents.touchUpInside)
        self.addSubview(self.continueButton!)
        
        self.createTabBarButtons()
    }
    
    override func layoutSubviews() {
        self.logo?.frame = CGRect(x: (self.frame.width - 112)/2,y: 28,width: 112,height: 28)
        self.arrowImage?.frame = CGRect(x: self.logo!.frame.midX - 4,y: self.logo!.frame.maxY - 4,width: 9,height: 29)
        self.logoLabel?.frame = CGRect(x: (self.frame.width - 128)/2,y: self.logo!.frame.maxY + 29,width: 128,height: 14)
        self.searchIcon?.frame = CGRect(x: 12,y: 31.5,width: 20,height: 20)
        self.searchLabel?.frame = CGRect(x: 8,y: self.searchIcon!.frame.maxY + 15,width: 35,height: 14)
        self.shoppingCartIcon?.frame = CGRect(x: (self.frame.width - 46),y: 25,width: 35,height: 35)
        self.shoppingCartLabel?.frame = CGRect(x: (self.frame.width - 46),y: self.shoppingCartIcon!.frame.maxY + 8,width: 35,height: 14)
        self.continueButton?.frame = CGRect(x: (self.frame.width - 140)/2,y: (self.frame.height - 40)/2,width: 140,height: 40)
        self.helpLabel?.frame = CGRect(x: (self.frame.width - 162)/2,y: self.continueButton!.frame.minY - 42,width: 162,height: 20)
        self.helloLabel?.frame = CGRect(x: (self.frame.width - 80)/2,y: self.helpLabel!.frame.minY - 40,width: 80,height: 32)
    }
    
    class func initView() -> HelpHomeView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let helpView = HelpHomeView(frame:vc!.view.bounds)
        return helpView
    }
    
    func showView() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        self.alpha = 0.0
        vc!.view.addSubview(self)
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 1.0
            }, completion: nil)
    }
    
    func closeView(){
        UIView.animate(withDuration: 0.4, animations: {
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
        let spaceLabel: CGFloat = -1
        var xLabel: CGFloat = 0
        //let spaceImage: CGFloat = 43
        var xImage: CGFloat = ((self.frame.width - 135) / 4) / 2
        xImage = xImage + 5.0
        
        let widthLabel = (self.frame.width - 14.0) / 5
        let spaceImage = (self.frame.width - (xImage * 2) - 135) / 4
        
        for image in images {
            var title = NSString(format: "tabbar.%@", image)
            title = NSLocalizedString(title as String, comment: "") as NSString
            let imageLabel = UILabel()
            imageLabel.font = WMFont.fontMyriadProLightOfSize(12)
            imageLabel.textColor = UIColor.white
            imageLabel.text = title as String
            xLabel = (xImage - (spaceImage / 2)) - 2.0
            imageLabel.frame = CGRect(x: xLabel, y: self.frame.height - 71, width: widthLabel, height: 26)
            imageLabel.numberOfLines = 2
            imageLabel.textAlignment = .center
            //xLabel = imageLabel.frame.maxX + spaceLabel
            self.addSubview(imageLabel)
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: NSString(format: "%@_active", image) as String)
            imageView.frame = CGRect(x: xImage, y: self.frame.height - 34.5, width: 27, height: 27)
            xImage = imageView.frame.maxX + spaceImage
            self.addSubview(imageView)
        }
    }
}
