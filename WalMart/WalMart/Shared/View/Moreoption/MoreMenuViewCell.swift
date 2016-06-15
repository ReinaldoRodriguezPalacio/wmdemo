//
//  MoreMenuViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/22/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class MoreMenuViewCell : UITableViewCell {
    
    var title: UILabel?
    var tsepInView: UIView?
    var imageProfile: UIImageView?
    var viewBgSel : UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.light_light_gray
//        viewBgSel.backgroundColor = UIColor.yellowColor()
//        viewBgSel.alpha = 0.2
        viewBgSel.alpha = 1
        
        self.backgroundColor = UIColor.clearColor()
        self.title = UILabel()
        self.title!.backgroundColor = UIColor.clearColor()
        self.imageProfile = UIImageView()
        self.tsepInView = UIView()
        self.tsepInView!.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(self.tsepInView!)
        self.addSubview(self.title!)
        self.addSubview(self.imageProfile!)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        //self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)
        self.imageProfile!.frame = CGRectMake(0.0, 0.0, bounds.height, bounds.height)
        
        let width = bounds.width - bounds.height
       // self.title!.frame = CGRectMake(self.imageProfile!.frame.maxX, 0.0, width, bounds.height)
        self.tsepInView!.frame = CGRectMake(self.imageProfile!.frame.maxX, bounds.height - AppDelegate.separatorHeigth(), width, AppDelegate.separatorHeigth())
        
        if self.imageProfile!.image != nil {
            self.title!.frame = CGRectMake(self.imageProfile!.frame.maxX, 0.0, bounds.width, bounds.height)
        } else {
            self.title!.frame = CGRectMake(16, 0.0, bounds.width, bounds.height)
        }

        
    }
    
    func setValues(value:String, image:String?, size:CGFloat, colorText:UIColor, colorSeparate:UIColor) {
        self.title!.text = NSLocalizedString("moreoptions.title.\(value)", comment:"")
        self.title!.font = WMFont.fontMyriadProLightOfSize(size)
        self.title!.textColor = colorText
        self.tsepInView!.backgroundColor = colorSeparate
        
        if image != nil {
            self.imageProfile!.image = UIImage(named:image!)
            self.title!.frame = CGRectMake(self.imageProfile!.frame.maxX, 0.0, bounds.width, bounds.height)
        } else {
            self.imageProfile!.image = nil
            self.title!.frame = CGRectMake(16, 0.0, bounds.width, bounds.height)
        }
        
        if value == "Notification" {
            let badgeNotification = BadgeView(frame: CGRectMake(self.frame.width - 32, (self.frame.height - 16) / 2, 16, 16), backgroundColor: WMColor.red, textColor: UIColor.whiteColor())
            let badgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
            if badgeNumber > 0 {
                badgeNotification.showBadge(false)
                badgeNotification.updateTitle(badgeNumber)
            }
            self.addSubview(badgeNotification)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.hidden = !selected
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.hidden = true
    }

}