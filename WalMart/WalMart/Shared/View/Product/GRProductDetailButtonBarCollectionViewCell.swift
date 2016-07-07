//
//  GRProductDetailButtonBarCollectionViewCell.swift
//  WalMart
//
//  Created by neftali on 27/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRProductDetailButtonBarCollectionViewCell: ProductDetailButtonBarCollectionViewCell {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var idListSelect =  ""

    override func setup() {
        super.setup()
        
        self.listButton.setImage(UIImage(named:"detail_list"), forState: .Normal)
        self.listButton.setImage(UIImage(named:"detail_list_selected"), forState: .Selected)
        self.listButton.setImage(UIImage(named:"detail_list_selected"), forState: .Highlighted)
        
        
    }
    
    func validateIsInList(upc:String) {
        self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(upc)
    }
    
    /**
     Send product to wishList
     */
    override func addProductToWishlist() {
        self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(upc)
        //event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(desc) - \(upc)")
        
        if idListSelect !=  ""{
            print("cambio de funcionalidad")
            self.addDirectToListId()
        }else{
            
            self.delegate.addOrRemoveToWishList(upc,desc:desc,imageurl:image,price:price,addItem:!self.listButton.selected,isActive:self.isActive,onHandInventory:self.onHandInventory,isPreorderable:self.isPreorderable,category:self.productDepartment, added: { (addedTWL:Bool) -> Void in
                self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc)
            })
        }
    }
    
    func addDirectToListId(){
        
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError:UIImage(named:"list_alert_error"))
        alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
        
        let service = GRAddItemListService()
        
        self.isActive =  self.isActive == "" ?  "true" : self.isActive
        let productObject = [service.buildProductObject(upc:self.upc, quantity:1,pesable:"\(self.isPesable.hashValue)",active:self.isActive == "true" ? true : false)]//isActive
        
        service.callService(service.buildParams(idList: idListSelect, upcs: productObject),
            successBlock: { (result:NSDictionary) -> Void in
                self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc)
                alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                alertView!.showDoneIcon()
              
                
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                alertView!.setMessage(error.localizedDescription)
                alertView!.showErrorIcon("Ok")
                
            }
        )
    
    }

}
