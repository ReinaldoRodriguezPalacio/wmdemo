//
//  ShoppingCartCrossSellCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class ShoppingCartCrossSellCollectionViewCell : ProductDetailCrossSellTableViewCell {
    
    
    var labelTitle : UILabel!
    var buttonClose : UIButton!
    
    override func setup() {
        super.setup()
        
        collection.register(ShoppingCartCrossSellItemCollectionViewCell.self, forCellWithReuseIdentifier: "shoppingCartCrossSellCell")
        
        labelTitle = UILabel(frame: CGRect(x: 16, y: 13, width: self.frame.width - 32, height: 14))
        labelTitle.font = WMFont.fontMyriadProLightOfSize(14)
        labelTitle.textColor = WMColor.orange
        labelTitle.text = NSLocalizedString("shoppingcart.beforeleave",comment:"")
        self.addSubview(labelTitle)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "shoppingCartCrossSellCell", for: indexPath) as! ShoppingCartCrossSellItemCollectionViewCell
        
        let itemUPC = itemsUPC[(indexPath as NSIndexPath).row] as! NSDictionary
        let upc = itemUPC["upc"] as? String ?? ""

        let desc = itemUPC["description"] as! String

        let price = itemUPC["price"] as? String ?? ""
        let imageUrl = itemUPC["smallImageUrl"] as! String

        cell.setValues(imageUrl, productShortDescription: desc, productPrice: price,grayScale: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc))
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let itemUPC = itemsUPC[(indexPath as NSIndexPath).row] as! NSDictionary
        let upc = itemUPC["upc"] as! String
        
        let shoppingCartItems  = UserCurrentSession.sharedInstance().itemsMG!["items"] as? NSArray
       
        /*for itemInCart in shoppingCartItems! {
            if let dictItem = itemInCart as? [String:Any] {
               // if let preorderable = dictItem["isPreorderable"] {
               //     if(preorderable as! String == "true"){
                
                        let alert = IPOWMAlertViewController.showAlert(UIImage(named: "img_default_home"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))//Pass image to add
                        alert!.spinImage.hidden =  true
                        alert!.viewBgImage.backgroundColor =  UIColor.whiteColor()
                        let messagePreorderable = NSLocalizedString("alert.presaleindependent",comment:"")
                        //messagePreorderable =  NSLocalizedString("alert.presaleindependent",comment:"")
                        alert!.setMessage(messagePreorderable)
                        
                        let buttonClose = UIButton(frame: CGRectMake(0, 20, 44, 44))
                        buttonClose.setImage(UIImage(named:"tutorial_close"), forState: UIControlState.Normal)
                        buttonClose.addTarget(alert!, action: #selector(FMDatabase.close), forControlEvents: UIControlEvents.TouchUpInside)
                        alert!.view.addSubview(buttonClose)
                        //
                        return
                 //   }
                //}
            }
        }*/
        
        
        //
        if (!UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)) {
            //let itemUPC = itemsUPC[indexPath.row] as NSDictionary
            let upc = itemUPC["upc"] as! String
            let desc = itemUPC["description"] as! String
            let price = itemUPC["price"] as! String
            let imageUrl = itemUPC["smallImageUrl"] as! String
            let skuId = itemUPC["repositoryId"] as! String
            
            var numOnHandInventory : String = "0"
            if let numberOf = itemUPC["onHandInventory"] as? String{
                numOnHandInventory  = numberOf
            }
            
            var isPreorderable : String = "false"
            if let isPreorderableVal = itemUPC["isPreorderable"] as? String{
                isPreorderable  = isPreorderableVal
            }
            
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_BEFORE_TO_GO.rawValue, action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: "\(desc) - \(upc)")
            
            let params = CustomBarViewController.buildParamsUpdateShoppingCart(skuId, upc:upc, desc: desc, imageURL: imageUrl, price: price, quantity: "1",onHandInventory:numOnHandInventory,pesable:"0",isPreorderable:isPreorderable)
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
        }else {
            
            let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
        }
    }
    
}
