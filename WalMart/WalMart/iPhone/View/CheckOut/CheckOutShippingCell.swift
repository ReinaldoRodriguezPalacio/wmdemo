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
    var separator : UIView?
    var delegate : CheckOutShippingDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
        self.descriptionTitle = UILabel()
        self.descriptionTitle!.numberOfLines = 1
        self.descriptionTitle!.textAlignment = .Left
        self.descriptionTitle!.backgroundColor = UIColor.clearColor()
        
        self.descriptionTitle!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.descriptionTitle!.textColor = WMColor.gray_reg
        self.contentView.addSubview(self.descriptionTitle!)
        
     
        self.labelNumber = UILabel()
        self.labelNumber!.numberOfLines = 2
        self.labelNumber!.textAlignment = .Left
        self.labelNumber!.backgroundColor = UIColor.clearColor()
        self.labelNumber!.font = WMFont.fontMyriadProRegularOfSize(12)
        self.contentView.addSubview(self.labelNumber!)
        
        self.separator = UIView(frame:  CGRect(x:0 , y:0 , width: self.contentView.frame.width, height:1))
        self.separator?.backgroundColor = WMColor.light_gray
        self.contentView.addSubview(self.separator!)
        
        self.cartButton = UIButton(frame: CGRect(x:16 , y:30 , width: 80  , height:30))
        self.cartButton!.setTitle("Editar Carrito", forState: .Normal)
        self.cartButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.cartButton!.addTarget(self, action: #selector(CheckOutShippingCell.shoppingCart), forControlEvents: .TouchUpInside)
        self.cartButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cartButton!.backgroundColor =  WMColor.blue
        self.cartButton!.layer.cornerRadius =  17
        self.contentView.addSubview(self.cartButton!)
        
        cartButton!.hidden = true
        separator!.hidden = true

    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*margin)
        
        self.labelNumber!.frame = CGRectMake(bounds.width - 40, 0.0, 30.0, 30.0)
        self.descriptionTitle!.frame = CGRectMake(margin, 0.0, width -  self.labelNumber!.frame.width, 30.0)
        self.separator!.frame = CGRectMake(0,  self.labelNumber!.frame.maxY, bounds.width, 1.0)
        self.cartButton!.frame = CGRectMake(margin,  self.labelNumber!.frame.maxY + 12, 100.0, 30.0)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(value: String, quanty: String ) {
        var quantyInt =  Int(quanty)
        self.descriptionTitle!.text = value
        if quanty != "" {
            self.labelNumber!.text = "(\(quanty))"
        }
    }
    
    func shoppingCart() {
        delegate?.gotoShoppingCart()
    }
    
}


