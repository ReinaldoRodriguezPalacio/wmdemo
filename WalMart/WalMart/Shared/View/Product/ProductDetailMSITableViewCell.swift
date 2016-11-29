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
        
        downBorder = UIView(frame: CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.light_light_gray

        
        self.addSubview(downBorder)
        self.addSubview(descLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         downBorder.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth())
    }
    
    func setValues(_ msi:[Any]){
        //var first = true
        clearView(self)
        var currntY : CGFloat = 5.0
        let lblPagos = NSLocalizedString("productdetail.paiments",comment:"")
        let lblOf = NSLocalizedString("productdetail.of",comment:"")
        
        for msiVal in msi {

            let payDetailPrice = NSNumber(value: (priceProduct.doubleValue/(msiVal as AnyObject).doubleValue) as Double).stringValue
            let formattedStr = CurrencyCustomLabel.formatString(payDetailPrice)
            
            let lblPay = UILabel(frame: CGRect(x: 16, y: currntY, width: 55, height: 14))
            lblPay.textAlignment = NSTextAlignment.right
            lblPay.font = WMFont.fontMyriadProSemiboldOfSize(14)
            lblPay.textColor = WMColor.gray
            lblPay.text = "\(msiVal) \(lblPagos)"
            lblPay.tag = 101
            
            let lblDesc = CurrencyCustomLabel(frame: CGRect(x: lblPay.frame.maxX + 4, y: currntY, width: 150, height: 14))
            lblDesc.textAlignment = NSTextAlignment.left
            lblDesc.updateMount("\(lblOf) \(formattedStr)", font:  WMFont.fontMyriadProLightOfSize(14), color:  WMColor.dark_gray, interLine: false)
            lblDesc.tag = 102
            
            self.addSubview(lblPay)
            self.addSubview(lblDesc)
            currntY = currntY + 17
        }
        
    }
    
    func clearView(_ view: UIView){
        for subview in view.subviews{
            if subview.isKind(of: CurrencyCustomLabel.self) {
                subview.removeFromSuperview()
            }
        }
    }
    
}
