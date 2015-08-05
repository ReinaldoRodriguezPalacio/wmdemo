//
//  IPAGRProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/14/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class IPAGRProductDetailViewController : IPAProductDetailViewController, ListSelectorDelegate , IPAUserListDetailDelegate{
    var idFamily : String =  ""
    var idLine : String =  ""
    var idDepartment: String = ""
    var detailList  : IPAUserListDetailViewController? = nil
    var visibleDetailList = false;
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    
    var comments = ""
    
    var nutrmentals : [String]!
    var ingredients : String!
    var nutrimentalsView : GRNutrimentalInfoView? = nil
    
    var equivalenceByPiece : NSNumber! = NSNumber(int:0)
    
    override func viewDidLoad() {
        NSLog("viewDidLoad")
        super.viewDidLoad()
        NSLog("super.viewDidLoad()")
        self.type = ResultObjectType.Groceries.rawValue
        NSLog("self.type = ResultObjectType.Groceries.rawValue")
    }
    
    override func loadDataFromService() {
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue, action: WMGAIUtils.GR_EVENT_SHOWPRODUCTDETAIL.rawValue, label: upc, value: nil).build())
        }

        let productService = GRProductDetailService()
        productService.callService(upc, successBlock: { (result: NSDictionary) -> Void in
            self.name = result["description"] as NSString
            if let priceR =  result["price"] as? NSNumber {
                self.price = "\(priceR)"
            }
            if let department = result["department"] as? NSDictionary {
                self.idDepartment = department["idDepto"] as NSString
            }
            if let family = result["family"] as? NSDictionary {
                 self.idFamily = family["id"] as NSString
            }
            if let line = result["line"] as? NSDictionary {
                 self.idLine = line["id"] as NSString
            }
            self.detail = result["longDescription"] as NSString
            self.saving = ""
            if let savingResult = result["promoDescription"] as? NSString {
                self.saving = result["promoDescription"] as NSString
            }
            self.characteristics = []
            var allCharacteristics : [AnyObject] = []
            
            let strLabel = "UPC"
            let strValue = self.upc
            allCharacteristics.append(["label":strLabel,"value":self.upc])
            
            if let carStr = result["characteristics"] as? String {
                allCharacteristics.append(["label":"Características","value":carStr])
            }
            for characteristic in self.characteristics  {
                allCharacteristics.append(characteristic)
            }
            self.characteristics = allCharacteristics
            
            if let msiResult =  result["msi"] as? NSString {
                if msiResult != "" {
                    self.msi = msiResult.componentsSeparatedByString(",")
                }else{
                    self.msi = []
                }
            }
            if let images = result["imageUrl"] as? NSArray {
                self.imageUrl = images
            }
            if let images = result["imageUrl"] as? NSString {
                self.imageUrl = [images]
            }
            //let freeShippingStr  = result["freeShippingItem"] as NSString
            self.freeShipping = false
            
            //self.strisActive  = result["isActive"] as NSString
            self.isActive = true //"true" == self.strisActive

            if self.isActive == true {
                self.isActive = self.price.doubleValue > 0
            }
            
            
            if let stockSvc = result["stock"] as?  Bool {
                if self.isActive == true  {
                    self.isActive  = stockSvc
                }
            }
            
            if let stockSvc = result["stock"] as?  NSNumber {
                if self.isActive == true  {
                    self.isActive  = stockSvc.boolValue
                }
            }

            
            if let equivalence = result["equivalenceByPiece"] as? NSNumber {
                self.equivalenceByPiece = equivalence
            }
            
            if let equivalence = result["equivalenceByPiece"] as? NSString {
                if equivalence != "" {
                    self.equivalenceByPiece =  NSNumber(int: equivalence.intValue)
                }
            }
            
            self.strisPreorderable  = "false"
            self.isPreorderable = false//"true" == self.strisPreorderable
            
            self.bundleItems = NSArray()
            if let bndl = result["bundleItems"] as?  NSArray {
                self.bundleItems = bndl
            }
            
            if let pesable = result["type"] as?  NSString {
                self.isPesable = pesable.intValue == 1
            }
            
            
            var numOnHandInventory : NSString = (self.isPesable ? "20000" : "99")
            if let numberOf = result["onHandInventory"] as? NSString{
                numOnHandInventory  = numberOf
            }
            self.onHandInventory  = numOnHandInventory
            
            //Nutrimental
            self.ingredients = ""
            self.nutrmentals = []
            if let ingredientsInfo = result["ingredients"] as? String{
                self.ingredients = ingredientsInfo
            }
            if let nutrimentalArray = result["nutritional"] as? [String] {
                self.nutrmentals = nutrimentalArray
            }
            
            self.isLoading = false
            self.tabledetail.delegate = self
            self.tabledetail.dataSource = self
            self.tabledetail.reloadData()
            self.bannerImagesProducts.items = self.imageUrl
            self.bannerImagesProducts.collection.reloadData()
            
            self.loadCrossSell()
            
            self.titlelbl.text = self.name
            
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
            
            if let tracker = GAI.sharedInstance().defaultTracker {
                
                var product = GAIEcommerceProduct()
                var builder = GAIDictionaryBuilder.createScreenView()
                product.setId(self.upc)
                product.setName(self.name)
                
                var action = GAIEcommerceProductAction();
                action.setAction(kGAIPADetail)
                builder.setProductAction(action)
                builder.addProduct(product)
                
                tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue)
                tracker.send(builder.build())
            }
           
            }) { (error:NSError) -> Void in
              //  var empty = IPOGenericEmptyView(frame:self.viewLoad.frame)
                var empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
               
                self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                empty.returnAction = { () in
                    println("")
                    self.navigationController!.popViewControllerAnimated(true)
                }
                self.view.addSubview(empty)
                if self.viewLoad != nil {
                    self.viewLoad.stopAnnimating()
                }
        }
    }
    
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let headerView = UIView()
        switch section {
        case 0:
            return nil
        default:
            
            if isLoading {
                return UIView()
            }
            
            let productDetailButtonGR = GRProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 64.0),spaceBetweenButtons:13,widthButtons:63)
            productDetailButtonGR.upc = self.upc
            productDetailButtonGR.desc = self.name
            productDetailButtonGR.price = self.price
            productDetailButtonGR.isPesable  = self.isPesable
            productDetailButtonGR.onHandInventory = self.onHandInventory
            productDetailButtonGR.isActive = self.strisActive
            productDetailButtonGR.isPreorderable = self.strisPreorderable
            productDetailButtonGR.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 && isPreorderable == false
            productDetailButtonGR.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc)
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as NSString
            }
            productDetailButtonGR.image = imageUrl
            productDetailButtonGR.delegate = self
            productDetailButtonGR.validateIsInList(self.upc)
            
            productDetailButton = productDetailButtonGR
            return productDetailButton
        }
    }

    override func loadCrossSell() {
        NSLog("lcs 1")
        var service = GRProductBySearchService()
        var params = service.buildParamsForSearch(text: "", family: self.idFamily, line: self.idLine, sort: FilterType.descriptionAsc.rawValue, departament: self.idDepartment, start: 0, maxResult: 6)
        service.callService(params,
            successBlock: { (arrayProduct:NSArray?) -> Void in
                NSLog("lcs 2")
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    NSLog("lcs 2")
                    var keywords = Array<AnyObject>()
                    for item in arrayProduct as [AnyObject] {
                        
                        if self.upc !=  item["upc"] as NSString {
                        
                        var urlArray : [String] = []
                        urlArray.append(item["imageUrl"] as String)
                 
                        var price : NSString = ""
                        if let value = item["price"] as? NSString {
                            price = item["price"] as NSString
                        }
                        else if let value = item["price"] as? NSNumber {
                            price = "\(value)"
                        }
                        
                        keywords.append(["codeMessage":"0","description":item["description"] as NSString, "imageUrl":urlArray, "price" : price,  "upc" :item["upc"] as NSString  , "type" : ResultObjectType.Groceries.rawValue ])
                        }
                        
                        if keywords.count == 5 {
                            break
                        }
                    }
                    self.itemsCrossSellUPC = keywords
                    if self.itemsCrossSellUPC.count > 0{
                        self.productCrossSell.reloadWithData(self.itemsCrossSellUPC, upc: self.upc)
                    }
                }
                
            }, errorBlock: {(error: NSError) in
                println(error)
                
            }
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endUpdatingShoppingCart:", name: CustomBarNotification.UpdateBadge.rawValue, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    override func addProductToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String ) {
        self.comments = comments
        if visibleDetailList {
            self.removeDetailListSelector(
                { () -> Void in
                   self.addProductToShoppingCart(upc,desc:desc,price:price,imageURL:imageURL, comments:comments)
            })
        }
        else {
            super.addProductToShoppingCart(upc,desc:desc,price:price,imageURL:imageURL, comments:comments)
        }
    }
    
    
    override func addOrRemoveToWishList(upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,added:(Bool) -> Void) {
        let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        
        if self.isShowShoppingCart || self.isShowProductDetail  {
            self.closeContainer(
                { () -> Void in
                    self.productDetailButton.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                    self.selectQuantityGR = nil
                    self.addOrRemoveToWishList(upc, desc: desc, imageurl: imageurl, price: price, addItem: addItem, isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable, added: added)
                }, closeRow:false
            )
            return
        }
       
        if self.listSelectorController == nil {
           addToList()
        }
        else {
            if visibleDetailList {
                self.removeDetailListSelector(
                    { () -> Void in
                         self.removeListSelector(action: nil, closeRow:true)
                })
            }else {
                self.removeListSelector(action: nil, closeRow:true)
            }
        }
    }
    
    
    func addToList() {
        let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        self.listSelectorContainer = UIView(frame: frameDetail)
        self.listSelectorContainer!.clipsToBounds = true
        self.listSelectorController = ListsSelectorViewController()
        self.listSelectorController!.delegate = self
        self.listSelectorController!.productUpc = self.upc
        self.addChildViewController(self.listSelectorController!)
        self.listSelectorController!.view.frame = frameDetail
        self.listSelectorContainer!.addSubview(self.listSelectorController!.view)
        self.listSelectorController!.didMoveToParentViewController(self)
        self.listSelectorController!.view.clipsToBounds = true
        self.listSelectorBackgroundView = self.listSelectorController!.createBlurImage(self.tabledetail, frame: frameDetail)
        self.listSelectorContainer!.insertSubview(self.listSelectorBackgroundView!, atIndex: 0)
        var bg = UIView(frame: frameDetail)
        bg.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        self.listSelectorContainer!.insertSubview(bg, aboveSubview: self.listSelectorBackgroundView!)
        opencloseContainer(true,viewShow:self.listSelectorContainer!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton!.listButton.selected = true
            },additionalAnimationClose:{ () -> Void in
               
            },additionalAnimationFinish: { () -> Void in
        })
    }
    
    //new
    override func addToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String) {
        NSLog("20")
        let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
        
        if self.isPesable {
            selectQuantityGR = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue),equivalenceByPiece:equivalenceByPiece)
        }
        else {
            selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue))
        }
        selectQuantityGR?.closeAction = { () in
            self.closeContainer({ () -> Void in
                self.productDetailButton.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                }, closeRow:true)
        }
        selectQuantityGR?.generateBlurImage(self.tabledetail,frame:CGRectMake(0,0, self.tabledetail.frame.width, heightDetail))
        selectQuantityGR?.addToCartAction = { (quantity:String) in
            if self.onHandInventory.integerValue >= quantity.toInt() {
                self.closeContainer({ () -> Void in
                    self.productDetailButton.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        
                        self.isShowShoppingCart = false
                        
                        var pesable = self.isPesable ? "1" : "0"
                        
                        var params  =  CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price,quantity: quantity,onHandInventory:"1",pesable:pesable)
                        params.updateValue(comments, forKey: "comments")
                        params.updateValue(self.type, forKey: "type")
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                        
                    }, closeRow:true )
            } else {
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                var secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                
                if self.isPesable {
                    secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                }
                
                
                let msgInventory = "\(firstMessage)\(self.onHandInventory) \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
        }
        selectQuantityGR.addUpdateNote = {() in
            if self.productDetailButton.detailProductCart != nil {
                let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
                var frame = vc!.view.frame
                
                
                let addShopping = ShoppingCartUpdateController()
                let paramsToSC = self.buildParamsUpdateShoppingCart(self.productDetailButton.detailProductCart!.quantity.stringValue) as [String:AnyObject]
                addShopping.params = paramsToSC
                vc!.addChildViewController(addShopping)
                addShopping.view.frame = frame
                vc!.view.addSubview(addShopping.view)
                addShopping.didMoveToParentViewController(vc!)
                addShopping.typeProduct = ResultObjectType.Groceries
                addShopping.comments = self.productDetailButton.detailProductCart!.note!
                addShopping.goToShoppingCart = {() in }
                addShopping.removeSpinner()
                addShopping.addActionButtons()
                addShopping.addNoteToProduct(nil)
            }
            
        }
        if productDetailButton.detailProductCart?.quantity != nil {
            selectQuantityGR?.userSelectValue(productDetailButton.detailProductCart?.quantity.stringValue)
            selectQuantityGR?.first = true
            selectQuantityGR?.showNoteButton()
        }

        
        opencloseContainer(true,viewShow:selectQuantityGR!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton.setOpenQuantitySelector()
            self.selectQuantityGR?.imageBlurView.frame = frameDetail
            self.productDetailButton.addToShoppingCartButton.selected = true
            },additionalAnimationClose:{ () -> Void in
                self.selectQuantityGR?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, self.tabledetail.frame.width, self.heightDetail)
                self.productDetailButton.addToShoppingCartButton.selected = true
            },additionalAnimationFinish: { () -> Void in
                self.productDetailButton.addToShoppingCartButton.setTitleColor(WMColor.navigationTilteTextColor, forState: UIControlState.Normal)
        })
        
    }
    //close new
    
    
    func listSelectorDidShowList(listId: String, andName name:String) {
        if visibleDetailList {
            self.removeDetailListSelector(
                { () -> Void in
                   self.listSelectorDidShowList(listId, andName: name)
            })
            return
        }
        
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.delegate = self
            vc.widthView = self.bannerImagesProducts.frame.width
            vc.addGestureLeft = true
            
            let frameDetail = CGRectMake(-self.bannerImagesProducts.frame.width, 0.0, self.bannerImagesProducts.frame.width, self.productCrossSell.frame.maxY )
            vc.view.frame = frameDetail
            self.view!.addSubview(vc.view)
            detailList = vc
            self.addChildViewController(self.detailList!)
            self.detailList!.didMoveToParentViewController(self)
            self.detailList!.view.clipsToBounds = true
            self.view!.bringSubviewToFront(self.detailList!.view)
            
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.detailList!.view.frame = CGRectMake(0.0, 0.0, self.bannerImagesProducts.frame.width, self.productCrossSell.frame.maxY)
                }, completion: { (finished:Bool) -> Void in
                    self.visibleDetailList = true
                }
            )
        }
    }
    
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil, closeRow:true)
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        NSLog("22")
        let frameDetail = CGRectMake(self.tabledetail.frame.width, 0.0, self.tabledetail.frame.width, heightDetail)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil, closeRow:true)
        }
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            /*if quantity.toInt() == 0 {
                self.listSelectorDidDeleteProduct(inList: listId)
            }
            else {*/
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
            
                var service = GRAddItemListService()
            let pesable =  self.isPesable ? "1" : "0"
            var productObject = service.buildProductObject(upc: self.upc, quantity:quantity.toInt()!,pesable:pesable,active:self.isActive)
                service.callService(service.buildParams(idList: listId, upcs: [productObject]),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                        self.alertView!.showDoneIcon()
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil, closeRow:true)
                    }
                    }, errorBlock: { (error:NSError) -> Void in
                        println("Error at add product to list: \(error.localizedDescription)")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil, closeRow:true)
                    }
                    }
                )
            //}
        }
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(-self.tabledetail.frame.width, 0.0, self.tabledetail.frame.width, self.heightDetail)
                self.selectQuantityGR!.frame = CGRectMake(0.0, 0.0, self.tabledetail.frame.width, self.heightDetail)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
        NSLog("23")
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))
        let detailService = GRUserListDetailService()
        detailService.buildParams(listId)
        detailService.callService([:],
            successBlock: { (result:NSDictionary) -> Void in
                var service = GRDeleteItemListService()
                service.callService(service.buildParams(self.upc),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
                        self.alertView!.showDoneIcon()
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil, closeRow:true)
                        }
                    }, errorBlock: { (error:NSError) -> Void in
                        println("Error at remove product from list: \(error.localizedDescription)")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil, closeRow:true)
                        }
                    }
                )
            },
            errorBlock: { (error:NSError) -> Void in
                println("Error at retrieve list detail")
            }
        )
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
        let frameDetail = CGRectMake(self.tabledetail.frame.width, 0.0,  self.tabledetail.frame.width, heightDetail)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil, closeRow:true)
        }
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            var detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
            detail!.upc = self.upc
            detail!.desc = self.name
            detail!.price = self.price
            detail!.quantity = NSNumber(integer: quantity.toInt()!)
            detail!.type = NSNumber(bool: self.isPesable)
            detail!.list = list
            if self.imageUrl.count > 0 {
                detail!.img = self.imageUrl[0] as NSString
            }
            var error: NSError? = nil
            context.save(&error)
            if error != nil {
                println(error!.localizedDescription)
            }
            var count:Int = list.products.count
            list.countItem = NSNumber(integer: count)
            error = nil
            context.save(&error)
            if error != nil {
                println(error!.localizedDescription)
            }
            self.removeListSelector(action: nil, closeRow:true)
        }
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(-self.tabledetail.frame.width, 0.0, self.tabledetail.frame.width, self.heightDetail)
                self.selectQuantityGR!.frame = CGRectMake(0.0, 0.0, self.tabledetail.frame.width, self.heightDetail)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
    }
    
    
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        context.deleteObject(product)
        var error: NSError? = nil
        context.save(&error)
        if error != nil {
            println(error!.localizedDescription)
        }
        var count:Int = list.products.count
        list.countItem = NSNumber(integer: count)
        error = nil
        context.save(&error)
        if error != nil {
            println(error!.localizedDescription)
        }
        self.removeListSelector(action: nil, closeRow:true)
    }
    
    func instanceOfQuantitySelector(frame:CGRect) -> GRShoppingCartQuantitySelectorView? {
        var instance: GRShoppingCartQuantitySelectorView? = nil
        if self.isPesable {
            instance = GRShoppingCartWeightSelectorView(frame: frame, priceProduct: NSNumber(double:self.price.doubleValue),equivalenceByPiece:equivalenceByPiece)
        } else {
            instance = GRShoppingCartQuantitySelectorView(frame: frame, priceProduct: NSNumber(double:self.price.doubleValue))
        }
        return instance
    }

    
    func listSelectorDidShowListLocally(list: List) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = list.idList
            vc.listName = name
            vc.listEntity = list
            vc.delegate = self
            vc.widthView = self.bannerImagesProducts.frame.width
            vc.addGestureLeft = true
            
            let frameDetail = CGRectMake(-self.bannerImagesProducts.frame.width, 0.0, self.bannerImagesProducts.frame.width, self.productCrossSell.frame.maxY )
            
            vc.view.frame = frameDetail
            self.view!.addSubview(vc.view)
            detailList = vc
            self.addChildViewController(self.detailList!)
            self.detailList!.didMoveToParentViewController(self)
            self.detailList!.view.clipsToBounds = true
            self.view!.bringSubviewToFront(self.detailList!.view)
            
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                   
                      self.detailList!.view.frame = CGRectMake(0.0, 0.0, self.bannerImagesProducts.frame.width, self.productCrossSell.frame.maxY )
                    
                }, completion: { (finished:Bool) -> Void in
                     self.visibleDetailList = true
                }
            )
        }
    }
    
    
    func shouldDelegateListCreation() -> Bool {
        return false
    }
    
    func listSelectorDidCreateList(name:String) {
        
    }
    
    //MARK: - IPAUserListDetailDelegate
    func showProductListDetail(fromProducts products:[AnyObject], indexSelected index:Int) {
        var controller = IPAProductDetailPageViewController()
        controller.ixSelected = index
        controller.itemsToShow = products
        self.pagerController!.navigationController?.delegate = self
        self.pagerController!.navigationController?.pushViewController(controller, animated: true)
    }

    
    func reloadTableListUser() {
        if (self.listSelectorController  != nil) {
            self.listSelectorController!.loadLocalList()
        }
    }
    
    func closeUserListDetail() {
        self.removeDetailListSelector(nil)
    }
    
    override func removeListSelector(#action:(()->Void)?, closeRow:Bool ) {
        if visibleDetailList {
            self.removeDetailListSelector(
                { () -> Void in
                    self.removeListSelector(action: action?, closeRow:true)
                })
        }else {
            super.removeListSelector(action: action?, closeRow:true)
        }
        
    }

    
    
    func removeDetailListSelector(#action:(()->Void)?) {
        NSLog("27")
        if visibleDetailList {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.detailList!.view.frame =  CGRectMake(-self.bannerImagesProducts.frame.width, 0.0, self.self.bannerImagesProducts.frame.width, self.productCrossSell.frame.maxY )
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        if self.detailList != nil {
                            //self.detailList!.willMoveToParentViewController(nil)
                            self.detailList!.view.removeFromSuperview()
                            self.detailList!.removeFromParentViewController()
                        }
                        self.detailList = nil
                        self.visibleDetailList = false
                        
                        action?()
                        
                    }
                }
            )
            
        }else {
            action?()
        }
        
    }
    

