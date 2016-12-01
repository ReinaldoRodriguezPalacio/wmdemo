//
//  SearchProductCollectionViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol SearchProductCollectionViewCellDelegate{
    func selectGRQuantityForItem(_ cell: SearchProductCollectionViewCell)
    func selectMGQuantityForItem(_ cell: SearchProductCollectionViewCell)
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
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)

    
        
        self.productPriceThroughLabel = CurrencyCustomLabel(frame:CGRect.zero)
        self.productPriceThroughLabel!.textAlignment = .center
        //self.productPriceThroughLabel!.font = WMFont.fontMyriadProSemiboldOfSize(9)
        //self.productPriceThroughLabel!.textColor = WMColor.green
        
        self.productShortDescriptionLabel!.textColor = WMColor.gray
        self.productShortDescriptionLabel?.textAlignment = NSTextAlignment.center
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel?.lineBreakMode =  .byTruncatingTail

        
        self.addProductToShopingCart = UIButton()
        self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), for: UIControlState())
        self.addProductToShopingCart!.addTarget(self, action: #selector(SearchProductCollectionViewCell.addProductToShoping), for: UIControlEvents.touchUpInside)
       
        self.contentView.addSubview(productPriceThroughLabel!)
       
        self.layer.borderWidth = 0.6
        self.layer.borderColor = WMColor.light_light_gray.cgColor
        
        self.contentView.addSubview(addProductToShopingCart!)
        
        self.addProductToShopingCart!.bringSubview(toFront: self.contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (100 / 2),y: 14 , width: 95, height: 95)
        self.addProductToShopingCart!.frame = CGRect(x: self.bounds.maxX - 44, y: 0, width: 44 , height: 44)
        self.productPriceLabel!.frame = CGRect(x: 8, y: self.productImage!.frame.maxY + 6, width: self.bounds.width - 16 , height: 18)
        self.productPriceThroughLabel!.frame = CGRect(x: 8, y: self.productPriceLabel!.frame.maxY, width: self.bounds.width - 16 , height: 12)
        self.productShortDescriptionLabel!.frame = CGRect(x: 8,  y: self.productPriceThroughLabel!.frame.maxY, width: self.frame.width - 16 , height: 46)
        
        if IS_IPAD {
            self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (100 / 2),y: 22, width: 95, height: 95)
            self.addProductToShopingCart!.frame = CGRect(x: self.bounds.maxX - 52, y: 8, width: 44 , height: 44)
            self.productPriceLabel!.frame = CGRect(x: 8, y: self.productImage!.frame.maxY + 16, width: self.bounds.width - 16 , height: 18)
            self.productPriceThroughLabel!.frame = CGRect(x: 8, y: self.productPriceLabel!.frame.maxY + 8, width: self.bounds.width - 16 , height: 12)
            self.productShortDescriptionLabel!.frame = CGRect(x: 40,  y: self.productPriceThroughLabel!.frame.maxY + 16, width: self.frame.width - 80 , height: 46)
        }
    }
    
    func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,type:String ,pesable:Bool,isFormList:Bool,productInlist:Bool,isLowStock:Bool, category: String,equivalenceByPiece:String,position:String) {
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        self.positionSelected = position
        imagePresale.isHidden = !isPreorderable
        imagePresale.frame = CGRect(x: 0, y: 0, width: imagePresale.frame.width, height: imagePresale.frame.height)
        
        if isLowStock {
            self.lowStock?.frame = CGRect(x: 8, y: 0 ,width: self.frame.width - 16 , height: 14)
            self.lowStock?.textAlignment =  .center
            self.lowStock?.isHidden =  false
        }else{
            self.lowStock?.isHidden = true
        }
        
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.orange, interLine: false)

        
        var savingPrice = ""
        if productPriceThrough != "" && type == ResultObjectType.Groceries.rawValue {
            savingPrice = productPriceThrough
        }
        if type == ResultObjectType.Mg.rawValue {
            let doubleVaule = NSString(string: productPriceThrough).doubleValue
            if doubleVaule > 0.1 {
                let savingStr = NSLocalizedString("price.saving",comment:"")
                let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)" as NSString)
                savingPrice = "\(savingStr) \(formated)"
            }
        }
        
        if savingPrice != ""{
            self.productPriceThroughLabel!.isHidden = false
            self.productPriceThroughLabel!.updateMount(savingPrice, font: IS_IPAD ? WMFont.fontMyriadProSemiboldOfSize(14) :WMFont.fontMyriadProSemiboldOfSize(9), color: WMColor.green, interLine: false)
        }else{
            
            self.productPriceThroughLabel!.isHidden = true
        }
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory) as NSString
        self.type = type
        self.pesable = pesable
        self.isPreorderable = "\(isPreorderable)"
        self.productDeparment = category
        self.equivalenceByPiece = equivalenceByPiece
        
        if self.pesable! { self.onHandInventory = "20000"}
        
        isDisabled = false
        if isActive == false || onHandInventory == 0  {
            self.addProductToShopingCart!.setImage(UIImage(named: "products_cart_disabled"), for: UIControlState())
            isDisabled = true
        }else{
            if isInShoppingCart {
                self.addProductToShopingCart!.setImage(UIImage(named: "products_done"), for:UIControlState())
            }else {
                self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), for: UIControlState())
            }
        }
        serachFromList = isFormList
        if isFormList {
            if productInlist {
                self.addProductToShopingCart!.setImage(UIImage(named: "addedtolist_icon"), for: UIControlState())

            }else{
                self.addProductToShopingCart!.setImage(UIImage(named: "addtolist_icon"), for: UIControlState())

            }
        }
        
    }
    
    
    func addProductToShoping(){
        if !isDisabled {
            var hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
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

