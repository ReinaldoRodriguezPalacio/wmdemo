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
        viewBgSel.backgroundColor = WMColor.light_light_gray
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = WMColor.light_blue
        
        countLabel = UILabel()
        countLabel.font = WMFont.fontMyriadProLightOfSize(16)
        countLabel.textColor = WMColor.light_blue
        
        separator = CALayer()
        separator.backgroundColor = WMColor.light_light_gray.cgColor
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(self.countLabel)
        self.layer.insertSublayer(separator, at: 0)
        self.addSubview(titleLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - 1.0)
        titleLabel.frame = CGRect(x: 16, y: 0, width: self.bounds.width - 32, height: self.bounds.height)
        countLabel.frame = CGRect(x: self.bounds.width - 32, y: 0, width: 32, height: self.bounds.height)
        let widthAndHeightSeparator = CGFloat(1.0)
        separator.frame = CGRect(x: 0, y: self.bounds.height - 1.2, width: self.bounds.width, height: widthAndHeightSeparator)
    }
    
    func setTitleAndCount(_ title:String,count: String){
        titleLabel.text = title
        countLabel.text = count
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