func buildParamsUpdateShoppingCart(quantity:String) -> [NSObject:AnyObject] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as NSString
        }
        var pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"comments":self.comments,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
    }
    
    
    //Info nutrimental
    
    override func showProductDetail() {
        if visibleDetailList {
            self.removeDetailListSelector(
                { () -> Void in
                    self.showProductDetail()
            })
        }
        else {
            super.showProductDetail()
        }
    }
    
    override func openProductDetail() {
        if self.nutrmentals.count == 0 {
            super.openProductDetail()
        } else {
            
            isShowProductDetail = true
            let frameDetail = CGRectMake(0,0, self.tabledetail.frame.width, heightDetail)
            nutrimentalsView  = GRNutrimentalInfoView(frame: frameDetail)
            nutrimentalsView?.setup(ingredients, nutrimentals: self.nutrmentals)
            nutrimentalsView?.generateBlurImage(self.tabledetail,frame:CGRectMake(0,0, self.tabledetail.frame.width, heightDetail))
            nutrimentalsView?.imageBlurView.frame =  CGRectMake(0, -heightDetail, self.tabledetail.frame.width, heightDetail)
            nutrimentalsView?.closeDetail = {() in
                self.closeContainer({ () -> Void in
                    },completeClose:{() in
                        self.isShowProductDetail = false
                        self.productDetailButton.deltailButton.selected = false
                    }, closeRow:true)
            }
            opencloseContainer(true,viewShow:nutrimentalsView!, additionalAnimationOpen: { () -> Void in
                self.nutrimentalsView?.imageBlurView.frame = frameDetail
                self.productDetailButton.deltailButton.selected = true
                self.productDetailButton.reloadShoppinhgButton()
                },additionalAnimationClose:{ () -> Void in
                    self.nutrimentalsView?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail, self.tabledetail.frame.width, self.heightDetail)
                    self.productDetailButton.deltailButton.selected = true
            })
            
        }
        
    }
    
    func endUpdatingShoppingCart(sender:AnyObject) {
        self.productDetailButton.reloadShoppinhgButton()
    }
    
    
    override func cellForPoint(point:(Int,Int),indexPath: NSIndexPath) -> UITableViewCell? {
        var cell : UITableViewCell? = nil
        switch point {
       
        case (0,1) :
            let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
            cell = cellSpace
        case (0,3) :
            if self.saving != ""{
                let cellAhorro = tabledetail.dequeueReusableCellWithIdentifier("priceCell", forIndexPath: indexPath) as? ProductDetailCurrencyCollectionView
                var savingSend = self.saving
                let doubleVaule = self.saving.doubleValue
                if doubleVaule > 0 {
                    let savingStr = NSLocalizedString("price.saving",comment:"")
                    let formated = CurrencyCustomLabel.formatString("\(savingSend)")
                    savingSend = "\(savingStr) \(formated)"
                }
                
                cellAhorro!.setValues(savingSend, font: WMFont.fontMyriadProSemiboldOfSize(14), textColor: WMColor.savingTextColor, interLine: false)
                cell = cellAhorro
               
            } else{
                let cellSpace = tabledetail.dequeueReusableCellWithIdentifier("emptyCell", forIndexPath: indexPath) as? UITableViewCell
                cell = cellSpace
            }
        default :
            return super.cellForPoint(point, indexPath: indexPath)
        }
        return cell
    }
    
    override func sleectedImage(indexPath:NSIndexPath) {
        var controller = ImageDisplayCollectionViewController()
        controller.name = self.name
        
        var imagesLarge : [String] = []
        for image in imageUrl {
            var imgLarge = NSString(string: image as String)
            imgLarge = imgLarge.stringByReplacingOccurrencesOfString("img_small", withString: "img_large")
            let pathExtention = imgLarge.pathExtension
            let imageurl = imgLarge.stringByReplacingOccurrencesOfString("s.\(pathExtention)", withString: "l.\(pathExtention)")
            imagesLarge.append(imageurl)
        }
        
        controller.imagesToDisplay = imagesLarge
        controller.currentItem = indexPath.row
        controller.type = self.type
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }

    
   
}