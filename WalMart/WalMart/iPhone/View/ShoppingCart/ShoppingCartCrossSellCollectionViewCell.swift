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
        
        let itemUPC = itemsUPC[indexPath.row] 
        let upc = itemUPC["upc"] as! String

        let desc = itemUPC["description"] as! String
        let price = itemUPC["price"] as! String
        let imageArray = itemUPC["imageUrl"] as! [Any]
        var imageUrl = ""
        if imageArray.count > 0 {
            imageUrl = imageArray[0] as! String
        }
        cell.setValues(imageUrl, productShortDescription: desc, productPrice: price,grayScale: UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc))
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let itemUPC = itemsUPC[indexPath.row] 
        let upc = itemUPC["upc"] as! String
        
        UserCurrentSession.sharedInstance.nameListToTag = NSLocalizedString("shoppingcart.beforeleave", comment: "")
        let shoppingCartItems  = UserCurrentSession.sharedInstance.itemsMG!["items"] as? [Any]
        for itemInCart in shoppingCartItems! {
            if let dictItem = itemInCart as? [String:Any] {
                if let preorderable = dictItem["isPreorderable"] {
                    if(preorderable as! String == "true"){
                        let array = dictItem["imageUrl"] as! [String]
                        let alert = IPOWMAlertViewController.showAlert(WishListViewController.createImage(array[0]),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                        alert!.spinImage.isHidden =  true
                        alert!.viewBgImage.backgroundColor =  UIColor.white
                        let messagePreorderable = NSLocalizedString("alert.presaleindependent",comment:"")
                        //messagePreorderable =  NSLocalizedString("alert.presaleindependent",comment:"")
                        alert!.setMessage(messagePreorderable)
                        
                        let buttonClose = UIButton(frame: CGRect(x: 0, y: 20, width: 44, height: 44))
                        buttonClose.setImage(UIImage(named:"tutorial_close"), for: UIControlState())
                        buttonClose.addTarget(alert!, action: #selector(FMDatabase.close), for: UIControlEvents.touchUpInside)
                        alert!.view.addSubview(buttonClose)
                        //
                        return
                    }
                }
            }
        }
        
        if (!UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc)) {
            //let itemUPC = itemsUPC[indexPath.row] as [String:Any]
            let upc = itemUPC["upc"] as! String
            let desc = itemUPC["description"] as! String
            let price = itemUPC["price"] as! String
            let imageArray = itemUPC["imageUrl"] as! [Any]
            var imageUrl = ""
            if imageArray.count > 0 {
                imageUrl = imageArray[0] as! String
            }
            
            var numOnHandInventory : String = "0"
            if let numberOf = itemUPC["onHandInventory"] as? String{
                numOnHandInventory  = numberOf
            }
            
            var isPreorderable : String = "false"
            if let isPreorderableVal = itemUPC["isPreorderable"] as? String{
                isPreorderable  = isPreorderableVal
            }
            
            //EVENT
            ////BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_BEFORE_TO_GO.rawValue, action: WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: "\(desc) - \(upc)")
            let params = CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageUrl, price: price, quantity: "1", onHandInventory: numOnHandInventory, pesable: "0", isPreorderable: isPreorderable, orderByPieces: true, pieces: 1)
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
        }else {
            
            let alert = IPAWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
            alert!.setMessage(NSLocalizedString("productdetail.notaviable",comment:""))
            alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            
        }
        
      
        
    }
    
}
