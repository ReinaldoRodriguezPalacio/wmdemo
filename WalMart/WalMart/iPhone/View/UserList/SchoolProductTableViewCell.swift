//
//  SchoolProductTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 26/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolProductTableViewCell: DetailListViewCell {
    
  override func setValuesDictionary(_ product:[String:Any],disabled:Bool) {
        var imageUrl: String? = ""
        if let imageArray = product["imageUrl"] as? [Any] {
            if imageArray.count > 0 {
                var imgSmall = NSString(string: imageArray[0] as! String)
                imgSmall = imgSmall.replacingOccurrences(of: "img_large", with: "img_small") as NSString
                let pathExtention = imgSmall.pathExtension
                imageUrl = imgSmall.replacingOccurrences(of: "L.\(pathExtention)", with:"s.\(pathExtention)")
            }
        } else if let imageUrlTxt = product["imageUrl"] as? String {
            imageUrl = imageUrlTxt
        }
    
        self.productImage!.contentMode = UIViewContentMode.center
        self.productImage!.setImageWith(URLRequest(url:URL(string: imageUrl!)!), placeholderImage: UIImage(named:"img_default_table"), success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
            self.productImage!.contentMode = self.contentModeOrig
            self.productImage!.image = image
            self.imageGrayScale = self.convertImageToGrayScale(image)
            self.imageNormal = image
            }, failure: nil)
    
        self.promoDescription!.text = product["promoDescription"] as? String
        self.upcVal = product["upc"] as? String
    
        if let equivalence = product["equivalenceByPiece"] as? NSNumber {
            self.equivalenceByPiece = equivalence
        }
        
        if let equivalence = product["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                self.equivalenceByPiece =  NSNumber(value: equivalence.intValue as Int32)
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
            text = String(format: NSLocalizedString("shoppingcart.quantity.article", comment:""), NSNumber(value: quantity as Double))
        }
        else {
            text = String(format: NSLocalizedString("shoppingcart.quantity.articles", comment:""), NSNumber(value: quantity as Double))
        }
        total = (quantity * price.doubleValue)
        self.quantityIndicator!.setTitle(text!, for: UIControlState())
        let formatedPrice = CurrencyCustomLabel.formatString("\(total)")
        self.total = formatedPrice
    
        self.productShortDescriptionLabel!.text = product["description"] as? String
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
    
        if let stock = product["stock"] as? NSString {
            if stock == "false" {
                self.check!.isEnabled = false
                self.quantityIndicator!.isEnabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            } else {
                 self.check!.isEnabled = true
                self.quantityIndicator!.isEnabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            }
        }
    self.checkDisabled(disabled)
    }

}
