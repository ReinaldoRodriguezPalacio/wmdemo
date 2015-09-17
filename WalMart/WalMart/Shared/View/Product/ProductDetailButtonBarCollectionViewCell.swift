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
    func addOrRemoveToWishList(upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,added:(Bool) -> Void)
    func addProductToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String)
    func showMessageProductNotAviable()
    func showProductDetailOptions()
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
    var hasDetailOptions: Bool = false
    
    var isAviableToShoppingCart : Bool = true {
        didSet {
            if isAviableToShoppingCart  {
                reloadButton()
            }else {
                self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), forState: UIControlState.Normal)
                self.addToShoppingCartButton!.setTitleColor(WMColor.productDetailShoppingTexttnBGColor, forState: UIControlState.Normal)
                self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), forState: UIControlState.Selected)
                self.addToShoppingCartButton!.setTitleColor(WMColor.productDetailShoppingTexttnBGColor, forState: UIControlState.Selected)
                self.addToShoppingCartButton!.backgroundColor = WMColor.productDetailShoppingCartNDBtnBGColor
                
            }
        }
    }
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    func retrieveProductInCar() -> Cart? {
        var detail: Cart? = nil
        if self.upc != nil {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Cart", inManagedObjectContext: self.managedContext!)
            
            var predicate = NSPredicate(format: "product.upc == %@ && user == nil && status != %@", self.upc as NSString,NSNumber(integer: CartStatus.Deleted.rawValue))
            if UserCurrentSession.sharedInstance().userSigned != nil {
                predicate = NSPredicate(format: "product.upc == %@ AND user == %@ && status != %@", self.upc as NSString,UserCurrentSession.sharedInstance().userSigned!,NSNumber(integer: CartStatus.Deleted.rawValue))
            }
            
            fetchRequest.predicate = predicate
            
            var error: NSError? = nil
            var result: [Cart] = self.managedContext!.executeFetchRequest(fetchRequest, error: &error) as! [Cart]
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
    
   
    
    required init(coder aDecoder: NSCoder) {
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
        self.backgroundColor = UIColor.whiteColor()
        
        deltailButton = UIButton()
        deltailButton.frame = CGRectMake(spaceBetweenButtons, 0, widthButtons, self.frame.height)
        deltailButton.setImage(UIImage(named:"detail_infoOff"), forState: UIControlState.Normal)
        deltailButton.setImage(UIImage(named:"detail_info"), forState: UIControlState.Selected)
        deltailButton.setImage(UIImage(named:"detail_info"), forState: UIControlState.Highlighted)
        deltailButton.addTarget(self, action: "detailProduct", forControlEvents: UIControlEvents.TouchUpInside)
        
        listButton = UIButton()
        listButton.frame = CGRectMake(deltailButton.frame.maxX, 0, widthButtons, self.frame.height)
        listButton.setImage(UIImage(named:"detail_wishlistOff"), forState: UIControlState.Normal)
        listButton.setImage(UIImage(named:"detail_wishlist"), forState: UIControlState.Selected)
        listButton.setImage(UIImage(named:"detail_wishlist"), forState: UIControlState.Highlighted)
        listButton.addTarget(self, action: "addProductToWishlist", forControlEvents: UIControlEvents.TouchUpInside)
        
        facebookButton = UIButton()
        facebookButton.frame = CGRectMake(listButton.frame.maxX, 0, widthButtons, self.frame.height)
        facebookButton.setImage(UIImage(named:"detail_shareOff"), forState: UIControlState.Normal)
        facebookButton.setImage(UIImage(named:"detail_share"), forState: UIControlState.Highlighted)
        facebookButton.setImage(UIImage(named:"detail_share"), forState: UIControlState.Selected)
        facebookButton.addTarget(self, action: "shareProduct", forControlEvents: UIControlEvents.TouchUpInside)
      
        self.addToShoppingCartButton = UIButton()
        self.addToShoppingCartButton.frame = CGRectMake(facebookButton.frame.maxX + 12, (self.frame.height / 2) - 17, 102, 34)
        self.addToShoppingCartButton!.layer.cornerRadius = 17
        self.addToShoppingCartButton!.backgroundColor = WMColor.productDetailShoppingCartBtnBGColor
        self.addToShoppingCartButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.addToShoppingCartButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
         self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shop",comment:""), forState: UIControlState.Normal)
        self.addToShoppingCartButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shop",comment:""), forState: UIControlState.Selected)
        
        self.addToShoppingCartButton!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        //addToShoppingCartButton.setImage(UIImage(named:"detail_cart"), forState: UIControlState.Normal)
       
        self.addToShoppingCartButton!.addTarget(self, action: "addProductToShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
        let upBorder = UIView(frame: CGRectMake(0, 0, self.frame.width, AppDelegate.separatorHeigth()))
        upBorder.backgroundColor = WMColor.lineSaparatorColor
        
        let downBorder = UIView(frame: CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth()))
        downBorder.backgroundColor = WMColor.lineSaparatorColor
        
        self.addSubview(upBorder)
        self.addSubview(downBorder)
        self.addSubview(facebookButton)
        self.addSubview(deltailButton)
        self.addSubview(listButton)
        self.addSubview(self.addToShoppingCartButton)
    }
    
   
    func addProductToWishlist() {
        let animation = UIImageView(frame: CGRectMake(0, 0,36, 36));
        animation.center = self.listButton.center
        animation.image = UIImage(named:"detail_addToList")
        animation.tag = 99999
        runSpinAnimationOnView(animation, duration: 100, rotations: 1, repeat: 100)
        self.addSubview(animation)
        
        //event
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.GR_EVENT_PRODUCTDETAIL_ADDTOLIST.rawValue,
                action:WMGAIUtils.GR_EVENT_PRODUCTDETAIL_ADDTOLIST.rawValue ,
                label: upc,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        
        delegate.addOrRemoveToWishList(upc,desc:desc,imageurl:image,price:price,addItem:!self.listButton.selected,isActive:self.isActive,onHandInventory:self.onHandInventory,isPreorderable:self.isPreorderable, added: { (addedTWL:Bool) -> Void in
            if addedTWL == true {
                self.listButton.selected = !self.listButton.selected
            }
            animation.layer.removeAllAnimations()
            animation.removeFromSuperview()
        })

    }
    
    func addProductToShoppingCart() {
        if hasDetailOptions{
            delegate.showProductDetailOptions()
        }
        else if isAviableToShoppingCart {
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
    
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,repeat:CGFloat) {
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(repeat)
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func setOpenQuantitySelector() {
        self.addToShoppingCartButton!.setImage(nil, forState: UIControlState.Normal)
        self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.cancel",comment:""), forState: UIControlState.Normal)
        self.addToShoppingCartButton!.setTitleColor(WMColor.productDetailShoppingTexttnBGColor, forState: UIControlState.Normal)
        
        self.addToShoppingCartButton!.setImage(nil, forState: UIControlState.Selected)
        self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.cancel",comment:""), forState: UIControlState.Selected)
        self.addToShoppingCartButton!.setTitleColor(WMColor.productDetailShoppingTexttnBGColor, forState: UIControlState.Selected)
        
        self.addToShoppingCartButton!.backgroundColor = WMColor.productDetailShoppingCartNDBtnBGColor
        
    }
    
    func reloadShoppinhgButton() {
        if isAviableToShoppingCart  {
            reloadButton()
        }else {
            self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), forState: UIControlState.Normal)
            self.addToShoppingCartButton!.setTitleColor(WMColor.productDetailShoppingTexttnBGColor, forState: UIControlState.Normal)
            
            self.addToShoppingCartButton!.setTitle(NSLocalizedString("productdetail.shopna",comment:""), forState: UIControlState.Selected)
            self.addToShoppingCartButton!.setTitleColor(WMColor.productDetailShoppingTexttnBGColor, forState: UIControlState.Selected)
            
            self.addToShoppingCartButton!.backgroundColor = WMColor.productDetailShoppingCartNDBtnBGColor
            
        }
    }
  
    func reloadButton(){
        var buttonTitle = hasDetailOptions ? NSLocalizedString("productdetail.options",comment:"") : NSLocalizedString("productdetail.shop",comment:"")
        
        self.addToShoppingCartButton!.setTitle(buttonTitle, forState: UIControlState.Normal)
        self.addToShoppingCartButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.addToShoppingCartButton!.setTitle(buttonTitle, forState: UIControlState.Selected)
        self.addToShoppingCartButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
       
        
        self.addToShoppingCartButton!.backgroundColor = WMColor.productDetailShoppingCartBtnBGColor
        
        detailProductCart  = self.retrieveProductInCar()
        
        self.addToShoppingCartButton!.setImage(nil, forState: UIControlState.Normal)
        self.addToShoppingCartButton!.setImage(nil, forState: UIControlState.Selected)
        
        self.comments = ""
        
        if detailProductCart != nil {
                let quantity = detailProductCart!.quantity
                //var price = detail!.product.price as NSNumber
                var text: String? = ""
                var total: Double = 0.0
                //Piezas
                if self.isPesable == false {
                    if quantity.integerValue == 1 {
                        text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
                    }
                    else {
                        text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
                    }
                    //total = (quantity.doubleValue * price.doubleValue)
                }
                    //Gramos
                else {
                    var q = quantity.doubleValue
                    if q < 1000.0 {
                        text = String(format: NSLocalizedString("list.detail.quantity.gr", comment:""), quantity)
                    }
                    else {
                        let kg = q/1000.0
                        text = String(format: NSLocalizedString("list.detail.quantity.kg", comment:""), NSNumber(double: kg))
                    }
                    let kgrams = quantity.doubleValue / 1000.0
                    //total = (kgrams * price.doubleValue)
                }
            
            self.addToShoppingCartButton!.setTitle(text, forState: UIControlState.Normal)
              self.addToShoppingCartButton!.setTitle(text, forState: UIControlState.Selected)
            
            if detailProductCart!.type == ResultObjectType.Groceries.rawValue {
                if detailProductCart!.note != nil && detailProductCart!.note != "" {
                    self.comments = detailProductCart!.note
                    self.addToShoppingCartButton!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
                    self.addToShoppingCartButton!.setImage(UIImage(named:"notes_cart"), forState: UIControlState.Normal)
                }
            }
        } else {
            self.addToShoppingCartButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.addToShoppingCartButton!.setTitle(buttonTitle, forState: UIControlState.Normal)
            self.addToShoppingCartButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            self.addToShoppingCartButton!.setTitle(buttonTitle, forState: UIControlState.Selected)
        }
    }
    
}