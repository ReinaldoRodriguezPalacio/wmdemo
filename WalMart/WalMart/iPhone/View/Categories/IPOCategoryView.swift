//
//  IPOCategoryView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPOCategoryViewDelegate {
    func closeButtonPressed()
    func closeButtonPressedEndAnimation()
}


class IPOCategoryView : CategoryView {
    
    var auxiliarBgView : UIView!
    var closeButton : UIButton!
    var delegate : IPOCategoryViewDelegate!
    var separator : UIView!
    
    var viewOverCellWhite : UIView!
    
    override func setup() {
        super.setup()
        
        //let imageBg : CGFloat = 98
        
        titleLabel.numberOfLines = 2
        
        auxiliarBgView = UIView()
        auxiliarBgView.backgroundColor = UIColor.whiteColor()
        
        viewOverCellWhite = UIView()
        viewOverCellWhite.backgroundColor = UIColor.whiteColor()
        viewOverCellWhite.hidden = true
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeCategory", forControlEvents: UIControlEvents.TouchUpInside)
        self.closeButton.enabled = false
        self.closeButton.alpha = 0
        
        imageIcon.contentMode = UIViewContentMode.Center
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        separator = UIView()
        separator.backgroundColor = WMColor.categoryLineSeparatorColor
        
        
        self.addSubview(auxiliarBgView)
        self.bringSubviewToFront(titleLabel)
        self.addSubview(closeButton)
        self.addSubview(separator)
        self.addSubview(viewOverCellWhite)
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewOverCellWhite.frame = self.bounds
        if self.selected == false {
            imageBackground.frame = self.bounds
            titleLabel.frame = CGRectMake(114, 0, self.frame.width - self.frame.height, self.frame.height)
            auxiliarBgView.frame = CGRectMake(self.frame.height, 0, self.frame.width - self.frame.height, self.frame.height)
            imageIcon.frame = CGRectMake(0, 0, self.frame.height, self.frame.height)
            closeButton.frame = CGRectMake(self.frame.maxX - 36, 0, 36, self.frame.height)
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            separator.frame = CGRectMake(auxiliarBgView.frame.minX, self.frame.height - widthAndHeightSeparator, self.frame.width, widthAndHeightSeparator)
        }
    }
    
    func animateAfterSelect() {
        self.closeButton.enabled = true
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.closeButton.alpha = 1
            self.auxiliarBgView.frame = CGRectMake(self.frame.maxX, 0, self.frame.width - self.frame.height, self.frame.height)
            self.titleLabel.frame = CGRectMake(self.frame.height - 24, 0, self.frame.width - self.frame.height, self.frame.height)
            self.titleLabel.textColor = UIColor.whiteColor()
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            self.separator.frame = CGRectMake(self.auxiliarBgView.frame.minX, self.frame.height - widthAndHeightSeparator, self.frame.width, widthAndHeightSeparator)
        })
        
    }
    
    func closeCategory() {
        self.closeButton.enabled = false
        self.delegate.closeButtonPressed()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.titleLabel.frame = CGRectMake(114, 0, self.frame.width - self.frame.height, self.frame.height)
            self.auxiliarBgView.frame = CGRectMake(self.frame.height, 0, self.frame.width - self.frame.height, self.frame.height)
            self.titleLabel.textColor = WMColor.light_blue
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            self.separator.frame = CGRectMake(self.auxiliarBgView.frame.minX, self.frame.height - widthAndHeightSeparator, self.frame.width, widthAndHeightSeparator)
            }) { (complete:Bool) -> Void in
            self.delegate.closeButtonPressedEndAnimation()
        }
        
    }
    
    
    
    
}