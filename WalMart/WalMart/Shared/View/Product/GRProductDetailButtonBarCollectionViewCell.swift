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

    override func setup() {
        super.setup()
        
        self.listButton.setImage(UIImage(named:"detail_list"), forState: .Normal)
        self.listButton.setImage(UIImage(named:"detail_list_selected"), forState: .Selected)
        self.listButton.setImage(UIImage(named:"detail_list_selected"), forState: .Highlighted)

        
        
        
    }
    
    func validateIsInList(upc:String) {
        self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(upc)
    }
    
    override func addProductToWishlist() {
        self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(upc)
        //event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(desc) - \(upc)")
        
        self.delegate.addOrRemoveToWishList(upc,desc:desc,imageurl:image,price:price,addItem:!self.listButton.selected,isActive:self.isActive,onHandInventory:self.onHandInventory,isPreorderable:self.isPreorderable, added: { (addedTWL:Bool) -> Void in
            self.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc)
        })
    }

}
