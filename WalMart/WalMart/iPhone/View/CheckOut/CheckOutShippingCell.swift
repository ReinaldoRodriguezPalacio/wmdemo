//
//  CheckOutShippingCell.swift
//  WalMart
//
//  Created by Everardo Garcia on 01/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit


protocol CheckOutShippingDelegate {
    func gotoShoppingCart()
  }

class CheckOutShippingCell: UITableViewCell {

    var labelNumber: UILabel?
    var descriptionTitle: UILabel?
    var cartButton : UIButton?
    var separator : CALayer?
    var delegate : CheckOutShippingDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        self.descriptionTitle = UILabel()
        self.descriptionTitle!.numberOfLines = 2
        self.descriptionTitle!.textAlignment = .Left
        self.descriptionTitle!.backgroundColor = UIColor.clearColor()
        self.descriptionTitle!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.descriptionTitle!.textColor = WMColor.dark_gray
        self.contentView.addSubview(self.descriptionTitle!)
        
     
        self.labelNumber = UILabel()
        self.labelNumber!.numberOfLines = 2
        self.labelNumber!.textAlignment = .Right
        self.labelNumber!.backgroundColor = UIColor.clearColor()
        self.labelNumber!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.labelNumber!.textColor = WMColor.reg_gray
        self.contentView.addSubview(self.labelNumber!)
        
        separator = CALayer()
        separator!.backgroundColor = WMColor.light_light_gray.CGColor
        self.layer.insertSublayer(separator!, atIndex: 0)
        //self.contentView.addSubview(self.separator!)
        
        self.cartButton = UIButton()
        self.cartButton!.setTitle("Editar Carrito", forState: .Normal)
        self.cartButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.cartButton!.addTarget(self, action: #selector(CheckOutShippingCell.shoppingCart), forControlEvents: .TouchUpInside)
        self.cartButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.cartButton!.backgroundColor =  WMColor.light_blue
        self.cartButton!.layer.cornerRadius =  11
        self.contentView.addSubview(self.cartButton!)
        
        cartButton!.hidden = true
        separator!.hidden = true

    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*margin)
        
        self.labelNumber!.frame = CGRectMake(bounds.width - 61, 0.0, 45.0, 30.0)
        self.descriptionTitle!.frame = CGRectMake(margin, 0.0, width -  (self.labelNumber!.frame.width + 8), 30.0)
        self.separator!.frame = CGRectMake(0, self.labelNumber!.frame.maxY, self.bounds.width, 1.0)
        self.cartButton!.frame = CGRectMake(margin,  self.labelNumber!.frame.maxY + 12, 76, 22)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(value: String, quanty: NSNumber) {
        if quanty != 0 {
            self.descriptionTitle!.text = value
            self.descriptionTitle!.textColor = WMColor.reg_gray
            self.labelNumber!.text = quanty == 1 ? "" : "(\(quanty))"
        }else{
         self.descriptionTitle!.text = value
            self.descriptionTitle!.textColor = WMColor.dark_gray
         self.labelNumber!.text = ""
        }
    }
    
    func shoppingCart() {
        delegate?.gotoShoppingCart()
    }
    
}


