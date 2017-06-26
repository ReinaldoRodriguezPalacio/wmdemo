//
//  SearchProductCollectionViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 29/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol SearchProductCollectionViewCellDelegate: class{
    func selectGRQuantityForItem(_ cell: SearchProductCollectionViewCell,productInCart:Cart?)
    func selectMGQuantityForItem(_ cell: SearchProductCollectionViewCell,productInCart:Cart?)
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
  var providerLBL : UILabel!
  
  weak var delegate: SearchProductCollectionViewCellDelegate?
  
  var positionSelected : String = ""
  var serachFromList : Bool = false
    
  var sellerName: String? = ""
  var sellerId: String? = ""
  var offerId: String? = ""
  
  override func setup() {
    super.setup()
    
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
    self.addProductToShopingCart!.setImage(UIImage(named: "productToShopingCart"), for: UIControlState())
    self.addProductToShopingCart!.addTarget(self, action: #selector(SearchProductCollectionViewCell.addProductToShoping), for: UIControlEvents.touchUpInside)
    
    self.contentView.addSubview(productPriceThroughLabel!)
    
    providerLBL = UILabel()
    providerLBL!.font = WMFont.fontMyriadProRegularOfSize(12)
    providerLBL!.numberOfLines = 1
    providerLBL!.textColor =  WMColor.orange
    providerLBL!.isHidden = true
    providerLBL!.text = "Desde"
    self.addSubview(providerLBL)
    
    self.layer.borderWidth = 0.6
    self.layer.borderColor = WMColor.light_light_gray.cgColor
    
    self.contentView.addSubview(addProductToShopingCart!)
    
    self.addProductToShopingCart!.bringSubview(toFront: self.contentView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (100 / 2),y: 14 , width: 95, height: 95)
    self.addProductToShopingCart!.frame = CGRect(x: self.bounds.maxX - 44, y: 0, width: 44 , height: 44)
    self.productPriceLabel!.frame = CGRect(x: 8, y: self.productImage!.frame.maxY + 6, width: self.bounds.width - 16 , height: 19)
    self.productPriceThroughLabel!.frame = CGRect(x: 8, y: self.productPriceLabel!.frame.maxY, width: self.bounds.width - 16 , height: 12)
    self.productShortDescriptionLabel!.frame = CGRect(x: 8,  y: self.productPriceThroughLabel!.frame.maxY, width: self.frame.width - 16 , height: 46)
    
    if IS_IPAD {
      self.productImage!.frame = CGRect(x: (self.frame.width / 2) - (100 / 2),y: 22, width: 95, height: 95)
      self.addProductToShopingCart!.frame = CGRect(x: self.bounds.maxX - 52, y: 8, width: 44 , height: 44)
      self.productPriceLabel!.frame = CGRect(x: 8, y: self.productImage!.frame.maxY + 16, width: self.bounds.width - 16 , height: 19)
      self.productPriceThroughLabel!.frame = CGRect(x: 8, y: self.productPriceLabel!.frame.maxY + 8, width: self.bounds.width - 16 , height: 12)
      self.productShortDescriptionLabel!.frame = CGRect(x: 40,  y: self.productPriceThroughLabel!.frame.maxY + 16, width: self.frame.width - 80 , height: 46)
    }
    self.showProvider()
  }
  
  //MARK: - SetValues
  func setValues(_ upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String,isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,type:String ,pesable:Bool,isFormList:Bool,productInlist:Bool,isLowStock:Bool, category: String,equivalenceByPiece:String,position:String, providers:Bool) {
    
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
    
    providerLBL!.isHidden = !providers
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
    
    self.showProvider()
    
    if self.pesable! { self.onHandInventory = "20000"}
    
    isDisabled = false
    if isActive == false || onHandInventory == 0  {
      self.addProductToShopingCart!.setImage(UIImage(named: "products_cart_disabled"), for: UIControlState())
      isDisabled = true
    }else{
      if isInShoppingCart {
        self.addProductToShopingCart!.setImage(UIImage(named: "products_done"), for:UIControlState())
      }else {
        self.addProductToShopingCart!.setImage(UIImage(named: "productToShopingCart"), for: UIControlState())
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
    
    func showProvider() {
        if !providerLBL!.isHidden {
            let priceWidth = (self.productPriceLabel!.label1!.frame.width + self.productPriceLabel!.label2!.frame.width)
            
            let productWidth = (self.frame.width - (priceWidth + 32.0 + 8.0)) / 2
            providerLBL!.frame =  CGRect(x: productWidth, y: self.productImage!.frame.maxY + (IS_IPAD ? 16.0 : 6.0) + 3.0, width: 32.0, height: 12.0)
            self.productPriceLabel!.frame = CGRect(x: providerLBL.frame.maxX + 8, y: self.productPriceLabel!.frame.minY, width: priceWidth, height: 19)
            
            let formatedPrice = CurrencyCustomLabel.formatString(self.price as NSString)
            self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        } else {
            self.productPriceLabel!.frame = CGRect(x: 8, y: self.productImage!.frame.maxY + 6, width: self.bounds.width - 16 , height: 19)
        }
    }
  
  
  //MARK: - addProductToShoping
  func addProductToShoping(){
    if !isDisabled {
      var hasUPC = UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)
      if serachFromList {
        hasUPC =  false
      }
      if !hasUPC {
        if self.pesable ?? false {
          self.delegate?.selectGRQuantityForItem(self,productInCart: nil)
        } else {
          
          if serachFromList   {
            self.delegate?.selectGRQuantityForItem(self,productInCart: nil)
            return
          }
            let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: "1",onHandInventory:self.onHandInventory as String,pesable:"0", type: self.type,isPreorderable:self.isPreorderable,sellerId:self.sellerId,sellerName: self.sellerName, offerId: self.offerId)
          NotificationCenter.default.post(name:  .addUPCToShopingCart, object: self, userInfo: params)
          //                    if self.type == ResultObjectType.Groceries.rawValue {
          //                        self.delegate?.selectGRQuantityForItem(self)
          //                    }
          //                    else {
          //                        self.delegate?.selectMGQuantityForItem(self)
          //                    }
        }
      }else{
        let productincar = UserCurrentSession.sharedInstance.userHasQuantityUPCShoppingCart(upc)
        
        if self.type == ResultObjectType.Groceries.rawValue {
          self.delegate?.selectGRQuantityForItem(self,productInCart: productincar)
        }
        else {
          self.delegate?.selectMGQuantityForItem(self,productInCart: productincar)
        }
      }
      
    } else {
      let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
      alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
      alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
    }
  }

}

