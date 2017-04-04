//
//  IPAGRProductDetailViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/14/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
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


class IPAGRProductDetailViewController : IPAProductDetailViewController, ListSelectorDelegate , IPAUserListDetailDelegate{
 


    var pushList = false
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
    
    var equivalenceByPiece : NSNumber! = NSNumber(value: 0 as Int32)
    var productDetailButtonGR: GRProductDetailButtonBarCollectionViewCell?
    
     var itemOrderbyPices =  true
    
    override func viewDidLoad() {
        NSLog("viewDidLoad")
        super.viewDidLoad()
        NSLog("super.viewDidLoad()")
        self.type = ResultObjectType.Groceries.rawValue as NSString
        NSLog("self.type = ResultObjectType.Groceries.rawValue")
    }
    
    override func loadDataFromService() {
        
        print("parametro para signals GR:::\(self.indexRowSelected)")
        
        let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let productService = GRProductDetailService(dictionary:signalsDictionary)
        let eventType = self.fromSearch ? "clickdetails" : "pdpview"
        let params = productService.buildParams(upc as String, eventtype: eventType,stringSearch : self.stringSearch,position:"\(self.indexRowSelected)")//position
        productService.callService(requestParams: params, successBlock: { (result: [String:Any]) -> Void in
            self.name = result["description"] as! NSString
            if let priceR =  result["price"] as? NSNumber {
                self.price = "\(priceR)" as NSString
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
            self.detail = result["longDescription"] as! NSString
            self.saving = ""
            
            if let savingResult = result["promoDescription"] as? NSString {
                if savingResult != "" {
                    self.saving = result["promoDescription"] as! NSString
                }
            }
            
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
            if let images = result["imageUrl"] as? String {
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
            self.defaultLoadingImg?.isHidden = true 
            self.titlelbl.text = self.name as String
            
            self.bannerImagesProducts.imageIconView.isHidden = !ProductDetailViewController.validateUpcPromotion(self.upc as String)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ClearSearch.rawValue), object: nil)
            
            //FACEBOOKLOG
            FBSDKAppEvents.logEvent(FBSDKAppEventNameViewedContent, valueToSum:self.price.doubleValue, parameters: [FBSDKAppEventParameterNameCurrency:"MXN",FBSDKAppEventParameterNameContentType: "productgr",FBSDKAppEventParameterNameContentID:self.upc])
            
            //Analitics
            let linea = result["linea"] as? String ?? ""
            BaseController.sendAnalyticsPush(["event":"interaccionFoto", "category" : self.productDeparment, "subCategory" :"", "subsubCategory" :linea])
            
            let isBundle = result["isBundle"] as? Bool ?? false
            if self.detailOf == "" {
                fatalError("detailOf not seted")
            }
            
            BaseController.sendAnalyticsPush(["event": "productClick","ecommerce":["click":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
            
             BaseController.sendAnalyticsPush(["event": "ecommerce","ecommerce":["detail":["actionField":["list": self.detailOf],"products":[["name": self.name,"id": self.upc,"price": self.price,"brand": "", "category": self.productDeparment,"variant": "pieza","dimension21": isBundle ? self.upc : "","dimension22": "","dimension23": linea,"dimension24": "","dimension25": ""]]]]])
            
            

           
            }) { (error:NSError) -> Void in
              //  var empty = IPOGenericEmptyView(frame:self.viewLoad.frame)
                let empty = IPOGenericEmptyView(frame:CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
               
                self.name = NSLocalizedString("empty.productdetail.title",comment:"") as NSString
                empty.returnAction = { () in
                    print("")
                    self.backButton()
                }
                self.view.addSubview(empty)
                if self.viewLoad != nil {
                    self.viewLoad.stopAnnimating()
                }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let headerView = UIView()
        switch section {
        case 0:
            return nil
        default:
            
            if isLoading {
                return UIView()
            }
            
            self.productDetailButtonGR = GRProductDetailButtonBarCollectionViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64.0),spaceBetweenButtons:13,widthButtons:63)
            productDetailButtonGR!.upc = self.upc as String
            productDetailButtonGR!.desc = self.name as String
            productDetailButtonGR!.price = self.price as String
            productDetailButtonGR!.isPesable  = self.isPesable
            productDetailButtonGR!.onHandInventory = self.onHandInventory as String
            productDetailButtonGR!.isActive = self.strisActive as String
            productDetailButtonGR!.isPreorderable = self.strisPreorderable as String
            productDetailButtonGR!.isAviableToShoppingCart = isActive == true && onHandInventory.integerValue > 0 //&& isPreorderable == false
            productDetailButtonGR!.listButton.isSelected = UserCurrentSession.sharedInstance.userHasUPCWishlist(self.upc as String)
            productDetailButtonGR!.idListSelect =  self.idListSelected
            var imageUrl = ""
            if self.imageUrl.count > 0 {
                imageUrl = self.imageUrl[0] as! NSString as String
            }
            productDetailButtonGR!.image = imageUrl
            productDetailButtonGR!.delegate = self
            productDetailButtonGR!.validateIsInList(self.upc as String)
            
            productDetailButton = productDetailButtonGR
            return productDetailButton
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
                        
                        if self.upc as String !=  item["upc"] as! String {
                        
                        var urlArray : [String] = []
                        urlArray.append(item["imageUrl"] as! String)
                 
                        var price : NSString = ""
                        if let value = item["price"] as? String {
                            price = value as NSString
                        }
                        else if let value = item["price"] as? NSNumber {
                            price = "\(value)" as NSString
                        }
                        
                        keywords.append(["codeMessage":"0","description":item["description"] as! String, "imageUrl":urlArray, "price" : price,  "upc" :item["upc"] as! String, "type" : ResultObjectType.Groceries.rawValue ])
                        }
                        
                        if keywords.count == 5 {
                            break
                        }
                    }
                    self.itemsCrossSellUPC = keywords
                    if self.itemsCrossSellUPC.count > 0{
                        self.productCrossSell.reloadWithData(self.itemsCrossSellUPC, upc: self.upc as String)
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
    
    override func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String ) {
        self.comments = comments
        
        
        if visibleDetailList {
            self.removeDetailListSelector(
                action: { () -> Void in
                   self.addProductToShoppingCart(upc,desc:desc,price:price,imageURL:imageURL, comments:comments)
            })
        }
        else {
            super.addProductToShoppingCart(upc,desc:desc,price:price,imageURL:imageURL, comments:comments)
        }
    }
    
    
    override func addOrRemoveToWishList(_ upc:String,desc:String,imageurl:String,price:String,addItem:Bool,isActive:String,onHandInventory:String,isPreorderable:String,category:String,added:@escaping (Bool) -> Void) {
        
        if self.isShowShoppingCart || self.isShowProductDetail {
            self.closeContainer(
                { () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                    self.selectQuantityGR = nil
                    self.addOrRemoveToWishList(upc, desc: desc, imageurl: imageurl, price: price, addItem: addItem, isActive: isActive, onHandInventory: onHandInventory, isPreorderable: isPreorderable,category:category,added: added)
                }, closeRow:false
            )
            return
        }
       
        if self.listSelectorController == nil {
            
            self.addToList(push:false)
        
        } else {
            if visibleDetailList {
                self.removeDetailListSelector(
                    action: { () -> Void in
                         self.removeListSelector(action: nil, closeRow:true)
                })
            } else {
                self.removeListSelector(action: nil, closeRow:true)
            }
        }
    }
    
    var quantitySelect =  0
    var orderByPieceSelect  =  false
    
    func addToList(push: Bool) {
        
        self.pushList = push
        
        if self.listSelectorController == nil {
            
            let frameDetail = push ? CGRect(x: self.selectQuantityGR!.frame.maxX, y: 0, width: self.selectQuantityGR.frame.width, height: heightDetail) : CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
            self.listSelectorContainer = UIView(frame: frameDetail)
            self.listSelectorContainer!.clipsToBounds = true
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.delegate = self
            self.listSelectorController!.pesable = self.isPesable
            self.listSelectorController!.productUpc = self.upc as String
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = push ? CGRect(x: 0, y: 0.0, width: self.selectQuantityGR.frame.width, height: heightDetail) : frameDetail
            self.listSelectorContainer!.addSubview(self.listSelectorController!.view)
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            if push {
                self.listSelectorController!.closeBtn!.setImage(UIImage(named: "search_back"), for: UIControlState())
                self.containerinfo!.addSubview(listSelectorContainer!)
            } else {
                opencloseContainer(true,viewShow:self.listSelectorContainer!, additionalAnimationOpen: { () -> Void in
                    self.productDetailButton?.listButton.isSelected = true
                },additionalAnimationClose:{ () -> Void in
                },additionalAnimationFinish: { () -> Void in
                })
            }
            
        }
        
        if push {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                
                self.selectQuantityGR?.frame = CGRect(x: -self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                self.listSelectorContainer?.frame = CGRect(x: 0, y: 0, width: self.tabledetail.frame.width, height: self.heightDetail)
                self.listSelectorController?.view.frame = CGRect(x: 0.0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                
            }, completion: { (complete:Bool) -> Void in
                self.selectQuantityGR!.isHidden = true
            })
        }
        
    }
    
    //new
    override func addToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String) {
        let isInCart = self.productDetailButton?.detailProductCart != nil
        if !isInCart && !self.isPesable {
            self.tabledetail.reloadData()
            self.isShowShoppingCart = false
            var params  =  self.buildParamsUpdateShoppingCart("1", orderByPiece: true, pieces: 1,equivalenceByPiece:0 )//equivalenceByPiece
            params.updateValue(comments, forKey: "comments")
            params.updateValue(ResultObjectType.Groceries.rawValue, forKey: "type")
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
            return
        }
        
        let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
        
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR.isFromList = false
        selectQuantityGR?.closeAction = { () in
            self.productDetailButton!.isOpenQuantitySelector = false
            self.closeContainer({ () -> Void in
                self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    self.isShowShoppingCart = false
                }, closeRow:true)
        }
        
        selectQuantityGR?.generateBlurImage(self.tabledetail,frame:CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail))
        selectQuantityGR?.addToCartAction = { (quantity:String) in
            self.itemOrderbyPices = self.selectQuantityGR!.orderByPiece
            if quantity == "00" {
                self.deleteFromCartGR()
                return
            }
            
            if self.onHandInventory.integerValue >= Int(quantity) {
                self.closeContainer({ () -> Void in
                    self.productDetailButton?.reloadShoppinhgButton()
                }, completeClose: { () -> Void in
                    
                    self.isShowShoppingCart = false
                    
                    let pesable = self.isPesable ? "1" : "0"
                    let pieces = self.equivalenceByPiece.intValue > 0 ? (Int(quantity)! / self.equivalenceByPiece.intValue) : (Int(quantity)!)
                    
                    var params  =  CustomBarViewController.buildParamsUpdateShoppingCart(upc, desc: desc, imageURL: imageURL, price: price,quantity: quantity,comments: comments,onHandInventory:"1",type: self.type as String, pesable:pesable, isPreorderable:"false",orderByPieces:self.selectQuantityGR!.orderByPiece)
                    params.updateValue(comments, forKey: "comments")
                    params.updateValue(self.type, forKey: "type")
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
                    self.productDetailButton?.isOpenQuantitySelector = false
                    self.productDetailButton?.reloadShoppinhgButton()
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
            if self.productDetailButton!.detailProductCart != nil {
                let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                let frame = vc!.view.frame
                
                self.productDetailButton!.detailProductCart  = self.productDetailButton!.retrieveProductInCar()
                let addShopping = ShoppingCartUpdateController()
                let paramsToSC = self.buildParamsUpdateShoppingCart(self.productDetailButton!.detailProductCart!.quantity.stringValue) as! [String:Any]
                addShopping.params = paramsToSC
                vc!.addChildViewController(addShopping)
                addShopping.view.frame = frame
                vc!.view.addSubview(addShopping.view)
                addShopping.didMove(toParentViewController: vc!)
                addShopping.typeProduct = ResultObjectType.Groceries
                addShopping.comments = self.productDetailButton!.detailProductCart!.note ?? ""
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

        opencloseContainer(true,viewShow:selectQuantityGR!, additionalAnimationOpen: { () -> Void in
            self.productDetailButton?.setOpenQuantitySelector()
            self.selectQuantityGR?.imageBlurView.frame = frameDetail
            self.productDetailButton?.addToShoppingCartButton.isSelected = true
            },additionalAnimationClose:{ () -> Void in
                self.selectQuantityGR?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.tabledetail.frame.width, height: self.heightDetail)
                self.productDetailButton?.addToShoppingCartButton.isSelected = true
            },additionalAnimationFinish: { () -> Void in
                self.productDetailButton!.addToShoppingCartButton.setTitleColor(WMColor.light_blue, for: UIControlState())
        })
        
    }
    //close new
    func deleteFromCartGR() {
        //Add Alert
        let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"remove_cart"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"preCart_mg_icon"))
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
    
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if visibleDetailList {
            self.removeDetailListSelector(
                action: { () -> Void in
                    print("-- removeDetailListSelector --")
                    for  children in self.childViewControllers {
                        if children.isKind(of: IPAUserListDetailViewController.self){
                            children.view.removeFromSuperview()
                            children.removeFromParentViewController()
                        }
                    }
                   self.listSelectorDidShowList(listId, andName: name)
            })
            return
        }
        
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.delegate = self
            vc.widthView = self.bannerImagesProducts.frame.width
            vc.addGestureLeft = true
            vc.searchInList = {(controller) in
                self.navigationController?.pushViewController(controller, animated: false)
            }

            
            let frameDetail = CGRect(x: -self.bannerImagesProducts.frame.width, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
            vc.view.frame = frameDetail
            self.view!.addSubview(vc.view)
            detailList = vc
            self.addChildViewController(self.detailList!)
            self.detailList!.didMove(toParentViewController: self)
            self.detailList!.view.clipsToBounds = true
            self.view!.bringSubview(toFront: self.detailList!.view)
            
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.detailList!.view.frame = CGRect(x: 0.0, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY)
                }, completion: { (finished:Bool) -> Void in
                    self.visibleDetailList = true
                }
            )
        }
    }
    
    //Mark: ListSelectorDelegate
    
    var closeContainer =  false
    
    func listSelectorDidClose() {
        
        if pushList {
            
            self.selectQuantityGR!.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.selectQuantityGR!.frame = CGRect(x: 0, y: 0.0, width: self.selectQuantityGR.frame.width, height: self.heightDetail)
                self.listSelectorContainer!.frame = CGRect(x: self.selectQuantityGR.frame.width, y: 0.0, width: self.selectQuantityGR.frame.width, height: self.heightDetail)
            }, completion: { (complete: Bool) -> Void in
                self.pushList = false
            })
            
        } else {
            self.removeListSelector(action: nil, closeRow:true)
        }
        
    }
    
