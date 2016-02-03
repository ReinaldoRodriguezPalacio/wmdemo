//
//  ProductDetailMSICollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailMSITableViewCell : UITableViewCell {
 
    var titleLabel = UILabel()
    var downBorder : UIView!
    var descLabel = UILabel()
    var priceProduct : NSString!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        descLabel = UILabel()
        descLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        descLabel.textColor = WMColor.gray
        descLabel.numberOfLines = 0
        
        downBorder = UIView(frame: CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.light_light_gray

        
        self.addSubview(downBorder)
        self.addSubview(descLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         downBorder.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth())
    }
    
    func setValues(msi:NSArray){
        //var first = true
        var currntY : CGFloat = 5.0
        let lblPagos = NSLocalizedString("productdetail.paiments",comment:"")
        let lblOf = NSLocalizedString("productdetail.of",comment:"")
        
        for msiVal in msi {

            let payDetailPrice = NSNumber(double:(priceProduct.doubleValue/msiVal.doubleValue)).stringValue
            let formattedStr = CurrencyCustomLabel.formatString(payDetailPrice)
            
            let lblPay = UILabel(frame: CGRectMake(16, currntY, 55, 14))
            lblPay.textAlignment = NSTextAlignment.Right
            lblPay.font = WMFont.fontMyriadProSemiboldOfSize(14)
            lblPay.textColor = WMColor.gray
            lblPay.text = "\(msiVal) \(lblPagos)"
            
            let lblDesc = CurrencyCustomLabel(frame: CGRectMake(lblPay.frame.maxX + 4, currntY, 150, 14))
            lblDesc.textAlignment = NSTextAlignment.Left
            lblDesc.updateMount("\(lblOf) \(formattedStr)", font:  WMFont.fontMyriadProLightOfSize(14), color:  WMColor.dark_gray, interLine: false)
            
            self.addSubview(lblPay)
            self.addSubview(lblDesc)
            currntY = currntY + 17
        }
        
    }
    
}