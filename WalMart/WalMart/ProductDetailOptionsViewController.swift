//
//  ProductDetailOptionsViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 14/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailOptionsViewController: ImageDisplayCollectionViewController{
    
    var colorItems: [AnyObject]? = nil
    var sizeItems: [AnyObject]? = nil
    var otherItems: [AnyObject]? = nil
    
    var colorsView: ProductDetailColorSizeView? = nil
    var sizesView: ProductDetailColorSizeView? = nil
    var otherOptionsView: ProductDetailColorSizeView? = nil
    
    
    var priceBefore : CurrencyCustomLabel!
    var price : CurrencyCustomLabel!
    var saving : CurrencyCustomLabel!
    var optionsLabel : UILabel!
    var buttonShop : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.colorsView = ProductDetailColorSizeView()
        self.view.addSubview(self.colorsView!)
        
        self.sizesView = ProductDetailColorSizeView()
        self.view.addSubview(self.sizesView!)
        
        self.otherOptionsView = ProductDetailColorSizeView()
        self.view.addSubview(self.otherOptionsView!)
        
        optionsLabel = UILabel(frame: CGRectMake(0, self.pointSection!.frame.maxY  , self.view.frame.width, 15.0))
        optionsLabel.textColor = WMColor.navigationTilteTextColor
        optionsLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        optionsLabel.textAlignment = NSTextAlignment.Center
        optionsLabel.text =  NSLocalizedString("productdetail.options",comment:"")
        self.view.addSubview(optionsLabel)
        priceBefore = CurrencyCustomLabel(frame: CGRectMake(0, self.optionsLabel.frame.maxY  , self.view.frame.width, 15.0))
        self.view.addSubview(priceBefore)
        price = CurrencyCustomLabel(frame: CGRectMake(0, self.priceBefore.frame.maxY  , self.view.frame.width, 24.0))
        self.view.addSubview(price)
        saving = CurrencyCustomLabel(frame: CGRectMake(0, self.price.frame.maxY  , self.view.frame.width, 15.0))
        self.view.addSubview(saving)
        
        buttonShop = UIButton(frame: CGRectMake(0, self.price.frame.maxY , 60, 34))
        buttonShop.setTitle(NSLocalizedString("productdetail.shop",comment:""), forState: UIControlState.Normal)
        buttonShop.backgroundColor = WMColor.yellow
        buttonShop.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonShop.layer.cornerRadius = 17
        self.view.addSubview(buttonShop)
        
        self.colorItems = [0xDF1C11,0x696E72,0x0E1219,0x1183C2,0x573281]
        self.sizeItems = [["name":"S","enabled":false],["name":"M","enabled":true],["name":"L","enabled":true],["name":"XL","enabled":true],["name":"XXL","enabled":false]]
        self.otherItems = [["name":"Nice","enabled":true],["name":"Más Nice","enabled":true],["name":"Super Nice","enabled":false]]
        
    }
    
    override func viewWillLayoutSubviews() {
        var bounds = self.view.frame.size
        var frame = self.view.frame
        var itemsHeight = CGFloat(141)
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.maxX, 66)
        self.close!.frame = CGRectMake(0.0, 20, 40.0, 40.0)
        self.titleLabel!.frame =  CGRectMake(40.0 , 20, bounds.width - 40 , 46)
        
        if otherItems?.count != 0{
            self.otherOptionsView!.items = self.otherItems
            self.otherOptionsView!.buildforColors = false
            itemsHeight += 40
            self.otherOptionsView!.frame =  CGRectMake(0,  bounds.height - itemsHeight   , frame.width, 40.0)
            self.addBottomBorder(self.otherOptionsView!)
        }
        
        if sizeItems?.count != 0{
            self.sizesView!.items = self.sizeItems
            self.sizesView!.buildforColors = false
            itemsHeight += 40
            self.sizesView!.frame =  CGRectMake(0,  bounds.height - itemsHeight   , frame.width, 40.0)
            self.addBottomBorder(self.sizesView!)
        }
        
        if colorItems?.count != 0{
            self.colorsView!.items = self.colorItems
            self.colorsView!.buildforColors = true
            self.colorsView!.alpha = 1.0
            itemsHeight += 40
            self.colorsView!.frame =  CGRectMake(0,  bounds.height - itemsHeight   , frame.width, 40.0)
            self.addBottomBorder(self.colorsView!)
        }else{
            self.colorsView!.alpha = 0
        }
        
        itemsHeight += 20
        self.optionsLabel.frame = CGRectMake((frame.width / 2) - 100, bounds.height - itemsHeight   , 200, 30)
        itemsHeight += 30
        self.pointSection!.frame = CGRectMake(0, bounds.height - itemsHeight   , bounds.width, 20)
        itemsHeight += 50
        self.collectionView!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - itemsHeight)
        
        self.priceBefore.frame = CGRectMake(0,  bounds.height - 129   , frame.width, 15.0)
        self.price.frame = CGRectMake(0, bounds.height - 114 , frame.width, 24.0)
        self.saving.frame = CGRectMake(0, bounds.height - 90  , frame.width, 15.0)
        self.buttonShop.frame = CGRectMake((frame.width / 2) - 51 , bounds.height - 47  , 102, 32.0)
        
        var line: CALayer = CALayer()
        line.frame = CGRectMake(0.0, bounds.height - 65, frame.size.width, 0.8);
        line.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6, alpha: 0.7).CGColor
        self.view.layer.insertSublayer(line, atIndex: 0)
    }
    
    func setAdditionalValues(listPrice:String,price:String,saving:String){
        if price == "" || (price as NSString).doubleValue == 0 {
            self.price.hidden = true
        } else {
            self.price.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(price))"
            self.price.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.priceDetailProductTextColor, interLine: false)
        }
        
        if listPrice == "" || (listPrice as NSString).doubleValue == 0 || (price as NSString).doubleValue >= (listPrice as NSString).doubleValue  {
            priceBefore.hidden = true
        } else {
            priceBefore.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(listPrice))"
            self.priceBefore.updateMount(formatedValue, font: WMFont.fontMyriadProLightOfSize(14), color: WMColor.productDetailPriceListText, interLine: true)
        }
        
        if saving == "" {
            self.saving.hidden = true
        } else {
            self.saving.hidden = false
            let formatedValue = "\(CurrencyCustomLabel.formatString(saving))"
            self.saving.updateMount(formatedValue, font: WMFont.fontMyriadProSemiboldOfSize(14), color: WMColor.savingTextColor, interLine: false)
        }
        
    }
    
    func addBottomBorder(view:UIView){
        var bottomBorder: CALayer = CALayer()
        bottomBorder.frame = CGRectMake(0.0, view.frame.height - 1.1, view.frame.size.width, 1.1);
        
        bottomBorder.backgroundColor = WMColor.UIColorFromRGB(0xF6F6F6, alpha: 1.0).CGColor
        view.layer.insertSublayer(bottomBorder, atIndex: 0)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
}