    internal func listSelectorDidAddProduct(inList listId: String) {
        listSelectorDidAddProduct(inList: listId, included:false)
    }

    
    func listSelectorDidAddProduct(inList listId:String, included: Bool) {
        
        let frameDetail = CGRect(x: self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: heightDetail)
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.isPush = true
        self.selectQuantityGR.isFromList = true
        self.selectQuantityGR.isUpcInList =  UserCurrentSession.sharedInstance.userHasUPCUserlist(upc as String,listId: listId)
        self.selectQuantityGR!.setQuantity(quantity: UserCurrentSession.sharedInstance.getProductQuantityForList(upc as String,listId: listId))
        self.selectQuantityGR!.closeAction = { () in
            
            if self.selectQuantityGR!.isPush {
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRect(x: 0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                    self.selectQuantityGR!.frame = CGRect(x: self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                }, completion: { (complete: Bool) -> Void in
                    self.selectQuantityGR!.removeFromSuperview()
                    self.listSelectorController?.sowKeyboard = false
                })
                
            } else {
                self.removeListSelector(action: nil, closeRow:true)
            }
            
        }
        
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            self.itemOrderbyPices = self.selectQuantityGR!.orderByPiece
            if quantity.toIntNoDecimals() == 0 {
                self.listSelectorDidDeleteProduct(inList: listId)
            } else {
            
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"addedtolist_icon"),imageError: UIImage(named:"list_alert_error"))
                if let imageURL = self.productDetailButton?.image {
                    if let urlObject = URL(string:imageURL) {
                        self.alertView?.imageIcon.setImageWith(urlObject)
                    }
                }
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductToList", comment:""))
                
