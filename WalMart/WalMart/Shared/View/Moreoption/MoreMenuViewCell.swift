//
//  MoreMenuViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/22/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class MoreMenuViewCell : UITableViewCell {
    
    var isSeparatorComplete:Bool = false
    var title: UILabel?
    var tsepInView: UIView?
    var imageProfile: UIImageView?
    var viewBgSel : UIView!
    var badgeNotification: BadgeView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.light_light_gray
//        viewBgSel.backgroundColor = UIColor.yellowColor()
//        viewBgSel.alpha = 0.2
        viewBgSel.alpha = 1
        
        self.badgeNotification = BadgeView(frame: CGRect(x: self.frame.width - 32, y: (self.frame.height - 16) / 2, width: 16, height: 16), backgroundColor: WMColor.red, textColor: UIColor.white)
        self.badgeNotification.isHidden = true
        self.addSubview(self.badgeNotification)
        
        self.backgroundColor = UIColor.clear
        self.title = UILabel()
        self.title!.backgroundColor = UIColor.clear
        self.imageProfile = UIImageView()
        self.tsepInView = UIView()
        self.tsepInView!.backgroundColor = UIColor.white
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(self.tsepInView!)
        self.addSubview(self.title!)
        self.addSubview(self.imageProfile!)
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        //self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.viewBgSel!.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - 1.0)
        self.imageProfile!.frame = CGRect(x: 0.0, y: 0.0, width: bounds.height, height: bounds.height)
        
        let width = bounds.width - bounds.height
        
        if isSeparatorComplete {
            self.tsepInView!.frame = CGRect(x: 0, y: bounds.height - AppDelegate.separatorHeigth(), width: bounds.width, height: AppDelegate.separatorHeigth())
        } else {
            self.tsepInView!.frame = CGRect(x: self.imageProfile!.frame.maxX, y: bounds.height - AppDelegate.separatorHeigth(), width: width, height: AppDelegate.separatorHeigth())
        }
       
        // self.title!.frame = CGRectMake(self.imageProfile!.frame.maxX, 0.0, width, bounds.height)
        
        if self.imageProfile!.image != nil {
            self.title!.frame = CGRect(x: self.imageProfile!.frame.maxX, y: 0.0, width: bounds.width, height: bounds.height)
        } else {
            self.title!.frame = CGRect(x: 16, y: 0.0, width: bounds.width, height: bounds.height)
        }

        self.badgeNotification.frame = CGRect(x: self.frame.width - 32, y: (self.frame.height - 16) / 2, width: 16, height: 16)
    }
    
    func setValues(_ value:String, image:String?, size:CGFloat, colorText:UIColor, colorSeparate:UIColor) {
        self.title!.text = NSLocalizedString("moreoptions.title.\(value)", comment:"")
        self.title!.font = WMFont.fontMyriadProLightOfSize(size)
        self.title!.textColor = colorText
        self.tsepInView!.backgroundColor = colorSeparate
        
        if image != nil {
            self.imageProfile!.image = UIImage(named:image!)
            self.title!.frame = CGRect(x: self.imageProfile!.frame.maxX, y: 0.0, width: bounds.width, height: bounds.height)
        } else {
            self.imageProfile!.image = nil
            self.title!.frame = CGRect(x: 16, y: 0.0, width: bounds.width, height: bounds.height)
        }
        
        if value == "Notification" {
            let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
            self.badgeNotification.isHidden = badgeNumber == 0
            if badgeNumber > 0 {
                badgeNotification.showBadge(false)
                badgeNotification.updateTitle(badgeNumber)
            }
        }else{
           self.badgeNotification.isHidden = true
        }

    }
    
    func setPreferenceValues(_ value:String, size:CGFloat, colorText:UIColor, colorSeparate:UIColor) {
        self.title!.text = NSLocalizedString("preferences.title.\(value)", comment:"")
        self.title!.font = WMFont.fontMyriadProLightOfSize(size)
        self.title!.textColor = colorText
        self.tsepInView!.backgroundColor = colorSeparate
        self.imageProfile!.image = nil
        self.title!.frame = CGRect(x: 16, y: 0.0, width: bounds.width, height: bounds.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.isHidden = !selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.isHidden = true
    }

}
