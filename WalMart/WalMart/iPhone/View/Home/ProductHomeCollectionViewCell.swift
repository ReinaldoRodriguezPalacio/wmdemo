//
//  ProductHomeCollectionVIewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ProductHomeCollectionViewCell : ProductCollectionViewCell {
  var borderViewTop : UIView!
  var iconDiscount : UIImageView!
  var imagePresale : UIImageView!
  var providerLBL : UILabel!
  
  override func setup() {
    super.setup()
    
    iconDiscount = UIImageView(image:UIImage(named:"saving_icon"))
    iconDiscount.frame = CGRect(x: 6, y: 6, width: 18, height: 18)
    self.addSubview(iconDiscount)
    
    imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
    imagePresale.isHidden =  true
    self.addSubview(imagePresale)
    
    productShortDescriptionLabel!.numberOfLines = 3
    
    self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (75 / 2), y: 8, width: 75, height: 75)
    
    self.productPriceLabel!.frame = CGRect(x: 4, y: self.productImage!.frame.maxY + 6 , width: self.frame.width - 8 , height: 13)
    
    self.productShortDescriptionLabel!.frame = CGRect(x: 8, y: self.productPriceLabel!.frame.maxY  , width: self.frame.width - 16, height: 33)
    self.productShortDescriptionLabel!.textAlignment = .center
    self.productShortDescriptionLabel!.numberOfLines = 3
    
    providerLBL = UILabel()
    providerLBL!.font = WMFont.fontMyriadProRegularOfSize(9)
    providerLBL!.numberOfLines = 1
    providerLBL!.textColor =  WMColor.orange
    providerLBL!.isHidden = true
    providerLBL!.text = "Desde"
    self.addSubview(providerLBL)
    
    let widthAndHeightSeparator: CGFloat = 1
    
    let borderView = UIView(frame: CGRect(x: self.frame.width - widthAndHeightSeparator, y: 0, width: widthAndHeightSeparator, height: self.frame.height))
    borderView.backgroundColor = WMColor.light_light_gray
    self.addSubview(borderView)
    
    borderViewTop = UIView(frame: CGRect(x: 0,y: self.frame.height - widthAndHeightSeparator, width: self.frame.width,height: widthAndHeightSeparator ))
    borderViewTop.backgroundColor = WMColor.light_light_gray
    self.addSubview(borderViewTop)
  }
  
  
  //MARK: - Action
  func setValues(_ productImageURL:String,productShortDescription:String,productPrice:String,saving:String,preorderable:Bool,listPrice:Bool, providers:Bool) {
    super.setValues(productImageURL,productShortDescription:productShortDescription,productPrice:productPrice)
    
    iconDiscount.alpha = saving != "" && saving != "null" ? 1 : 0
    imagePresale.isHidden = !preorderable
    productPriceLabel!.label2?.isHidden = false
    
    if  saving != "" && saving != "null"  {
      productPriceLabel!.updateMount(saving, font: WMFont.fontMyriadProSemiboldSize(10), color: WMColor.green, interLine: false)
      productPriceLabel?.label1?.lineBreakMode = .byTruncatingTail
      providerLBL!.textColor = WMColor.green
    }
    
    if providers {
      providerLBL!.isHidden = !providers
      let priceWidth = (self.productPriceLabel!.label1!.frame.width + self.productPriceLabel!.label2!.frame.width)
      
      let productWidth = (self.frame.width - (priceWidth + 24.0 + 4.0)) / 2
      providerLBL!.frame =  CGRect(x: productWidth, y: self.productPriceLabel!.frame.minY + 3.0, width: 24.0, height: 9.0)
      self.productPriceLabel!.frame = CGRect(x: providerLBL.frame.maxX + 4, y: self.productImage!.frame.maxY  + 6, width: priceWidth, height: 14)
      
      if  !(saving != "" && saving != "null") {
        let formatedPrice = CurrencyCustomLabel.formatString("\(productPrice)" as NSString)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(14), color: WMColor.orange, interLine: false)
        providerLBL!.textColor = WMColor.orange
      }
      
    }
    
    if listPrice {
      productPriceLabel!.label1?.textColor = WMColor.green
      productPriceLabel!.label2?.textColor = WMColor.green
      providerLBL!.textColor = providers ? WMColor.green : WMColor.orange
    }
  }
  
}
