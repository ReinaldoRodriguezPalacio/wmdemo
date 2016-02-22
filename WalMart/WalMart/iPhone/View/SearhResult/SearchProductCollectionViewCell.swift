//
//  SearchProductCollectionViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol SearchProductCollectionViewCellDelegate{
    func selectGRQuantityForItem(cell: SearchProductCollectionViewCell)
    func selectMGQuantityForItem(cell: SearchProductCollectionViewCell)
}

class SearchProductCollectionViewCell: ProductCollectionViewCell  {
    
    var addProductToShopingCart : UIButton? = nil
    var productPriceThroughLabel : CurrencyCustomLabel? = nil
    var upc : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    var onHandInventory : NSString = "0"
    var isDisabled : Bool = false
    var type : String!
    var pesable : Bool!
    var isPreorderable: String!
    var presale : UILabel!
    var imagePresale : UIImageView!
    var delegate: SearchProductCollectionViewCellDelegate?

    
    override func setup() {
        super.setup()
        
        //presale
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.hidden =  true
        self.addSubview(imagePresale)

    
        
        self.productPriceThroughLabel = CurrencyCustomLabel(frame:CGRectZero)
        self.productPriceThroughLabel!.textAlignment = .Center
        //self.productPriceThroughLabel!.font = WMFont.fontMyriadProSemiboldOfSize(9)
        //self.productPriceThroughLabel!.textColor = WMColor.green
        
        self.productShortDescriptionLabel!.textColor = WMColor.gray
        self.productShortDescriptionLabel?.textAlignment = NSTextAlignment.Center
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        
        self.addProductToShopingCart = UIButton()
        self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), forState: UIControlState.Normal)
        self.addProductToShopingCart!.addTarget(self, action: "addProductToShoping", forControlEvents: UIControlEvents.TouchUpInside)
       
        self.contentView.addSubview(productPriceThroughLabel!)
        
       
        self.productShortDescriptionLabel!.frame = CGRectMake(8, 0, self.frame.width - 16 , 46)
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (100 / 2), self.productShortDescriptionLabel!.frame.maxY , 95, 95)
        self.productPriceLabel!.frame = CGRectMake(0,  self.bounds.maxY - 36 , self.bounds.width , 18)
        self.productPriceThroughLabel!.frame = CGRectMake(0, self.productPriceLabel!.frame.maxY  , self.bounds.width , 12)
        self.addProductToShopingCart!.frame = CGRectMake(self.bounds.maxX - 44, self.bounds.maxY - 44 , 44 , 44)
       
        let borderView = UIView(frame: CGRectMake(self.frame.width - AppDelegate.separatorHeigth() - 1, 0,AppDelegate.separatorHeigth(), self.frame.height ))
        borderView.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderView)
        
        let borderViewTop = UIView(frame: CGRectMake(0, self.frame.height - AppDelegate.separatorHeigth() , self.frame.width,AppDelegate.separatorHeigth()))
        borderViewTop.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderViewTop)
        
        self.contentView.addSubview(addProductToShopingCart!)
        
        self.addProductToShopingCart!.bringSubviewToFront(self.contentView)
    }
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,type:String ,pesable:Bool) {
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        
        imagePresale.hidden = !isPreorderable
        
        if isPreorderable {
            if IS_IPHONE {
                self.productShortDescriptionLabel?.textAlignment = .Right
            }
            self.productShortDescriptionLabel?.frame = CGRectMake(38, 0,self.frame.width - 42 , 46)
            self.productShortDescriptionLabel?.lineBreakMode =  .ByTruncatingTail
        }else{
            self.productShortDescriptionLabel?.textAlignment = .Center
            self.productShortDescriptionLabel!.frame = CGRectMake(8, 0, self.frame.width - 16 , 46)
        }
        
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice)
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.orange, interLine: false)

        
        var savingPrice = ""
        if productPriceThrough != "" && type == ResultObjectType.Groceries.rawValue {
            savingPrice = productPriceThrough
        }
        if type == ResultObjectType.Mg.rawValue {
            let doubleVaule = NSString(string: productPriceThrough).doubleValue
            if doubleVaule > 0.1 {
                let savingStr = NSLocalizedString("price.saving",comment:"")
                let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)")
                savingPrice = "\(savingStr) \(formated)"
            }
        }
        
        if savingPrice != ""{
            self.productPriceThroughLabel!.hidden = false
            self.productPriceThroughLabel!.updateMount(savingPrice, font: IS_IPAD ? WMFont.fontMyriadProSemiboldOfSize(14) :WMFont.fontMyriadProSemiboldOfSize(9), color: WMColor.green, interLine: false)
        }else{
            
            self.productPriceThroughLabel!.hidden = true
        }
        //self.productPriceThroughLabel!.text = savingPrice
        if savingPrice == "" {
            self.productPriceLabel!.frame = CGRectMake(0,  self.bounds.maxY - 30 , self.bounds.width , 18)
        } else {
            self.productPriceLabel!.frame = CGRectMake(0,  self.bounds.maxY - 36 , self.bounds.width , 18)
        }
        
        //self.productPriceThroughLabel!.frame = CGRectMake(0, self.productPriceLabel!.frame.maxY  , self.bounds.width , 12)
       
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory)
        self.type = type
        self.pesable = pesable
        self.isPreorderable = "\(isPreorderable)"
        
        if self.pesable! { self.onHandInventory = "20000"}
        
        isDisabled = false
        if isActive == false || onHandInventory == 0  {
            self.addProductToShopingCart!.setImage(UIImage(named: "products_cart_disabled"), forState: UIControlState.Normal)
            isDisabled = true
        }else{
            if isInShoppingCart {
                self.addProductToShopingCart!.setImage(UIImage(named: "products_done"), forState:UIControlState.Normal)
            }else {
                self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), forState: UIControlState.Normal)
            }
        }
    }
    
    
    func addProductToShoping(){
        if !isDisabled {
            let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
            if !hasUPC {
                if self.type == ResultObjectType.Groceries.rawValue {
                    self.delegate?.selectGRQuantityForItem(self)
                }
                else {
                    self.delegate?.selectMGQuantityForItem(self)
                }
            }else{
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"done"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"done"))
                alert!.setMessage(NSLocalizedString("shoppingcart.isincart",comment:""))
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
            
        } else {
            let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
        }
    }
}

