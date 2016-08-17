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
    func showViewPlpItem()
}

class SearchProductCollectionViewCell: ProductCollectionViewCell  {
    
    var addProductToShopingCart : UIButton? = nil
    var productPriceThroughLabel : UILabel!//CurrencyCustomLabel? = nil
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

    
        
        self.productPriceThroughLabel = UILabel(frame:CGRectZero)
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
       
        let borderView = UIView(frame: CGRectMake(self.frame.width - AppDelegate.separatorHeigth() - 1, 0,AppDelegate.separatorHeigth(), self.frame.height ))
        borderView.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderView)
        
        let borderViewTop = UIView(frame: CGRectMake(0, self.frame.height - AppDelegate.separatorHeigth() , self.frame.width,AppDelegate.separatorHeigth()))
        borderViewTop.backgroundColor = WMColor.light_light_gray
        self.contentView.addSubview(borderViewTop)
        
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
    
    func setValues(upc:String,productImageURL:String,productShortDescription:String,productPrice:String,productPriceThrough:String, isMoreArts:Bool, isActive:Bool,onHandInventory:Int,isPreorderable:Bool,isInShoppingCart:Bool,pesable:Bool,isFormList:Bool,productInlist:Bool,isLowStock:Bool, category: String,equivalenceByPiece:String,position:String) {
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        self.positionSelected = position
        imagePresale.hidden = !isPreorderable
        imagePresale.frame = CGRectMake(-1, 0, imagePresale.frame.width, imagePresale.frame.height)
        
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
        if productPriceThrough != "" { //&& type == ResultObjectType.Groceries.rawValue
            if isMoreArts {
                let doubleVaule = NSString(string: productPriceThrough).doubleValue
                if doubleVaule > 0.1 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(productPriceThrough)")
                    savingPrice = "\(savingStr) \(formated)"
                    self.productPriceThroughLabel.textColor = WMColor.red
                }
            } else {
                savingPrice = productPriceThrough
                self.productPriceThroughLabel.textColor = WMColor.green
            }
        }
        
        if savingPrice != ""{
            self.productPriceThroughLabel!.hidden = false
            self.productPriceThroughLabel.text = savingPrice
            self.productPriceThroughLabel.font = WMFont.fontMyriadProSemiboldOfSize(12)
        } else{
            self.productPriceThroughLabel!.hidden = true
        }
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory)
        self.type = "MG"
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
    
    func setPLP(PlpArray:NSArray){
        
        var yView : CGFloat = 8.0
        let xView : CGFloat = 8.0
        let ySpace : CGFloat = 4.0
        let heighView : CGFloat = 14.0
        let widthView : CGFloat = 18.0
        
        //Show PLP in Cell
        if PlpArray.count > 0 {
            for lineToShow in PlpArray {
                //Se muestran etiquetas para promociones, etc.
                let picturesView = UIView(frame: CGRectMake(xView, yView, widthView, heighView))
                picturesView.backgroundColor = lineToShow["color"] as? UIColor //WMColor.light_red
                picturesView.layer.cornerRadius = 2.0
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchProductCollectionViewCell.showViewPLP))
                picturesView.addGestureRecognizer(tapGesture)
                
                let textLabel = UILabel(frame: CGRectMake(0, 0, widthView, heighView))
                textLabel.text =  lineToShow["text"] as? String //"TS"
                textLabel.textColor = UIColor.whiteColor()
                textLabel.font = WMFont.fontMyriadProRegularOfSize(9)
                textLabel.textAlignment = .Center
                picturesView.addSubview(textLabel)
                
                self.contentView.addSubview(picturesView)
                yView = picturesView.frame.maxY + ySpace
            }
        }
    }
    
    func showViewPLP(){
        self.delegate?.showViewPlpItem()
    }
    
    func addProductToShoping(){
        if !isDisabled {
            var hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
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

