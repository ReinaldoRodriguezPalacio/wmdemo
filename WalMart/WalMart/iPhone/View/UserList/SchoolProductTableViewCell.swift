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
                var imgSmall = NSString(string: imageArray[0] as! String)
                imgSmall = imgSmall.stringByReplacingOccurrencesOfString("img_large", withString: "img_small")
                let pathExtention = imgSmall.pathExtension
                imageUrl = imgSmall.stringByReplacingOccurrencesOfString("L.\(pathExtention)", withString:"s.\(pathExtention)")
            }
        } else if let imageUrlTxt = product["imageUrl"] as? String {
            imageUrl = imageUrlTxt
        }
    
        self.productImage!.contentMode = UIViewContentMode.Center
        self.productImage!.setImageWithURL(NSURL(string: imageUrl!), placeholderImage: UIImage(named:"img_default_table"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
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
                self.equivalenceByPiece =  NSNumber(int: equivalence.intValue)
            }
        }
    
        //self.onHandInventory = Int(product["onHandInventory"] as! String)!
        
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

        let price = product["specialPrice"] as! NSString
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
    
        self.productShortDescriptionLabel!.text = product["description"] as? String
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
    
        if let stock = product["stock"] as? NSString {
            if stock == "false" {
                self.check!.enabled = false
                self.quantityIndicator!.enabled = false
                self.quantityIndicator!.backgroundColor = WMColor.light_gray
                self.hasStock = false
            } else {
                 self.check!.enabled = true
                self.quantityIndicator!.enabled = true
                self.quantityIndicator!.backgroundColor = WMColor.yellow
                self.hasStock = true
            }
        }
    self.checkDisabled(disabled)
    }

}