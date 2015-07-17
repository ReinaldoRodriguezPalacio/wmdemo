//
//  ProductDetailMSICollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/8/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailMSICollectionViewCell : UICollectionViewCell {
    
    var titleLabel = UILabel()
    var downBorder : UIView!
    var descLabel = UILabel()
    var priceProduct : NSString!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        descLabel = UILabel()
        descLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        descLabel.textColor = WMColor.productDetailTextColor
        descLabel.numberOfLines = 0
        
        downBorder = UIView(frame: CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.lineSaparatorColor
        
        titleLabel.text = NSLocalizedString("productdetail.msitext",comment:"")
        titleLabel.frame = CGRectMake(12, 0, self.bounds.width - (12 * 2), 40.0)
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Left
        titleLabel.textColor = WMColor.productProductPromotionsTextColor
        
        self.addSubview(titleLabel)
        self.addSubview(downBorder)
        self.addSubview(descLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        downBorder.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth())
    }
    
    func setValues(msi:NSArray){
        var first = true
        var currntY : CGFloat = 45.0
        let lblPagos = NSLocalizedString("productdetail.paiments",comment:"")
        let lblOf = NSLocalizedString("productdetail.of",comment:"")
        
        for msiVal in msi {
            
            let payDetailPrice = NSNumber(double:(priceProduct.doubleValue/msiVal.doubleValue)).stringValue
            let formattedStr = CurrencyCustomLabel.formatString(payDetailPrice)
            
            let lblPay = UILabel(frame: CGRectMake(16, currntY, 55, 14))
            lblPay.textAlignment = NSTextAlignment.Right
            lblPay.font = WMFont.fontMyriadProSemiboldOfSize(14)
            lblPay.textColor = WMColor.productDetailMSIBoldTextColor
            lblPay.text = "\(msiVal) \(lblPagos)"
            
            let lblDesc = CurrencyCustomLabel(frame: CGRectMake(lblPay.frame.maxX + 4, currntY, 150, 14))
            lblDesc.textAlignment = NSTextAlignment.Left
            lblDesc.updateMount("\(lblOf) \(formattedStr)", font:  WMFont.fontMyriadProLightOfSize(14), color:  WMColor.productDetailMSITextColor, interLine: false)
            
            self.addSubview(lblPay)
            self.addSubview(lblDesc)
            currntY = currntY + 17
        }
        
    }
    
}