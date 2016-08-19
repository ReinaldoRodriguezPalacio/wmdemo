//
//  ProductDetailCurrencyCollectionView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/4/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailCurrencyCollectionView : UITableViewCell {
    var titleLabel : CurrencyCustomLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        titleLabel = CurrencyCustomLabel(frame:CGRectMake(self.bounds.minX, self.bounds.minY , self.bounds.width,  self.bounds.height ))
        
    }
    
    func setValues(value:String,font:UIFont,textColor:UIColor,interLine:Bool){
        titleLabel.frame = CGRectMake(self.bounds.minX, self.bounds.minY , self.bounds.width,  self.bounds.height )
        titleLabel.updateMount(value, font: font, color: textColor, interLine: interLine)
        /*titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = textColor*/
        self.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //titleLabel.frame = CGRectMake(padding, 0, self.bounds.width - (padding * 2), self.bounds.height)
    }
    
    
}