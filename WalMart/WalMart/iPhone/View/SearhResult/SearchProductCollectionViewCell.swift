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
    var equivalenceByPiece : String = "0"
    var isDisabled : Bool = false
    var type : String!
    var pesable : Bool!
    var isPreorderable: String!
    var presale : UILabel!
    var imagePresale : UIImageView!
    var productDeparment:String = ""
    
    var delegate: SearchProductCollectionViewCellDelegate?
    
    var positionSelected : String = ""
    
    var serachFromList : Bool = false

    
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
        productShortDescriptionLabel?.lineBreakMode =  .ByTruncatingTail

        
        self.addProductToShopingCart = UIButton()
        self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), forState: UIControlState.Normal)
        self.addProductToShopingCart!.addTarget(self, action: #selector(SearchProductCollectionViewCell.addProductToShoping), forControlEvents: UIControlEvents.TouchUpInside)
       
        self.contentView.addSubview(productPriceThroughLabel!)
       
        self.layer.borderWidth = 0.6
        self.layer.borderColor = WMColor.light_light_gray.CGColor
        
        self.contentView.addSubview(addProductToShopingCart!)
        
        self.addProductToShopingCart!.bringSubviewToFront(self.contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productImage!.frame = CGRectMake((self.frame.width / 2) - (100 / 2),14 , 95, 95)
        self.addProductToShopingCart!.frame = CGRectMake(self.bounds.maxX - 44, 0, 44 , 44)
        self.productPriceLabel!.frame = CGRectMake(8, self.productImage!.frame.maxY + 6, self.bounds.width - 16 , 18)
        self.productPriceThroughLabel!.frame = CGRectMake(8, self.productPriceLabel!.frame.maxY, self.bounds.width - 16 , 12)
        self.productShortDescriptionLabel!.frame = CGRectMake(8,  self.productPriceThroughLabel!.frame.maxY, self.frame.width - 16 , 46)
        
        if IS_IPAD {
            self.productImage!.frame = CGRectMake((self.frame.width / 2) - (100 / 2),22, 95, 95)
            self.addProductToShopingCart!.frame = CGRectMake(self.bounds.maxX - 52, 8, 44 , 44)
            self.productPriceLabel!.frame = CGRectMake(8, self.productImage!.frame.maxY + 16, self.bounds.width - 16 , 18)
            self.productPriceThroughLabel!.frame = CGRectMake(8, self.productPriceLabel!.frame.maxY + 8, self.bounds.width - 16 , 12)
            self.productShortDescriptionLabel!.frame = CGRectMake(40,  self.productPriceThroughLabel!.frame.maxY + 16, self.frame.width - 80 , 46)
        }
    }
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,type:String ,pesable:Bool,isFormList:Bool,productInlist:Bool,isLowStock:Bool, category: String,equivalenceByPiece:String,position:String) {
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        self.positionSelected = position
        imagePresale.hidden = !isPreorderable
        imagePresale.frame = CGRectMake(0, 0, imagePresale.frame.width, imagePresale.frame.height)
        
        if isLowStock {
            self.lowStock?.frame = CGRectMake(8, 0 ,self.frame.width - 16 , 14)
            self.lowStock?.textAlignment =  .Center
            self.lowStock?.hidden =  false
        }else{
            self.lowStock?.hidden = true
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
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory)
        self.type = type
        self.pesable = pesable
        self.isPreorderable = "\(isPreorderable)"
        self.productDeparment = category
        self.equivalenceByPiece = equivalenceByPiece
        
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
        serachFromList = isFormList
        if isFormList {
            if productInlist {
                self.addProductToShopingCart!.setImage(UIImage(named: "addedtolist_icon"), forState: UIControlState.Normal)

            }else{
                self.addProductToShopingCart!.setImage(UIImage(named: "addtolist_icon"), forState: UIControlState.Normal)

            }
        }
        
    }
    
    
    func addProductToShoping(){
        if !isDisabled {
            var hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
            if serachFromList {
                hasUPC =  false
            }
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

