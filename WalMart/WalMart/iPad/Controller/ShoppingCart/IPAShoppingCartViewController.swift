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
        
        var x : CGFloat = 16
        var wShop : CGFloat =  341 - 82
        if UserCurrentSession.sharedInstance().userSigned != nil {
            if UserCurrentSession.sharedInstance().isAssociated == 1{
                buttonAsociate.frame =  CGRectMake(16, 16, 40, 40)
                x = buttonAsociate.frame.maxX + 16
                wShop = 341 - 135
            }
        }
        
        self.buttonWishlist.frame = CGRectMake(x,self.buttonWishlist.frame.minY,40,self.buttonWishlist.frame.height)
        
        self.buttonShop.frame = CGRectMake( buttonWishlist.frame.maxX + 16, self.buttonShop.frame.minY, wShop , self.buttonShop.frame.height)
        //customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
        
        self.titleView.frame = CGRectMake(16, self.viewHerader.bounds.minY, self.view.bounds.width - 32, self.viewHerader.bounds.height)
        self.editButton.frame = CGRectMake(self.view.frame.width - 71, 12, 55, 22)
        self.closeButton.frame = CGRectMake(0, 0, viewHerader.frame.height, viewHerader.frame.height)
        if self.customlabel != nil {
            self.customlabel.frame = self.buttonShop.bounds
        }
        if self.deleteall != nil {
            self.deleteall.frame = CGRectMake(editButton.frame.minX - 82, 12, 75, 22)
        }
        if UserCurrentSession.sharedInstance().userSigned != nil {
            if UserCurrentSession.sharedInstance().isAssociated == 1{
                self.associateDiscount("Si tienes descuento de asociado captura aquí tus datos")

            }
        }
    
    }

    
    override func updateTotalItemsRow() {
        let totalsItems = totalItems()
        let subTotalText = totalsItems["subtotal"] as String!
        let iva = totalsItems["iva"] as String!
        let total = totalsItems["total"] as String!
        let totalSaving = totalsItems["totalSaving"] as String!
        self.updateShopButton(total)
        
        var newTotal = total
        var newTotalSavings = totalSaving
        if self.isEmployeeDiscount {
            newTotal = "\((total as NSString).doubleValue - ((total as NSString).doubleValue *  UserCurrentSession.sharedInstance().porcentageAssociate))"
            newTotalSavings = "\((totalSaving as NSString).doubleValue + ((total as NSString).doubleValue *  UserCurrentSession.sharedInstance().porcentageAssociate))"
        }
        
        totalsView.setValues(subTotalText, iva: iva, total:newTotal,totalSaving:newTotalSavings)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInShoppingCart.count
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
        let addressService = AddressByUserService()
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
        cont!.isMGLogin =  true
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
        if self.itemsInShoppingCart.count >  0 {
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
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if itemsInShoppingCart.count > indexPath.row && !isSelectingProducts  {
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems()
            controller.ixSelected = indexPath.row
            //self.navigationController!.delegate = nil
            self.navigationController!.pushViewController(controller, animated: true)
        }
    
       
    }
    
    override func getUPCItems() -> [[String:String]] {
        
        var upcItems : [[String:String]] = []
        for shoppingCartProduct in  itemsInShoppingCart {
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue])
        }
        
        
        return upcItems
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMURLServices") as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    //On Close
    override func closeShoppingCart() {
        onClose?(isClose:false)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func deleteAll() {
        let serviceSCDelete = ShoppingCartDeleteProductsService()
        var upcs : [String] = []
        for itemSClist in self.itemsInShoppingCart {
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
   
   //alerta
    override func associateDiscount (message: String ){
        super.associateDiscount(message)
        self.imageView?.frame = CGRectMake((self.view.frame.width/2) + 178, viewFooter.frame.minY - 28, self.viewFooter.frame.minY - 100, 38)  }
}