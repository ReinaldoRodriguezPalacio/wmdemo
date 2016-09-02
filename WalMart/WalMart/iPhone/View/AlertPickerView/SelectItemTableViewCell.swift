//
//  SelectItemTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class SelectItemTableViewCell : UITableViewCell {
    
    var showButton: UIButton?
    var checkSelected : UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
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
        self.textLabel?.textColor = WMColor.gray_reg
        self.textLabel?.numberOfLines = 0
        
        self.showButton = UIButton()
        self.showButton?.hidden = true
        self.showButton?.setTitle("ver", forState: UIControlState.Normal)
        self.showButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.showButton?.setTitleColor( WMColor.light_blue, forState: UIControlState.Normal)
        addSubview(showButton!)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkSelected.frame = CGRectMake(0, 0, 33, 46)
        
        self.textLabel?.frame = CGRectMake(self.checkSelected.frame.maxX, self.textLabel!.frame.minY, 249, self.textLabel!.frame.height)
        
        self.showButton?.frame = CGRectMake(250, self.textLabel!.frame.minY, 22, self.textLabel!.frame.height)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if self.selected {
            self.checkSelected.image = UIImage(named: "checkAddressOn")
            self.textLabel?.textColor = WMColor.light_blue
        } else {
            self.checkSelected.image = UIImage(named: "checkTermOff")
            self.textLabel?.textColor = WMColor.gray_reg
        }
        super.setSelected(selected,animated:animated)
        
    }
    
    
    class func sizeText(text:String,width:CGFloat) -> CGFloat {
        let attrString = NSAttributedString(string:text, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)])
        let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return rectSize.height + 32

    }
    
   
    
}