//
//  helpViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 30/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class HelpViewCell: UITableViewCell {
    var titleLabel : UILabel!
    var viewLine : UIView!
    
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
        viewLine = UIView()
        self.addSubview(titleLabel)
        self.addSubview(viewLine)
     }
    
    func setValues(title:String,font:UIFont,numberOfLines:Int,textColor:UIColor,padding:CGFloat,align:NSTextAlignment){
        
        titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = align
        titleLabel.textColor = textColor
        
        viewLine.frame =  CGRectMake(padding, self.bounds.height-1 , self.bounds.width - padding, AppDelegate.separatorHeigth() )
        viewLine.backgroundColor = WMColor.light_light_gray
        titleLabel.frame = CGRectMake(padding, 1, self.bounds.width -  (padding * 2), self.bounds.height - 1)
    }
    
    
}