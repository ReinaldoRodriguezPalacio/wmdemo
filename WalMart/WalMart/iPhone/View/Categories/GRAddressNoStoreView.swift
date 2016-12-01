//
//  GRAddressNoStoreView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 08/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class GRAddressNoStoreView: UIView {
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
        self.infoLabel!.text = "Para poder ver el inventario de una tienda debes de registrar una dirección."
        self.infoLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.infoLabel!.textColor = WMColor.light_blue
        self.infoLabel!.numberOfLines = 2
        self.addSubview(infoLabel!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_gray.cgColor
        self.layer.insertSublayer(layerLine, at: 0)
        
        self.newButton = UIButton()
        self.newButton!.setTitle("Nueva Dirección", for:UIControlState())
        self.newButton!.titleLabel!.textColor = UIColor.white
        self.newButton!.titleLabel!.font = WMFont.fontMyriadProLightOfSize(14)
        self.newButton!.backgroundColor = WMColor.light_blue
        self.newButton!.layer.cornerRadius = 17
        self.newButton!.addTarget(self, action: #selector(GRAddressNoStoreView.new), for: UIControlEvents.touchUpInside)
        self.addSubview(newButton!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.infoLabel!.frame = CGRect(x: 16,y: 49,width: self.frame.width - 40, height: 95)
        self.layerLine.frame = CGRect(x: 0,y: self.infoLabel!.frame.maxY,width: self.frame.width, height: 1)
        self.newButton?.frame = CGRect(x: (self.frame.width/2) - 63 , y: self.layerLine.frame.maxY + 16, width: 125, height: 34)
    }
    
    /**
     Calls the block to show a view with address form
     */
    func new(){
        self.newAdressForm?()
    }
}
