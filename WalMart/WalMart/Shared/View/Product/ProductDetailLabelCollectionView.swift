//
//  ProductDetailLabelCollectionView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailLabelCollectionView  : UITableViewCell {
    
    var titleLabel : UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        titleLabel = UILabel()
    }
    
    func setValues(_ title:String,font:UIFont,numberOfLines:Int,textColor:UIColor,padding:CGFloat,align:NSTextAlignment){
        titleLabel.frame = CGRect(x: padding, y: 0, width: self.bounds.width - (padding * 2), height: self.bounds.height)
        titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = align
        titleLabel.textColor = textColor
        self.clearView(titleLabel)
        self.addSubview(titleLabel)
        
    }
    
    func clearView(_ view: UIView){
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
    }
    
    
}