                if included {
                    self.updateItemToList(quantity: quantity, listId: listId, finishAdd: true, orderByPiece: self.selectQuantityGR!.orderByPiece)
                }else{
                    self.addItemsToList(quantity: quantity, listId: listId, finishAdd: true, orderByPiece: self.selectQuantityGR!.orderByPiece)
                }
            }
        }
        
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.listSelectorController!.view.frame = CGRect(x: -self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
            self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
        })
    }
    
    //new
    func addItemsToList(quantity:String,listId:String,finishAdd:Bool,orderByPiece:Bool) {
        
        let service = GRAddItemListService()
        let pesable =  self.isPesable ? "1" : "0"
        let productObject = service.buildProductObject(upc: self.upc as String, quantity:Int(quantity)!,pesable:pesable,active:self.isActive,baseUomcd:orderByPiece ? "EA": "GM")//baseUomcd
        service.callService(service.buildParams(idList: listId, upcs: [productObject]),
                            successBlock: { (result:[String:Any]) -> Void in
                                if finishAdd {
                                self.alertView!.setMessage(NSLocalizedString("list.message.addProductToListDone", comment:""))
                                self.alertView!.showDoneIcon()
                                
                                // 360 Event
                                BaseController.sendAnalyticsProductToList(self.upc as String, desc: self.name as String, price: "\(self.price)")
                                
                                self.alertView!.afterRemove = {
                                    self.removeListSelector(action: nil, closeRow:true)
                                    }
                                }
                                
        }, errorBlock: { (error:NSError) -> Void in
            print("Error at add product to list: \(error.localizedDescription)")
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showErrorIcon("Ok")
            self.alertView!.afterRemove = {
                self.removeListSelector(action: nil, closeRow:true)
            }
        })
        
    }
    
    func updateItemToList(quantity:String,listId:String,finishAdd:Bool,orderByPiece:Bool) {
        
        let orderByPiece = self.itemOrderbyPices
        let service = GRUpdateItemListService()
        service.listId = listId
        service.callService(service.buildParams(upc: self.upc as String, quantity: Int(quantity)!,baseUomcd:orderByPiece ? "EA" : "GM"),
                            successBlock: { (result:[String:Any]) -> Void in
                                
                                if finishAdd {
                                    self.alertView?.setMessage(NSLocalizedString("list.message.updatingProductInListDone", comment:""))
                                    self.alertView?.showDoneIcon()
                                    self.alertView?.afterRemove = {
                                        self.removeListSelector(action: nil, closeRow:true)
                                    }
                                }
                                
                                
                                BaseController.sendAnalyticsProductToList(self.upc as String, desc: self.name as String, price: self.price as String)
                                
        }, errorBlock: { (error:NSError) -> Void in
            print("Error at update product to list: \(error.localizedDescription)")
            self.alertView?.setMessage(error.localizedDescription)
            self.alertView?.showErrorIcon("Ok")
            self.alertView?.afterRemove = {
                self.removeListSelector(action: nil, closeRow:true)
            }
        }
        )
        
        
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
        NSLog("23")
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"remove_cart"), imageDone:UIImage(named:"done"),imageError:UIImage(named:"list_alert_error"))
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
                            self.removeListSelector(action: nil, closeRow:true)
                        }
                    }, errorBlock: { (error:NSError) -> Void in
                        print("Error at remove product from list: \(error.localizedDescription)")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.alertView!.afterRemove = {
                            self.removeListSelector(action: nil, closeRow:true)
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
            
        let frameDetail = CGRect(x: self.tabledetail.frame.width, y: 0.0,  width: self.tabledetail.frame.width, height: heightDetail)
            
        self.selectQuantityGR = self.instanceOfQuantitySelector(frameDetail)
        self.selectQuantityGR!.isPush = true
        self.selectQuantityGR.isFromList = true
        self.selectQuantityGR.isUpcInList =  UserCurrentSession.sharedInstance.userHasUPCUserlist(upc as String,listId: list.name)
        self.selectQuantityGR!.setQuantity(quantity: UserCurrentSession.sharedInstance.getProductQuantityForList(upc as String,listId: list.name))
        self.selectQuantityGR!.closeAction = { () in
                
            if self.selectQuantityGR!.isPush { 
                    
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRect(x: 0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                    self.selectQuantityGR!.frame = CGRect(x: self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                }, completion: { (complete: Bool) -> Void in
                    self.selectQuantityGR!.removeFromSuperview()
                    self.listSelectorController?.sowKeyboard = false
                })
                    
            } else {
                self.removeListSelector(action: nil, closeRow:true)
            }

        }
            
        self.selectQuantityGR!.addToCartAction = { (quantity:String) in
            self.itemOrderbyPices = self.selectQuantityGR!.orderByPiece
            if exist {
                self.updateToListLocally(quantity: quantity, list: list)
            }else {
                self.addToListLocally(quantity: quantity , list: list,removeSelector: true)
            }
        }
            
        self.listSelectorContainer!.addSubview(self.selectQuantityGR!)
        UIView.animate(withDuration: 0.5,
                        animations: { () -> Void in
                        self.listSelectorController!.view.frame = CGRect(x: -self.tabledetail.frame.width, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
                        self.selectQuantityGR!.frame = CGRect(x: 0.0, y: 0.0, width: self.tabledetail.frame.width, height: self.heightDetail)
        })
    }
    
    //
    func addToListLocally(quantity:String,list:List,removeSelector:Bool){
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
        
        detail!.upc = self.upc as String
        detail!.desc = self.name as String
        detail!.price = self.price
        detail!.quantity = NSNumber(value: Int(quantity)! as Int)
        detail!.orderByPiece = self.orderByPieceSelect as NSNumber //self.itemOrderbyPices as NSNumber
        detail!.pieces = NSNumber(value:Int(quantity)!)
        detail!.type = NSNumber(value: self.isPesable as Bool)
        detail!.list = list
        detail!.equivalenceByPiece = self.equivalenceByPiece!//self.selectQuantityGR!.equivalenceByPiece as NSNumber
        
        if self.imageUrl.count > 0 {
            detail!.img = self.imageUrl[0] as! NSString as String
        }
        
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
        
        if removeSelector {
            self.removeListSelector(action: nil, closeRow:true)
        }
        
        self.productDetailButtonGR!.listButton.isSelected = true
        
        // 360 Event
        BaseController.sendAnalyticsProductToList(self.upc as String, desc: self.name as String, price: "\(self.price)")
        
        //TODO: Add message
        if quantity == "00" {
            self.showMessageWishList("Se eliminó de la lista")
        }else{
            self.showMessageWishList("Se agregó a la lista")
        }
    
    }
    
    func updateToListLocally(quantity:String,list:List) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        for  product in  list.products  {
            let productSelect =  product as? Product
            if productSelect!.upc ==  self.upc as String {
                if quantity == "00"{
                    context.delete(productSelect!)
                    
                }else{
                    productSelect?.quantity = NSNumber(value:Int(quantity)!)
                }
            }
        }
        //savecontex from add or remove
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
        
        //save contex from new count items
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
        
        self.removeListSelector(action: nil, closeRow:true)
        
        //TODO: Add message
        if quantity == "00" {
            self.showMessageWishList("Se eliminó de la lista")
        }else{
            self.showMessageWishList("Se agregó a la lista")
        }
        
        
    }
    
    
    
    func listSelectorDidDeleteProductLocally(inList list:List) {
        if UserCurrentSession.hasLoggedUser() {
            self.listSelectorDidDeleteProduct(inList: list.idList!)
        }else{
            self.updateToListLocally(quantity:"00",list:list)
        }
    }
    
    func instanceOfQuantitySelector(_ frame:CGRect) -> GRShoppingCartQuantitySelectorView? {
        var instance: GRShoppingCartQuantitySelectorView? = nil
        if self.isPesable {
            instance = GRShoppingCartWeightSelectorView(frame: frame, priceProduct: NSNumber(value: self.price.doubleValue as Double),equivalenceByPiece:equivalenceByPiece,upcProduct:self.upc as String)
        } else {
            instance = GRShoppingCartQuantitySelectorView(frame: frame, priceProduct: NSNumber(value: self.price.doubleValue as Double),upcProduct:self.upc as String)
        }
        return instance
    }

    var isOpenListDetail  =  false
    
    /**
     show list detail in product detail and validate if any list detail opnen
     
     - parameter list: id list open
     */
    func listSelectorDidShowListLocally(_ list: List) {
        
        if self.isOpenListDetail {
            self.removeDetailListSelector(action: {
                for  children in self.childViewControllers {
                    if children.isKind(of: IPAUserListDetailViewController.self){
                        children.view.removeFromSuperview()
                        children.removeFromParentViewController()
                    }
                }
                self.listSelectorDidShowListLocallyAnimation(list)
            })
        }else{
            self.listSelectorDidShowListLocallyAnimation(list)
        }
        
        
    }

    
    /**
     show  list detail controller in product detail
     
     - parameter list: id list selected
     */
    func  listSelectorDidShowListLocallyAnimation(_ list: List) {

        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = list.idList
            vc.listName = name as String
            vc.listEntity = list
            vc.delegate = self
            vc.widthView = self.bannerImagesProducts.frame.width
            vc.addGestureLeft = true
            
            let frameDetail = CGRect(x: -self.bannerImagesProducts.frame.width, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
            
            vc.view.frame = frameDetail
            self.view!.addSubview(vc.view)
            detailList = vc
            self.addChildViewController(self.detailList!)
            self.detailList!.didMove(toParentViewController: self)
            self.detailList!.view.clipsToBounds = true
            self.view!.bringSubview(toFront: self.detailList!.view)
            
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                      self.isOpenListDetail =  true
                      self.detailList!.view.frame = CGRect(x: 0.0, y: 0.0, width: self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
                    
                }, completion: { (finished:Bool) -> Void in
                    self.visibleDetailList = true
                }
            )
        }
        
    }
    
    
    func shouldDelegateListCreation() -> Bool {
        return false
    }
    
    func listSelectorDidCreateList(_ name:String) {
        
    }
    
    //MARK: - IPAUserListDetailDelegate
    func showProductListDetail(fromProducts products:[Any], indexSelected index:Int,listName:String) {
        let controller = IPAProductDetailPageViewController()
        controller.ixSelected = index
        controller.itemsToShow = products
        controller.detailOf = listName
        self.pagerController!.navigationController?.delegate = self
        self.pagerController!.navigationController?.pushViewController(controller, animated: true)
    }

    
    func reloadTableListUser() {
        if (self.listSelectorController  != nil) {
            self.listSelectorController!.loadLocalList()
        }
    }
    
    func closeUserListDetail() {
        self.removeDetailListSelector(action: nil)
    }
    
    override func removeListSelector(action:(()->Void)?, closeRow:Bool ) {
        
        if visibleDetailList {
            self.removeDetailListSelector(
                action: { () -> Void in
                    self.isOpenListDetail =  false
                    for  children in self.childViewControllers {
                        if children.isKind(of: IPAUserListDetailViewController.self){
                            children.view.removeFromSuperview()
                            children.removeFromParentViewController()
                        }
                    }

                    self.removeListSelector(action: action, closeRow:true)
                })
        } else {
            super.removeListSelector(action: action, closeRow:true)
        }
    }
    
    override func closeContainer(_ additionalAnimationClose:@escaping (() -> Void),completeClose:@escaping (() -> Void), closeRow: Bool) {
                
    
        let finalFrameOfQuantity = CGRect(x: self.tabledetail.frame.minX, y: self.headerView.frame.maxY + heightDetail, width: self.tabledetail.frame.width, height: 0)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerinfo.frame = finalFrameOfQuantity
            additionalAnimationClose()
        }, completion: { (comple:Bool) -> Void in
            self.isContainerHide = true
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                self.isShowShoppingCart = false
                self.isShowProductDetail = false
                self.productDetailButton!.deltailButton.isSelected = false
                self.tabledetail.isScrollEnabled = true
                self.productDetailButtonGR?.validateIsInList(self.upc as String)
                self.listSelectorController = nil
                self.listSelectorBackgroundView = nil
                
                completeClose()
                for viewInCont in self.containerinfo.subviews {
                    viewInCont.removeFromSuperview()
                }
                self.selectQuantity = nil
                self.viewDetail = nil
                
            })
            
            print("close continer")
            if self.tabledetail.numberOfRows(inSection: 0) >= 5 && closeRow {
                self.tabledetail.beginUpdates()
                self.tabledetail.deleteRows(at: [IndexPath(row: 5, section: 0)], with: UITableViewRowAnimation.top)
                self.tabledetail.endUpdates()
                
                
                self.pagerController!.enabledGesture(true)
            }
            CATransaction.commit()
        }) 
    }
    
    func removeDetailListSelector(action:(()->Void)?) {
        NSLog("27")
        if visibleDetailList {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.detailList!.view.frame =  CGRect(x: -self.bannerImagesProducts.frame.width, y: 0.0, width: self.self.bannerImagesProducts.frame.width, height: self.productCrossSell.frame.maxY )
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        if self.detailList != nil {
                            //self.detailList!.willMoveToParentViewController(nil)
                            self.detailList!.willMove(toParentViewController: nil)
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
    

func buildParamsUpdateShoppingCart(_ quantity:String) -> [AnyHashable: Any] {
        var imageUrlSend = ""
        if self.imageUrl.count > 0 {
            imageUrlSend = self.imageUrl[0] as! NSString as String
        }
        let pesable = isPesable ? "1" : "0"
        return ["upc":self.upc,"desc":self.name,"imgUrl":imageUrlSend,"price":self.price,"quantity":quantity,"comments":self.comments,"onHandInventory":self.onHandInventory,"wishlist":false,"type":ResultObjectType.Groceries.rawValue,"pesable":pesable, "orderByPiece": self.itemOrderbyPices, "pieces": quantity,"equivalenceByPiece":self.equivalenceByPiece!]
    }
    
    
    //Info nutrimental
    
    override func showProductDetail() {
        if visibleDetailList {
            self.removeDetailListSelector(
                action: { () -> Void in
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
            let frameDetail = CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail)
            nutrimentalsView  = GRNutrimentalInfoView(frame: frameDetail)
            nutrimentalsView?.setup(ingredients, nutrimentals: self.nutrmentals)
            nutrimentalsView?.generateBlurImage(self.tabledetail,frame:CGRect(x: 0,y: 0, width: self.tabledetail.frame.width, height: heightDetail))
            nutrimentalsView?.imageBlurView.frame =  CGRect(x: 0, y: -heightDetail, width: self.tabledetail.frame.width, height: heightDetail)
            nutrimentalsView?.closeDetail = {() in
                self.closeContainer({ () -> Void in
                    },completeClose:{() in
                        self.isShowProductDetail = false
                        self.productDetailButton!.deltailButton.isSelected = false
                    }, closeRow:true)
            }
            opencloseContainer(true,viewShow:nutrimentalsView!, additionalAnimationOpen: { () -> Void in
                self.nutrimentalsView?.imageBlurView.frame = frameDetail
                self.productDetailButton!.deltailButton.isSelected = true
                self.productDetailButton!.reloadShoppinhgButton()
                },additionalAnimationClose:{ () -> Void in
                    self.nutrimentalsView?.imageBlurView.frame =  CGRect(x: 0, y: -self.heightDetail, width: self.tabledetail.frame.width, height: self.heightDetail)
                    self.productDetailButton!.deltailButton.isSelected = true
            })
            
        }
        
    }
    
    override func cellForPoint(_ point:(Int,Int),indexPath: IndexPath) -> UITableViewCell? {
        var cell : UITableViewCell? = nil
        switch point {
       
        case (0,2) :
            let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            cell = cellSpace
        case (0,4) :
            if self.saving != ""{
                let cellAhorro = tabledetail.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as? ProductDetailCurrencyCollectionView
                let savingSend = self.saving
                cellAhorro!.setValues(savingSend as String, font: WMFont.fontMyriadProSemiboldOfSize(14), textColor: WMColor.green, interLine: false)
                cell = cellAhorro
               
            } else{
                let cellSpace = tabledetail.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell = cellSpace
            }
        default :
            return super.cellForPoint(point, indexPath: indexPath)
        }
        return cell
    }
    
    override func sleectedImage(_ indexPath:IndexPath) {
        let controller = ImageDisplayCollectionViewController()
        controller.name = self.name as String
        
        var imagesLarge : [String] = []
        for image in imageUrl {
            var imgLarge = NSString(string: image as! String)
            imgLarge = imgLarge.replacingOccurrences(of: "img_small", with: "img_large") as NSString
            let pathExtention = imgLarge.pathExtension
            let imageurl = imgLarge.replacingOccurrences(of: "s.\(pathExtention)", with: "L.\(pathExtention)")
            imagesLarge.append(imageurl)
        }
        
        controller.imagesToDisplay = imagesLarge as [Any]?
        controller.currentItem = indexPath.row
        controller.type = self.type as String
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func reloadTableListUserSelectedRow() {
        

        
    }

    
   
}
