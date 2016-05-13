//
//  ReferedDetailTableViewCell.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation
/// Celda con detalle de Referidos
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
        separator.backgroundColor = WMColor.light_light_gray.CGColor
        
        self.addSubview(self.viewBgSel!)
        self.layer.insertSublayer(separator, atIndex: 0)
        self.addSubview(referedLabel)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewBgSel!.frame =  CGRectMake(0.0, 0.0, bounds.width, bounds.height - 1.0)
        referedLabel.frame = CGRectMake(16, 0, self.bounds.width - 16, self.bounds.height)
        let widthAndHeightSeparator = CGFloat(1.0)
        separator.frame = CGRectMake(0, self.bounds.height - 1.3, self.bounds.width, widthAndHeightSeparator)
    }
    
    func setValues(name:String,email: String){
        referedLabel.text = "\(name)\n\(email)"
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