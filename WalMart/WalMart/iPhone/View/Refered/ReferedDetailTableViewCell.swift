//
//  ReferedDetailTableViewCell.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedDetailTableViewCell : UITableViewCell {
    
    var referedLabel : UILabel!
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
        
        referedLabel = UILabel()
        referedLabel.font = WMFont.fontMyriadProLightOfSize(16)
        referedLabel.textColor = WMColor.dark_gray
        referedLabel.numberOfLines = 2
        
        separator = CALayer()
        separator.backgroundColor = WMColor.light_light_gray.cgColor
        
        self.addSubview(self.viewBgSel!)
        self.layer.insertSublayer(separator, at: 0)
        self.addSubview(referedLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - 1.0)
        referedLabel.frame = CGRect(x: 16, y: 0, width: self.bounds.width - 16, height: self.bounds.height)
        let widthAndHeightSeparator = CGFloat(1.0)
        separator.frame = CGRect(x: 0, y: self.bounds.height - 1.3, width: self.bounds.width, height: widthAndHeightSeparator)
    }
    
    func setValues(_ name:String,email: String){
        referedLabel.text = "\(name)\n\(email)"
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
