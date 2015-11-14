//
//  GRProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class GRProductDetailViewController : ProductDetailViewController, ListSelectorDelegate {
    
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var listSelectorContainer: UIView?
    var listSelectorBackgroundView: UIImageView?
    var listSelectorController: ListsSelectorViewController?
    var alertView: IPOWMAlertViewController?
   
    
    var nutrmentals : [String]!
    var ingredients : String!
    var nutrimentalsView : GRNutrimentalInfoView? = nil
    
    
    var equivalenceByPiece : NSNumber! = NSNumber(int:0)
    var stock : Bool! = true
    var idFamily: String = ""
    var idLine : String =  ""
    var idDepartment: String = ""
    
    override func loadDataFromService() {
        
        self.type = ResultObjectType.Groceries
    
        let productService = GRProductDetailService()
        productService.callService(requestParams:upc, successBlock: { (result: NSDictionary) -> Void in
            
            //println("ResultGr \(result)")
            
            
            self.name = result["description"] as! NSString
            if let priceR =  result["price"] as? NSNumber {
                self.price = "\(priceR)"
            }

            self.detail = result["longDescription"] as! NSString
            
            if let savingResult = result["promoDescription"] as? NSString {
                if savingResult != "" {
                    self.saving = result["promoDescription"] as! NSString
                }
            }
            //self.listPrice = result["original_listprice"] as NSString
            self.characteristics = []
            var allCharacteristics : [AnyObject] = []
            
            let strLabel = "UPC"
            //let strValue = self.upc
            allCharacteristics.append(["label":strLabel,"value":self.upc])
            
            if var carStr = result["characteristics"] as? String {
                carStr = carStr.stringByReplacingOccurrencesOfString("^", withString: "\n")
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
            if let images = result["imageUrl"] as? [AnyObject] {
                self.imageUrl = images
            }
            if let images = result["imageUrl"] as? NSString {
                var imgLarge = NSString(string: images)
                imgLarge = imgLarge.stringByReplacingOccurrencesOfString("img_small", withString: "img_large")
                let pathExtention = imgLarge.pathExtension
                imgLarge = imgLarge.stringByReplacingOccurrencesOfString("s.\(pathExtention)", withString: "l.\(pathExtention)")
                self.imageUrl = [imgLarge]
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
            if let department = result["department"] as? NSDictionary {
                self.idDepartment = department["idDepto"] as! String
            }

            if let family = result["family"] as? NSDictionary {
                self.idFamily = family["id"] as! String
            }
            
            if let line = result["line"] as? NSDictionary {
                self.idLine = line["id"] as! String
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
            
            self.bundleItems = [AnyObject]()
            if let bndl = result["bundleItems"] as?  [AnyObject] {
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
            
            self.isLoading = false
            self.detailCollectionView.reloadData()
            
            self.viewLoad.stopAnnimating()  
            self.detailCollectionView.scrollEnabled = true
            self.gestureCloseDetail.enabled = false
            
            self.titlelbl.text = self.name as String
            
            //Nutrimental
            self.ingredients = ""
            self.nutrmentals = []
            if let ingredientsInfo = result["ingredients"] as? String{
                self.ingredients = ingredientsInfo
            }
            if let nutrimentalArray = result["nutritional"] as? [String] {
                self.nutrmentals = nutrimentalArray
            }
            
            
            
            self.loadCrossSell()
            
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
           
            
            if let tracker = GAI.sharedInstance().defaultTracker {
                
                let product = GAIEcommerceProduct()
                let builder = GAIDictionaryBuilder.createScreenView()
                product.setId(self.upc as String)
                product.setName(self.name as String)
                
                let action = GAIEcommerceProductAction();
                action.setAction(kGAIPADetail)
                builder.setProductAction(action)
                builder.addProduct(product)
                
                tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue)
                tracker.send(builder.build() as [NSObject : AnyObject])
                
            }
            
            },errorBlock: { (error:NSError) -> Void in
                let empty = IPOGenericEmptyView(frame:CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
                self.name = NSLocalizedString("empty.productdetail.title",comment:"")
                empty.returnAction = { () in
                    print("")
                    self.navigationController!.popViewControllerAnimated(true)
                }
                self.view.addSubview(empty)
                self.viewLoad.stopAnnimating()
        })
    }
    
   
    //MARK: - UICollectionView
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) 
            
            let productDetailButtonGR = GRProductDetailButtonBarCollectionViewCell(frame: CGRectMake(0, 0, self.view.frame.width, 56.0))
            productDetailButtonGR.upc = self.upc as String
            productDetailButtonGR.desc = self.name as String
            productDetailButtonGR.price = self.price as String
            productDetailButtonGR.isPesable  = self.isPesable
            productDetailButtonGR.isActive = isActive == true ? self.strisActive! : "false"
            productDetailButtonGR.onHandInventory = self.onHandInventory as String
            productDetailButtonGR.isPreorderable = self.strisPreorderable
            productDetailButtonGR.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButtonGR.validateIsInList(self.upc as String)
            productDetailButton = productDetailButtonGR
            
            //productDetailButton.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCWishlist(self.upc)
            
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton.image = imageUrl
            productDetailButton.delegate = self
            view.addSubview(productDetailButton)
            
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
        
    }

    
    //MARK: -  ProductDetailButtonBarCollectionViewCellDelegate

    override func addOrRemoveToWishList(upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,added:(Bool) -> Void) {

        if self.selectQuantityGR != nil {
            self.closeContainer(
                { () -> Void in
                    self.productDetailButton.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                    self.selectQuantityGR = nil
                    self.addOrRemoveToWishList(upc, desc: desc, imageurl: imageurl, price: price, addItem: addItem, isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable, added: added)
                }
            )
            return
        }
        
        //Event
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ADD_TO_LIST.rawValue, label: "\(self.name) - \(self.upc)")


        

        if self.listSelectorController == nil {
            self.listSelectorContainer = UIView(frame: CGRectMake(0, 360.0, 320.0, 0.0))
            self.listSelectorContainer!.clipsToBounds = true
            self.view.addSubview(self.listSelectorContainer!)
            
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            self.listSelectorController!.productUpc = self.upc as String
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRectMake(0.0, 0.0, 320.0, 360.0)
            self.listSelectorContainer!.addSubview(self.listSelectorController!.view)
            self.listSelectorController!.didMoveToParentViewController(self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorBackgroundView = self.listSelectorController!.createBlurImage(self.view, frame: CGRectMake(0, 0, 320, 360))
            self.listSelectorContainer!.insertSubview(self.listSelectorBackgroundView!, atIndex: 0)
            
            let bg = UIView(frame: CGRectMake(0.0, 0.0, 320.0, 360.0))
            bg.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
            self.listSelectorContainer!.insertSubview(bg, aboveSubview: self.listSelectorBackgroundView!)
            
            self.detailCollectionView.scrollEnabled = false
            UIView.animateWithDuration(0.3,
                animations: { () -> Void in
                    self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height), animated: false)
                },
                completion: { (complete:Bool) -> Void in
                    if complete {
                        self.listSelectorBackgroundView!.frame = CGRectMake(0, -360.0, 320.0, 360.0)
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.listSelectorContainer!.frame = CGRectMake(0, 0, 320, 360)
                            self.listSelectorBackgroundView!.frame = CGRectMake(0, 0, 320, 360)
                            self.listSelectorController!.view.frame = CGRectMake(0.0, 0.0, 320.0, 360.0)
                        })
                    }
            })
        }
        else {
            self.removeListSelector(action: nil)
        }

    }
    
    override func addProductToShoppingCart(upc:String,desc:String,price:String,imageURL:String, comments:String )
    {
        
//        let sb = UIStoryboard(name: "WeightPiceKeyboard", bundle: nil)
//        let vc = sb.instantiateInitialViewController() as UIViewController
//        
//        vc.view.frame = CGRectMake(0, 0, self.view.frame.width, 360)
//        self.addChildViewController(vc)
//        self.view.addSubview(vc.view)
        
        
        
        self.comments = comments
        if selectQuantityGR == nil {
            
            if self.listSelectorController != nil {
                self.removeListSelector(action: { () -> Void in
                    self.addProductToShoppingCart(upc, desc: desc, price: price, imageURL: imageURL,comments:comments  )
                })
                return
            }
            
            let frameDetail = CGRectMake(0,0, self.detailCollectionView.frame.width, heightDetail)
            if self.isPesable {
                let selectQuantityGRW = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue),equivalenceByPiece:equivalenceByPiece,upcProduct:self.upc as String)
                selectQuantityGR = selectQuantityGRW
            }else{
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:self.price.doubleValue),upcProduct:self.upc as String)
            }
            selectQuantityGR?.closeAction = { () in
                self.closeContainer({ () -> Void in
                    self.productDetailButton.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        self.isShowShoppingCart = false
                            self.selectQuantityGR = nil
                        //self.tabledetail.deleteRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Top)
                })
            }
            selectQuantityGR.addUpdateNote = {() in
                if self.productDetailButton.detailProductCart != nil {
                    let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
                    let frame = vc!.view.frame
                    
                    
                    let addShopping = ShoppingCartUpdateController()
                    let paramsToSC = self.buildParamsUpdateShoppingCart(self.productDetailButton.detailProductCart!.quantity.stringValue) as! [String:AnyObject]
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
            selectQuantityGR?.generateBlurImage(self.detailCollectionView,frame:CGRectMake(0,0, self.detailCollectionView.frame.width, heightDetail))
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                
                if self.onHandInventory.integerValue >= Int(quantity) {
                    self.closeContainer({ () -> Void in
                        self.productDetailButton.reloadShoppinhgButton()
                        }, completeClose: { () -> Void in
                            
                            self.isShowShoppingCart = false
                            //self.tabledetail.deleteRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Top)
                            let params = self.buildParamsUpdateShoppingCart(quantity)
                            BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.GR_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_ADD_TO_SHOPPING_CART.rawValue, label: self.name as String)
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
                            
                    })
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
            
            self.opencloseContainer(true, viewShow:selectQuantityGR!,
                additionalAnimationOpen: { () -> Void in
                    self.productDetailButton.setOpenQuantitySelector()
                    self.selectQuantityGR?.imageBlurView.frame = frameDetail
                    self.productDetailButton.addToShoppingCartButton.selected = true
                },
                additionalAnimationClose:{ () -> Void in
                    self.selectQuantityGR?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail,
                    self.detailCollectionView.frame.width, self.heightDetail)
                    self.productDetailButton.addToShoppingCartButton.selected = true
                }
            )
        }else{
            self.closeContainerDetail()
        }

    }

    override func closeContainerDetail() {
        if selectQuantityGR != nil {
            self.closeContainer({ () -> Void in
                
                
                
                self.productDetailButton.reloadShoppinhgButton()
//                UserCurrentSession.sharedInstance().loadGRShoppingCart
//                    { () -> Void in
//                        self.productDetailButton.reloadShoppinhgButton()
//                }
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantityGR = nil
            })
        }else{
            UserCurrentSession.sharedInstance().loadGRShoppingCart
                { () -> Void in
                    if self.productDetailButton != nil {
                        self.productDetailButton.reloadShoppinhgButton()
                    }
            }
        }
    }
    
    func instanceOfQuantitySelector(frame:CGRect) -> GRShoppingCartQuantitySelectorView? {
        var instance: GRShoppingCartQuantitySelectorView? = nil
        if self.isPesable {
            instance = GRShoppingCartWeightSelectorView(frame: frame, priceProduct: NSNumber(double:self.price.doubleValue),equivalenceByPiece:equivalenceByPiece,upcProduct:self.upc as String)
        } else {
            instance = GRShoppingCartQuantitySelectorView(frame: frame, priceProduct: NSNumber(double:self.price.doubleValue),upcProduct:self.upc as String)
        }
        return instance
    }
    
    //MARK: - ListSelectorDelegate
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
        
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, action: WMGAIUtils.ACTION_CANCEL_ADD_TO_LIST.rawValue, label: "")
        
    }

    func listSelectorDidAddProduct(inList listId:String) {
        let frameDetail = CGRectMake(320.0, 0.0, 320.0, 360.0)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil)
        }
        
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            /*if quantity.toInt() == 0 {
                self.listSelectorDidDeleteProduct(inList: listId)
            }
            else {*/
            if Int(quantity) <= 20000 {
            
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
            
                let service = GRAddItemListService()
                let pesable = self.isPesable ? "1" : "0"
                let productObject = service.buildProductObject(upc: self.upc as String, quantity:Int(quantity)!,pesable:pesable,active:self.isActive)
                service.callService(service.buildParams(idList: listId, upcs: [productObject]),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action: WMGAIUtils.ACTION_ADD_TO_LIST.rawValue, label:"\(self.name) \(self.upc) ")
                        
                        self.alertView!.showDoneIcon()
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil)
                        }
                    }, errorBlock: { (error:NSError) -> Void in
                        print("Error at add product to list: \(error.localizedDescription)")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil)
                        }
                    }
                )
                
            }else{
                
                let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                let secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                let msgInventory = "\(firstMessage) 20000 \(secondMessage)"
                alert!.setMessage(msgInventory)
                alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
            }
            
            //}
        }
        
        //--
        
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(-320.0, 0.0, 320.0, 360.0)
                self.selectQuantityGR!.frame = CGRectMake(0.0, 0.0, 320.0, 360.0)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))

        let detailService = GRUserListDetailService()
        detailService.buildParams(listId)
        detailService.callService([:],
            successBlock: { (result:NSDictionary) -> Void in
                let service = GRDeleteItemListService()
                service.callService(service.buildParams(self.upc as String),
                    successBlock: { (result:NSDictionary) -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
                        self.alertView!.showDoneIcon()
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil)
                        }
                        //Event
                        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_MYLIST.rawValue, label: "\(self.name) - \(self.upc)")
                        
                    }, errorBlock: { (error:NSError) -> Void in
                        print("Error at remove product from list: \(error.localizedDescription)")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil)
                        }
                    }
                )
            },
            errorBlock: { (error:NSError) -> Void in
                print("Error at retrieve list detail")
            }
        )
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
        
        let frameDetail = CGRectMake(320.0, 0.0, 320.0, 360.0)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.closeAction = { () in
            self.removeListSelector(action: nil)
        }
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            
            let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
            detail!.upc = self.upc as String
            detail!.desc = self.name as String
            detail!.price = self.price
            detail!.quantity = NSNumber(integer: Int(quantity)!)
            detail!.type = NSNumber(bool: self.isPesable)
            detail!.list = list
            
            if self.imageUrl.count > 0 {
                detail!.img = self.imageUrl[0] as! NSString as String
            }
            
            BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue , action:WMGAIUtils.ACTION_ADD_TO_LIST.rawValue , label:"\(self.name as String) \(self.upc as String)")
            

            var error: NSError? = nil
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
            if error != nil {
                print(error!.localizedDescription)
            }

            let count:Int = list.products.count
            list.countItem = NSNumber(integer: count)

            error = nil
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
            if error != nil {
                print(error!.localizedDescription)
            }

            self.removeListSelector(action: nil)
            
            //TODO: Add message
            self.showMessageWishList("Se agregó a la lista")
            
            self.productDetailButton.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc as String)
            
            
        }
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(-320.0, 0.0, 320.0, 360.0)
                self.selectQuantityGR!.frame = CGRectMake(0.0, 0.0, 320.0, 360.0)
            }, completion: { (finished:Bool) -> Void in
                
            }
        )
    }
    
    func showMessageWishList(message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRectMake(self.detailCollectionView.frame.minX, self.detailCollectionView.frame.minY +  314, self.detailCollectionView.frame.width, 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRectMake(self.detailCollectionView.frame.minX, 270, self.detailCollectionView.frame.width, 44))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRectMake(self.detailCollectionView.frame.minX, 0, self.detailCollectionView.frame.width, 44)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRectMake(self.detailCollectionView.frame.minX,self.detailCollectionView.frame.minY + 270, self.detailCollectionView.frame.width, 96)
            }) { (complete:Bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    addedAlertWL.frame = CGRectMake(addedAlertWL.frame.minX, self.detailCollectionView.frame.minY + 314.0, addedAlertWL.frame.width, 0)
                    }) { (complete:Bool) -> Void in
                        self.detailCollectionView.scrollEnabled = true
                        addedAlertWL.removeFromSuperview()
                }
        }
        
        
    }
    
    
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        context.deleteObject(product)
        do {
            try context.save()
        } catch {
            abort()
        }

        let count:Int = list.products.count
        list.countItem = NSNumber(integer: count)
        do {
            try context.save()
        } catch  {
            abort()
        }

        self.removeListSelector(action: nil)
        
    }

    
    func removeListSelector(action action:(()->Void)?) {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height), animated: false)
            },
            completion: { (complete:Bool) -> Void in
                if complete {
                    UIView.animateWithDuration(0.5,
                        delay: 0.0,
                        options: .LayoutSubviews,
                        animations: { () -> Void in
                            self.listSelectorContainer!.frame = CGRectMake(0, 360.0, 320.0, 0.0)
                            self.listSelectorBackgroundView!.frame = CGRectMake(0, -360.0, 320.0, 360.0)
                        }, completion: { (complete:Bool) -> Void in
                            if complete {
                                self.listSelectorController!.willMoveToParentViewController(nil)
                                self.listSelectorController!.view.removeFromSuperview()
                                self.listSelectorController!.removeFromParentViewController()
                                self.listSelectorController = nil
                                
                                self.listSelectorBackgroundView!.removeFromSuperview()
                                self.listSelectorBackgroundView = nil
                                self.listSelectorContainer!.removeFromSuperview()
                                self.listSelectorContainer = nil
                                
                                //self.productDetailButton!.listButton.selected = false
                                self.productDetailButton.listButton.selected = UserCurrentSession.sharedInstance().userHasUPCUserlist(self.upc as String)
                                
                                action?()
                                self.detailCollectionView.scrollEnabled = true
                            }
                        }
                    )
                }
        })
    }
    
    
    func listSelectorDidShowList(listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(list: List) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func shouldDelegateListCreation() -> Bool {
        return false
    }
    
    func listSelectorDidCreateList(name:String) {
        
    }

    
    //MARK: -
    
    override func buildParamsUpdateShoppingCart(quantity:String) -> [NSObject:AnyObject] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"comments":self.comments,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable]
    }
    
  
    
    
    
    //Info nutrimental
    
    override func showProductDetail() {
        
        if isShowShoppingCart {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRectMake(0, 360, 320, 0)
                self.selectQuantity!.imageBlurView.frame = CGRectMake(0, -360, 320, 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.scrollEnabled = true
                        self.gestureCloseDetail.enabled = false
                    }
            })
        }

        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_INFORMATION.rawValue, label: "\(name) - \(upc)")
        
        self.detailCollectionView.scrollsToTop = true
        self.detailCollectionView.scrollEnabled = false
        gestureCloseDetail.enabled = true
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.detailCollectionView.scrollRectToVisible(CGRectMake(0, 0, self.detailCollectionView.frame.width,  self.detailCollectionView.frame.height ), animated: false)
            }, completion: { (complete:Bool) -> Void in
                if self.viewDetail == nil && self.nutrimentalsView == nil {
                    self.isShowProductDetail = true
                    self.startAnimatingProductDetail()
                } else {
                    self.closeProductDetail()
                    
                }
        })
        
        
    }
    
    override func startAnimatingProductDetail() {
        if self.nutrmentals.count == 0 {
            super.startAnimatingProductDetail()
        } else {
            
            let finalFrameOfQuantity = CGRectMake(0, 0, 320, 360)
            if nutrimentalsView == nil {
                nutrimentalsView = GRNutrimentalInfoView(frame: CGRectMake(0,360, 320, 0))
                nutrimentalsView?.setup(ingredients, nutrimentals: self.nutrmentals)
                nutrimentalsView!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            }
            
            nutrimentalsView!.frame = CGRectMake(0,360, 320, 0)
            self.nutrimentalsView!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
            

            nutrimentalsView!.closeDetail = { () in
                self.closeProductDetailNutrimental()
            }
            self.view.addSubview(nutrimentalsView!)
            
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.nutrimentalsView!.frame = finalFrameOfQuantity
                self.nutrimentalsView!.imageBlurView.frame = finalFrameOfQuantity
                //self.viewDetail.frame = CGRectMake(0, 0, self.tabledetail.frame.width, self.tabledetail.frame.height - 145)
                self.productDetailButton.deltailButton.selected = true
            })
            
        }
        
    }
    
    func closeProductDetailNutrimental () {
        if isShowProductDetail == true {
            isShowProductDetail = false
            gestureCloseDetail.enabled = false
            self.detailCollectionView.scrollEnabled = true
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.nutrimentalsView!.imageBlurView.frame =  CGRectMake(0, -360, 320, 360)
                self.nutrimentalsView!.frame = CGRectMake(0,360, 320, 0)
                }) { (ended:Bool) -> Void in
                    if self.nutrimentalsView != nil {
                        self.nutrimentalsView!.removeFromSuperview()
                        self.nutrimentalsView = nil
                        
                        
                        self.productDetailButton.deltailButton.selected = false
                    }
            }
        }
    }
    
    override func closeProductDetail () {
        if isShowProductDetail == true {
            if viewDetail ==  nil {
                    closeProductDetailNutrimental()
            }else {
                super.closeProductDetail()
            }
            
        }
    }
    
    override func loadCrossSell() {
        NSLog("lcs 1")
        let service = GRProductBySearchService()
        let params = service.buildParamsForSearch(text: "", family: self.idFamily, line: self.idLine, sort: FilterType.descriptionAsc.rawValue, departament: self.idDepartment, start: 0, maxResult: 6,brand:"")
        service.callService(params,
            successBlock: { (arrayProduct:NSArray?) -> Void in
                NSLog("lcs 2")
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    NSLog("lcs 2")
                    var keywords = Array<AnyObject>()
                    for item in arrayProduct as! [AnyObject] {
                        
                        if self.upc !=  item["upc"] as! String {
                            
                            var urlArray : [String] = []
                            urlArray.append(item["imageUrl"] as! String)
                            
                            var price : NSString = ""
                            if let value = item["price"] as? String {
                                price = value
                            }
                            else if let value = item["price"] as? NSNumber {
                                price = "\(value)"
                            }
                            
                            keywords.append(["codeMessage":"0","description":item["description"] as! String, "imageUrl":urlArray, "price" : price,  "upc" :item["upc"], "type" : ResultObjectType.Groceries.rawValue ])
                        }
                        
                        if keywords.count == 5 {
                            break
                        }
                    }
                    self.itemsCrossSellUPC = keywords
                    if self.itemsCrossSellUPC.count > 0{
                         self.showCrossSell()
                    }
                }
                
            }, errorBlock: {(error: NSError) in
                print(error)
                
            }
        )
    }
    
    // MARK: - Collection view config
   override func goTODetailProduct(upc:String,items:[[String:String]],index:Int,imageProduct:UIImage?,point:CGRect) {
        let controller = ProductDetailPageViewController()
        controller.ixSelected = index
        controller.itemsToShow = []
        for product  in items {
            let upc : NSString = product["upc"]!
            let desc : NSString = product["description"]!
            let type : NSString = ResultObjectType.Groceries.rawValue
            controller.itemsToShow.append(["upc":upc,"description":desc,"type":type])
        }
        self.navigationController!.pushViewController(controller, animated: true)
    }

    
}