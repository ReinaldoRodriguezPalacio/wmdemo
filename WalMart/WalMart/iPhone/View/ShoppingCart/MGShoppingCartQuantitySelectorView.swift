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
     self.keyboardView = NumericKeyboardView(frame:CGRect(x: startPos, y: lblQuantity.frame.maxY + 10, width: 315, height: 212))
     self.keyboardView.widthButton = 80
     self.keyboardView.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white,numberOfButtons: 5)
    self.keyboardView.delegate = self
    self.lblQuantity.textAlignment = .center
    
    self.btnLess = UIButton(frame: CGRect(x: lblQuantity.frame.minX , y: lblQuantity.frame.minY , width: 32, height: 32))
    self.btnLess.addTarget(self, action: #selector(MGShoppingCartQuantitySelectorView.btnLessAction), for: UIControlEvents.touchUpInside)
    self.btnLess.setImage(UIImage(named: "addProduct_Less"), for: UIControlState())
    
    self.btnMore = UIButton(frame: CGRect(x: lblQuantity.frame.maxX - 32, y: lblQuantity.frame.minY , width: 32, height: 32))
    self.btnMore.addTarget(self, action: #selector(MGShoppingCartQuantitySelectorView.btnMoreAction), for: UIControlEvents.touchUpInside)
    self.btnMore.setImage(UIImage(named: "addProduct_Add"), for: UIControlState())
    
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
