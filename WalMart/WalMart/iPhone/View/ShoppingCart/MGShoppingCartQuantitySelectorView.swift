//
//  MGShoppingCartQuantitySelectorView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 28/12/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class MGShoppingCartQuantitySelectorView : ShoppingCartQuantitySelectorView {

    var btnLess : UIButton!
    var btnMore : UIButton!
    
   override func setup() {
     super.setup()
     self.keyboardView.removeFromSuperview()
     self.keyboardView = nil
     let startPos = (self.frame.width - 288) / 2
     self.keyboardView = NumericKeyboardView(frame:CGRectMake(startPos, lblQuantity.frame.maxY + 10, 315, 212))
     self.keyboardView.widthButton = 80
     self.keyboardView.generateButtons(UIColor.whiteColor().colorWithAlphaComponent(0.35), selected: UIColor.whiteColor(),numberOfButtons: 5)
    self.keyboardView.delegate = self
    self.lblQuantity.textAlignment = .Center
    
    self.btnLess = UIButton(frame: CGRectMake(lblQuantity.frame.minX , lblQuantity.frame.minY , 32, 32))
    self.btnLess.addTarget(self, action: #selector(MGShoppingCartQuantitySelectorView.btnLessAction), forControlEvents: UIControlEvents.TouchUpInside)
    self.btnLess.setImage(UIImage(named: "addProduct_Less"), forState: UIControlState.Normal)
    
    self.btnMore = UIButton(frame: CGRectMake(lblQuantity.frame.maxX - 32, lblQuantity.frame.minY , 32, 32))
    self.btnMore.addTarget(self, action: #selector(MGShoppingCartQuantitySelectorView.btnMoreAction), forControlEvents: UIControlEvents.TouchUpInside)
    self.btnMore.setImage(UIImage(named: "addProduct_Add"), forState: UIControlState.Normal)
    
    self.addSubview(btnLess)
    self.addSubview(btnMore)
    self.addSubview(keyboardView)
    }
    
    func btnMoreAction() {
        let val = Int(lblQuantity.text!)
        if (val! + 1) <= 5 {
            lblQuantity.text = "0\(val! + 1)"
        }
    }
    
    func btnLessAction() {
        let val = Int(lblQuantity.text!)
        if (val! - 1)  >= 1 {
            lblQuantity.text = "0\(val! - 1)"
        }
    }


}