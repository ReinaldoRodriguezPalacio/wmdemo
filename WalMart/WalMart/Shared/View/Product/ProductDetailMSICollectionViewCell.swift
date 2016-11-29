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
    var doneValues : Bool = false
    
    
    required init?(coder aDecoder: NSCoder) {
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
        descLabel.textColor = WMColor.gray
        descLabel.numberOfLines = 0
        
        downBorder = UIView(frame: CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.light_light_gray
        
        titleLabel.text = NSLocalizedString("productdetail.msitext",comment:"")
        titleLabel.frame = CGRect(x: 12, y: 0, width: self.bounds.width - (12 * 2), height: 40.0)
        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.textColor = WMColor.orange
        
        self.addSubview(titleLabel)
        self.addSubview(downBorder)
        self.addSubview(descLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        downBorder.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth())
    }
    
    func setValues(_ msi:[Any]){

        if doneValues  { return }
        doneValues = true
        
        //var first = true
        var currntY : CGFloat = 45.0
        let lblPagos = NSLocalizedString("productdetail.paiments",comment:"")
        let lblOf = NSLocalizedString("productdetail.of",comment:"")
        self.clearView()
        self.setup()
        for msiVal in msi {
            
            let payDetailPrice = NSNumber(value: (priceProduct.doubleValue/(msiVal as AnyObject).doubleValue) as Double).stringValue
            let formattedStr = CurrencyCustomLabel.formatString(payDetailPrice)
            
            let lblPay = UILabel(frame: CGRect(x: 16, y: currntY, width: 55, height: 14))
            lblPay.textAlignment = NSTextAlignment.right
            lblPay.font = WMFont.fontMyriadProSemiboldOfSize(14)
            lblPay.textColor = WMColor.gray
            lblPay.text = "\(msiVal) \(lblPagos)"
            
            let lblDesc = CurrencyCustomLabel(frame: CGRect(x: lblPay.frame.maxX + 4, y: currntY, width: 150, height: 14))
            lblDesc.textAlignment = NSTextAlignment.left
            lblDesc.updateMount("\(lblOf) \(formattedStr)", font:  WMFont.fontMyriadProLightOfSize(14), color:  WMColor.dark_gray, interLine: false)
            
            self.addSubview(lblPay)
            self.addSubview(lblDesc)
            currntY = currntY + 17
        }
        
    }
    
    func clearView(){
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
    }
    
}
