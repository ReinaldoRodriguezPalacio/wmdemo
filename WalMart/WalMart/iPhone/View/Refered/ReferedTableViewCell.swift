//
//  ReferedTableViewCell.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedTableViewCell : UITableViewCell {

    var titleLabel : UILabel!
    var countLabel: UILabel!
    var separator : CALayer!
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
        viewBgSel.backgroundColor = WMColor.UIColorFromRGB(0xE1ECFB)
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = WMColor.light_blue
        
        countLabel = UILabel()
        countLabel.font = WMFont.fontMyriadProLightOfSize(16)
        countLabel.textColor = WMColor.light_blue
        
        separator = CALayer()
        separator.backgroundColor = WMColor.light_light_gray.CGColor
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(self.countLabel)
        self.layer.insertSublayer(separator, atIndex: 0)
        self.addSubview(titleLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)
        titleLabel.frame = CGRectMake(16, 0, self.bounds.width - 32, self.bounds.height)
        countLabel.frame = CGRectMake(self.bounds.width - 32, 0, 32, self.bounds.height)
        let widthAndHeightSeparator = CGFloat(1.0)
        separator.frame = CGRectMake(0, self.bounds.height - 1.2, self.bounds.width, widthAndHeightSeparator)
    }
    
    func setTitleAndCount(title:String,count: String){
        titleLabel.text = title
        countLabel.text = count
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: true)
        viewBgSel.hidden = !selected
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.hidden = true
    }
    
}