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
        
        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: imageUrl!)!),
                                                  placeholderImage: UIImage(named:"img_default_table"),
                                                  success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                                                    self.productImage!.contentMode = self.contentModeOrig
                                                    self.productImage!.image = image
                                                    self.imageGrayScale = self.convertImageToGrayScale(image)
                                                    self.imageNormal = image
                                                    
            }, failure: nil)
        self.promoDescription!.text = product["promoDescription"] as? String
        self.productShortDescriptionLabel!.text = product["description"] as? String
        self.upcVal = product["upc"] as? String
        
        if let equivalence = product["equivalenceByPiece"] as? NSNumber {
            self.equivalenceByPiece = equivalence
        }
        
        if let equivalence = product["equivalenceByPiece"] as? NSString {
            if equivalence != "" {
                self.equivalenceByPiece =  NSNumber(int: equivalence.intValue)
            }
        }
        
        let quantity = product["quantity"] as! NSString
        let price = product["price"] as! NSString
        var text: String? = ""
        var total: Double = 0.0
        //Piezas
        if quantity.integerValue == 1 {
            text = String(format: NSLocalizedString("shoppingcart.quantity.article", comment:""), quantity)
        }
        else {
            text = String(format: NSLocalizedString("shoppingcart.quantity.articles", comment:""), quantity)
        }
        total = (quantity.doubleValue * price.doubleValue)
        
        self.quantityIndicator!.setTitle(text!, forState: .Normal)
        
        let formatedPrice = CurrencyCustomLabel.formatString("\(total)")
        self.total = formatedPrice
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        checkDisabled(disabled)
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
    }

}