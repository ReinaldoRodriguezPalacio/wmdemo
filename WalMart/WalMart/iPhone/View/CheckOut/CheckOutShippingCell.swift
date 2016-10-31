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
        
        self.selectionStyle = .none
        
        self.descriptionTitle = UILabel()
        self.descriptionTitle!.numberOfLines = 2
        self.descriptionTitle!.textAlignment = .left
        self.descriptionTitle!.backgroundColor = UIColor.clear
        self.descriptionTitle!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.descriptionTitle!.textColor = WMColor.dark_gray
        self.contentView.addSubview(self.descriptionTitle!)
        
     
        self.labelNumber = UILabel()
        self.labelNumber!.numberOfLines = 2
        self.labelNumber!.textAlignment = .right
        self.labelNumber!.backgroundColor = UIColor.clear
        self.labelNumber!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.labelNumber!.textColor = WMColor.reg_gray
        self.contentView.addSubview(self.labelNumber!)
        
        separator = CALayer()
        separator!.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(separator!, at: 0)
        //self.contentView.addSubview(self.separator!)
        
        self.cartButton = UIButton()
        self.cartButton!.setTitle("Editar Carrito", for: UIControlState())
        self.cartButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.cartButton!.addTarget(self, action: #selector(CheckOutShippingCell.shoppingCart), for: .touchUpInside)
        self.cartButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.cartButton!.backgroundColor =  WMColor.light_blue
        self.cartButton!.layer.cornerRadius =  11
        self.contentView.addSubview(self.cartButton!)
        
        cartButton!.isHidden = true
        separator!.isHidden = true

    }
    
    override func layoutSubviews() {
        let bounds = self.frame
        let margin:CGFloat = 16.0
        let width:CGFloat = bounds.width - (2*margin)
        
        self.labelNumber!.frame = CGRect(x: bounds.width - 61, y: 0.0, width: 45.0, height: 30.0)
        self.descriptionTitle!.frame = CGRect(x: margin, y: 0.0, width: width -  (self.labelNumber!.frame.width + 8), height: 30.0)
        self.separator!.frame = CGRect(x: 0, y: self.labelNumber!.frame.maxY, width: self.bounds.width, height: 1.0)
        self.cartButton!.frame = CGRect(x: margin,  y: self.labelNumber!.frame.maxY + 12, width: 76, height: 22)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(_ value: String, quanty: NSNumber) {
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


