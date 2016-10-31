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
        
        self.selectionStyle = .none
        
        self.titleLabel = UILabel()
        self.titleLabel!.numberOfLines = 1
        self.titleLabel!.textAlignment = .left
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.titleLabel!.textColor =  WMColor.light_blue
        self.contentView.addSubview(self.titleLabel!)
        
        self.descriptionLabel  =  UILabel()
        self.descriptionLabel!.numberOfLines = 3
        self.descriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.descriptionLabel!.textColor =  WMColor.reg_gray
        self.contentView.addSubview(self.descriptionLabel!)
        
        self.nameLabel  =  UILabel()
        self.nameLabel!.numberOfLines = 1
        self.nameLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel!.textColor =  WMColor.reg_gray
        self.contentView.addSubview(self.nameLabel!)
        
        self.moreDetail =  UILabel()
        moreDetail!.font = WMFont.fontMyriadProRegularOfSize(14)
        moreDetail!.textColor =  WMColor.reg_gray
        self.contentView.addSubview(moreDetail!)

    }
    
    override func layoutSubviews() {
        self.titleLabel?.frame = CGRect(x: 16, y:16 , width:self.contentView.frame.width - 32 , height:12)
        self.descriptionLabel?.frame = CGRect(x: 16, y:titleLabel!.frame.maxY + 4, width:self.contentView.frame.width - 32 , height:28)
        self.nameLabel?.frame = CGRect(x: 16, y:titleLabel!.frame.maxY + 4 , width:self.contentView.frame.width - 32 , height:14)
        
        let y = self.descriptionLabel?.text == "" ? nameLabel!.frame.maxY + 4 : descriptionLabel!.frame.maxY + 4
        self.moreDetail?.frame  = CGRect(x: 16, y:y, width:self.contentView.frame.width - 32 , height:14)
    }
    
    
    func setValues(_ title: String,name:String,description:String,detailDesc:String) {
        
        titleLabel!.text = title
        nameLabel?.text =  name
        nameLabel!.isHidden = name == ""
        
        descriptionLabel!.text = description
        descriptionLabel!.isHidden = description == ""
        
        moreDetail!.isHidden = detailDesc == ""
        moreDetail!.text = detailDesc
    
    }
    
    
}
