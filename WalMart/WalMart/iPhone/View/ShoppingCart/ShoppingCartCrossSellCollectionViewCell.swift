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

    
    override func setup() {
        super.setup()
        
        collection.registerClass(ShoppingCartCrossSellItemCollectionViewCell.self, forCellWithReuseIdentifier: "shoppingCartCrossSellCell")
        
        
        labelTitle = UILabel(frame: CGRectMake(16, 13, self.frame.width - 32, 14))
        labelTitle.font = WMFont.fontMyriadProLightOfSize(14)
        labelTitle.textColor = WMColor.shoppingCartBeforeLeaveTextColor
        labelTitle.text = NSLocalizedString("shoppingcart.beforeleave",comment:"")
        
        self.addSubview(labelTitle)
        
    }


        
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("shoppingCartCrossSellCell", forIndexPath: indexPath) as ShoppingCartCrossSellItemCollectionViewCell
        
        let itemUPC = itemsUPC[indexPath.row] as NSDictionary
        let upc = itemUPC["upc"] as NSString

        let desc = itemUPC["description"] as NSString
        let price = itemUPC["price"] as NSString
        let imageArray = itemUPC["imageUrl"] as NSArray
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray.objectAtIndex(0) as String
        }
        cell.setValues(imageUrl, productShortDescription: desc, productPrice: price,grayScale: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc))
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        let itemUPC = itemsUPC[indexPath.row] as NSDictionary
        let upc = itemUPC["upc"] as NSString
        
        if (!UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc)) {
            //let itemUPC = itemsUPC[indexPath.row] as NSDictionary
            let upc = itemUPC["upc"] as NSString
            let desc = itemUPC["description"] as NSString
            let price = itemUPC["price"] as NSString
            let imageArray = itemUPC["imageUrl"] as NSArray
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray.objectAtIndex(0) as String
            }
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = itemUPC["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            
            let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageUrl, price: price, quantity: "1",onHandInventory:numOnHandInventory,pesable:"0")
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
        }else {
            
            let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            
        }
        
      
        
    }
    
}