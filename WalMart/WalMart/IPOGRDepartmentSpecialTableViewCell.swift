//
//  IPOGRDepartmentSpecialTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPOGRDepartmentSpecialTableViewCellDelegate {
    func didTapProduct(upcProduct:String,descProduct:String)
}

class IPOGRDepartmentSpecialTableViewCell : UITableViewCell {
    
    var delegate: IPOGRDepartmentSpecialTableViewCellDelegate!
    
    func setProducts(products:[[String:AnyObject]],width:CGFloat) {
        
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
        
        
        var currentX : CGFloat = 0.0
        for  prod in products {
            let product = GRProductSpecialCollectionViewCell(frame: CGRectMake(currentX, 0, width, 150))
            let imageProd =  prod["imageUrl"] as! String
            let descProd =  prod["description"] as! String
            let priceProd =  prod["price"] as! NSNumber
            let upcProd =  prod["upc"] as! String
            
            product.upcProduct = upcProd
            product.setValues(imageProd, productShortDescription: descProd, productPrice: priceProd.stringValue)
            self.contentView.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: "productTap:")
            product.addGestureRecognizer(tapOnProdut)
            
            currentX = currentX + width
            
        }
        
        let separator = UIView()
        separator.backgroundColor = WMColor.lineSaparatorColor
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        separator.frame = CGRectMake(0, self.frame.height - widthAndHeightSeparator, self.frame.width, widthAndHeightSeparator)
        
        self.contentView.addSubview(separator)
        
        
        
        
    }
    
    
    func withOutProducts(){
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
    }
    
    func productTap(sender:UITapGestureRecognizer) {
        let viewC = sender.view as! GRProductSpecialCollectionViewCell
        
        delegate.didTapProduct(viewC.upcProduct!,descProduct:viewC.productShortDescriptionLabel!.text!)
    }
    
    
}