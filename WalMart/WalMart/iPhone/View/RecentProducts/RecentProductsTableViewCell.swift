//
//  RecentProducts .swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol RecentProductsTableViewCellDelegate {
    func deleteFromWishlist(UPC:String)
    func showViewPlpItem()
}

class RecentProductsTableViewCell : ProductTableViewCell {
    
    var emptyView : IPOWishlistEmptyView!
    var productPriceSavingLabelGR : UILabel!
    
    var delegateProduct : RecentProductsTableViewCellDelegate!
    var resultObjectType : ResultObjectType! = ResultObjectType.Mg
    var separatorView : UIView?
    var btnShoppingCart : UIButton!
    var upc : String!
    var desc : String!
    var price : String!
    var imageURL : String!
    var isDisabled : Bool = false
    var onHandInventory : NSString = "0"
    var isPesable : String!
    var isPreorderable : String!
    var picturesView : UIView? = nil
    var countPromotion: Int = 0
    
    var imagePresale : UIImageView!
    var borderViewTop : UIView!
    var iconDiscount : UIImageView!
    let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
    var presale : UILabel!
    
    
    override func setup() {
        super.setup()
        
        productShortDescriptionLabel!.textColor = WMColor.gray
        productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        productShortDescriptionLabel!.numberOfLines = 2
        productShortDescriptionLabel!.adjustsFontSizeToFitWidth = true
        productShortDescriptionLabel!.minimumScaleFactor = 9 / 12
        
        productImage!.frame = CGRectMake(16, 0, 80, 109)
        //productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 16, self.frame.width - (productImage!.frame.maxX + 16) - 16, 28)
        
        //self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 16 , 100 , 19)
        self.productPriceLabel!.textAlignment = NSTextAlignment.Left
        
        self.productPriceLabel!.hidden = false
        
        btnShoppingCart = UIButton(frame: CGRectMake(self.frame.width - 16 - 32, productShortDescriptionLabel!.frame.maxY + 16, 32, 32))
        btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
        btnShoppingCart.addTarget(self, action: #selector(RecentProductsTableViewCell.addToShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.picturesView = UIView(frame: CGRectZero)
        self.contentView.addSubview(picturesView!)
        
        self.separatorView = UIView(frame:CGRectMake(16, 108,self.frame.width - 16, 1.0))
        
        self.separatorView!.backgroundColor = WMColor.light_light_gray
        
        self.contentView.addSubview(btnShoppingCart)
       // self.contentView.addSubview(productPriceSavingLabel)
        self.contentView.addSubview(self.separatorView!)
        
        imagePresale =  UIImageView(image: UIImage(named: "preventa_home"))
        imagePresale.hidden =  true
        self.addSubview(imagePresale)
        
        //--
        productPriceSavingLabelGR = UILabel(frame: CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 19))
        productPriceSavingLabelGR!.font = WMFont.fontMyriadProSemiboldSize(14)
        productPriceSavingLabelGR!.textColor = WMColor.green
        self.contentView.addSubview(productPriceSavingLabelGR)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productShortDescriptionLabel!.frame = CGRectMake(productImage!.frame.maxX + 16, 0, self.frame.width - (productImage!.frame.maxX + 16) - 16, 34)
        self.productPriceLabel!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productShortDescriptionLabel!.frame.maxY + 8.0, 100 , 22)//36

        //self.btnShoppingCart.frame = CGRectMake(self.frame.width - 16 - 32, productShortDescriptionLabel!.frame.maxY + 16, 32, 32)
        
