    //
//  ShoppingCartUpdateController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import QuartzCore

class ShoppingCartUpdateController : UIViewController, CommentBubbleViewDelegate {
    
    var minContentY : CGFloat = 0
    var params : [String:AnyObject]!
    var multipleItems : [String:AnyObject]? = nil
    var viewBgImage : UIView!
    var imageURL : String = ""
    var spinImage : UIImageView!
    var titleLabel : UILabel!
    var currentIndex : Int = 0
    var imageProduct : UIImageView!
    var timmer : NSTimer!
    var finishCall : Bool = false
    var closeDone : Bool = false
    let contentModeOrig = UIViewContentMode.ScaleAspectFit
    var bgView : UIView!
    var closeButton : UIButton!
    var imageDone : UIImageView!
    var goToShoppingCart : (() -> Void)!
    var typeProduct : ResultObjectType!
    
    //buttons 
    var keepShoppingButton : UIButton!
    var goToShoppingCartButton : UIButton!
    
    var commentTextView: CommentBubbleView?
    var comments : String = ""
    
    var btnAddNote : UIButton!
    var content : UIView!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if multipleItems != nil {
            if multipleItems?.count > 0 {
                let allItems = multipleItems!["allitems"] as! NSArray
                if allItems.count > 0 {
                    params = allItems[currentIndex] as? [String:AnyObject]
                }
            }
        }
        
        generateBlurImage()
        
        if IS_IPAD == true {
            minContentY = 62
        }
        
        content = UIView(frame: CGRectMake(0, minContentY, self.view.frame.width, 340) )
        self.content.backgroundColor = UIColor.clearColor()
        
        bgView = UIView(frame: self.view.bounds)
        bgView.backgroundColor = WMColor.light_blue
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeAlert", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.frame = CGRectMake(0, 5, 44, 44)
        
        viewBgImage = UIView(frame: CGRectMake((self.view.frame.width / 2) - 40, 100, 80, 80))
        viewBgImage.layer.cornerRadius = viewBgImage.frame.width / 2
        viewBgImage.backgroundColor = UIColor.whiteColor()
        
        spinImage = UIImageView(frame: CGRectMake((self.view.frame.width / 2) - 42, 98, 84, 84))
        spinImage.image = UIImage(named:"waiting_add")
        
        runSpinAnimationOnView(spinImage, duration: 100, rotations: 1, `repeat`: 100)
        
        imageProduct = UIImageView(frame: CGRectMake(viewBgImage.frame.width / 4, viewBgImage.frame.width / 4, viewBgImage.frame.width - (viewBgImage.frame.width / 2), viewBgImage.frame.width - (viewBgImage.frame.width / 2)))
        
        if multipleItems == nil {
            let imageUrl = params["imgUrl"] as! NSString
            
            self.imageProduct!.contentMode = UIViewContentMode.Center
            self.imageProduct!.setImageWithURL(NSURL(string: imageUrl as String), placeholderImage: UIImage(named:"img_default_table"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.imageProduct!.contentMode = self.contentModeOrig
                self.imageProduct!.image = image
                }, failure: nil)
        } else
        {
            if let imageName = self.multipleItems!["image"] as? String {
                imageProduct.image = UIImage(named:imageName)
                imageProduct.frame = CGRectMake(0,0,imageProduct.image!.size.width,imageProduct.image!.size.height)
                imageProduct.center = CGPointMake(viewBgImage.frame.width / 2, viewBgImage.frame.width / 2)
            }
        }
        viewBgImage.addSubview(imageProduct)
        
        titleLabel = UILabel(frame: CGRectMake((self.view.frame.width / 2) - 116, viewBgImage.frame.maxY + 23, 232, 200))
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.textColor = WMColor.light_gray
        titleLabel.numberOfLines =  3
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0

