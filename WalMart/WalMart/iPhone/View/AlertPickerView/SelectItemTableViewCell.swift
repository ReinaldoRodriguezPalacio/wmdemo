//
//  SelectItemTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class SelectItemTableViewCell : UITableViewCell {
    
    
    var checkSelected : UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        
        
        checkSelected = UIImageView(frame: CGRectMake(8, 0, 33, 46))
        checkSelected.image = UIImage(named: "checkTermOff")
        checkSelected.contentMode = UIViewContentMode.Center

        self.addSubview(checkSelected)
        
        self.textLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textLabel?.textColor = WMColor.selectorPickerText
        
        self.textLabel?.numberOfLines = 0
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkSelected.frame = CGRectMake(0, 0, 33, 46)
        
        self.textLabel?.frame = CGRectMake(self.checkSelected.frame.maxX, self.textLabel!.frame.minY, 247.0, self.textLabel!.frame.height)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if self.selected {
            checkSelected.image = UIImage(named: "checkAddressOn")
        } else {
            checkSelected.image = UIImage(named: "checkTermOff")
        }
        super.setSelected(selected,animated:animated)
        
    }
    
    
    class func sizeText(text:String,width:CGFloat) -> CGFloat {
        let attrString = NSAttributedString(string:text, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)])
        let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return rectSize.height + 32

    }
    
   
    
}