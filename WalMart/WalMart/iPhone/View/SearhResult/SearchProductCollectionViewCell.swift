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
    var productPriceThroughLabel : UILabel!
    var upc : String!
    var skuId : String!
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
    var picturesView : UIView? = nil
    
    var delegate: SearchProductCollectionViewCellDelegate?
    
    var positionSelected : String = ""
    var promotiosView : UIView?
    
    var serachFromList : Bool = false

    override func setup() {
        super.setup()
        
        //presale
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.isHidden =  true
        self.addSubview(imagePresale)
        
        self.productPriceThroughLabel = UILabel(frame:CGRect.zero)
        self.productPriceThroughLabel!.textAlignment = .center
        //self.productPriceThroughLabel!.font = WMFont.fontMyriadProSemiboldOfSize(9)
        //self.productPriceThroughLabel!.textColor = WMColor.green
        
        self.productShortDescriptionLabel!.textColor = WMColor.reg_gray
        self.productShortDescriptionLabel?.textAlignment = NSTextAlignment.center
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel?.lineBreakMode =  .byTruncatingTail
        
        self.picturesView = UIView(frame: CGRect.zero)
        self.contentView.addSubview(picturesView!)
        
        self.addProductToShopingCart = UIButton()
        self.addProductToShopingCart!.setImage(UIImage(named: "ProductToShopingCart"), for: UIControlState())
        self.addProductToShopingCart!.addTarget(self, action: #selector(SearchProductCollectionViewCell.addProductToShoping), for: UIControlEvents.touchUpInside)
       
        self.contentView.addSubview(productPriceThroughLabel!)
       
        let borderView = UIView(frame: CGRect(x: self.frame.width - AppDelegate.separatorHeigth() - 1, y: 0,width: AppDelegate.separatorHeigth(), height: self.frame.height ))
        borderView.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderView)
        
        let borderViewTop = UIView(frame: CGRect(x: 0, y: self.frame.height - AppDelegate.separatorHeigth() , width: self.frame.width,height: AppDelegate.separatorHeigth()))
        borderViewTop.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderViewTop)
        
        self.contentView.addSubview(addProductToShopingCart!)
        
        self.addProductToShopingCart!.bringSubview(toFront: self.contentView)
        
        self.promotiosView = UIView()
        self.contentView.addSubview(promotiosView!)
        
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
        
        self.promotiosView?.frame = CGRect(x: 0.0, y: 8.0, width: 30, height: 140)
    }
    
    func setValueArray(_ plpArray:[[String:Any]]){
        if plpArray.count > 0 {
            if self.promotiosView != nil {
                for subview in self.promotiosView!.subviews {
                    subview.removeFromSuperview()
                }
            }
            
            let promoView = PLPLegendView(isvertical: true, PLPArray: plpArray, viewPresentLegend: self.superview!)
            promoView.frame = CGRect(x:0 , y:0 , width: 30, height:140)
            self.promotiosView!.addSubview(promoView)
        }
    }
    
    func setValues(_ upc:String,skuId:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String, isMoreArts:Bool, isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,pesable:Bool,isFormList:Bool,productInlist:Bool,isLowStock:Bool, category: String,equivalenceByPiece:String,position:String) {
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        self.positionSelected = position
        imagePresale.isHidden = !isPreorderable
        imagePresale.frame = CGRect(x: -1, y: 0, width: imagePresale.frame.width, height: imagePresale.frame.height)
        
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice as NSString)
        self.productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color:WMColor.orange, interLine: false)

        var savingPrice = ""
        if productPriceThrough != "" { //&& type == ResultObjectType.Groceries.rawValue
            self.productPriceThroughLabel.textColor = WMColor.green
            if isMoreArts {
                let doubleVaule = NSString(string: productPriceThrough).doubleValue
                if doubleVaule > 0.1 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)" as NSString)
                    savingPrice = "\(savingStr) \(formated)"
                }
            } else {
                savingPrice = productPriceThrough
            }
        }
        
        if savingPrice != ""{
            self.productPriceThroughLabel!.isHidden = false
            self.productPriceThroughLabel.text = savingPrice
            self.productPriceThroughLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        } else{
            self.productPriceThroughLabel!.isHidden = true
        }
        
        self.upc = upc
        self.skuId = skuId
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory) as NSString
        self.type = "MG"
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
                //Definir type para comparar quantity mg o gr
                //if self.type == ResultObjectType.Groceries.rawValue {
                if self.pesable == true{
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

