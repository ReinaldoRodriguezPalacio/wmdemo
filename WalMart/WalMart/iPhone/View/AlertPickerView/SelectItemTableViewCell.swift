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
    var disclosureImage : UIImageView!
    var preferedImage : UIImageView!
    var layerLine: CALayer!
    var showSeparator: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        self.checkSelected = UIImageView(frame: CGRect(x: 8, y: 0, width: 33, height: 46))
        self.checkSelected.image = UIImage(named: "checkTermOff")
        self.checkSelected.contentMode = UIViewContentMode.center

        self.addSubview(checkSelected)
        
        self.textLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.textLabel?.textColor = WMColor.reg_gray
        self.textLabel?.numberOfLines = 0
        
        
        self.showButton = UIButton()
        self.showButton?.isHidden = true
        self.showButton?.setTitle("ver", for: UIControlState())
        self.showButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.showButton?.setTitleColor( WMColor.light_blue, for: UIControlState())
        addSubview(showButton!)
        
        self.disclosureImage = UIImageView(frame: CGRect(x: 250, y: 0, width: 22, height: self.textLabel!.frame.height))
        self.disclosureImage.image = UIImage(named: "disclosure")
        self.disclosureImage.contentMode = UIViewContentMode.center
        self.disclosureImage.isHidden = true
        self.addSubview(disclosureImage)
        
        self.preferedImage = UIImageView(frame: CGRect(x: self.disclosureImage.frame.minX - 16, y: 0, width: 22, height: self.textLabel!.frame.height))
        self.preferedImage.image = UIImage(named: "favorite_selected")
        self.preferedImage.contentMode = UIViewContentMode.center
        self.preferedImage.isHidden = true
        self.addSubview(preferedImage)
        
        self.layerLine = CALayer()
        self.layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 100)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkSelected.frame = CGRect(x: 0, y: 0, width: 33, height: 46)
        self.textLabel?.frame = CGRect(x: self.checkSelected.frame.maxX, y: self.textLabel!.frame.minY, width: 249, height: self.textLabel!.frame.height)
        self.showButton?.frame = CGRect(x: 250, y: self.textLabel!.frame.minY, width: 22, height: self.textLabel!.frame.height)
        self.disclosureImage?.frame = CGRect(x: self.frame.width - 38, y: 0, width: 22, height: self.textLabel!.frame.height)
        self.preferedImage?.frame = CGRect(x: self.disclosureImage.frame.minX - 26, y: 0, width: 22, height: self.textLabel!.frame.height)
        if self.showSeparator {
            self.layerLine.frame = CGRect(x: 22, y: self.frame.height - 1, width: self.frame.width - 24, height: 1)
        }else{
            self.layerLine.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.isSelected {
            self.checkSelected.image = UIImage(named: "check_full")
            self.textLabel?.textColor = WMColor.light_blue
        } else {
            self.checkSelected.image = UIImage(named: "checkTermOff")
            self.textLabel?.textColor = WMColor.reg_gray
        }
        super.setSelected(selected,animated:animated)
        
    }
    
    
    class func sizeText(_ text:String,width:CGFloat) -> CGFloat {
        let attrString = NSAttributedString(string:text, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14)])
        let rectSize = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.max), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return rectSize.height + 32

    }
    
   
    
}
