//
//  CategorySelectorItemView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class CategorySelectorItemView: UIView {
    
    var title: UILabel!
    var especiales: UILabel!
    var sizeEspeciales: CGSize!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.especiales.alpha == 0 {
            self.title.sizeToFit()
            centerText()
        }
    }
    
    func setup() {
        
        title = UILabel(frame: self.bounds)
        title.font = WMFont.fontMyriadProRegularOfSize(16)
        
        let maxStrCat = "Especiales "
        sizeEspeciales = maxStrCat.size(attributes: [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(16)])
        
        especiales = UILabel(frame: CGRect(x: -sizeEspeciales.width, y: self.bounds.minY, width: sizeEspeciales.width, height: self.bounds.height))
        especiales.text = maxStrCat
        especiales.font = WMFont.fontMyriadProRegularOfSize(16)
        especiales.textColor = UIColor.white
        especiales.alpha = 0
        especiales.clipsToBounds = true
        
        self.addSubview(especiales)
        self.addSubview(title)
    }

    func setTextEspeciales() {
        
        self.especiales.frame = CGRect(x: self.title.frame.minX, y: self.bounds.minY, width: 0, height: self.bounds.height)
        self.especiales.alpha = 1
       
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let maxStrCat =  self.title.text!
            let sizeCategory = maxStrCat.size(attributes: [NSFontAttributeName: WMFont.fontMyriadProRegularOfSize(16)])
            let space = self.sizeEspeciales.width + sizeCategory.width
            self.especiales.frame = CGRect(x: (self.bounds.width / 2) - (space / 2) , y: self.bounds.minY, width: self.sizeEspeciales.width, height: self.bounds.height)
            self.title.frame = CGRect(x: self.especiales.frame.maxX, y: self.bounds.minY, width: sizeCategory.width , height: self.bounds.height)
        })
    }
    
    func deleteEspeciales() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.especiales.alpha = 0
            self.centerText()
        })
    }
    
    func centerText() {
        self.title.center = self.center;
    }

}
