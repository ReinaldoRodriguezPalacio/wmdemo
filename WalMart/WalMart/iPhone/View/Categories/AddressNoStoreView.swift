//
//  AddressNoStoreView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 08/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class AddressNoStoreView: UIView {
    var layerLine: CALayer!
    var newAdressForm: (() -> Void)?
    var newButton: UIButton?
    var infoLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.infoLabel = UILabel()
        self.infoLabel!.text = "Ingresa una dirección para poder facturar tu compra."
        self.infoLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.infoLabel!.textColor = WMColor.light_blue
        self.infoLabel!.numberOfLines = 2
        self.infoLabel!.textAlignment = .Center
        self.addSubview(infoLabel!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_gray.CGColor
        self.layer.insertSublayer(layerLine, atIndex: 0)
        
        self.newButton = UIButton()
        self.newButton!.setTitle("Crear Dirección", forState:.Normal)
        self.newButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.newButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.newButton!.backgroundColor = WMColor.green
        self.newButton!.layer.cornerRadius = 17
        self.newButton!.addTarget(self, action: #selector(AddressNoStoreView.new), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(newButton!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.infoLabel!.frame = CGRectMake(16,49,self.frame.width - 40, 95)
        self.layerLine.frame = CGRectMake(0,self.infoLabel!.frame.maxY,self.frame.width, 1)
        self.newButton?.frame = CGRectMake((self.frame.width/2) - 63 , self.layerLine.frame.maxY + 16, 125, 34)
    }
    
    /**
     Calls the block to show a view with address form
     */
    func new(){
        self.newAdressForm?()
    }
}