//
//  AddInvoiceAddressView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 02/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class AddInvoiceAddressView:GRAddAddressView {

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func setup() {
        super.setup()
        
        let addressController = AddressViewController()
        addressController.typeAddress = TypeAddress.FiscalMoral
        
        self.scrollForm = addressController.content
    }
    
    override func layoutSubviews() {
        self.scrollForm?.frame = CGRectMake(0,0,self.frame.width,self.frame.height - 66)
        self.layerLine.frame = CGRectMake(0,self.frame.height - 66,self.frame.width, 1)
        
        if self.showCancelButton {
            self.saveButton?.frame = CGRectMake((self.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton?.frame = CGRectMake((self.frame.width/2) - 133 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton!.hidden = false
        }else{
            self.saveButton?.frame = CGRectMake((self.frame.width/2) - 63 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton?.frame = CGRectMake((self.frame.width/2) - 63 , self.layerLine.frame.maxY + 16, 125, 34)
            self.cancelButton!.hidden = true
        }
    }



}