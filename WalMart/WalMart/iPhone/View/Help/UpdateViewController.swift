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
        title.textColor = UIColor.whiteColor()
        title.font = WMFont.fontMyriadProSemiboldOfSize(24)
        title.textAlignment = .Center
        self.addSubview(title)
       
        desc = UILabel()
        desc.text = NSLocalizedString("update.description" ,comment:"")
        desc.textColor = UIColor.whiteColor()
        desc.font = WMFont.fontMyriadProRegularOfSize(15)
        desc.numberOfLines = 0
        desc.textAlignment = .Center
        self.addSubview(desc)
        
        later = UIButton()
        later.setTitle(NSLocalizedString("update.later" ,comment:""), forState: UIControlState.Normal)
        later.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        later.backgroundColor = WMColor.blue
        later.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        later.layer.cornerRadius = 18
        later.addTarget(self, action: #selector(UpdateViewController.updatelater), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(later)
        
        update = UIButton()
        update.setTitle(NSLocalizedString("update.update" ,comment:""), forState: UIControlState.Normal)
        update.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        update.backgroundColor = WMColor.green
        update.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        update.layer.cornerRadius = 18
        update.addTarget(self, action: #selector(UpdateViewController.goToAppStore), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(update)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImage.frame = self.bounds
        
        
        var startY  : CGFloat =  189.0
        if UIDevice.currentDevice().userInterfaceIdiom != .Phone  {
            startY =  289
        }
        
        title.frame = CGRectMake((self.frame.width / 2) - 145, startY, 290, 24)
        desc.frame = CGRectMake((self.frame.width / 2) - 145, title.frame.maxY  + 26, 290, 45)
       
        
        if !forceUpdate {
            later.frame = CGRectMake((self.frame.width / 2) - 145, desc.frame.maxY + 80, 136, 36)
            update.frame = CGRectMake(later.frame.maxX + 15, later.frame.minY, 136, 36)
        } else {
            update.frame = CGRectMake((self.frame.width / 2) - 145,  desc.frame.maxY + 80, 290, 36)
        }
        
        
        
    }
    
    func updatelater() {
        self.close()
    }
    
    func updateNow() {
        self.close()
    }
    
    func close() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0
            }) { (complete) -> Void in
                self.removeFromSuperview()
        }
    }
    
    
    func goToAppStore() {
        let url  = NSURL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
        if UIApplication.sharedApplication().canOpenURL(url!) == true  {
            UIApplication.sharedApplication().openURL(url!)
        }
        if !forceUpdate {
            self.close()
        }
    }
    
    
}
