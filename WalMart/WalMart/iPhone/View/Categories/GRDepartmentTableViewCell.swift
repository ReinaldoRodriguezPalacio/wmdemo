//
//  GRDepartmentTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRDepartmentTableViewCell : UITableViewCell {
    
    
    var buttonDepartment : UIButton!
    var titleDepartment : String!
    
    var moreLabel : UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    
    func setup() {
        buttonDepartment = UIButton()
        buttonDepartment.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        buttonDepartment.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonDepartment.layer.cornerRadius = 14
        buttonDepartment.setImage(UIImage(named:""), forState: UIControlState.Normal)
        buttonDepartment.backgroundColor = WMColor.light_blue
        buttonDepartment.enabled = false
        buttonDepartment.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, 0.0, 0.0)
        
        
        self.addSubview(buttonDepartment)
        
        
        moreLabel = UILabel(frame: CGRectMake(self.frame.width - 116, 28, 100, 12))
        moreLabel.text = NSLocalizedString("gr.category.all", comment: "")
        moreLabel.textColor = WMColor.light_blue
        moreLabel.textAlignment = NSTextAlignment.Right
        moreLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.addSubview(moreLabel)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setValues(titleDepartment:String,collapsed:Bool) {
        
        self.titleDepartment = titleDepartment
        let attrStringLab = NSAttributedString(string:titleDepartment, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.whiteColor()])
        let size = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var startx : CGFloat = 0.0
        let  sizeDep = size.width + 40
        if collapsed {
            //startx = 16.0
            startx = 160 - (sizeDep / 2)
        } else {
            startx = 160 - (sizeDep / 2)
        }
        
        buttonDepartment.setTitle(titleDepartment, forState: UIControlState.Normal)
        self.buttonDepartment.frame = CGRectMake(startx, 20, sizeDep, 28)
        
        moreLabel.hidden = collapsed
        
    }
    
    func centerButton() {
        let attrStringLab = NSAttributedString(string:titleDepartment, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.whiteColor()])
        let size = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let  sizeDep = size.width + 40
        self.buttonDepartment.frame = CGRectMake(160 - (sizeDep / 2), 20, sizeDep, 28)
    }
    
    func letfButton() {
        let attrStringLab = NSAttributedString(string:titleDepartment, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.whiteColor()])
        let size = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let  sizeDep = size.width + 40
        self.buttonDepartment.frame = CGRectMake(16.0, 20, sizeDep, 28)
    }
    
    
}