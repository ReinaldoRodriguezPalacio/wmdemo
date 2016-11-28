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
        checkSelected = UIImageView(frame: CGRect(x: 8, y: 0, width: 33, height: 46))
        checkSelected.image = UIImage(named: "checkTermOff")
        checkSelected.contentMode = UIViewContentMode.center

        self.addSubview(checkSelected)
        
        self.textLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textLabel?.textColor = WMColor.gray
        self.textLabel?.numberOfLines = 0
        
        self.showButton = UIButton()
        self.showButton?.isHidden = true
        self.showButton?.setTitle("ver", for: UIControlState())
        self.showButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.showButton?.setTitleColor( WMColor.light_blue, for: UIControlState())
        addSubview(showButton!)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkSelected.frame = CGRect(x: 0, y: 0, width: 33, height: 46)
        
        self.textLabel?.frame = CGRect(x: self.checkSelected.frame.maxX, y: self.textLabel!.frame.minY, width: 249, height: self.textLabel!.frame.height)
        
        self.showButton?.frame = CGRect(x: 250, y: self.textLabel!.frame.minY, width: 22, height: self.textLabel!.frame.height)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.isSelected {
            self.checkSelected.image = UIImage(named: "checkAddressOn")
            self.textLabel?.textColor = WMColor.light_blue
        } else {
            self.checkSelected.image = UIImage(named: "checkTermOff")
            self.textLabel?.textColor = WMColor.gray
        }
        super.setSelected(selected,animated:animated)
        
    }
    
    
    class func sizeText(_ text:String,width:CGFloat) -> CGFloat {
        let attrString = NSAttributedString(string:text, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)])
        let rectSize = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return rectSize.height + 32

    }
    
   
    
}
