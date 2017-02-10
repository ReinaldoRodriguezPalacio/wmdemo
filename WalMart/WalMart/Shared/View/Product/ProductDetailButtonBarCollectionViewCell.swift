//
//  ProductDetailButtonBarCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData


protocol ProductDetailButtonBarCollectionViewCellDelegate {
    func shareProduct()
    func showProductDetail()
    func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:@escaping (Bool) -> Void)
    func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String)
    func showMessageProductNotAviable()
    //func showProductDetailOptions()
}




class ProductDetailButtonBarCollectionViewCell : UIView {
    
    var upc : String!
    var desc : String!
    var price : String!
    var image : String!
    var comments : String! = ""
    var isPesable : Bool = false
    var isActive : String!
    var onHandInventory : String!
    var isPreorderable : String!
    var spaceBetweenButtons : CGFloat = 12.0
    var widthButtons : CGFloat = 57.0
    var detailProductCart: Cart?
    var isAddingOrRemovingWishlist: Bool = false
    var productDepartment:String = ""
    
    var isAviableToShoppingCart : Bool = true {
        didSet {
            if isAviableToShoppingCart  {
                reloadButton()
            }else {
                self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), for: UIControlState())
                self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
                self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), for: UIControlState.selected)
                self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
                self.addToShoppingCartButton!.backgroundColor = WMColor.light_gray
                
            }
        }
    }
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    func retrieveProductInCar() -> Cart? {
        var detail: Cart? = nil
        if self.upc != nil {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Cart", in: self.managedContext!)
            
            var predicate = NSPredicate(format: "product.upc == %@ AND status != %@ AND user == nil ", self.upc as NSString,NSNumber(value: CartStatus.deleted.rawValue as Int))
            if UserCurrentSession.hasLoggedUser() {
                predicate = NSPredicate(format: "product.upc == %@ AND status != %@ AND user == %@ ",self.upc as NSString,NSNumber(value: CartStatus.deleted.rawValue as Int),UserCurrentSession.sharedInstance.userSigned!)
            }
            fetchRequest.predicate = predicate
            
            //var error: NSError? = nil
            var result: [Cart] = (try! self.managedContext!.fetch(fetchRequest)) as! [Cart]
            if result.count > 0 {
                detail = result[0]
            }
        }
        return detail
    }
    
    
    var facebookButton : UIButton!
    var deltailButton : UIButton!
    var listButton : UIButton!
    var delegate : ProductDetailButtonBarCollectionViewCellDelegate!
    
    var addToShoppingCartButton : UIButton!
    
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(frame: CGRect,spaceBetweenButtons:CGFloat,widthButtons:CGFloat) {
        super.init(frame: frame)
        self.spaceBetweenButtons = spaceBetweenButtons
        self.widthButtons = widthButtons
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
        
        deltailButton = UIButton()
        deltailButton.frame = CGRect(x: spaceBetweenButtons, y: 0, width: widthButtons, height: self.frame.height)
        deltailButton.setImage(UIImage(named:"detail_infoOff"), for: UIControlState())
        deltailButton.setImage(UIImage(named:"detail_info"), for: UIControlState.selected)
        deltailButton.setImage(UIImage(named:"detail_info"), for: UIControlState.highlighted)
        deltailButton.addTarget(self, action: #selector(ProductDetailButtonBarCollectionViewCell.detailProduct), for: UIControlEvents.touchUpInside)
        
        listButton = UIButton()
        listButton.frame = CGRect(x: deltailButton.frame.maxX, y: 0, width: widthButtons, height: self.frame.height)
        listButton.setImage(UIImage(named:"detail_wishlistOff"), for: UIControlState())
        listButton.setImage(UIImage(named:"detail_wishlist"), for: UIControlState.selected)
        listButton.setImage(UIImage(named:"detail_wishlist"), for: UIControlState.highlighted)
        listButton.setImage(UIImage(named:"wish_list_deactivated"), for: UIControlState.disabled)
        listButton.addTarget(self, action: #selector(ProductDetailButtonBarCollectionViewCell.addProductToWishlist), for: UIControlEvents.touchUpInside)
        
        facebookButton = UIButton()
        facebookButton.frame = CGRect(x: listButton.frame.maxX, y: 0, width: widthButtons, height: self.frame.height)
        facebookButton.setImage(UIImage(named:"detail_shareOff"), for: UIControlState())
        facebookButton.setImage(UIImage(named:"detail_share"), for: UIControlState.highlighted)
        facebookButton.setImage(UIImage(named:"detail_share"), for: UIControlState.selected)
        facebookButton.addTarget(self, action: #selector(ProductDetailButtonBarCollectionViewCell.shareProduct), for: UIControlEvents.touchUpInside)
      
        self.addToShoppingCartButton = UIButton()
        self.addToShoppingCartButton.frame = CGRect(x: facebookButton.frame.maxX + 12, y: (self.frame.height / 2) - 17, width: 102, height: 34)
        self.addToShoppingCartButton!.layer.cornerRadius = 17
        self.addToShoppingCartButton!.backgroundColor = WMColor.yellow
        self.addToShoppingCartButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.addToShoppingCartButton!.setTitleColor(UIColor.white, for: UIControlState())
         self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shop",comment:""), for: UIControlState())
        self.addToShoppingCartButton!.setTitleColor(UIColor.white, for: UIControlState.selected)
        self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shop",comment:""), for: UIControlState.selected)
        
        self.addToShoppingCartButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        //addToShoppingCartButton.setImage(UIImage(named:"detail_cart"), forState: UIControlState.Normal)
       
        self.addToShoppingCartButton!.addTarget(self, action: #selector(ProductDetailButtonBarCollectionViewCell.addProductToShoppingCart), for: UIControlEvents.touchUpInside)
        
        let upBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: AppDelegate.separatorHeigth()))
        upBorder.backgroundColor = WMColor.light_light_gray
        
        let downBorder = UIView(frame: CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.light_light_gray
        
        self.addSubview(upBorder)
        self.addSubview(downBorder)
        self.addSubview(facebookButton)
        self.addSubview(deltailButton)
        self.addSubview(listButton)
        self.addSubview(self.addToShoppingCartButton)
    }
    
   
    func addProductToWishlist() {
        
        
    if !isAddingOrRemovingWishlist {
        isAddingOrRemovingWishlist = true
        let animation = UIImageView(frame: CGRect(x: 0, y: 0,width: 36, height: 36));
        animation.center = self.listButton.center
        animation.image = UIImage(named:"detail_addToList")
        animation.tag = 99999
        runSpinAnimationOnView(animation, duration: 100, rotations: 1, repeats: 100)
        self.addSubview(animation)
        
        //event
        // //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_WISHLIST.rawValue, label: "\(desc) - \(upc)")
        
        delegate.addOrRemoveToWishList(upc,desc:desc,imageurl:image,price:price,addItem:!self.listButton.isSelected,isActive:self.isActive,onHandInventory:self.onHandInventory,isPreorderable:self.isPreorderable,category:self.productDepartment, added: { (addedTWL:Bool) -> Void in
            if addedTWL == true {
                self.listButton.isSelected = !self.listButton.isSelected
                if self.listButton.isSelected {
                    BaseController.sendAnalyticsProductToList(self.upc, desc: self.desc, price: self.price as String)
                }
            }
            animation.layer.removeAllAnimations()
            animation.removeFromSuperview()
            self.isAddingOrRemovingWishlist = false

        })

     }
        
    }
    func addProductToShoppingCart() {
        if isAviableToShoppingCart {
            delegate.addProductToShoppingCart(self.upc, desc: desc,price:price, imageURL: image, comments:self.comments)
        } else {
            delegate.showMessageProductNotAviable()
        }
    }
    
    func shareProduct() {
        delegate.shareProduct()
    }
    
    func detailProduct() {
        delegate.showProductDetail()
    }
    
    func runSpinAnimationOnView(_ view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func setOpenQuantitySelector() {
        self.addToShoppingCartButton!.setImage(nil, for: UIControlState())
        self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.cancel",comment:""), for: UIControlState())
        self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
        
        self.addToShoppingCartButton!.setImage(nil, for: UIControlState.selected)
        self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.cancel",comment:""), for: UIControlState.selected)
        self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        
        self.addToShoppingCartButton!.backgroundColor = WMColor.light_gray
        
    }
    
    func reloadShoppinhgButton() {
        if isAviableToShoppingCart  {
            reloadButton()
        }else {
            self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), for: UIControlState())
            self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
            
            self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), for: UIControlState.selected)
            self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
            
            self.addToShoppingCartButton!.backgroundColor = WMColor.light_gray
            
        }
    }
  
    func reloadButton(){
        let buttonTitle = isAviableToShoppingCart ? NSLocalizedString("productdetail.shop",comment:"") : NSLocalizedString("productdetail.shopna",comment:"")
        let buttonColor = isAviableToShoppingCart ? WMColor.yellow : WMColor.light_gray
        
        self.addToShoppingCartButton!.setTitle(buttonTitle, for: UIControlState())
        self.addToShoppingCartButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.addToShoppingCartButton!.setTitle(buttonTitle, for: UIControlState.selected)
        self.addToShoppingCartButton!.setTitleColor(UIColor.white, for: UIControlState.selected)

       
        
        
        self.addToShoppingCartButton!.backgroundColor = buttonColor
        
        detailProductCart  = self.retrieveProductInCar()
        
        self.addToShoppingCartButton!.setImage(nil, for: UIControlState())
        self.addToShoppingCartButton!.setImage(nil, for: UIControlState.selected)
        
        self.comments = ""
        
        if detailProductCart != nil {
                let quantity = detailProductCart!.quantity
                //var price = detail!.product.price as NSNumber
                var text: String? = ""
                //var total: Double = 0.0
                //Piezas
                if self.isPesable == false {
                    if quantity.intValue == 1 {
                        text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
                    }
                    else {
                        text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
                    }
                    //total = (quantity.doubleValue * price.doubleValue)
                } else if detailProductCart!.product.orderByPiece.boolValue { // Gramos pero se ordena por pieza
                    
                    let pieces = detailProductCart!.product.pieces
                    
                    if pieces == 1 {
                        text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), pieces)
                    } else {
                        text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), pieces)
                    }
                    
                    
                } else { //Gramos

                    let q = quantity.doubleValue
                    if q < 1000.0 {
                        text = String(format: NSLocalizedString("list.detail.quantity.gr", comment:""), quantity)
                    }
                    else {
                        let kg = q/1000.0
                        text = String(format: NSLocalizedString("list.detail.quantity.kg", comment:""), NSNumber(value: kg as Double))
                    }
                    //let kgrams = quantity.doubleValue / 1000.0
                    //total = (kgrams * price.doubleValue)
                }
            
            self.addToShoppingCartButton!.setTitle(text, for: UIControlState())
              self.addToShoppingCartButton!.setTitle(text, for: UIControlState.selected)
            
            if detailProductCart!.type == ResultObjectType.Groceries.rawValue {
                if detailProductCart!.note != nil && detailProductCart!.note != "" {
                    self.comments = detailProductCart!.note
                    self.addToShoppingCartButton!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
                    self.addToShoppingCartButton!.setImage(UIImage(named:"notes_cart"), for: UIControlState())
                }
            }
        } else {
            self.addToShoppingCartButton!.setTitleColor(UIColor.white, for: UIControlState())
            self.addToShoppingCartButton!.setTitle(buttonTitle, for: UIControlState())
            self.addToShoppingCartButton!.setTitleColor(UIColor.white, for: UIControlState.selected)
            self.addToShoppingCartButton!.setTitle(buttonTitle, for: UIControlState.selected)
        }
        if !isAviableToShoppingCart{
            self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
            self.addToShoppingCartButton!.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
        }
    }
    
}
