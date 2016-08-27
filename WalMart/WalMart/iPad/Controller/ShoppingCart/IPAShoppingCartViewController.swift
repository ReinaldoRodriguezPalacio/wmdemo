//
//  IPAShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/20/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAShoppingCartViewController : ShoppingCartViewController {
    

    var imagePromotion : UIImageView!
    var totalsView : IPAShoppingCartTotalView!
    var beforeLeave : IPAShoppingCartBeforeToLeave!
    var viewSeparator : UIView!
    var popup : UIPopoverController?
    var onClose : ((isClose:Bool) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewFooter.backgroundColor  =  WMColor.light_light_gray
        
        viewShoppingCart.registerClass(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        
        
        imagePromotion = UIImageView()
        //imagePromotion.image = UIImage(named:"cart_promo")
        
        
        self.viewContent.addSubview(imagePromotion)
        
        
        totalsView = IPAShoppingCartTotalView(frame: CGRectMake(0, 0, 0, 0))
        self.viewContent.addSubview(totalsView)
        
      
        
        beforeLeave = IPAShoppingCartBeforeToLeave(frame:CGRectMake(0, 0, 682, 0))
        beforeLeave.backgroundColor = UIColor.whiteColor()
        self.viewContent.addSubview(beforeLeave)
        
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.light_gray
        self.viewContent.addSubview(viewSeparator)
        
        
        self.presentAddressFullScreen = true
        self.updateTotalItemsRow()
        
    }
 
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let url = NSURL(string: serviceUrl("WalmartMG.CartPromo"))
        imagePromotion.setImageWithURL(url, placeholderImage: UIImage(named:"cart_promo"))
    }

    
    override func viewDidLayoutSubviews() {
        
//        self.viewLoad.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        self.viewLoad.setNeedsLayout()
        
        self.viewHerader.frame = CGRectMake(0, 0, self.view.frame.width, 46)
        self.viewContent.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.viewFooter.frame = CGRectMake(self.viewContent.frame.width - 341, viewContent.frame.height - 72 , 341 , 72)
        self.viewShoppingCart.frame =  CGRectMake(0, self.viewHerader.frame.maxY , self.viewContent.frame.width - 341, 434)
        self.beforeLeave.frame = CGRectMake(0,self.viewShoppingCart.frame.maxY,self.viewContent.frame.width - 341, viewContent.frame.height - self.viewShoppingCart.frame.maxY)
        self.imagePromotion.frame = CGRectMake(self.viewContent.frame.width - 341, self.viewHerader.frame.maxY, 341, 434)
        self.totalsView.frame = CGRectMake(self.viewContent.frame.width - 341, self.imagePromotion.frame.maxY, 341, 168)
        
        self.viewSeparator.frame = CGRectMake(0,self.viewShoppingCart.frame.maxY,self.viewShoppingCart.frame.width,AppDelegate.separatorHeigth())
        
        let x : CGFloat = 16
        let wShop : CGFloat =  341 - 82
        
        self.buttonWishlist.frame = CGRectMake(x,self.buttonWishlist.frame.minY,40,self.buttonWishlist.frame.height)
        
        self.buttonShop.frame = CGRectMake( buttonWishlist.frame.maxX + 16, self.buttonShop.frame.minY, wShop , self.buttonShop.frame.height)
        //customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
        
        self.titleView.frame = CGRectMake(16, self.viewHerader.bounds.minY, self.view.bounds.width - 32, self.viewHerader.bounds.height)
        self.editButton.frame = CGRectMake(self.view.frame.width - 71, 12, 55, 22)
       
        // self.closeButton.frame = CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height)
        
        if self.customlabel != nil {
            self.customlabel.frame = self.buttonShop.bounds
        }
        if self.deleteall != nil {
            self.deleteall.frame = CGRectMake(editButton.frame.minX - 82, 12, 75, 22)
        }
       
    }

    
    override func updateTotalItemsRow() {
        let totalsItems = totalItems()
        let subTotalText = totalsItems["subtotal"] as String!
        let iva = totalsItems["iva"] as String!
        let total = totalsItems["total"] as String!
        let totalSaving = totalsItems["totalSaving"] as String!
        self.updateShopButton(total)
        
        
        totalsView.setValues(subTotalText, iva: iva, total:total,totalSaving:totalSaving)
    }
    
    override func loadShoppingCartService() {
        
        idexesPath = []
        
        self.itemsInCartOrderSection =  []
        if UserCurrentSession.sharedInstance().itemsMG != nil {
            //self.itemsInShoppingCart = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
            let itemsUserCurren = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
            self.itemsInCartOrderSection = RecentProductsViewController.adjustDictionary(itemsUserCurren as [AnyObject]) as! [AnyObject]
            self.arrayItems()
        }
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }

        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            self.subtotal = UserCurrentSession.sharedInstance().itemsMG!["subtotal"] as! NSNumber
            self.ivaprod = UserCurrentSession.sharedInstance().itemsMG!["ivaSubtotal"] as! NSNumber
            self.totalest = UserCurrentSession.sharedInstance().itemsMG!["totalEstimado"] as! NSNumber
        }else{
            self.subtotal = NSNumber(int: 0)
            self.ivaprod = NSNumber(int: 0)
            self.totalest = NSNumber(int: 0)
        }
        
        
        let totalsItems = self.totalItems()
        let total = totalsItems["total"] as String!
        let totalSaving = totalsItems["totalSaving"] as String!
        let subTotalText = totalsItems["subtotal"] as String!
        let iva = totalsItems["iva"] as String!
        
        self.updateShopButton(total)
        
        if self.totalsView != nil {
            self.totalsView.setValues(subTotalText, iva: iva, total:total,totalSaving:totalSaving)
        }
        
        self.viewShoppingCart.delegate = self
        self.viewShoppingCart.dataSource = self
        self.viewShoppingCart.reloadData()
       
        
        self.loadCrossSell()
        self.removeLoadingView()
        
        self.emptyView!.hidden = self.itemsInShoppingCart.count > 0
        self.editButton.hidden = self.itemsInShoppingCart.count == 0
       
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.itemsInCartOrderSection.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        listObj = self.itemsInCartOrderSection[section - 1] as! NSDictionary
        productObje = listObj["products"] as! NSArray
        
        if section == (self.itemsInCartOrderSection.count) {
            return productObje!.count + 1
        } else {
            return productObje!.count
        }
        //return 1
    }
    

    
    func openShoppingCart(){
        if self.viewContent != nil {
            let originalY : CGFloat = self.navigationController!.view.frame.minY
            self.navigationController!.view.frame = CGRectMake(self.navigationController!.view.frame.minX,-self.navigationController!.view.frame.height , self.navigationController!.view.frame.width,  self.navigationController!.view.frame.height)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.navigationController!.view.frame = CGRectMake(self.navigationController!.view.frame.minX,originalY , self.navigationController!.view.frame.width,  self.navigationController!.view.frame.height)
                }) { (completed:Bool) -> Void in
            }
            loadShoppingCartService()
            self.updateTotalItemsRow()
        }
    }
    
    override func deleteRowAtIndexPath(indexPath : NSIndexPath){
        let itemWishlist = itemsInShoppingCart[indexPath.row] as! [String:AnyObject]
        let upc = itemWishlist["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        //let paramUpc = deleteShoppingCartService.builParams(upc)
        //deleteShoppingCartService.callService(paramUpc, successBlock: { (result:NSDictionary) -> Void in
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (result:NSDictionary) -> Void in
            self.itemsInShoppingCart.removeAtIndex(indexPath.row)
            
            if self.itemsInShoppingCart.count > 0 {
                self.viewShoppingCart.reloadData()
                self.updateTotalItemsRow()
            } else {
                 self.onClose?(isClose: true)
                self.navigationController?.popViewControllerAnimated(true)
            }
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    

    override func showloginshop() {
        self.canceledAction = false
        self.buttonShop.enabled = false
        self.buttonShop.alpha = 0.7
        //let storyboard = self.loadStoryboardDefinition()
        let addressService = ShippingAddressByUserService()
        self.buttonShop.enabled = true
        self.buttonShop.alpha = 1.0
        let cont = IPALoginController.showLogin()
        var user = ""
        
        cont!.closeAlertOnSuccess = false
        cont!.okCancelCallBack = {() in
            //check.back()
            self.canceledAction = true
            //let response = self.navigationController?.popToRootViewControllerAnimated(true)
            cont!.closeAlert(true, messageSucesss: false)
        }
        
        if UserCurrentSession.hasLoggedUser() {
            cont!.noAccount?.hidden = true
            cont!.registryButton?.hidden = true
            cont!.valueEmail = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email?.text = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email!.enabled = false
            user = UserCurrentSession.sharedInstance().userSigned!.email as String
        }
        cont!.successCallBack = {() in
            if UserCurrentSession.hasLoggedUser() {
                if user !=  UserCurrentSession.sharedInstance().userSigned!.email {
                     NSNotificationCenter.defaultCenter().postNotificationName(ProfileNotification.updateProfile.rawValue, object: nil)
                    self.reloadShoppingCart()
                }
            }
           
            addressService.callService({ (resultCall:NSDictionary) -> Void in
                if let shippingAddress = resultCall["shippingAddresses"] as? NSArray
                {
                    if shippingAddress.count > 0 {
                        if(cont!.password?.text == nil || cont!.password?.text == "" ){
                            self.showloginshop()
                            cont!.closeAlert(true, messageSucesss: true)
                            return
                        }
                        self.presentedCheckOut(cont!, address: nil)
                        cont!.closeAlert(false, messageSucesss: true)
                    }else {
                        cont!.showAddres()
                        cont!.addressViewController.successCallBack = {() in
                            self.presentedCheckOut(cont!, address: cont!.addressViewController)
                        }
                        cont!.closeAlert(false, messageSucesss: true)
                    }
                }
                else{
                    cont!.showAddres()
                    cont!.addressViewController.successCallBack = {() in
                        self.presentedCheckOut(cont!, address: cont!.addressViewController)
                    }
                    cont!.closeAlert(false, messageSucesss: true)
                }
                }, errorBlock: { (error:NSError) -> Void in
                    self.buttonShop.enabled = true
                    self.buttonShop.alpha = 1.0
                    cont!.showAddres()
                    cont!.addressViewController.successCallBack = {() in
                        self.presentedCheckOut(cont!, address: cont!.addressViewController)
                    }
                    cont!.closeAlert(false, messageSucesss: true)

            })
        }
    }

   override func loadCrossSell() {
    for itemSection in 0 ..< itemsInShoppingCart.count {
        let listObj = self.itemsInShoppingCart[itemSection] as! NSDictionary
        if listObj.count >  0 {
            let upcValue = getExpensive()
            let crossService = CrossSellingProductService()
            crossService.callService(upcValue, successBlock: { (result:NSArray?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: 0) == self.itemsInShoppingCart.count + 2 {
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC as [AnyObject]
                        arrayUPCS.sortInPlace({ (before, after) -> Bool in
                            let priceB = before["price"] as! NSString
                            let priceA = after["price"] as! NSString
                            return priceB.doubleValue < priceA.doubleValue
                        })
                        var resultArray : [AnyObject] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = NSArray(array:resultArray)
                        
                    }
                    if self.itemsInShoppingCart.count >  0  {
                        if self.itemsUPC.count > 0  && !isShowingBeforeLeave {
                            self.beforeLeave.itemsUPC = self.itemsUPC
                            self.beforeLeave.collection.reloadData()
                        }else{
                            
                        }
                    }
                    //self.collection.reloadData()
                }else {
                    
                }
                }, errorBlock: { (error:NSError) -> Void in
                    print("Termina sevicio app")
            })
        }
    }
    
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if itemsInCartOrderSection.count > indexPath.row && !isSelectingProducts  {
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems(indexPath.section, row: indexPath.row)
            controller.ixSelected = self.itemSelect //indexPath.row
            //self.navigationController!.delegate = nil
            self.navigationController!.pushViewController(controller, animated: true)
        }
    
       
    }
    
    override func getUPCItems(section: Int, row: Int) -> [[String:String]] {
        
        var upcItems : [[String:String]] = []
        var countItems = 0
        //Get UPC of All items
        for sect in 0 ..< self.itemsInCartOrderSection.count {
            let lineItems = self.itemsInCartOrderSection[sect]
            let productsline = lineItems["products"]
            for idx in 0 ..< productsline!.count {
                if section == sect && row == idx {
                    self.itemSelect = countItems
                    }
                let upc = productsline![idx]["upc"] as! String
                let desc = productsline![idx]["description"] as! String
                upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue])
                countItems = countItems + 1
            }
        }
        
        
        return upcItems
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMMustangURLServices") as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    override func userShouldChangeQuantity(cell:ProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRectMake(0, 0, 320, 568)
            if cell.typeProd == 1 {
                selectQuantity = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc)
            } else {
                selectQuantity = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),upcProduct:cell.upc as String)
            }
            let text = String(cell.quantity).characters.count < 2 ? "0" : ""
            self.selectQuantity!.lblQuantity.text = "\(text)"+"\(cell.quantity)"
            self.selectQuantity!.updateQuantityBtn()
            selectQuantity!.closeAction = { () in
                self.popup!.dismissPopoverAnimated(true)
            }
            selectQuantity!.addToCartAction = { (quantity:String) in
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let updateService = ShoppingCartUpdateProductsService()
                    updateService.isInCart = true
                    updateService.callCoreDataService(cell.upc, quantity: String(quantity), comments: "", desc:cell.desc,price:cell.price as String,imageURL:cell.imageurl,onHandInventory:cell.onHandInventory,isPreorderable:cell.isPreorderable,category:cell.productDeparment, pesable:String(cell.pesable),successBlock: nil,errorBlock: nil)
                    self.reloadShoppingCart()
                    self.popup!.dismissPopoverAnimated(false)
                } else {
                     self.popup!.dismissPopoverAnimated(false)
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    self.selectQuantity!.lblQuantity?.text = maxProducts < 10 ? "0\(maxProducts)" : "\(maxProducts)"
                }
            }
            let viewController = UIViewController()
            viewController.view = selectQuantity
            viewController.view.frame = frameDetail
            popup = UIPopoverController(contentViewController: viewController)
            popup!.setPopoverContentSize(CGSizeMake(320,394), animated: true)
            popup!.backgroundColor = WMColor.light_blue
            popup!.presentPopoverFromRect(cell.priceSelector.bounds, inView: cell.priceSelector, permittedArrowDirections: UIPopoverArrowDirection.Right, animated: true)
        }
    }

    
    //On Close
    override func closeShoppingCart() {
        onClose?(isClose:false)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func deleteAll() {
        let serviceSCDelete = ShoppingCartDeleteProductsService()
        var upcs : [String] = []
        for itemSClist in self.itemsInCartOrderSection {
            let upc = itemSClist["upc"] as! String
            upcs.append(upc)
        }
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }

        
        serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs), successBlock: { (result:NSDictionary) -> Void in
            print("Error not done")
            
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
            }
            
            self.onClose?(isClose:true)
            self.navigationController?.popViewControllerAnimated(true)
            //self.navigationController!.popToRootViewControllerAnimated(true)
            }) { (error:NSError) -> Void in
                print("error al eliminar todos los productos del carrito: ")
                print(error.localizedDescription)
                
        }
        
    }
    
    override func checkOutController() -> CheckOutViewController {
        return IPACheckOutViewController()
    }
   
}