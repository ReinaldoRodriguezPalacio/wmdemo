//
//  UpdateViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class UpdateViewController: UIView {
    
    var backgroundImage : UIImageView!
    
    var title : UILabel!
    var desc : UILabel!
    
    var later : UIButton!
    var update : UIButton!
    var forceUpdate : Bool! = false
    
    
    func setup (){
        backgroundImage = UIImageView ()
        backgroundImage.image = UIImage(named: "update")
        self.addSubview(backgroundImage)
    
        title = UILabel()
        title.text = NSLocalizedString("update.title",comment:"")
        title.textColor = UIColor.white
        title.font = WMFont.fontMyriadProSemiboldOfSize(24)
        title.textAlignment = .center
        self.addSubview(title)
       
        desc = UILabel()
        desc.text = NSLocalizedString("update.description" ,comment:"")
        desc.textColor = UIColor.white
        desc.font = WMFont.fontMyriadProRegularOfSize(15)
        desc.numberOfLines = 0
        desc.textAlignment = .center
        self.addSubview(desc)
        
        later = UIButton()
        later.setTitle(NSLocalizedString("update.later" ,comment:""), for: UIControlState())
        later.setTitleColor(UIColor.white, for: UIControlState())
        later.backgroundColor = WMColor.blue
        later.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        later.layer.cornerRadius = 18
        later.addTarget(self, action: #selector(UpdateViewController.updatelater), for: UIControlEvents.touchUpInside)
        self.addSubview(later)
        
        update = UIButton()
        update.setTitle(NSLocalizedString("update.update" ,comment:""), for: UIControlState())
        update.setTitleColor(UIColor.white, for: UIControlState())
        update.backgroundColor = WMColor.green
        update.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        update.layer.cornerRadius = 18
        update.addTarget(self, action: #selector(UpdateViewController.goToAppStore), for: UIControlEvents.touchUpInside)
        self.addSubview(update)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImage.frame = self.bounds
        
        
        var startY  : CGFloat =  189.0
        if UIDevice.current.userInterfaceIdiom != .phone  {
            startY =  289
        }
        
        title.frame = CGRect(x: (self.frame.width / 2) - 145, y: startY, width: 290, height: 24)
        desc.frame = CGRect(x: (self.frame.width / 2) - 145, y: title.frame.maxY  + 26, width: 290, height: 45)
       
        
        if !forceUpdate {
            later.frame = CGRect(x: (self.frame.width / 2) - 145, y: desc.frame.maxY + 80, width: 136, height: 36)
            update.frame = CGRect(x: later.frame.maxX + 15, y: later.frame.minY, width: 136, height: 36)
        } else {
            update.frame = CGRect(x: (self.frame.width / 2) - 145,  y: desc.frame.maxY + 80, width: 290, height: 36)
        }
        
        
        
    }
    
    func updatelater() {
        self.close()
    }
    
    func updateNow() {
        self.close()
    }
    
    func close() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (complete) -> Void in
                self.removeFromSuperview()
        }) 
    }
    
    
    func goToAppStore() {
        let url  = URL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
        if UIApplication.shared.canOpenURL(url!) == true  {
            UIApplication.shared.openURL(url!)
        }
        if !forceUpdate {
            self.close()
        }
    }
    
    
}
