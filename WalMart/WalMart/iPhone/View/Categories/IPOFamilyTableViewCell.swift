//
//  IPOFamilyTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class IPOFamilyTableViewCell : UITableViewCell {
    
    
    var titleLabel : UILabel!
    var separator : UIView!
    var viewBgSel : UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.light_light_gray
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = WMColor.light_blue
        
        separator = UIView()
        separator.backgroundColor = WMColor.light_light_gray
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(separator)
        self.addSubview(titleLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - 1.0)
        titleLabel.frame = CGRect(x: 20, y: 0, width: self.bounds.width - 40, height: self.bounds.height)
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        separator.frame = CGRect(x: 0, y: self.bounds.height - widthAndHeightSeparator, width: self.bounds.width, height: widthAndHeightSeparator)
    }
    
    func setTitle(_ title:String){
        titleLabel.text = title
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.isHidden = !selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.isHidden = true
    }
    
}
