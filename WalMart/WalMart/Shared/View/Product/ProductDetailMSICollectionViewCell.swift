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
        self.titleMSILabel.textAlignment = .Left
        self.titleMSILabel.textColor = WMColor.dark_gray
        
        self.titleDelibery = UILabel()
        self.titleDelibery.text = "Envío asegurado 100%"
        self.titleDelibery.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.titleDelibery.numberOfLines = 1
        self.titleDelibery.textAlignment = .Left
        self.titleDelibery.textColor = WMColor.dark_gray
        
        self.titleSafeSell = UILabel()
        self.titleSafeSell.text = "Compra asegurada 100%"
        self.titleSafeSell.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.titleSafeSell.numberOfLines = 1
        self.titleSafeSell.textAlignment = .Left
        self.titleSafeSell.textColor = WMColor.dark_gray
        
        self.deliberyLabel = UILabel()
        self.deliberyLabel.text = "Desde $1,930,00 mensuales"
        self.deliberyLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        self.deliberyLabel.numberOfLines = 1
        self.deliberyLabel.textAlignment = .Left
        self.deliberyLabel.textColor = WMColor.gray
        
        self.safeSellLabel = UILabel()
        self.safeSellLabel.text = "en Walmart.com.mx"
        self.safeSellLabel.font =  WMFont.fontMyriadProLightOfSize(14)
        self.safeSellLabel.numberOfLines = 1
        self.safeSellLabel.textAlignment = .Left
        self.safeSellLabel.textColor = WMColor.gray
        

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
        self.imageMSI.frame = CGRectMake(16, 16, 16, 16)
        self.titleMSILabel.frame = CGRectMake(self.imageMSI.frame.maxX + 8,16, self.bounds.width - 32, 16.0)
    }
    
    func setValues(msi:NSArray){

        if doneValues  { return }
        doneValues = true
        
        //var first = true
        var currntY : CGFloat = 40
        let lblPagos = NSLocalizedString("productdetail.paiments",comment:"")
        let lblOf = NSLocalizedString("productdetail.of",comment:"")
        self.clearView()
        self.setup()
        for msiVal in msi {
            
            let payDetailPrice = NSNumber(double:(priceProduct.doubleValue/msiVal.doubleValue)).stringValue
            let formattedStr = CurrencyCustomLabel.formatString(payDetailPrice)
            
            let lblPay = UILabel(frame: CGRectMake(32, currntY, 55, 14))
            lblPay.textAlignment = NSTextAlignment.Right
            lblPay.font = WMFont.fontMyriadProLightOfSize(14)
            lblPay.textColor = WMColor.gray
            lblPay.text = "\(msiVal) \(lblPagos)"
            
            let lblDesc = CurrencyCustomLabel(frame: CGRectMake(lblPay.frame.maxX + 4, currntY, 150, 14))
            lblDesc.textAlignment = NSTextAlignment.Left
            lblDesc.updateMount("\(lblOf) \(formattedStr)", font:  WMFont.fontMyriadProLightOfSize(14), color:  WMColor.gray, interLine: false)
            
            self.addSubview(lblPay)
            self.addSubview(lblDesc)
            currntY = currntY + 17
        }
        
        self.imageDelibery.frame = CGRectMake(16, currntY + 16, 16, 16)
        self.titleDelibery.frame = CGRectMake(self.imageDelibery.frame.maxX + 8,currntY + 16, self.bounds.width - 32, 16.0)
        self.deliberyLabel.frame = CGRectMake(self.imageDelibery.frame.maxX + 8, self.titleDelibery.frame.maxY + 8.0, self.bounds.width - 32, 14)
        
        self.imageSafeSell.frame = CGRectMake(16, self.deliberyLabel.frame.maxY + 16, 16, 16)
        self.titleSafeSell.frame = CGRectMake(self.imageSafeSell.frame.maxX + 8,self.deliberyLabel.frame.maxY + 16, self.bounds.width - 32, 16.0)
        self.safeSellLabel.frame = CGRectMake(self.imageSafeSell.frame.maxX + 8, self.titleSafeSell.frame.maxY + 8.0, self.bounds.width - 32, 14)
        
    }
    
    func clearView(){
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
    }
    
}