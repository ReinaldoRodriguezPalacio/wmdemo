//
//  ComfirmViewCell.swift
//  WalMart
//
//  Created by Ingenieria de Soluciones on 02/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class ComfirmViewCell: UITableViewCell {

    
    var titleLabel: UILabel?
    var nameLabel : UILabel?
    var descriptionLabel: UILabel?
    var moreDetail: UILabel?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        self.titleLabel = UILabel()
        self.titleLabel!.numberOfLines = 1
        self.titleLabel!.textAlignment = .Left
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.titleLabel!.textColor =  WMColor.light_blue
        self.contentView.addSubview(self.titleLabel!)
        
        
        self.descriptionLabel  =  UILabel()
        self.descriptionLabel!.numberOfLines = 3
        self.descriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.descriptionLabel!.textColor =  WMColor.gray_reg
        self.contentView.addSubview(self.descriptionLabel!)
        
        
        self.nameLabel  =  UILabel()
        self.nameLabel!.numberOfLines = 1
        self.nameLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel!.textColor =  WMColor.gray_reg
        self.contentView.addSubview(self.nameLabel!)
        
        
        self.moreDetail =  UILabel()
        moreDetail!.font = WMFont.fontMyriadProRegularOfSize(14)
        moreDetail!.textColor =  WMColor.gray_reg
        self.contentView.addSubview(moreDetail!)

    
    }
    
    override func layoutSubviews() {
        self.titleLabel?.frame = CGRect(x: 16, y:16 , width:self.contentView.frame.width - 32 , height:12)
        self.descriptionLabel?.frame = CGRect(x: 16, y:titleLabel!.frame.maxY + 8 , width:self.contentView.frame.width - 32 , height:36)
        self.nameLabel?.frame = CGRect(x: 16, y:titleLabel!.frame.maxY + 8 , width:self.contentView.frame.width - 32 , height:14)
        self.moreDetail?.frame  = CGRect(x: 16, y:descriptionLabel!.frame.maxY + 8 , width:self.contentView.frame.width - 32 , height:14)
    }
    
    
    func setValues(title: String,name:String,description:String,detailDesc:String ) {
        
        titleLabel!.text = title
        nameLabel?.text =  name
        descriptionLabel!.text = description
        descriptionLabel!.highlighted = description == ""
        
        
        moreDetail!.hidden = detailDesc == ""
        moreDetail!.text = detailDesc
    
    }
    
    
    

}