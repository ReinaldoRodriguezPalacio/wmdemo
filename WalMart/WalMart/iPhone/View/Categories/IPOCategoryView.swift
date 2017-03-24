//
//  IPOCategoryView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPOCategoryViewDelegate: class{
    func closeButtonPressed()
    func closeButtonPressedEndAnimation()
}


class IPOCategoryView : CategoryView {
    
    var auxiliarBgView : UIView!
    var closeButton : UIButton!
    weak var delegate : IPOCategoryViewDelegate?
    var separator : UIView!
    
    var viewOverCellWhite : UIView!
    
    override func setup() {
        super.setup()
        
        //let imageBg : CGFloat = 98
        
        titleLabel.numberOfLines = 2
        
        auxiliarBgView = UIView()
        auxiliarBgView.backgroundColor = UIColor.white
        
        viewOverCellWhite = UIView()
        viewOverCellWhite.backgroundColor = UIColor.white
        viewOverCellWhite.isHidden = true
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(IPOCategoryView.closeCategory), for: UIControlEvents.touchUpInside)
        self.closeButton.isEnabled = false
        self.closeButton.alpha = 0
        
        imageIcon.contentMode = UIViewContentMode.center
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        separator = UIView()
        separator.backgroundColor = WMColor.light_gray
        
        
        self.addSubview(auxiliarBgView)
        self.bringSubview(toFront: titleLabel)
        self.addSubview(closeButton)
        self.addSubview(separator)
        self.addSubview(viewOverCellWhite)
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewOverCellWhite.frame = self.bounds
        if self.isSelected == false {
            imageBackground.frame = self.bounds
            titleLabel.frame = CGRect(x: 114, y: 0, width: self.frame.width - self.frame.height, height: self.frame.height)
            auxiliarBgView.frame = CGRect(x: self.frame.height, y: 0, width: self.frame.width - self.frame.height, height: self.frame.height)
            imageIcon.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
            closeButton.frame = CGRect(x: self.frame.maxX - 36, y: 0, width: 36, height: self.frame.height)
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            separator.frame = CGRect(x: auxiliarBgView.frame.minX, y: self.frame.height - widthAndHeightSeparator, width: self.frame.width, height: widthAndHeightSeparator)
        }
    }
    
    func animateAfterSelect() {
        self.closeButton.isEnabled = true
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.closeButton.alpha = 1
            self.auxiliarBgView.frame = CGRect(x: self.frame.maxX, y: 0, width: self.frame.width - self.frame.height, height: self.frame.height)
            self.titleLabel.frame = CGRect(x: self.frame.height - 24, y: 0, width: self.frame.width - self.frame.height, height: self.frame.height)
            self.titleLabel.textColor = UIColor.white
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            self.separator.frame = CGRect(x: self.auxiliarBgView.frame.minX, y: self.frame.height - widthAndHeightSeparator, width: self.frame.width, height: widthAndHeightSeparator)
        })
        
    }
    
    func closeCategory() {
        self.closeButton.isEnabled = false
        self.delegate?.closeButtonPressed()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.titleLabel.frame = CGRect(x: 114, y: 0, width: self.frame.width - self.frame.height, height: self.frame.height)
            self.auxiliarBgView.frame = CGRect(x: self.frame.height, y: 0, width: self.frame.width - self.frame.height, height: self.frame.height)
            self.titleLabel.textColor = WMColor.light_blue
            let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
            self.separator.frame = CGRect(x: self.auxiliarBgView.frame.minX, y: self.frame.height - widthAndHeightSeparator, width: self.frame.width, height: widthAndHeightSeparator)
            }, completion: { (complete:Bool) -> Void in
            self.delegate?.closeButtonPressedEndAnimation()
        }) 
        
    }
    
    
    
    
}
