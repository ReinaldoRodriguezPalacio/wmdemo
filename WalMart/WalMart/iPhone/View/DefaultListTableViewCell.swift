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
        
        self.iconView.frame = CGRect(x: 8, y: 8, width: 81, height: 81)
        self.nameView!.frame = CGRect(x: self.iconView.frame.maxX + 16, y: 16, width: self.frame.width - (self.iconView.frame.maxX + 32), height: 32)
        self.articlesView!.frame = CGRect(x: self.iconView.frame.maxX + 16,y: self.nameView!.frame.maxY +  2, width: 81, height: 14)
        self.priceView!.frame = CGRect(x: self.iconView.frame.maxX + 16, y: self.articlesView!.frame.maxY + 8, width: 81, height: 18)
        self.separator!.frame = CGRect(x: self.iconView.frame.maxX, y: self.bounds.height - 1,width: self.frame.width - 16, height: 1)
        
    
    
    
    }
    
    func setup(){
        
        self.iconView = UIImageView(frame: CGRect(x: 8, y: 8, width: 81, height: 81))
        self.iconView.image = UIImage(named: "superlist")
        self.iconView.contentMode = UIViewContentMode.center
        self.addSubview(self.iconView)
        
        self.nameView = UILabel(frame: CGRect(x: self.iconView.frame.maxX + 16, y: 17, width: self.frame.width - (self.iconView.frame.maxX + 32), height: 14))
        self.nameView!.font =  WMFont.fontMyriadProLightOfSize(16) //WMFont.fontMyriadProRegularOfSize(14)
        self.nameView!.textColor = WMColor.gray
        self.nameView!.numberOfLines = 2
        self.addSubview(self.nameView)
        
        self.articlesView = UILabel(frame: CGRect(x: self.iconView.frame.maxX + 14, y: self.nameView!.frame.maxY + 16, width: 81, height: 14))
        self.articlesView!.font = WMFont.fontMyriadProRegularOfSize(14)// WMFont.fontMyriadProSemiboldSize(14)
        self.articlesView!.textColor = WMColor.gray
        self.addSubview(self.articlesView)
        
        self.priceView = UILabel(frame: CGRect(x: self.iconView.frame.maxX + 16, y: self.articlesView!.frame.maxY + 8, width: 81, height: 18))
        self.priceView!.font = WMFont.fontMyriadProSemiboldSize(18)
        self.priceView!.textColor = WMColor.orange
        self.addSubview(self.priceView)
        
        self.separator = UIView(frame:CGRect(x: 16, y: 108,width: self.frame.width - 16, height: 1.0))
        self.separator!.backgroundColor = WMColor.light_light_gray
        self.addSubview(self.separator!)


        
    }

    
    
    func setValues(_ nameList:String,numberItems:String,total:String) {
        self.nameView!.text = nameList
        self.articlesView!.text = String(format: NSLocalizedString("list.articles", comment:""), numberItems)
        self.priceView!.text = total
    }
    
}
