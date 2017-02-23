//
//  GRProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/22/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import FBSDKCoreKit
import Foundation
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class GRProductDetailViewController : ProductDetailViewController, ListSelectorDelegate {
  
    var selectQuantityGR : GRShoppingCartQuantitySelectorView!
    var listSelectorContainer: UIView?
    var listSelectorController: ListsSelectorViewController?
    var alertView: IPOWMAlertViewController?
   
    
    var nutrmentals : [String]!
    var ingredients : String!
    var nutrimentalsView : GRNutrimentalInfoView? = nil
    
    
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    var stock : Bool! = true
    var idFamily: String = ""
    var idLine : String =  ""
    var idDepartment: String = ""
    
    override func loadDataFromService() {
        
        print("parametro para signals GR Iphone :::\(self.indexRowSelected)")
        
        self.type = ResultObjectType.Groceries
        let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let productService = GRProductDetailService(dictionary:signalsDictionary )
        let eventType = self.fromSearch ? "clickdetails" : "pdpview"
        let params = productService.buildParams(upc as String,eventtype:eventType,stringSearch: self.stringSearching,position:"\(self.indexRowSelected)")//position
        productService.callService(requestParams:params, successBlock: { (result: [String:Any]) -> Void in
            
            
            self.name = result["description"] as! NSString
            if let priceR =  result["price"] as? NSNumber {
                self.price = "\(priceR)" as NSString
            }

            self.baseUomcd = result["baseUomcd"] as! String// new
            
            self.detail = result["longDescription"] as! NSString
            
            if let savingResult = result["promoDescription"] as? NSString {
                if savingResult != "" {
                    self.saving = result["promoDescription"] as! NSString
                }
            }
            //self.listPrice = result["original_listprice"] as NSString
            self.characteristics = []
            var allCharacteristics : [[String:Any]] = []
            
            let strLabel = "UPC"
            //let strValue = self.upc
            allCharacteristics.append(["label":strLabel,"value":self.upc])
            
            if var carStr = result["characteristics"] as? String {
                carStr = carStr.replacingOccurrences(of: "^", with: "\n")
                allCharacteristics.append(["label":"Características","value":carStr])
            }
            
            for characteristic in self.characteristics  {
                allCharacteristics.append(characteristic)
            }
            self.characteristics = allCharacteristics
            
            if let msiResult =  result["msi"] as? NSString {
                if msiResult != "" {
                    self.msi = msiResult.components(separatedBy: ",")
                }else{
                    self.msi = []
                }
            }
            if let images = result["imageUrl"] as? [Any] {
                self.imageUrl = images
            }
            if let images = result["imageUrl"] as? NSString {
                var imgLarge = NSString(string: images)
                imgLarge = imgLarge.replacingOccurrences(of: "img_small", with: "img_large") as NSString
                let pathExtention = imgLarge.pathExtension
                imgLarge = imgLarge.replacingOccurrences(of: "s.\(pathExtention)", with: "L.\(pathExtention)") as NSString
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
            if let department = result["department"] as? [String:Any] {
                self.idDepartment = department["idDepto"] as! String
            }

            if let family = result["family"] as? [String:Any] {
                self.idFamily = family["id"] as! String
            }
            
            if let line = result["line"] as? [String:Any] {
                self.idLine = line["id"] as! String
            }
            
            if let equivalence = result["equivalenceByPiece"] as? NSNumber {
                self.equivalenceByPiece = equivalence
            }
            
            if let equivalence = result["equivalenceByPiece"] as? NSString {
                if equivalence != "" {
                    self.equivalenceByPiece =  NSNumber(value: equivalence.intValue as Int32)
                }
            }
            
            self.strisPreorderable  = "false"
            self.isPreorderable = false//"true" == self.strisPreorderable
            
            self.bundleItems = [[String:Any]]()
            if let bndl = result["bundleItems"] as?  [[String:Any]] {
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
            self.detailCollectionView.isScrollEnabled = true
            self.gestureCloseDetail.isEnabled = false
            
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
            
            //NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
            
            //FACEBOOKLOG
            FBSDKAppEvents.logEvent(FBSDKAppEventNameViewedContent, valueToSum:self.price.doubleValue, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productgr",FBSDKAppEventParameterNameContentID:self.upc])
            
            //Analitics
            let linea = result["linea"] as? String ?? ""
            BaseController.sendAnalyticsPush(["event":"interaccionFoto", "category" : self.productDeparment, "subCategory" :"", "subsubCategory" :linea])
            
            let isBundle = result["isBundle"] as? Bool ?? false
            if self.detailOf == "" {
                fatalError("detailOf not seted")
            }
            
            BaseController.sendAnalyticsPush(["event": "productClick","ecommerce":["click":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": self.isPesable ? "gramos" : "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
            
            BaseController.sendAnalyticsPush(["event": "ecommerce","ecommerce":["detail":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": self.isPesable ? "gramos" : "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
            
            
            },errorBlock: { (error:NSError) -> Void in
                let empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
                self.name = NSLocalizedString("empty.productdetail.title",comment:"") as NSString
                empty.returnAction = { () in
                    print("")
                    self.navigationController!.popViewController(animated: true)
                }
                self.view.addSubview(empty)
                self.viewLoad.stopAnnimating()
        })
    }
    
   
    //MARK: - UICollectionView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let view = detailCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) 
            
            let productDetailButtonGR = GRProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56.0))
            productDetailButtonGR.upc = self.upc as String
            productDetailButtonGR.desc = self.name as String
            productDetailButtonGR.price = self.price as String
            productDetailButtonGR.isPesable  = self.isPesable
            productDetailButtonGR.isActive = isActive == true ? self.strisActive! : "false"
            productDetailButtonGR.onHandInventory = self.onHandInventory as String
            productDetailButtonGR.isPreorderable = self.strisPreorderable
            productDetailButtonGR.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButtonGR.validateIsInList(self.upc as String)
            productDetailButtonGR.idListSelect =  self.idListFromlistFind
            productDetailButton = productDetailButtonGR
            
            //productDetailButton.listButton.selected = UserCurrentSession.sharedInstance.userHasUPCWishlist(self.upc)
            
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButton!.image = imageUrl
            productDetailButton!.delegate = self
            view.addSubview(productDetailButton!)
            
            return view
        }
        
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        
    }

    
    //MARK: -  ProductDetailButtonBarCollectionViewCellDelegate

    override func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:@escaping (Bool) -> Void) {
        self.closeProductDetail()
        if self.selectQuantityGR != nil {
            self.closeContainer(
                { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                    self.selectQuantityGR = nil
                    self.addOrRemoveToWishList(upc, desc: desc, imageurl: imageurl, price: price, addItem: addItem, isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable,category:category,added: added)
                }
            )
            return
        }
        
        //Event
//        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ADD_TO_LIST.rawValue, label: "\(self.name) - \(self.upc)")

        if self.listSelectorController == nil {
            self.listSelectorContainer = UIView(frame: CGRect(x: 0, y: 360.0, width: self.view.frame.width, height: 0.0))
            self.listSelectorContainer!.clipsToBounds = true
            self.view.addSubview(self.listSelectorContainer!)
            
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            self.listSelectorController!.productUpc = self.upc as String
            self.listSelectorController!.pesable = self.isPesable
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 360.0)
            self.listSelectorContainer!.addSubview(self.listSelectorController!.view)
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            
            self.detailCollectionView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3,
                animations: { () -> Void in
                    self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height), animated: false)
                },
                completion: { (complete:Bool) -> Void in
                    if complete {
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            self.listSelectorContainer!.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 360)
                            self.listSelectorController!.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 360.0)
                        })
                    }
            })
        }
        else {
            self.removeListSelector(action: nil)
        }

    }
    
    override func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String )
    {
        
//        let sb = UIStoryboard(name: "WeightPiceKeyboard", bundle: nil)
//        let vc = sb.instantiateInitialViewController() as UIViewController
//        
//        vc.view.frame = CGRectMake(0, 0, self.view.frame.width, 360)
//        self.addChildViewController(vc)
//        self.view.addSubview(vc.view)
        
        if isShowProductDetail == true {
            self.closeProductDetail()
        }
        
        self.comments = comments as NSString
        if selectQuantityGR == nil {
            
            if self.listSelectorController != nil {
                self.removeListSelector(action: { () -> Void in
                    self.addProductToShoppingCart(upc, desc: desc, price: price, imageURL: imageURL,comments:comments  )
                })
                return
            }
            
            let frameDetail = CGRect(x: 0,y: 0, width: self.detailCollectionView.frame.width, height: heightDetail)
            if self.isPesable {
                let selectQuantityGRW = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(value: self.price.doubleValue as Double),equivalenceByPiece:equivalenceByPiece,upcProduct:self.upc as String, isSearchProductView: false)
                selectQuantityGR = selectQuantityGRW
            }else{
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
            }
            self.selectQuantityGR.isFromList = false
            selectQuantityGR?.closeAction = { () in
                self.closeContainer({ () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                    }, completeClose: { () -> Void in
                        self.isShowShoppingCart = false
                            self.selectQuantityGR = nil
                        //self.tabledetail.deleteRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Top)
                })
            }
            selectQuantityGR.addUpdateNote = {() in
                if self.productDetailButton!.detailProductCart != nil {
                    let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                    let frame = vc!.view.frame
                    
                    
                    let addShopping = ShoppingCartUpdateController()
                    let quantity = self.productDetailButton!.detailProductCart!.quantity
                    let paramsToSC = self.buildParamsUpdateShoppingCart(quantity.stringValue, orderByPiece: self.selectQuantityGR!.orderByPiece, pieces: quantity.intValue,equivalenceByPiece:Int(self.selectQuantityGR!.equivalenceByPiece) ) as! [String:Any]
                    addShopping.params = paramsToSC
                    vc!.addChildViewController(addShopping)
                    addShopping.view.frame = frame
                    vc!.view.addSubview(addShopping.view)
                    addShopping.didMove(toParentViewController: vc!)
                    addShopping.typeProduct = ResultObjectType.Groceries
                    
                    addShopping.comments = self.productDetailButton!.detailProductCart!.note == nil ? "" : self.productDetailButton!.detailProductCart!.note!
                    addShopping.goToShoppingCart = {() in }
                    addShopping.removeSpinner()
                    addShopping.addActionButtons()
                    addShopping.addNoteToProduct(nil)
                }
            
            }
            
            if productDetailButton!.detailProductCart?.quantity != nil {
                
                selectQuantityGR?.userSelectValue(productDetailButton!.detailProductCart!.quantity.stringValue)
                selectQuantityGR?.first = true
                selectQuantityGR?.showNoteButton()
                
                if productDetailButton!.detailProductCart?.product != nil {
                    selectQuantityGR?.validateOrderByPiece(orderByPiece: productDetailButton!.detailProductCart!.product.orderByPiece.boolValue, quantity: productDetailButton!.detailProductCart!.quantity.doubleValue, pieces: productDetailButton!.detailProductCart!.product.pieces.intValue)
                }
                
            }
            
            //selectQuantityGR?.generateBlurImage(self.detailCollectionView,frame:CGRectMake(0,0, self.detailCollectionView.frame.width, heightDetail))
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                
                if quantity == "00" {
                    self.deleteFromCartGR()
                    return
                }
                
                if self.onHandInventory.integerValue >= Int(quantity) {
                    self.closeContainer({ () -> Void in
                        self.productDetailButton?.reloadShoppinhgButton()
                        }, completeClose: { () -> Void in
                            
                            self.isShowShoppingCart = false
                            //self.tabledetail.deleteRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Top)
            
                            let pieces = self.equivalenceByPiece.intValue > 0 ? (Int(quantity)! / self.equivalenceByPiece.intValue) : (Int(quantity)!)
                            let params = self.buildParamsUpdateShoppingCart(quantity, orderByPiece: self.selectQuantityGR!.orderByPiece, pieces: pieces,equivalenceByPiece:self.equivalenceByPiece.intValue)
                       
                            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                            
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
                    self.productDetailButton?.setOpenQuantitySelector()
                    //self.selectQuantityGR?.imageBlurView.frame = frameDetail
                    self.productDetailButton?.addToShoppingCartButton.isSelected = true
                },
                additionalAnimationClose:{ () -> Void in
//                    self.selectQuantityGR?.imageBlurView.frame =  CGRectMake(0, -self.heightDetail,
//                    self.detailCollectionView.frame.width, self.heightDetail)
                    self.productDetailButton?.addToShoppingCartButton.isSelected = true
                }
            )
        }else{
            self.closeContainerDetail()
        }

    }
    
    
    func deleteFromCartGR() {
        //Add Alert
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"preCart_mg_icon"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"preCart_mg_icon"))
        alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductAlert", comment:""))
        self.selectQuantityGR?.closeAction()
        self.selectQuantityGR = nil
        
        let itemToDelete = self.buildParamsUpdateShoppingCart("0",orderByPiece: false, pieces: 0,equivalenceByPiece:0 )
        if !UserCurrentSession.hasLoggedUser() {
            BaseController.sendAnalyticsAddOrRemovetoCart([itemToDelete], isAdd: false)
        }
        let upc = itemToDelete["upc"] as! String
        let deleteShoppingCartService = GRShoppingCartDeleteProductsService()
        
        deleteShoppingCartService.callService([upc], successBlock: { (result:[String:Any]) -> Void in
            UserCurrentSession.sharedInstance.loadGRShoppingCart({ () -> Void in
                print("delete pressed OK")
                alertView?.setMessage(NSLocalizedString("shoppingcart.deleteProductDone", comment:""))
                alertView?.showDoneIcon()
                alertView?.afterRemove = {
                    self.productDetailButton?.reloadShoppinhgButton()
                }
            })
        }) { (error) in
            alertView?.showDoneIcon()
            print("delete pressed Errro \(error)")
        }
    }

    override func closeContainerDetail() {
        if selectQuantityGR != nil {
            self.closeContainer({ () -> Void in
                
                
                
                self.productDetailButton?.reloadShoppinhgButton()
//                UserCurrentSession.sharedInstance.loadGRShoppingCart
//                    { () -> Void in
//                        self.productDetailButton.reloadShoppinhgButton()
//                }
            }, completeClose: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantityGR = nil
            })
        }else{
            UserCurrentSession.sharedInstance.loadGRShoppingCart
                { () -> Void in
                    if self.productDetailButton != nil {
                        self.productDetailButton?.reloadShoppinhgButton()
                    }
            }
        }
    }
    
    func instanceOfQuantitySelector(_ frame:CGRect) -> GRShoppingCartQuantitySelectorView? {
        var instance: GRShoppingCartQuantitySelectorView? = nil
        if self.isPesable {
            instance = GRShoppingCartWeightSelectorView(frame: frame, priceProduct: NSNumber(value: self.price.doubleValue as Double),equivalenceByPiece:equivalenceByPiece,upcProduct:self.upc as String, isSearchProductView: false)
        } else {
            instance = GRShoppingCartQuantitySelectorView(frame: frame, priceProduct: NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
        return instance
    }
    
    //MARK: - ListSelectorDelegate
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, action: WMGAIUtils.ACTION_CANCEL_ADD_TO_LIST.rawValue, label: "")
    }

    internal func listSelectorDidAddProduct(inList listId: String) {
        listSelectorDidAddProduct(inList:listId,included: false)
    }
    
    func listSelectorDidAddProduct(inList listId:String,included: Bool ) {
        let frameDetail = CGRect(x: 320.0, y: 0.0, width: 320.0, height: 360.0)
        
        if self.isPesable ||  included {
            self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
            self.selectQuantityGR.isFromList = true
            self.selectQuantityGR!.generateBlurImage(self.view, frame:CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 360.0))
            self.selectQuantityGR!.closeAction = { () in
                self.removeListSelector(action: nil)
            }
            
            self.selectQuantityGR!.addToCartAction = { (quantity:String) in
                if quantity.toIntNoDecimals() == 0 {
                    self.listSelectorDidDeleteProduct(inList: listId)
                    return
                }
                
                if Int(quantity) <= 20000 {
                    
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"new_alert_list"),imageError: UIImage(named:"list_alert_error"))
                    if let imageURL = self.productDetailButton?.image {
                        if let urlObject = URL(string:imageURL) {
                            self.alertView?.imageIcon.setImageWith(urlObject)
                        }
                    }
                    self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
                    
                    self.addItemsToList(quantity:quantity,listId:listId)
                    
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
            
            UIView.animate(withDuration: 0.5,
                           animations: { () -> Void in
                            self.listSelectorController!.view.frame = CGRect(x: -320.0, y: 0.0, width: self.view.frame.width, height: 360.0)
                            self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 360.0)
            }, completion: { (finished:Bool) -> Void in
                
            }
            )
        } else {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"new_alert_list"),imageError: UIImage(named:"list_alert_error"))
            if let imageURL = self.productDetailButton?.image {
                if let urlObject = URL(string:imageURL) {
                    self.alertView?.imageIcon.setImageWith(urlObject)
                    
                    
                }
            }
            self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
            
             addItemsToList(quantity:"1",listId:listId)
        }
        
        
        
    }
    
    
    func addItemsToList(quantity:String,listId:String) {
        
        let service = GRAddItemListService()
        let pesable = self.isPesable ? "1" : "0"
        let orderByPiece = self.selectQuantityGR?.orderByPiece ?? true
        let productObject = service.buildProductObject(upc: self.upc as String, quantity:Int(quantity)!,pesable:pesable,active:self.isActive,baseUomcd:orderByPiece ? "EA" : "GM")
        service.callService(service.buildParams(idList: listId, upcs: [productObject]),
                            successBlock: { (result:[String:Any]) -> Void in
                                self.alertView?.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action: WMGAIUtils.ACTION_ADD_TO_LIST.rawValue, label:"\(self.name) \(self.upc) ")
                                
                                self.alertView?.showDoneIcon()
                                self.alertView?.afterRemove = {
                                    self.removeListSelector(action: nil)
                                }
                                
                                // 360 Event
                                BaseController.sendAnalyticsProductToList(self.upc as String, desc: self.name as String, price: self.price as String)
                                
        }, errorBlock: { (error:NSError) -> Void in
            print("Error at add product to list: \(error.localizedDescription)")
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showErrorIcon("Ok")
            self.alertView!.afterRemove = {
                self.removeListSelector(action: nil)
            }
        }
        )
    
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToList", comment:""))

        let detailService = GRUserListDetailService()
        detailService.buildParams(listId)
        detailService.callService([:],
            successBlock: { (result:[String:Any]) -> Void in
                let service = GRDeleteItemListService()
                service.callService(service.buildParams(self.upc as String),
                    successBlock: { (result:[String:Any]) -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.deleteProductToListDone", comment:""))
                        self.alertView!.showDoneIcon()
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil)
                        }
                        //Event
                        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRODUCT_DETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRODUCT_DETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_DELETE_PRODUCT_MYLIST.rawValue, label: "\(self.name) - \(self.upc)")
                        self.completeDelete?()
                        
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
        
        let exist = (list.products.allObjects as! [Product]).contains { (product) -> Bool in
            return product.upc == self.upc as String
        }
        
        if self.isPesable || exist  {
            let frameDetail = CGRect(x: 320.0, y: 0.0, width: self.view.frame.width, height: 360.0)
            self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
            self.selectQuantityGR!.generateBlurImage(self.view, frame:CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 360.0))
            self.selectQuantityGR!.closeAction = { () in
                self.removeListSelector(action: nil)
            }
            self.selectQuantityGR.isFromList = true
            self.selectQuantityGR!.addToCartAction = { (quantity:String) in
                self.addToListLocally(quantity:quantity,list:list)
            }
            self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
            
            UIView.animate(withDuration: 0.5,
                           animations: { () -> Void in
                            self.listSelectorController!.view.frame = CGRect(x: -320.0, y: 0.0, width: self.view.frame.width, height: 360.0)
                            self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 360.0)
            }, completion: { (finished:Bool) -> Void in
                
            }
            )
        } else {
            self.addToListLocally(quantity:"1",list:list)
        }
    }
    
    func addToListLocally(quantity:String,list:List) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
        detail!.upc = self.upc as String
        detail!.desc = self.name as String
        detail!.price = self.price
        detail!.orderByPiece = self.selectQuantityGR?.orderByPiece as? NSNumber ?? 0
        detail!.pieces =  NSNumber(value: Int(quantity)!)
        detail!.quantity = NSNumber(value: Int(quantity)! as Int)
        detail!.type = NSNumber(value: self.isPesable as Bool)
        detail!.list = list
        detail!.equivalenceByPiece = self.equivalenceByPiece
        
        if self.imageUrl.count > 0 {
            detail!.img = self.imageUrl[0] as! NSString as String
        }
        
        //BaseController.sendAnalytics(WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue, categoryNoAuth:WMGAIUtils.GR_CATEGORY_SHOPPING_CART_AUTH.rawValue , action:WMGAIUtils.ACTION_ADD_TO_LIST.rawValue , label:"\(self.name as String) \(self.upc as String)")
        
        
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
        list.countItem = NSNumber(value: count as Int)
        
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
        
        self.productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCUserlist(self.upc as String)
        
        // 360 Event
        BaseController.sendAnalyticsProductToList(self.upc as String, desc: self.name as String, price: self.price as String)
    }
    
    func showMessageWishList(_ message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRect(x: self.detailCollectionView.frame.minX, y: self.detailCollectionView.frame.minY +  314, width: self.detailCollectionView.frame.width, height: 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRect(x: self.detailCollectionView.frame.minX, y: 270, width: self.detailCollectionView.frame.width, height: 44))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRect(x: self.detailCollectionView.frame.minX, y: 0, width: self.detailCollectionView.frame.width, height: 44)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRect(x: self.detailCollectionView.frame.minX,y: self.detailCollectionView.frame.minY + 270, width: self.detailCollectionView.frame.width, height: 96)
            }, completion: { (complete:Bool) -> Void in
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                    addedAlertWL.frame = CGRect(x: addedAlertWL.frame.minX, y: self.detailCollectionView.frame.minY + 314.0, width: addedAlertWL.frame.width, height: 0)
                    }) { (complete:Bool) -> Void in
                        self.detailCollectionView.isScrollEnabled = true
                        addedAlertWL.removeFromSuperview()
                }
        }) 
        
        
    }
    
    
    func listSelectorDidDeleteProductLocally(_ product:Product, inList list:List) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        context.delete(product)
        do {
            try context.save()
        } catch {
            abort()
        }

        let count:Int = list.products.count
        list.countItem = NSNumber(value: count as Int)
        do {
            try context.save()
            self.completeDelete?()
        } catch  {
            abort()
        }
        
        self.removeListSelector(action: nil)
        
    }

    
    func removeListSelector(action:(()->Void)?) {
        UIView.animate(withDuration: 0.3,
            animations: { () -> Void in
                self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height), animated: false)
            },
            completion: { (complete:Bool) -> Void in
                if complete {
                    UIView.animate(withDuration: 0.5,
                        delay: 0.0,
                        options: .layoutSubviews,
                        animations: { () -> Void in
                            self.listSelectorContainer!.frame = CGRect(x: 0, y: 360.0, width: self.view.frame.width, height: 0.0)
                        }, completion: { (complete:Bool) -> Void in
                            if complete {
                                self.listSelectorController!.willMove(toParentViewController: nil)
                                self.listSelectorController!.view.removeFromSuperview()
                                self.listSelectorController!.removeFromParentViewController()
                                self.listSelectorController = nil
                                
                                self.listSelectorContainer!.removeFromSuperview()
                                self.listSelectorContainer = nil
                                
                                //self.productDetailButton!.listButton.selected = false
                                self.productDetailButton!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCUserlist(self.upc as String)
                                
                                action?()
                                self.detailCollectionView.isScrollEnabled = true
                            }
                        }
                    )
                }
        })
    }
    
    
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(_ list: List) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func shouldDelegateListCreation() -> Bool {
        return false
    }
    
    func listSelectorDidCreateList(_ name:String) {
        
    }

    
    //MARK: -
    
    override func buildParamsUpdateShoppingCart(_ quantity: String, orderByPiece: Bool, pieces: Int,equivalenceByPiece:Int) -> [AnyHashable : Any] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"comments":self.comments,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable, "orderByPiece": orderByPiece, "pieces": pieces,"equivalenceByPiece":equivalenceByPiece]
    }
    
    
    //Info nutrimental
    
    override func showProductDetail() {
        
        if isShowShoppingCart {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.isShowShoppingCart = false
                self.selectQuantity!.frame = CGRect(x: 0, y: 360, width: self.view.frame.width, height: 0)
                self.selectQuantity!.imageBlurView.frame = CGRect(x: 0, y: -360, width: self.view.frame.width, height: 360)
                }, completion: { (animated:Bool) -> Void in
                    if self.selectQuantity != nil {
                        self.selectQuantity!.removeFromSuperview()
                        self.selectQuantity = nil
                        self.detailCollectionView.isScrollEnabled = true
                        self.gestureCloseDetail.isEnabled = false
                    }
            })
        }
        
        self.detailCollectionView.scrollsToTop = true
        self.detailCollectionView.isScrollEnabled = false
        gestureCloseDetail.isEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.detailCollectionView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.detailCollectionView.frame.width,  height: self.detailCollectionView.frame.height ), animated: false)
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
        
        if self.selectQuantityGR != nil {
            self.closeContainer(
                { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.selectQuantityGR = nil
                  self.isShowProductDetail = true
                }
            )
        }
        
        if self.nutrmentals.count == 0 {
            super.startAnimatingProductDetail()
        } else {
            
            let finalFrameOfQuantity = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 360)
            if nutrimentalsView == nil {
                nutrimentalsView = GRNutrimentalInfoView(frame: CGRect(x: 0,y: 360, width: self.view.frame.width, height: 0))
                nutrimentalsView?.setup(ingredients, nutrimentals: self.nutrmentals)
                nutrimentalsView!.generateBlurImage(self.view,frame:finalFrameOfQuantity)
            }
            
            nutrimentalsView!.frame = CGRect(x: 0,y: 360, width: self.view.frame.width, height: 0)
            self.nutrimentalsView!.imageBlurView.frame =  CGRect(x: 0, y: -360, width: self.view.frame.width, height: 360)
            

            nutrimentalsView!.closeDetail = { () in
                self.closeProductDetailNutrimental()
            }
            self.view.addSubview(nutrimentalsView!)
            
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.nutrimentalsView!.frame = finalFrameOfQuantity
                self.nutrimentalsView!.imageBlurView.frame = finalFrameOfQuantity
                //self.viewDetail.frame = CGRectMake(0, 0, self.tabledetail.frame.width, self.tabledetail.frame.height - 145)
                self.productDetailButton!.deltailButton.isSelected = true
            })
            
        }
        
    }
    
    func closeProductDetailNutrimental () {
        if isShowProductDetail == true {
            isShowProductDetail = false
            gestureCloseDetail.isEnabled = false
            self.detailCollectionView.isScrollEnabled = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                
                self.nutrimentalsView?.imageBlurView.frame =  CGRect(x: 0, y: -360, width: self.view.frame.width, height: 360)
                self.nutrimentalsView?.frame = CGRect(x: 0,y: 360, width: self.view.frame.width, height: 0)
                }, completion: { (ended:Bool) -> Void in
                    if self.nutrimentalsView != nil {
                        self.nutrimentalsView?.removeFromSuperview()
                        self.nutrimentalsView = nil
                        
                        
                        self.productDetailButton!.deltailButton.isSelected = false
                    }
            }) 
        }
    }
    
    override func closeProductDetail () {
        if isShowProductDetail == true {
            if viewDetail ==  nil {
                if  self.nutrimentalsView != nil {
                    closeProductDetailNutrimental()
                }else{
                     super.closeProductDetail()
                }
            }else {
                super.closeProductDetail()
            }
            
        }
    }
    
    override func loadCrossSell() {
        NSLog("lcs 1")
        let service = GRProductBySearchService()
        let params = service.buildParamsForSearch(text: "", family: self.idFamily, line: self.idLine, sort: FilterType.descriptionAsc.rawValue, departament: self.idDepartment, start: 0, maxResult: 6,brand:"")
        service.callService(params!,
                            successBlock: { (arrayProduct:[[String:Any]]?,resultDic:[String:Any]) -> Void in
                NSLog("lcs 2")
                if arrayProduct != nil && arrayProduct!.count > 0 {
                    NSLog("lcs 2")
                    var keywords = Array<[String:Any]>()
                    for item in arrayProduct! {
                        
                        if self.upc !=  item["upc"] as! NSString {
                            
                            var urlArray : [String] = []
                            urlArray.append(item["imageUrl"] as! String)
                            
                            var price : NSString = ""
                            if let value = item["price"] as? String {
                                price = value as NSString
                            }
                            else if let value = item["price"] as? NSNumber {
                                price = "\(value)" as NSString
                            }
                            
                            keywords.append(["codeMessage":"0","description":item["description"] as! String, "imageUrl":urlArray, "price" : price,  "upc" :item["upc"]!, "type" : ResultObjectType.Groceries.rawValue ])
                        }
                        
                        if keywords.count == 5 {
                            break
                        }
                    }
                    self.itemsCrossSellUPC = keywords
                    if self.itemsCrossSellUPC.count > 0{
                         self.showCrossSell()
                    }
                    
                    var position = 0
                    var positionArray: [Int] = []
                    
                    for _ in self.itemsCrossSellUPC {
                        position += 1
                        positionArray.append(position)
                    }
                    
                    let listName = "CrossSell"
                    let subCategory = ""
                    let subSubCategory = ""
                    BaseController.sendAnalyticsTagImpressions(self.itemsCrossSellUPC, positionArray: positionArray, listName: listName, mainCategory: "", subCategory: subCategory, subSubCategory: subSubCategory)
                }
                
            }, errorBlock: {(error: NSError) in
                print(error)
                
            }
        )
    }
    
    // MARK: - Collection view config
    override func goTODetailProduct(_ upc: String, items: [[String : String]], index: Int, imageProduct: UIImage?, point: CGRect, idList: String, isBundle: Bool) {
        let controller = ProductDetailPageViewController()
        controller.ixSelected = index
        controller.idListSeleted = idList
        controller.itemsToShow = []
        controller.detailOf =   isBundle ? "Bundle" : "CrossSell"
        for product  in items {
            let upc : NSString = product["upc"]! as NSString
            let desc : NSString = product["description"]! as NSString
            let type : NSString = ResultObjectType.Groceries.rawValue as NSString
            controller.itemsToShow.append(["upc":upc,"description":desc,"type":type])
        }
        self.navigationController!.pushViewController(controller, animated: true)
    }

    
}