        self.btnShoppingCart.frame = CGRectMake(self.frame.width - 16 - 32, productPriceLabel!.frame.minY, 32, 32)
        self.separatorView!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, 108,self.frame.width - productShortDescriptionLabel!.frame.minX, AppDelegate.separatorHeigth())
        self.productPriceSavingLabelGR!.frame = CGRectMake(productShortDescriptionLabel!.frame.minX, productPriceLabel!.frame.maxY  , 100 , 14)
        
        self.picturesView!.frame = CGRectMake(112.0, 94.0, 22.0 * CGFloat(self.countPromotion), 14.0)
    }
    
    func addToShoppingCart() {
        if !isDisabled {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue , label:"\(self.desc)\(self.upc)")
            
            let hasUPC = UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)
            if !hasUPC {
                
                var quanty = "1"
                if self.isPesable == "true"  {
                    quanty = "50"
                }
               
                let params = CustomBarViewController.buildParamsUpdateShoppingCart(self.upc, desc: self.desc, imageURL: self.imageURL, price: self.price, quantity: quanty,onHandInventory:self.onHandInventory as String,pesable:"0", type: resultObjectType.rawValue,isPreorderable:self.isPreorderable)
                btnShoppingCart.setImage(UIImage(named: "wishlist_done"), forState:UIControlState.Normal)
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                
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
    
    func setValues(upc: String, productImageURL: String, productShortDescription: String, productPrice: String, saving: NSString, isMoreArts:Bool, isActive: Bool, onHandInventory: Int, isPreorderable: Bool, isInShoppingCart: Bool, pesable: NSString) {
        
        imagePresale.hidden = !isPreorderable
        
        self.upc = upc
        self.desc = productShortDescription
        self.imageURL = productImageURL
        self.price = productPrice
        self.onHandInventory = String(onHandInventory)
        self.isPesable = pesable as String
        self.isPreorderable = "\(isPreorderable)"
        
        super.setValues(productImageURL, productShortDescription: productShortDescription, productPrice: productPrice)
        let formatedPrice = CurrencyCustomLabel.formatString(productPrice)
        productPriceLabel!.updateMount(formatedPrice, font: WMFont.fontMyriadProSemiboldSize(18), color: WMColor.orange, interLine: false)
        
        isDisabled = false
        if isActive == false || onHandInventory == 0  {
            self.btnShoppingCart.setImage(UIImage(named: "wishlist_cart_disabled"), forState: UIControlState.Normal)
            isDisabled = true
        }else{
            if isInShoppingCart {
                btnShoppingCart.setImage(UIImage(named: "wishlist_done"), forState:UIControlState.Normal)
            }else {
                btnShoppingCart.setImage(UIImage(named: "wishlist_cart"), forState:UIControlState.Normal)
            }
        }
        //...
        var savingPrice = ""
        if saving != "" {
            if isMoreArts {
                let doubleVaule = NSString(string: saving).doubleValue
                if doubleVaule > 0.1 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(saving)")
                    savingPrice = "\(savingStr) \(formated)"
                    self.productPriceSavingLabelGR.textColor = WMColor.red
                }
            } else {
                savingPrice = saving as String
                self.productPriceSavingLabelGR.textColor = WMColor.green
            }
        }
        
        if savingPrice != ""{
            self.productPriceSavingLabelGR!.hidden = false
            self.productPriceSavingLabelGR.text = savingPrice
            self.productPriceSavingLabelGR.font = WMFont.fontMyriadProSemiboldOfSize(12)
        } else{
            self.productPriceSavingLabelGR!.hidden = true
        }
    }
    
    func setPLP(PlpArray:NSArray){
        self.countPromotion =  PlpArray.count
        
        for subview in picturesView!.subviews {
            subview.removeFromSuperview()
        }
        
        let yView : CGFloat = 0.0
        var xView : CGFloat = 0.0
        let ySpace : CGFloat = 4.0
        let heighView : CGFloat = 14.0
        let widthView : CGFloat = 18.0
        
        //Show PLP in Cell
        if PlpArray.count > 0 {
            for lineToShow in PlpArray {
                //Se muestran etiquetas para promociones, etc.
                let promotion = UIView(frame: CGRectMake(xView, yView, widthView, heighView))
                promotion.backgroundColor = lineToShow["color"] as? UIColor
                promotion.layer.cornerRadius = 2.0
                
                let textLabel = UILabel(frame: CGRectMake(0, 0, widthView, heighView))
                textLabel.text =  lineToShow["text"] as? String //"TS"
                textLabel.textColor = UIColor.whiteColor()
                textLabel.font = WMFont.fontMyriadProRegularOfSize(9)
                textLabel.textAlignment = .Center
                promotion.addSubview(textLabel)
                
                self.picturesView!.addSubview(promotion)
                
                xView = promotion.frame.maxX + ySpace
            }
        }
        
        self.picturesView!.frame = CGRectMake(112.0, 94.0, 22.0 * CGFloat(self.countPromotion), heighView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchProductCollectionViewCell.showViewPLP))
        picturesView!.addGestureRecognizer(tapGesture)
    }
    
    func showViewPLP(){
        self.delegateProduct?.showViewPlpItem()
    }
    
    func deleteUPCWishlist() {
        delegateProduct.deleteFromWishlist("")
    }
    
    
}