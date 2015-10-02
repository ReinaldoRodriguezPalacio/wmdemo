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
    func didTapLine(name:String,department:String,family:String,line:String)
}

class IPOGRDepartmentSpecialTableViewCell : UITableViewCell {
    
    var delegate: IPOGRDepartmentSpecialTableViewCellDelegate!
    var viewLoading : UIView?
    
    func setLines(lines:[[String:AnyObject]],width:CGFloat) {
        
        let jsonLines = JSON(lines)
        
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
        
        
        var currentX : CGFloat = 0.0
        for  lineToShow in jsonLines.arrayValue {
            let product = GRProductSpecialCollectionViewCell(frame: CGRectMake(currentX, 0, width, 150))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                                productShortDescription: descProd,
                                productPrice: "")
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
        
        self.viewLoadingProduct ()
        
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "removeViewLoading", userInfo: nil, repeats: false)
        
    }
    
    func removeViewLoading(){
        viewLoading!.hidden =  true
    }
    
    func viewLoadingProduct(){
        viewLoading =  UIView()
        viewLoading!.frame = CGRectMake(0,0,self.frame.width,self.frame.height - 2)
        viewLoading!.backgroundColor =  UIColor.whiteColor()
        
        let imageIndicator =  UIImageView(frame: CGRectMake(self.frame.midX - 16, 20,32,32))
        imageIndicator.image =  UIImage(named:"home_super_spark")
        viewLoading!.addSubview(imageIndicator)
        
        let labelLoading =  UILabel(frame:CGRectMake(0, imageIndicator.frame.maxY + 10, self.frame.width, 30))
        labelLoading.text =  NSLocalizedString("gr.category.message.loading", comment:"")
        labelLoading.textAlignment =  .Center
        labelLoading.font =  WMFont.fontMyriadProRegularOfSize(14)
        labelLoading.textColor = WMColor.navigationFilterBGColor

        
        viewLoading!.addSubview(labelLoading)
        
        self.contentView.addSubview(viewLoading!)
    }
    
    
    func withOutProducts(){
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
    }
    
    func productTap(sender:UITapGestureRecognizer) {
        //let viewC = sender.view as! GRProductSpecialCollectionViewCell
//        
//        delegate.didTapProduct(viewC.upcProduct!,descProduct:viewC.productShortDescriptionLabel!.text!)

        let viewC = sender.view as! GRProductSpecialCollectionViewCell
        delegate.didTapLine(viewC.jsonItemSelected["name"].stringValue, department: viewC.jsonItemSelected["department"].stringValue, family:  viewC.jsonItemSelected["family"].stringValue, line:viewC.jsonItemSelected["line"].stringValue)
    }
    
    
}