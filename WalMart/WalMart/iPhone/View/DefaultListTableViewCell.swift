//
//  File.swift
//  WalMart
//
//  Created by Alejandro Miranda on 24/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class DefaultListTableViewCell : UITableViewCell {


    var iconView : UIImageView!
    var nameView : UILabel!
    var articlesView : UILabel!
    var priceView : UILabel!
    var separator: UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    override func layoutSubviews() {
        
        self.iconView.frame = CGRectMake(8, 8, 81, 81)
        self.nameView!.frame = CGRectMake(self.iconView.frame.maxX + 16, 16, self.frame.width - (self.iconView.frame.maxX + 32), 32)
        self.articlesView!.frame = CGRectMake(self.iconView.frame.maxX + 16,self.nameView!.frame.maxY +  2, 81, 14)
        self.priceView!.frame = CGRectMake(self.iconView.frame.maxX + 16, self.articlesView!.frame.maxY + 8, 81, 18)
        self.separator!.frame = CGRectMake(nameView!.frame.minX, 108,self.frame.width - nameView!.frame.minX, AppDelegate.separatorHeigth())
       
        
    }
    
    func setup(){
        
        self.iconView = UIImageView(frame: CGRectMake(8, 8, 81, 81))
        self.iconView.image = UIImage(named: "superlist")
        self.iconView.contentMode = UIViewContentMode.Center
        self.addSubview(self.iconView)
        
        self.nameView = UILabel(frame: CGRectMake(self.iconView.frame.maxX + 16, 17, self.frame.width - (self.iconView.frame.maxX + 32), 14))
        self.nameView!.font =  WMFont.fontMyriadProLightOfSize(16) //WMFont.fontMyriadProRegularOfSize(14)
        self.nameView!.textColor = WMColor.regular_gray
        self.nameView!.numberOfLines = 2
        self.addSubview(self.nameView)
        
        self.articlesView = UILabel(frame: CGRectMake(self.iconView.frame.maxX + 14, self.nameView!.frame.maxY + 16, 81, 14))
        self.articlesView!.font = WMFont.fontMyriadProRegularOfSize(14)// WMFont.fontMyriadProSemiboldSize(14)
        self.articlesView!.textColor = WMColor.regular_gray
        self.addSubview(self.articlesView)
        
        self.priceView = UILabel(frame: CGRectMake(self.iconView.frame.maxX + 16, self.articlesView!.frame.maxY + 8, 81, 18))
        self.priceView!.font = WMFont.fontMyriadProSemiboldSize(18)
        self.priceView!.textColor = WMColor.orange
        self.addSubview(self.priceView)
        
        self.separator = UIView(frame:CGRectMake(nameView!.frame.minX, 108,self.frame.width - nameView!.frame.minX, AppDelegate.separatorHeigth()))
        self.separator!.backgroundColor = WMColor.lineSaparatorColor
        self.addSubview(self.separator!)
        
    }
    
    
    
    func setValues(nameList:String,numberItems:String,total:String) {
        self.nameView!.text = nameList
        self.articlesView!.text = String(format: NSLocalizedString("list.articles", comment:""), numberItems)
        self.priceView!.text = total
    }
    
}
