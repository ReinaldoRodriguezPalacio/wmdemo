//
//  ProductDetailMSICollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/8/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class ProductDetailMSICollectionViewCell : UICollectionViewCell {
    
    var titleMSILabel = UILabel()
    var titleDelibery: UILabel!
    var titleSafeSell: UILabel!
    var imageMSI: UIImageView!
    var imageDelibery:UIImageView!
    var imageSafeSell: UIImageView!
    var priceProduct : NSString!
    var doneValues : Bool = false
    var deliberyLabel:UILabel!
    var safeSellLabel:UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.backgroundColor = WMColor.light_light_gray
        
        self.imageMSI = UIImageView()
        self.imageMSI.image = UIImage(named: "img_msi")
        
        self.imageDelibery = UIImageView()
        self.imageDelibery.image = UIImage(named: "img_delibery")
        
        self.imageSafeSell = UIImageView()
        self.imageSafeSell.image = UIImage(named: "img_safe_sell")
        
        self.titleMSILabel.text = NSLocalizedString("productdetail.msitext",comment:"")
        self.titleMSILabel.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.titleMSILabel.numberOfLines = 1
        self.titleMSILabel.textAlignment = .left
        self.titleMSILabel.textColor = WMColor.dark_gray
        
        self.titleDelibery = UILabel()
        self.titleDelibery.text = "Envío asegurado 100%"
        self.titleDelibery.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.titleDelibery.numberOfLines = 1
        self.titleDelibery.textAlignment = .left
        self.titleDelibery.textColor = WMColor.dark_gray
        
        self.titleSafeSell = UILabel()
        self.titleSafeSell.text = "Compra asegurada 100%"
        self.titleSafeSell.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.titleSafeSell.numberOfLines = 1
        self.titleSafeSell.textAlignment = .left
        self.titleSafeSell.textColor = WMColor.dark_gray
        
        self.deliberyLabel = UILabel()
        self.deliberyLabel.text = "Desde $1,930,00 mensuales"
        self.deliberyLabel.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.deliberyLabel.numberOfLines = 1
        self.deliberyLabel.textAlignment = .left
        self.deliberyLabel.textColor = WMColor.reg_gray
        
        self.safeSellLabel = UILabel()
        self.safeSellLabel.text = "en Walmart.com.mx"
        self.safeSellLabel.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.safeSellLabel.numberOfLines = 1
        self.safeSellLabel.textAlignment = .left
        self.safeSellLabel.textColor = WMColor.reg_gray
        

        self.addSubview(self.titleMSILabel)
        self.addSubview(self.titleDelibery)
        self.addSubview(self.titleSafeSell)
        self.addSubview(self.imageMSI)
        self.addSubview(self.imageDelibery)
        self.addSubview(self.imageSafeSell)
        self.addSubview(self.deliberyLabel)
        self.addSubview(self.safeSellLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageMSI.frame = CGRect(x: 16, y: 16, width: 16, height: 16)
        self.titleMSILabel.frame = CGRect(x: self.imageMSI.frame.maxX + 8,y: 16, width: self.bounds.width - 32, height: 16.0)
    }
    
    func setValues(_ msi:NSArray){

        if doneValues  { return }
        doneValues = true
        
        //var first = true
        var currntY : CGFloat = 40
        let lblPagos = NSLocalizedString("productdetail.paiments",comment:"")
        let lblOf = NSLocalizedString("productdetail.of",comment:"")
        self.clearView()
        self.setup()
        for msiVal in msi {
            
            let payDetailPrice = NSNumber(value: (priceProduct.doubleValue/(msiVal as AnyObject).doubleValue) as Double).stringValue
            let formattedStr = CurrencyCustomLabel.formatString(payDetailPrice)
            
            let lblPay = UILabel(frame: CGRect(x: 40, y: currntY, width: 55, height: 14))
            lblPay.textAlignment = NSTextAlignment.left
            lblPay.font = WMFont.fontMyriadProRegularOfSize(14)
            lblPay.textColor = WMColor.reg_gray
            lblPay.text = "\(msiVal) \(lblPagos)"
            
            let lblDesc = CurrencyCustomLabel(frame: CGRect(x: lblPay.frame.maxX + 4, y: currntY, width: 150, height: 14))
            lblDesc.textAlignment = NSTextAlignment.left
            lblDesc.updateMount("\(lblOf) \(formattedStr)", font:  WMFont.fontMyriadProRegularOfSize(14), color:  WMColor.reg_gray, interLine: false)
            
            self.addSubview(lblPay)
            self.addSubview(lblDesc)
            currntY = currntY + 17
        }
        
        self.imageDelibery.frame = CGRect(x: 16, y: currntY + 16, width: 16, height: 16)
        self.titleDelibery.frame = CGRect(x: self.imageDelibery.frame.maxX + 8,y: currntY + 16, width: self.bounds.width - 32, height: 16.0)
        self.deliberyLabel.frame = CGRect(x: self.imageDelibery.frame.maxX + 8, y: self.titleDelibery.frame.maxY + 8.0, width: self.bounds.width - 32, height: 14)
        
        self.imageSafeSell.frame = CGRect(x: 16, y: self.deliberyLabel.frame.maxY + 16, width: 16, height: 16)
        self.titleSafeSell.frame = CGRect(x: self.imageSafeSell.frame.maxX + 8,y: self.deliberyLabel.frame.maxY + 16, width: self.bounds.width - 32, height: 16.0)
        self.safeSellLabel.frame = CGRect(x: self.imageSafeSell.frame.maxX + 8, y: self.titleSafeSell.frame.maxY + 8.0, width: self.bounds.width - 32, height: 14)
        
    }
    
    func clearView(){
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
    }
    
}
