    //
//  ShoppingCartUpdateController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/5/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import QuartzCore
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ShoppingCartUpdateController : UIViewController, CommentBubbleViewDelegate {
    
    var minContentY : CGFloat = 0
    var params : [String:Any]!
    var multipleItems : [String:Any]? = nil
    var viewBgImage : UIView!
    var imageURL : String = ""
    var spinImage : UIImageView!
    var titleLabel : UILabel!
    var currentIndex : Int = 0
    var imageProduct : UIImageView!
    var timmer : Timer!
    var finishCall : Bool = false
    var closeDone : Bool = false
    let contentModeOrig = UIViewContentMode.scaleAspectFit
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
    var showBtnAddNote: Bool = true
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if multipleItems != nil {
            if multipleItems?.count > 0 {
                let allItems = multipleItems!["allitems"] as! [[String:Any]]
                if allItems.count > 0 {
                    params = allItems[currentIndex] as? [String:Any]
                }
            }
        }
        
        //generateBlurImage()
        
        if IS_IPAD == true {
            minContentY = 62
        }
        
        content = UIView(frame: CGRect(x: 0, y: minContentY, width: self.view.frame.width, height: 340) )
        self.content.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: self.view.bounds)
        bgView.backgroundColor = WMColor.light_blue
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(ShoppingCartUpdateController.closeAlert), for: UIControlEvents.touchUpInside)
        closeButton.frame = CGRect(x: 0, y: 5, width: 44, height: 44)
        
        viewBgImage = UIView(frame: CGRect(x: (self.view.frame.width / 2) - 40, y: 100, width: 80, height: 80))
        viewBgImage.layer.cornerRadius = viewBgImage.frame.width / 2
        viewBgImage.backgroundColor = UIColor.white
        
        spinImage = UIImageView(frame: CGRect(x: (self.view.frame.width / 2) - 42, y: 98, width: 84, height: 84))
        spinImage.image = UIImage(named:"waiting_add")
        
        runSpinAnimationOnView(spinImage, duration: 100, rotations: 1, repeats: 100)
        
        imageProduct = UIImageView(frame: CGRect(x: viewBgImage.frame.width / 4, y: viewBgImage.frame.width / 4, width: viewBgImage.frame.width - (viewBgImage.frame.width / 2), height: viewBgImage.frame.width - (viewBgImage.frame.width / 2)))
        
        if multipleItems == nil {
            let imageUrl = params["imgUrl"] as! String
            
            self.imageProduct!.contentMode = UIViewContentMode.center
            self.imageProduct!.setImageWith(URLRequest(url:URL(string: imageUrl)!), placeholderImage: UIImage(named:"img_default_table"), success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                self.imageProduct!.contentMode = self.contentModeOrig
                self.imageProduct!.image = image
                }, failure: nil)
        } else {
            if let imageName = self.multipleItems!["image"] as? String {
                imageProduct.image = UIImage(named:imageName)
                imageProduct.frame = CGRect(x: 0,y: 0,width: imageProduct.image!.size.width,height: imageProduct.image!.size.height)
                imageProduct.center = CGPoint(x: viewBgImage.frame.width / 2, y: viewBgImage.frame.width / 2)
            }
        }
        viewBgImage.addSubview(imageProduct)
        
        titleLabel = UILabel(frame: CGRect(x: (self.view.frame.width / 2) - 116, y: viewBgImage.frame.maxY + 23, width: 232, height: 200))
        titleLabel.font = WMFont.fontMyriadProLightOfSize(18)
        titleLabel.textColor = WMColor.light_gray
        titleLabel.numberOfLines =  3
        titleLabel.textAlignment = .center
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
        let size =  labelTitleResult.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
        
        titleLabel.frame = CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.minY, width: titleLabel.frame.width, height: size.height)
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
        
        content.frame =  CGRect(x: 0, y: minContentY, width: self.view.frame.width, height: 340)
        
        closeButton.frame = CGRect(x: 0, y: 5, width: 44, height: 44)
        viewBgImage.frame = CGRect(x: (self.view.frame.width / 2) - 40, y: 100, width: 80, height: 80)
        spinImage.frame = CGRect(x: (self.view.frame.width / 2) - 42, y: 98, width: 84, height: 84)
        titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - (titleLabel.frame.width / 2), y: titleLabel.frame.minY, width: titleLabel.frame.width, height: titleLabel.frame.height)
        
        if closeDone == false {
            imageProduct.frame = CGRect(x: viewBgImage.frame.width / 4, y: viewBgImage.frame.width / 4, width: viewBgImage.frame.width - (viewBgImage.frame.width / 2), height: viewBgImage.frame.width - (viewBgImage.frame.width / 2))
        }
        else {
            imageProduct.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
             self.view.alpha = 1.0
            }, completion: { (complete:Bool) -> Void in
            
        }) 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func startAddingToShoppingCart() {
        
        timmer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ShoppingCartUpdateController.showDoneIcon), userInfo: nil, repeats: false)
        finishCall = false
        if multipleItems != nil {
            /*if multipleItems?.count > 0 {
            callItemsService()
            }*/
            let allItems = multipleItems!["allitems"] as! [Dictionary<String,Any>]
            let serviceAddProduct = ShoppingCartAddProductsService()
            var paramsitems :  [[String:Any]] = []
            
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
                
                var isPreorderable = "false"
                if let lpreoObj = itemToShop["isPreorderable"] as? String {
                    isPreorderable = lpreoObj
                }
                
                var category = ""
                if let categoryVal = itemToShop["category"] as? String {
                    category = categoryVal
                }

                
                if let commentsParams = itemToShop["comments"] as? NSString{
                    self.comments = commentsParams as String
                }
                
                var pesable : NSString = "0"    
                if let pesableP = itemToShop["pesable"] as? NSString{
                    pesable = pesableP
                }
                
                let param = serviceAddProduct.builParam(itemToShop["skuId"] as! String,upc:itemToShop["upc"] as! String, quantity: itemToShop["quantity"] as! String, comments: self.comments ,desc:itemToShop["desc"] as! String,price:itemToShop["price"] as! String,imageURL:itemToShop["imgUrl"] as! String,onHandInventory:numOnHandInventory,wishlist:wishlistObj,pesable:pesable,isPreorderable:isPreorderable,category:category)
                
                paramsitems.append(param)
            }
            

            
            if type as String == ResultObjectType.Groceries.rawValue {
                self.showBtnAddNote = false
            /*serviceAddProduct.callService(requestParams : paramsitems, successBlock: { (result:[String:Any]) -> Void in
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
               })*/
            //}else {
                 let serviceAddProductMG = ShoppingCartAddProductsService()
                serviceAddProductMG.jsonFromObject(paramsitems as AnyObject!)
                serviceAddProductMG.callService(paramsitems, successBlock: { (result:[String:Any]) -> Void in
                    self.finishCall = true
                    
                    if self.timmer == nil {
                        self.showDoneIcon()
                        
                    }
                    
                    
                    }, errorBlock: { (error:NSError) -> Void in
                        self.spinImage.layer.removeAllAnimations()
                        self.spinImage.isHidden = true
                        self.titleLabel.sizeToFit()
                        self.titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - 116, y: self.titleLabel.frame.minY,  width: 232, height: 60)
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
            let signalParametrer = params["parameter"] as? [String:Any]
            let signalsDictionary : [String:Any] = ["signals" : signalParametrer == nil ? false : BaseService.getUseSignalServices()]
            let serviceAddProduct  = ShoppingCartAddProductsService(dictionary:signalsDictionary)
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = params["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            var isPreorderable = "false"
            if let isPreorderableVal = params["isPreorderable"] as? String{
                isPreorderable = isPreorderableVal
            }
            
            var category = ""
            if let categoryVal = params["category"] as? String {
              category = categoryVal
            }
            
            
            /*if let type = params["type"] as?  String {
                if type == ResultObjectType.Groceries.rawValue {
                    typeProduct = ResultObjectType.Groceries
                    print("Parametros = \(params)")
                    //TODO Signals
                    let signalParametrer = params["parameter"] as? [String:Any]
                    
                    let signalsDictionary : [String:Any] = [String:Any](dictionary: ["signals" : signalParametrer == nil ? false : BaseService.getUseSignalServices()])
                    let serviceAddProduct = GRShoppingCartAddProductsService(dictionary:signalsDictionary)
                    
                    if let commentsParams = params["comments"] as? NSString{
                        self.comments = commentsParams as String
                    }
                    
                    serviceAddProduct.callService(params["upc"] as! NSString as String, quantity:params["quantity"] as! NSString as String, comments: self.comments ,desc:params["desc"] as! NSString as String,price:params["price"] as! NSString as String,imageURL:params["imgUrl"] as! NSString as String,onHandInventory:numOnHandInventory,pesable:params["pesable"] as! NSString,parameter:signalParametrer, successBlock: { (result:[String:Any]) -> Void in
                        
                        self.finishCall = true
                        if self.timmer == nil {
                            self.showDoneIcon()
                            
                            
                            WishlistService.shouldupdate = true
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ReloadWishList.rawValue, object: nil)
                            
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddItemsToShopingCart.rawValue, object: self, userInfo: nil)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.SuccessAddUpdateCommentCart.rawValue, object: self, userInfo: nil)
                        
                            UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                                UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
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
            }*/
            
            typeProduct = ResultObjectType.Mg
            serviceAddProduct.callService(params["skuId"] as! NSString as String, upc:params["upc"] as! NSString as String, quantity:params["quantity"] as! NSString as String, comments: "",desc:params["desc"] as! NSString as String,price:params["price"] as! NSString as String,imageURL:params["imgUrl"] as! NSString as String,onHandInventory:numOnHandInventory,isPreorderable:isPreorderable,category:category,pesable:params["pesable"] as! NSString,parameter: params["parameter"] as? [String:Any], successBlock: { (result:[String:Any]) -> Void in
                
                //["catalogRefids":"00841020507906_009537102","productId":"00841020507906","quantity":"1","orderedUOM":"EA","itemComment":"EA","orderedQTYWeight":"6"]
                
                //let responceObject = result["responseObject"] as! [String: AnyObject]
                //let order = responceObject["order"] as! [String: AnyObject]
                
                
                //self.jsonFromObject(result as AnyObject!)
                //let order = responceObject["order"] as! [String: AnyObject]
                let commerceItems = result["cartDetails"] as! NSArray//order["commerceItems"] as! NSArray
                
                /*for item in commerceItems {
                    //let productId = item["productId"] as! String
                    if let commerceId = item["commerceItemId"] as? String {
                    //if productId == self.params["upc"] as! String{ //TODO:quitar
                        self.params["commerceItemId"] = commerceId
                        //break
                   // }
                    } else {
                        self.params["commerceItemId"] = ""
                    }
                }*/
                
                self.finishCall = true
                if self.timmer == nil {
                    self.showDoneIcon()
                                    
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue), object: self, userInfo: nil)
                
                 NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.SuccessAddUpdateCommentCart.rawValue), object: self, userInfo: nil)
                
                 UserCurrentSession.sharedInstance.loadMGShoppingCart({ () -> Void in
                    UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
                 })
                
                }) { (error:NSError) -> Void in
                    self.spinImage.layer.removeAllAnimations()
                    self.spinImage.isHidden = true
                    self.titleLabel.sizeToFit()
                    self.titleLabel.frame = CGRect(x: (self.view.frame.width / 2) - 116, y: self.titleLabel.frame.minY,  width: 232, height: 60)
                    if error.code == 1 || error.code == 999  {
                         self.titleLabel.text = error.localizedDescription
                    }else{
                        self.titleLabel.text = error.localizedDescription
                        self.imageProduct.image = UIImage(named:"alert_ups")
                        self.viewBgImage.backgroundColor = WMColor.light_light_blue
                    }
                    self.showDoneIcon()
            }
        }
    }
    
    
    func callItemsService() {
        let allItems = multipleItems!["allitems"] as! [[String:Any]]
        if allItems.count > currentIndex {
            params = allItems[currentIndex] as? [String:Any]
            
            let imageUrl = params["imgUrl"] as! String
            imageProduct.setImageWith(URL(string: imageUrl)!)
            
            //Change label 
            let startTitleAddShoppingCart = NSLocalizedString("shoppingcart.additem",comment:"")
            let startTitleAddShoppingCartEnd = NSLocalizedString("shoppingcart.additemend",comment:"")
            let descItem = params["desc"] as! String
            let labelTitleResult : NSString = "\(startTitleAddShoppingCart) \(descItem) \(startTitleAddShoppingCartEnd)" as NSString
            let size =  labelTitleResult.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
            
            titleLabel.frame = CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.minY, width: titleLabel.frame.width, height: size.height)
            titleLabel.text = labelTitleResult as String
            
            var numOnHandInventory : NSString = "0"
            if let numberOf = params["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            
            var isPreorderable = "false"
            if let isPreorderableVal = params["isPreorderable"] as? String{
                isPreorderable = isPreorderableVal
            }
            
            var category = ""
            if let categoryVal = params["category"] as? String{
                category = categoryVal
            }
            
            let serviceAddProduct = ShoppingCartAddProductsService()
            serviceAddProduct.callCoreDataService(params["skuId"] as! NSString as String, upc:params["upc"] as! String, quantity: "1", comments: "",desc:params["desc"] as! String,price:params["price"] as! String,imageURL:params["imgUrl"] as! String,onHandInventory:numOnHandInventory,isPreorderable:isPreorderable,category:category, pesable:params["pesable"] as! NSString, successBlock: { (result:[String:Any]) -> Void in
                self.currentIndex += 1
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
            if timmer != nil {
                timmer.invalidate()
                timmer = nil
            }
            
            return
        }
        
        self.spinImage.layer.removeAllAnimations()
        self.spinImage.isHidden = true
        if !self.closeDone {
            self.addActionButtons()
        }
        
        self.titleLabel.text = NSLocalizedString("shoppingcart.ready",comment:"")
        self.titleLabel.frame = CGRect(x: self.titleLabel.frame.minX, y: self.titleLabel.frame.minY, width: self.titleLabel.frame.width, height: 18)
        
        imageDone = UIImageView(frame:self.spinImage.frame)
        imageDone.image = UIImage(named:"waiting_done")
        imageDone.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.content.addSubview(imageDone)
        
        UIView.animateKeyframes(withDuration: 0.3 , delay: 0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.imageDone.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            //self.viewBgImage.transform = CGAffineTransformMakeScale(0.0, 0.0)
            self.viewBgImage.isHidden = true
            }) { (complete:Bool) -> Void in
                UIView.animateKeyframes(withDuration: 0.3 , delay: 0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
                    self.imageDone.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }) { (complete:Bool) -> Void in
                        UIView.animateKeyframes(withDuration: 0.3 , delay: 0.0, options: UIViewKeyframeAnimationOptions.allowUserInteraction, animations: { () -> Void in
                            self.imageDone.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
            if self.showBtnAddNote {
                btnAddNote = UIButton(frame: CGRect(x: 0, y: 248, width: self.view.frame.width, height: 20))
                btnAddNote.setImage(UIImage(named: "notes_alert"), for: UIControlState())
                self.btnAddNote!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
                if self.comments.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                     self.btnAddNote.setTitle(NSLocalizedString("shoppingcart.updateNote",comment:""), for: UIControlState())
                }else {
                    self.btnAddNote.setTitle(NSLocalizedString("shoppingcart.addNote",comment:""), for: UIControlState())
                }
                btnAddNote.setTitleColor(UIColor.white, for: UIControlState())
                btnAddNote.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
                btnAddNote.addTarget(self, action: #selector(ShoppingCartUpdateController.addNoteToProduct(_:)), for: UIControlEvents.touchUpInside)
                self.content.addSubview(btnAddNote)
            }
            
            keepShoppingButton = UIButton(frame:CGRect(x: (self.view.frame.width / 2) - 134, y: 288, width: 128, height: 40))
            keepShoppingButton.layer.cornerRadius = 20
            keepShoppingButton.setTitle(NSLocalizedString("shoppingcart.keepshopping",comment:""), for: UIControlState())
            keepShoppingButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            keepShoppingButton.backgroundColor = WMColor.dark_blue
            keepShoppingButton.setTitleColor(UIColor.white, for: UIControlState())
            keepShoppingButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
            keepShoppingButton.addTarget(self, action: #selector(ShoppingCartUpdateController.keepShopping), for: UIControlEvents.touchUpInside)
            
            goToShoppingCartButton = UIButton(frame:CGRect(x: keepShoppingButton.frame.maxX + 11, y: keepShoppingButton.frame.minY,width: keepShoppingButton.frame.width, height: keepShoppingButton.frame.height))
            goToShoppingCartButton.layer.cornerRadius = 20
            goToShoppingCartButton.setTitle(NSLocalizedString("shoppingcart.goshoppingcart",comment:""), for: UIControlState())
            goToShoppingCartButton.backgroundColor = WMColor.green
            goToShoppingCartButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            goToShoppingCartButton.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)
            goToShoppingCartButton.addTarget(self, action: #selector(ShoppingCartUpdateController.goShoppingCart), for: UIControlEvents.touchUpInside)
            
            self.content.addSubview(keepShoppingButton)
            self.content.addSubview(goToShoppingCartButton)
        } else{
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ShoppingCartUpdateController.close), userInfo: nil, repeats: false)
        }
    }
    
    func closeAlert(){
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_CLOSED.rawValue, label:"")
        self.close()
    }
    
    func keepShopping(){
        //Event
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_CONTINUE_BUYING.rawValue, label:"")
        self.close()
    }
    
    func goShoppingCart() {
        self.close()
        if goToShoppingCart != nil {
            //Event
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_OPEN_SHOPPING_CART_SUPER.rawValue, label:"")
            
            goToShoppingCart()
        }
    }
    func saveNote(_ sender:UIButton){
        
        if self.commentTextView?.field?.text!.trim() ==  ""{
            return
        }
        
        //BaseController.sendAnalytics(WMGAIUtils.ACTION_ADD_NOTE.rawValue, action:WMGAIUtils.ACTION_ADD_NOTE_FOR_SEND.rawValue, label:"")
        
        self.view.endEditing(true)
        self.titleLabel.frame = CGRect(x: self.titleLabel.frame.minX,  y: viewBgImage.frame.maxY + 23, width: self.titleLabel.frame.width, height: 60)
        spinImage.image = UIImage(named:"waiting_cart")
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.commentTextView!.alpha = 0.0
            self.btnAddNote.alpha = 0.0
            self.commentTextView!.alpha = 0.0
            self.goToShoppingCartButton!.alpha = 0.0
            self.keepShoppingButton!.alpha = 0.0
            self.btnAddNote!.alpha = 0.0
            
            }, completion: { (complete:Bool) -> Void in
                self.closeDone = true
                self.titleLabel.alpha = 1.0
                self.commentTextView!.isHidden = true
                self.goToShoppingCartButton!.isHidden = true
                self.keepShoppingButton!.isHidden = true
                self.btnAddNote!.isHidden = true
                self.spinImage.isHidden = false
                self.titleLabel.isHidden = false
                if  self.imageDone != nil {
                    self.imageDone.isHidden = true
                }
                self.imageProduct.image = UIImage(named:"waiting_note")
                self.imageProduct.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                self.viewBgImage.addSubview(self.imageProduct)
                self.viewBgImage.isHidden = false
                self.viewBgImage.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                self.runSpinAnimationOnView(self.spinImage, duration: 100, rotations: 1, repeats: 100)
                self.timmer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ShoppingCartUpdateController.showDoneIcon), userInfo: nil, repeats: false)
                self.finishCall = false

                if (sender == self.keepShoppingButton) {
                    self.comments  = " ";
                    self.titleLabel.text = NSLocalizedString("shoppingcart.deleteNote",comment:"")
                }
                else {
                    self.comments = self.commentTextView!.field!.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                    self.titleLabel.text = NSLocalizedString("shoppingcart.saveNoteLoading",comment:"")
                }
                
                
                let updateCommentService = UpdateCommentsService()
                let updateCommentParams = updateCommentService.buildParameterItem(self.commentTextView!.field!.text!.trim(), itemId: self.params["commerceItemId"] as! String)
                
                updateCommentService.callService(requestParams: updateCommentParams as AnyObject, succesBlock: {(result) -> Void in
                    let codeMessage = result["codeMessage"] as! NSNumber
                    if codeMessage.int32Value == 0 {
                        self.finishCall = true
                    
                        if self.timmer == nil {
                            self.showDoneIcon()
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue), object: self, userInfo: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.SuccessAddUpdateCommentCart.rawValue), object: self, userInfo: nil)
                    }else{
                        self.spinImage.layer.removeAllAnimations()
                        self.spinImage.isHidden = true
                        self.titleLabel.text = result["message"] as? String
                        self.imageProduct.image = UIImage(named:"alert_ups")
                        self.viewBgImage.backgroundColor = WMColor.light_light_blue
                    }
                    }, errorBlock: {(error) -> Void in
                        self.spinImage.layer.removeAllAnimations()
                        self.spinImage.isHidden = true
                        if error.code == 1 || error.code == 999 {
                            self.titleLabel.text = error.localizedDescription
                        }else{
                            self.titleLabel.text = error.localizedDescription
                            self.imageProduct.image = UIImage(named:"alert_ups")
                            self.viewBgImage.backgroundColor = WMColor.light_light_blue
                        }

                })
        }) 
    }
    
    func generateBlurImage() {
        var cloneImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 1.0);
            self.parent!.view.layer.render(in: UIGraphicsGetCurrentContext()!)
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
    
    func runSpinAnimationOnView(_ view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func addNoteToProduct(_ sender:UIButton?) {
        self.btnAddNote!.alpha = 0.0
        
        if IS_IPHONE_4_OR_LESS == true {
             self.btnAddNote.frame = CGRect(x: self.btnAddNote.frame.minX, y: 46, width: self.btnAddNote.frame.width,height: self.btnAddNote.frame.height)
            self.commentTextView = CommentBubbleView(frame: CGRect(x: (self.view.frame.width - 300) / 2 , y: 77, width: 300, height: 115))
        }else {
            self.btnAddNote.frame = CGRect(x: self.btnAddNote.frame.minX, y: 76, width: self.btnAddNote.frame.width,height: self.btnAddNote.frame.height)
            self.commentTextView = CommentBubbleView(frame: CGRect(x: (self.view.frame.width - 300) / 2 , y: 110, width: 300, height: 155))
        }
        self.commentTextView?.delegate = self
        
       
  
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
           
            if self.imageDone != nil {
                self.titleLabel.frame = CGRect(x: self.titleLabel.frame.minX , y: self.titleLabel.frame.minY - self.imageDone.frame.minY , width: self.titleLabel.frame.width, height: self.titleLabel.frame.height)
                self.imageDone.frame = CGRect(x: self.imageDone.frame.minX , y: 0, width: self.imageDone.frame.width, height: self.imageDone.frame.height)
            }
            
            if self.imageDone != nil {
                self.imageDone.alpha = 0.0
            }
            if self.titleLabel != nil {
                self.titleLabel.alpha = 0.0
            }
            
            self.goToShoppingCartButton.setTitle(NSLocalizedString("shoppingcart.saveNote",comment:""), for: UIControlState())
            self.goToShoppingCartButton.removeTarget(self, action: #selector(ShoppingCartUpdateController.goShoppingCart), for: UIControlEvents.touchUpInside)
            self.goToShoppingCartButton.addTarget(self, action: #selector(ShoppingCartUpdateController.saveNote(_:)), for: UIControlEvents.touchUpInside)
            self.btnAddNote.setTitle(NSLocalizedString("shoppingcart.noteTile",comment:""), for: UIControlState())
            self.goToShoppingCartButton.alpha = 0.0
            
            self.btnAddNote.removeTarget(self, action: #selector(ShoppingCartUpdateController.addNoteToProduct(_:)), for: UIControlEvents.touchUpInside)
            
            if self.comments.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                self.keepShoppingButton.removeTarget(self, action: #selector(ShoppingCartUpdateController.close), for: UIControlEvents.touchUpInside)
                self.keepShoppingButton.addTarget(self, action: #selector(ShoppingCartUpdateController.saveNote(_:)), for: UIControlEvents.touchUpInside)
                self.keepShoppingButton.setTitle(NSLocalizedString("note.delete",comment:""), for: UIControlState())
            }else {
                 self.keepShoppingButton.alpha = 0
            }
            
            }, completion: { (complete:Bool) -> Void in
                if complete {
                    self.content.frame =  CGRect(x: 0, y: self.minContentY, width: self.view.frame.width, height: 340)
                    self.commentTextView!.alpha = 0.0
                    self.content.addSubview(self.commentTextView!)
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.commentTextView!.alpha = 1.0
                        self.btnAddNote.alpha = 1.0
                        
                        if IS_IPHONE_4_OR_LESS {
                            self.goToShoppingCartButton.frame = CGRect(x: self.goToShoppingCartButton.frame.minX , y: self.goToShoppingCartButton.frame.minY - 81.0 , width: self.goToShoppingCartButton.frame.width, height: 40)
                            self.keepShoppingButton.frame = CGRect(x: self.keepShoppingButton.frame.minX , y: self.keepShoppingButton.frame.minY - 81.0 , width: self.keepShoppingButton.frame.width, height: 40)
                        }
                        
                        
                        }, completion: { (complete:Bool) -> Void in
                    
                            if complete {
                                if self.imageDone != nil {
                                    self.imageDone.isHidden = true
                                    self.imageDone.removeFromSuperview()
                                }

                                //Event
                                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_SHOPPING_CART_ALERT.rawValue, action:WMGAIUtils.ACTION_ADD_NOTE.rawValue, label:"")

                                self.titleLabel.isHidden = true
                                if  self.comments != "" {
                                self.commentTextView!.field?.text = self.comments
                                }
                               
                            }
                    }) 
                }
        }) 
    }
    
    func removeSpinner() {
        self.spinImage.layer.removeAllAnimations()
        self.spinImage.isHidden = true
        self.imageProduct.removeFromSuperview()
        self.viewBgImage.isHidden = true
        
    }
    
   //MARK: CommentBubbleViewDelegate
    
    func showBottonAddNote(_ show: Bool) {
        self.goToShoppingCartButton.alpha = show ? 1.0 : 0.0
    }
    
    
    
    

}
