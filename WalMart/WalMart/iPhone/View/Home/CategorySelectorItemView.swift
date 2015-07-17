//
//  CategorySelectorItemView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class CategorySelectorItemView: UIView,iCarouselItem {
    
    
    var title : UILabel!
    var especiales : UILabel!
    var sizeEspeciales : CGSize!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        title = UILabel(frame: self.bounds)
        title.font = WMFont.fontMyriadProRegularOfSize(16)
        
        
        let maxStrCat =  "Especiales "
        sizeEspeciales = maxStrCat.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16)])
        
        especiales = UILabel(frame: CGRectMake(-sizeEspeciales.width, self.bounds.minY, sizeEspeciales.width, self.bounds.height))
        especiales.text = maxStrCat
        especiales.font = WMFont.fontMyriadProRegularOfSize(16)
        especiales.textColor = UIColor.whiteColor()
        especiales.alpha = 0
        especiales.clipsToBounds = true
        
        self.addSubview(especiales)
        self.addSubview(title)
    }
    
    
    
    func setTextEspeciales() {
        self.especiales.frame =  CGRectMake( self.title.frame.minX, self.bounds.minY, 0, self.bounds.height)
        self.especiales.alpha = 1
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let maxStrCat =  self.title.text!
            let sizeCategory = maxStrCat.sizeWithAttributes([NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16)])
            let space = self.sizeEspeciales.width + sizeCategory.width
            self.especiales.frame = CGRectMake((self.bounds.width / 2) - (space / 2) , self.bounds.minY, self.sizeEspeciales.width, self.bounds.height)
            self.title.frame = CGRectMake(self.especiales.frame.maxX, self.bounds.minY, sizeCategory.width , self.bounds.height)
            }) { (complete:Bool) -> Void in
                
        }
    }
    
    func deleteEspeciales() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.especiales.alpha = 0
            self.centerText()
            }) { (complete:Bool) -> Void in
                
        }
    }
    
    func centerText() {
        self.title.center = self.center;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.especiales.alpha == 0 {
            self.title.sizeToFit()
            centerText()
        }
    }
    
    
}