        var labelTitleResult = ""
        if multipleItems == nil {
            let startTitleAddShoppingCart = NSLocalizedString("shoppingcart.additem",comment:"")
            let startTitleAddShoppingCartEnd = NSLocalizedString("shoppingcart.additemend",comment:"")
            let descItem = params["desc"] as! NSString
            labelTitleResult = "\(startTitleAddShoppingCart) \(descItem) \(startTitleAddShoppingCartEnd)"
        }else{
            labelTitleResult = NSLocalizedString("shoppingcart.additemswishlist",comment:"")
        }
        let size =  labelTitleResult.boundingRectWithSize(CGSizeMake(titleLabel.frame.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
        
        titleLabel.frame = CGRectMake(titleLabel.frame.minX, titleLabel.frame.minY, titleLabel.frame.width, size.height)
        titleLabel.text = labelTitleResult
        
        
        self.view.addSubview(bgView)
        self.view.addSubview(content)
        self.view.addSubview(closeButton)
        
        self.content.addSubview(viewBgImage)
        self.content.addSubview(titleLabel)
        self.content.addSubview(spinImage)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bgView.frame = self.view.bounds
        
        content.frame =  CGRectMake(0, minContentY, self.view.frame.width, 340)
        
        closeButton.frame = CGRectMake(0, 5, 44, 44)
        viewBgImage.frame = CGRectMake((self.view.frame.width / 2) - 40, 100, 80, 80)
        spinImage.frame = CGRectMake((self.view.frame.width / 2) - 42, 98, 84, 84)
        titleLabel.frame = CGRectMake((self.view.frame.width / 2) - 116, titleLabel.frame.minY, titleLabel.frame.width, titleLabel.frame.height)
        
        if closeDone == false {
            imageProduct.frame = CGRectMake(viewBgImage.frame.width / 4, viewBgImage.frame.width / 4, viewBgImage.frame.width - (viewBgImage.frame.width / 2), viewBgImage.frame.width - (viewBgImage.frame.width / 2))
        }
        else {
            imageProduct.frame = CGRectMake(0, 0, 80, 80)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 0.0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
             self.view.alpha = 1.0
            }) { (complete:Bool) -> Void in
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func startAddingToShoppingCart() {
        
        timmer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "showDoneIcon", userInfo: nil, repeats: false)
        finishCall = false
        if multipleItems != nil {
            /*if multipleItems?.count > 0 {
            callItemsService()
            }*/
            let allItems = multipleItems!["allitems"] as! NSArray
            let serviceAddProduct = GRShoppingCartAddProductsService()
            var paramsitems : [AnyObject] = []
            var wishlistDelete : [String] = []
            
            var type : NSString = ""
            
            for itemToShop in allItems {
                
                
                if let typeProd = itemToShop["type"] as? NSString{
                    type = typeProd
                }
                
                
                var numOnHandInventory : NSString = "0"
                if let numberOf = itemToShop["onHandInventory"] as? NSString{
                    numOnHandInventory  = numberOf
                }
                
                var wishlistObj = false
                if let wishObj = itemToShop["wishlist"] as? Bool {
                    wishlistObj = wishObj
                }
                
                if let commentsParams = itemToShop["comments"] as? NSString{
                    self.comments = commentsParams as String
                }
                
                var pesable : NSString = "0"    
                if let pesableP = itemToShop["pesable"] as? NSString{
                    pesable = pesableP
                }
                if wishlistObj {
                    wishlistDelete.append(itemToShop["upc"] as! String)
                }
                
                
                let param = serviceAddProduct.builParam(itemToShop["upc"] as! String, quantity: itemToShop["quantity"] as! String, comments: self.comments ,desc:itemToShop["desc"] as! String,price:itemToShop["price"] as! String,imageURL:itemToShop["imgUrl"] as! String,onHandInventory:numOnHandInventory,wishlist:wishlistObj,pesable:pesable)
                
                paramsitems.append(param)
            }
            

            
            if type == ResultObjectType.Groceries.rawValue {
            serviceAddProduct.callService(requestParams : paramsitems, successBlock: { (result:NSDictionary) -> Void in
                self.finishCall = true
                
                    if self.timmer == nil {
                    self.showDoneIcon()
                    WishlistService.shouldupdate = true
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
                }
                
                }, errorBlock: { (error:NSError) -> Void in
                    self.spinImage.layer.removeAllAnimations()
                    self.spinImage.hidden = true
                    self.titleLabel.sizeToFit()
                    self.titleLabel.frame = CGRectMake((self.view.frame.width / 2) - 116, self.titleLabel.frame.minY,  232,60)
                    if error.code == 1 || error.code == 999 {
                        self.titleLabel.text = error.localizedDescription
                    }else{
                        self.titleLabel.text = error.localizedDescription
                        self.imageProduct.image = UIImage(named:"alert_ups")
                        self.viewBgImage.backgroundColor = WMColor.light_light_blue
                    }
               })
            }else {
                 let serviceAddProductMG = ShoppingCartAddProductsService()
                serviceAddProductMG.callService(paramsitems, successBlock: { (result:NSDictionary) -> Void in
                    self.finishCall = true
                    
                    if self.timmer == nil {
                        self.showDoneIcon()
                        
                    }
                    
                    
                    if wishlistDelete.count > 0 {
                        let deleteService = DeleteItemWishlistService()
                        let toSend = deleteService.buildParamsMultipe(wishlistDelete)
                        deleteService.callServiceWithParams(toSend, successBlock: { (response:NSDictionary) -> Void in
                            WishlistService.shouldupdate = true
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
                            }, errorBlock: { (error:NSError) -> Void in
                                
                        })
                    }
                    
                    }, errorBlock: { (error:NSError) -> Void in
                        self.spinImage.layer.removeAllAnimations()
                        self.spinImage.hidden = true
                        self.titleLabel.sizeToFit()
                        self.titleLabel.frame = CGRectMake((self.view.frame.width / 2) - 116, self.titleLabel.frame.minY,  232, 60)
                        if error.code == 1 || error.code == 999 {
                            self.titleLabel.text = error.localizedDescription
                        }else{
                            self.titleLabel.text = error.localizedDescription
                            self.imageProduct.image = UIImage(named:"alert_ups")
                            self.viewBgImage.backgroundColor = WMColor.light_light_blue
                        }
                })
                
            }
        }else{
            
            let signalParametrer = params["parameter"] as? [String:AnyObject]
            
            let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" : signalParametrer != nil ? true :  false])
            let serviceAddProduct  = ShoppingCartAddProductsService(dictionary:signalsDictionary)
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = params["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            
            var isPreorderable = "false"
            if let isPreorderableVal = params["isPreorderable"] as? String{
                isPreorderable = isPreorderableVal
            }
            
            if let type = params["type"] as?  String {
                if type == ResultObjectType.Groceries.rawValue {
                    typeProduct = ResultObjectType.Groceries
                    print("Parametros = \(params)")
                    //TODO Signals
                    let signalParametrer = params["parameter"] as? [String:AnyObject]
                    
                    let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" : signalParametrer != nil ? true :  false])
                    let serviceAddProduct = GRShoppingCartAddProductsService(dictionary:signalsDictionary)
                    
                    if let commentsParams = params["comments"] as? NSString{
                        self.comments = commentsParams as String
                    }
                    
                    serviceAddProduct.callService(params["upc"] as! NSString as String, quantity:params["quantity"] as! NSString as String, comments: self.comments ,desc:params["desc"] as! NSString as String,price:params["price"] as! NSString as String,imageURL:params["imgUrl"] as! NSString as String,onHandInventory:numOnHandInventory,pesable:params["pesable"] as! NSString,parameter:signalParametrer, successBlock: { (result:NSDictionary) -> Void in
                        
                        self.finishCall = true
                        if self.timmer == nil {
                            self.showDoneIcon()
                            
                            
                            WishlistService.shouldupdate = true
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
                            
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: self, userInfo: nil)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddUpdateCommentCart.rawValue, object: self, userInfo: nil)
                        
                            UserCurrentSession.sharedInstance().loadGRShoppingCart({ () -> Void in
                                UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
                            })
                        
                        
                        }) { (error:NSError) -> Void in
                            self.spinImage.layer.removeAllAnimations()
                            self.spinImage.hidden = true
                            self.titleLabel.sizeToFit()
                            self.titleLabel.frame = CGRectMake((self.view.frame.width / 2) - 116, self.titleLabel.frame.minY,  232, 60)
                            if error.code == 1 || error.code == 999 {
                                self.titleLabel.text = error.localizedDescription
                            }else{
                                self.titleLabel.text = error.localizedDescription
                                self.imageProduct.image = UIImage(named:"alert_ups")
                                self.viewBgImage.backgroundColor = WMColor.light_light_blue
                            }

                    }
                    return
                }
            }
            
            typeProduct = ResultObjectType.Mg
            
            serviceAddProduct.callService(params["upc"] as! NSString as String, quantity:params["quantity"] as! NSString as String, comments: "",desc:params["desc"] as! NSString as String,price:params["price"] as! NSString as String,imageURL:params["imgUrl"] as! NSString as String,onHandInventory:numOnHandInventory,isPreorderable:isPreorderable,parameter: params["parameter"] as? [String:AnyObject], successBlock: { (result:NSDictionary) -> Void in
                
                self.finishCall = true
                if self.timmer == nil {
                    self.showDoneIcon()
                    
                    WishlistService.shouldupdate = true
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
                    
                }
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: self, userInfo: nil)
                
                 NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddUpdateCommentCart.rawValue, object: self, userInfo: nil)
                
                 UserCurrentSession.sharedInstance().loadMGShoppingCart({ () -> Void in
                    UserCurrentSession.sharedInstance().updateTotalItemsInCarts()
                 })
                
                }) { (error:NSError) -> Void in
                    self.spinImage.layer.removeAllAnimations()
                    self.spinImage.hidden = true
                    self.titleLabel.sizeToFit()
                    self.titleLabel.frame = CGRectMake((self.view.frame.width / 2) - 116, self.titleLabel.frame.minY,  232, 60)
                    if error.code == 1 || error.code == 999  {
                         self.titleLabel.text = error.localizedDescription
                    }else{
                        self.titleLabel.text = error.localizedDescription
                        self.imageProduct.image = UIImage(named:"alert_ups")
                        self.viewBgImage.backgroundColor = WMColor.light_light_blue
                    }
            }
        }
    }
    
    
    func callItemsService() {
        let allItems = multipleItems!["allitems"] as! NSArray
        if allItems.count > currentIndex {
            params = allItems[currentIndex] as? [String:AnyObject]
            
            let imageUrl = params["imgUrl"] as! String
            imageProduct.setImageWithURL(NSURL(string: imageUrl))
            
            //Change label 
            let startTitleAddShoppingCart = NSLocalizedString("shoppingcart.additem",comment:"")
            let startTitleAddShoppingCartEnd = NSLocalizedString("shoppingcart.additemend",comment:"")
            let descItem = params["desc"] as! String
            let labelTitleResult : NSString = "\(startTitleAddShoppingCart) \(descItem) \(startTitleAddShoppingCartEnd)"
            let size =  labelTitleResult.boundingRectWithSize(CGSizeMake(titleLabel.frame.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
            
            titleLabel.frame = CGRectMake(titleLabel.frame.minX, titleLabel.frame.minY, titleLabel.frame.width, size.height)
            titleLabel.text = labelTitleResult as String
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = params["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            
            var isPreorderable = "false"
            if let isPreorderableVal = params["isPreorderable"] as? String{
                isPreorderable = isPreorderableVal
            }
            
            let serviceAddProduct = ShoppingCartAddProductsService()
            serviceAddProduct.callCoreDataService(params["upc"] as! String, quantity: "1", comments: "",desc:params["desc"] as! String,price:params["price"] as! String,imageURL:params["imgUrl"] as! String,onHandInventory:numOnHandInventory,isPreorderable:isPreorderable, successBlock: { (result:NSDictionary) -> Void in
                self.currentIndex++
                self.callItemsService()
                }) { (error:NSError) -> Void in
            }
        }else {
            self.finishCall = true
            if self.timmer == nil {
                self.showDoneIcon()
            }
        }
    }
    
    func showDoneIcon(){
        if finishCall ==  false {
            timmer.invalidate()
            timmer = nil
            return
        }
        
        self.spinImage.layer.removeAllAnimations()
        self.spinImage.hidden = true
        if !self.closeDone {
            self.addActionButtons()
        }
        
        self.titleLabel.text = NSLocalizedString("shoppingcart.ready",comment:"")
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.minX, self.titleLabel.frame.minY, self.titleLabel.frame.width, 18)
        
        imageDone = UIImageView(frame:self.spinImage.frame)
        imageDone.image = UIImage(named:"waiting_done")
        imageDone.transform = CGAffineTransformMakeScale(0.0, 0.0)
        self.content.addSubview(imageDone)
        
        UIView.animateKeyframesWithDuration(0.3 , delay: 0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.imageDone.transform = CGAffineTransformMakeScale(1.4, 1.4)
            //self.viewBgImage.transform = CGAffineTransformMakeScale(0.0, 0.0)
            self.viewBgImage.hidden = true
            }) { (complete:Bool) -> Void in
                UIView.animateKeyframesWithDuration(0.3 , delay: 0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    self.imageDone.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    }) { (complete:Bool) -> Void in
                        UIView.animateKeyframesWithDuration(0.3 , delay: 0.0, options: UIViewKeyframeAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                            self.imageDone.transform = CGAffineTransformMakeScale(1.0, 1.0)
                            }) { (complete:Bool) -> Void in
                                if (self.closeDone && complete){
                                    self.close()
                                }
                        }
                }
        }
    }
    
    func addActionButtons() {
        if goToShoppingCart != nil {
            if typeProduct == ResultObjectType.Groceries {
                
                btnAddNote = UIButton(frame: CGRectMake(0, 248, self.view.frame.width, 20))
                btnAddNote.setImage(UIImage(named: "notes_alert"), forState: UIControlState.Normal)
                self.btnAddNote!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
                if self.comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                     self.btnAddNote.setTitle(NSLocalizedString("shoppingcart.updateNote",comment:""), forState: UIControlState.Normal)
                }else {
                    self.btnAddNote.setTitle(NSLocalizedString("shoppingcart.addNote",comment:""), forState: UIControlState.Normal)
                }
                
                btnAddNote.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                btnAddNote.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
                btnAddNote.addTarget(self, action: "addNoteToProduct:", forControlEvents: UIControlEvents.TouchUpInside)
                self.content.addSubview(btnAddNote)
            }
            
            keepShoppingButton = UIButton(frame:CGRectMake((self.view.frame.width / 2) - 134, 288, 128, 40))
            keepShoppingButton.layer.cornerRadius = 20
            keepShoppingButton.setTitle(NSLocalizedString("shoppingcart.keepshopping",comment:""), forState: UIControlState.Normal)
            keepShoppingButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            keepShoppingButton.backgroundColor = WMColor.dark_blue
            keepShoppingButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            keepShoppingButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
            keepShoppingButton.addTarget(self, action: "keepShopping", forControlEvents: UIControlEvents.TouchUpInside)
            
            goToShoppingCartButton = UIButton(frame:CGRectMake(keepShoppingButton.frame.maxX + 11, keepShoppingButton.frame.minY,keepShoppingButton.frame.width, keepShoppingButton.frame.height))
            goToShoppingCartButton.layer.cornerRadius = 20
            goToShoppingCartButton.setTitle(NSLocalizedString("shoppingcart.goshoppingcart",comment:""), forState: UIControlState.Normal)
            goToShoppingCartButton.backgroundColor = WMColor.green
            goToShoppingCartButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            goToShoppingCartButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
            goToShoppingCartButton.addTarget(self, action: "goShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.content.addSubview(keepShoppingButton)
            self.content.addSubview(goToShoppingCartButton)
        } else{
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "close", userInfo: nil, repeats: false)
        }
    }
    
    func closeAlert(){
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_CLOSED.rawValue, label:"")
        self.close()
    }
    
    func keepShopping(){
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_CONTINUE_BUYING.rawValue, label:"")
        self.close()
    }
    
    func goShoppingCart() {
        self.close()
        if goToShoppingCart != nil {
            //Event
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_OPEN_SHOPPING_CART_SUPER.rawValue, label:"")
            
            goToShoppingCart()
        }
    }
    func saveNote(sender:UIButton){
        
        if self.commentTextView?.field?.text!.trim() ==  ""{
            return
        }
        
        //if self.commentTextView?

                //Event
        BaseController.sendAnalytics(WMGAIUtils.ACTION_ADD_NOTE.rawValue, action:WMGAIUtils.ACTION_ADD_NOTE_FOR_SEND.rawValue, label:"")
        
        self.view.endEditing(true)
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.minX,  viewBgImage.frame.maxY + 23, self.titleLabel.frame.width, 60)
        spinImage.image = UIImage(named:"waiting_cart")
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.commentTextView!.alpha = 0.0
            self.btnAddNote.alpha = 0.0
            self.commentTextView!.alpha = 0.0
            self.goToShoppingCartButton!.alpha = 0.0
            self.keepShoppingButton!.alpha = 0.0
            self.btnAddNote!.alpha = 0.0
            
            }) { (complete:Bool) -> Void in
                
                if complete {
                    self.closeDone = true
                    self.titleLabel.alpha = 1.0
                    self.commentTextView!.hidden = true
                    self.goToShoppingCartButton!.hidden = true
                    self.keepShoppingButton!.hidden = true
                    self.btnAddNote!.hidden = true
                    self.spinImage.hidden = false
                    self.titleLabel.hidden = false
                    if  self.imageDone != nil {
                        self.imageDone.hidden = true
                    }
                    self.imageProduct.image = UIImage(named:"waiting_note")
                    self.imageProduct.frame = CGRectMake(0, 0, 80, 80)
                    self.viewBgImage.addSubview(self.imageProduct)
                    self.viewBgImage.hidden = false
                    self.viewBgImage.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                    self.runSpinAnimationOnView(self.spinImage, duration: 100, rotations: 1, `repeat`: 100)
                    self.timmer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "showDoneIcon", userInfo: nil, repeats: false)
                    self.finishCall = false

                    if (sender == self.keepShoppingButton) {
                        self.comments  = " ";
                        self.titleLabel.text = NSLocalizedString("shoppingcart.deleteNote",comment:"")
                    }
                    else {
                        self.comments = self.commentTextView!.field!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        self.titleLabel.text = NSLocalizedString("shoppingcart.saveNote",comment:"")
                    }
                    if let type = self.params["type"] as?  String {
                        if type == ResultObjectType.Groceries.rawValue {
                            self.typeProduct = ResultObjectType.Groceries
                            print("Parametros = \(self.params)")
                            
                            var numOnHandInventory : NSString = "0"
                            if let numberOf = self.params["onHandInventory"] as? NSString{
                                numOnHandInventory  = numberOf
                            }
                            let pesable = self.params["pesable"] as! NSString
                            let serviceAddProduct = GRShoppingCartAddProductsService()
                            serviceAddProduct.callService(self.params["upc"] as! String, quantity:self.params["quantity"] as! String, comments: self.comments ,desc:self.params["desc"] as! String,price:self.params["price"] as! String,imageURL:self.params["imgUrl"] as! String,onHandInventory:numOnHandInventory,pesable:pesable,parameter:nil, successBlock: { (result:NSDictionary) -> Void in
                                
                                self.finishCall = true
                                
                                if self.timmer == nil {
                                    self.showDoneIcon()
                                    WishlistService.shouldupdate = true
                                }
                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: self, userInfo: nil)
                                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddUpdateCommentCart.rawValue, object: self, userInfo: nil)
                                
                                }) { (error:NSError) -> Void in
                                    self.spinImage.layer.removeAllAnimations()
                                    self.spinImage.hidden = true
                                    if error.code == 1 || error.code == 999 {
                                        self.titleLabel.text = error.localizedDescription
                                    }else{
                                        self.titleLabel.text = error.localizedDescription
                                        self.imageProduct.image = UIImage(named:"alert_ups")
                                        self.viewBgImage.backgroundColor = WMColor.light_light_blue
                                    }
                            }
                            
                        }
                    }
                    
                }
                
        }
    }
    
    func generateBlurImage() {
        var cloneImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 1.0);
            self.parentViewController!.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            cloneImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        let blurredImage = cloneImage!.applyLightEffect()
        let imageView = UIImageView()
        imageView.frame = self.view.bounds
        imageView.clipsToBounds = true
        imageView.image = blurredImage
        self.view.addSubview(imageView)
    }
    
    func close() {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,`repeat`:CGFloat) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(`repeat`)
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func addNoteToProduct(sender:UIButton?) {
        self.btnAddNote!.alpha = 0.0
        
        if IS_IPHONE_4_OR_LESS == true {
             self.btnAddNote.frame = CGRectMake(self.btnAddNote.frame.minX, 46, self.btnAddNote.frame.width,self.btnAddNote.frame.height)
            self.commentTextView = CommentBubbleView(frame: CGRectMake((self.view.frame.width - 300) / 2 , 77, 300, 115))
        }else {
            self.btnAddNote.frame = CGRectMake(self.btnAddNote.frame.minX, 76, self.btnAddNote.frame.width,self.btnAddNote.frame.height)
            self.commentTextView = CommentBubbleView(frame: CGRectMake((self.view.frame.width - 300) / 2 , 110, 300, 155))
        }
        self.commentTextView?.delegate = self
        
       
  
        UIView.animateWithDuration(0.3, animations: { () -> Void in
           
            if self.imageDone != nil {
                self.titleLabel.frame = CGRectMake(self.titleLabel.frame.minX , self.titleLabel.frame.minY - self.imageDone.frame.minY , self.titleLabel.frame.width, self.titleLabel.frame.height)
                self.imageDone.frame = CGRectMake(self.imageDone.frame.minX , 0, self.imageDone.frame.width, self.imageDone.frame.height)
            }
            
            if self.imageDone != nil {
                self.imageDone.alpha = 0.0
            }
            if self.titleLabel != nil {
                self.titleLabel.alpha = 0.0
            }
            
            self.goToShoppingCartButton.setTitle(NSLocalizedString("shoppingcart.saveNote",comment:""), forState: UIControlState.Normal)
            self.goToShoppingCartButton.removeTarget(self, action: "goShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
            self.goToShoppingCartButton.addTarget(self, action: "saveNote:", forControlEvents: UIControlEvents.TouchUpInside)
            self.btnAddNote.setTitle(NSLocalizedString("shoppingcart.noteTile",comment:""), forState: UIControlState.Normal)
            self.goToShoppingCartButton.alpha = 0.0
            
            self.btnAddNote.removeTarget(self, action: "addNoteToProduct:", forControlEvents: UIControlEvents.TouchUpInside)
            
            if self.comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                self.keepShoppingButton.removeTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
                self.keepShoppingButton.addTarget(self, action: "saveNote:", forControlEvents: UIControlEvents.TouchUpInside)
                self.keepShoppingButton.setTitle(NSLocalizedString("note.delete",comment:""), forState: UIControlState.Normal)
            }else {
                 self.keepShoppingButton.alpha = 0
            }
            
            }) { (complete:Bool) -> Void in
                if complete {
                    self.content.frame =  CGRectMake(0, self.minContentY, self.view.frame.width, 340)
                    self.commentTextView!.alpha = 0.0
                    self.content.addSubview(self.commentTextView!)
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.commentTextView!.alpha = 1.0
                        self.btnAddNote.alpha = 1.0
                        
                        if IS_IPHONE_4_OR_LESS {
                            self.goToShoppingCartButton.frame = CGRectMake(self.goToShoppingCartButton.frame.minX , self.goToShoppingCartButton.frame.minY - 81.0 , self.goToShoppingCartButton.frame.width, 40)
                            self.keepShoppingButton.frame = CGRectMake(self.keepShoppingButton.frame.minX , self.keepShoppingButton.frame.minY - 81.0 , self.keepShoppingButton.frame.width, 40)
                        }
                        
                        
                        }) { (complete:Bool) -> Void in
                    
                            if complete {
                                if self.imageDone != nil {
                                    self.imageDone.hidden = true
                                    self.imageDone.removeFromSuperview()
                                }

                                //Event
                                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_ADD_NOTE.rawValue, label:"")

                                
                                self.titleLabel.hidden = true
                                if  self.comments != "" {
                                self.commentTextView!.field?.text = self.comments
                                }
                               
                            }
                    }
                }
        }
    }
    
    func removeSpinner() {
        self.spinImage.layer.removeAllAnimations()
        self.spinImage.hidden = true
        self.imageProduct.removeFromSuperview()
        self.viewBgImage.hidden = true
        
    }
    
   //MARK: CommentBubbleViewDelegate
    
    func showBottonAddNote(show: Bool) {
        self.goToShoppingCartButton.alpha = show ? 1.0 : 0.0
        
        

        
    }
    
    
    
    

}