//
//  ProfileViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class ProfileViewCell: UITableViewCell {
    var title: UILabel?
    var tsepInView: UIView?
    var imageProfile: UIImageView?
    var viewBgSel : UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.loginProfileSelectedColor
        viewBgSel.alpha = 0.2
        
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
        var bounds = self.frame.size
        //self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - AppDelegate.separatorHeigth())
        self.imageProfile!.frame = CGRectMake(20, 20, 25 , 25)
        self.title!.frame = CGRectMake(self.imageProfile!.frame.maxX + 20 , 25, 250, 20)
        self.tsepInView!.frame = CGRectMake(self.title!.frame.minX , bounds.height - AppDelegate.separatorHeigth() , bounds.width - self.title!.frame.minX , AppDelegate.separatorHeigth())
    }
    
    func setValues(value:String,image:String, size:CGFloat,colorText:UIColor, colorSeparate: UIColor  ) {
        self.title!.text = value
        self.imageProfile!.image = UIImage(named:image)
        self.title!.font = WMFont.fontMyriadProLightOfSize(size)
        self.title!.textColor = colorText
       
    }
    
    required init(coder aDecoder: NSCoder) {
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
