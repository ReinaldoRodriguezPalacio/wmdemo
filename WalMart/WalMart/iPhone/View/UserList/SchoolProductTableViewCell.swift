//
//  SchoolProductTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolProductTableViewCell: DetailListViewCell {
    
  override func setValuesDictionary(product:[String:AnyObject],disabled:Bool) {
        var imageUrl: String? = ""
        if let imageArray = product["imageUrl"] as? NSArray {
            if imageArray.count > 0 {
                imageUrl = imageArray[0] as? String
            }
        } else if let imageUrlTxt = product["imageUrl"] as? String {
            imageUrl = imageUrlTxt
        }
        self.promoDescription!.text = product["promoDescription"] as? String
        self.upcVal = product["upc"] as? String
        
        if let equivalence = product["equivalenceByPiece"] as? NSNumber {
            self.equivalenceByPiece = equivalence
        }
        
        if let equivalence = product["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                self.equivalenceByPiece =  NSNumber(int: equivalence.intValue)
            }
        }
    
        self.onHandInventory = Int(product["onHandInventory"] as! String)!
        
        var quantity: Double = 0.0
        if let quantityString = product["quantity"] as? NSString {
            quantity = quantityString.doubleValue
        }
        if let quantityNumber = product["quantity"] as? NSNumber {
            quantity = quantityNumber.doubleValue
        }
    
        if let category = product["category"] as? String {
            self.productDeparment = category
        }

        let price = product["price"] as! NSString
        var text: String? = ""
        var total: Double = 0.0
        //Piezas
        if Int(quantity) == 1 {
            text = String(format: NSLocalizedString("shoppingcart.quantity.article", comment:""), NSNumber(double:quantity))
        }
        else {
            text = String(format: NSLocalizedString("shoppingcart.quantity.articles", comment:""), NSNumber(double:quantity))
        }
        total = (quantity * price.doubleValue)
        self.quantityIndicator!.setTitle(text!, forState: .Normal)
        let formatedPrice = CurrencyCustomLabel.formatString("\(total)")
        self.total = formatedPrice
    
        super.setValues(imageUrl!, productShortDescription: product["description"] as! String, productPrice: "\(total)")
    
        if let stock = product["stock"] as? NSString {
            if stock == "false" {
                self.quantityIndicator!.enabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            } else {
                self.quantityIndicator!.enabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            }
        }
    self.checkDisabled(disabled)
    }

}