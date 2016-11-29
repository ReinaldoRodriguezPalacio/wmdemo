//
//  IPAShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/20/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
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


class IPAShoppingCartViewController : ShoppingCartViewController {
    

    var imagePromotion : UIImageView!
    var totalsView : IPAShoppingCartTotalView!
    var beforeLeave : IPAShoppingCartBeforeToLeave!
    var viewSeparator : UIView!
    var popup : UIPopoverController?
    var onClose : ((_ isClose:Bool) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewFooter.backgroundColor  =  WMColor.light_light_gray
        
        viewShoppingCart.register(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        
        
        imagePromotion = UIImageView()
        //imagePromotion.image = UIImage(named:"cart_promo")
        
        
        self.viewContent.addSubview(imagePromotion)
        
        
        totalsView = IPAShoppingCartTotalView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.viewContent.addSubview(totalsView)
        
      
        
        beforeLeave = IPAShoppingCartBeforeToLeave(frame:CGRect(x: 0, y: 0, width: 682, height: 0))
        beforeLeave.backgroundColor = UIColor.white
        self.viewContent.addSubview(beforeLeave)
        
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.light_gray
        self.viewContent.addSubview(viewSeparator)
        
        
        self.presentAddressFullScreen = true
        self.updateTotalItemsRow()
        
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = URL(string: serviceUrl("WalmartMG.CartPromo"))
        imagePromotion.setImageWith(url!, placeholderImage: UIImage(named:"cart_promo"))
    }

    
    override func viewDidLayoutSubviews() {
        
//        self.viewLoad.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        self.viewLoad.setNeedsLayout()
        
        self.viewHerader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46)
        self.viewContent.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.viewFooter.frame = CGRect(x: self.viewContent.frame.width - 341, y: viewContent.frame.height - 72 , width: 341 , height: 72)
        self.viewShoppingCart.frame =  CGRect(x: 0, y: self.viewHerader.frame.maxY , width: self.viewContent.frame.width - 341, height: 434)
        self.beforeLeave.frame = CGRect(x: 0,y: self.viewShoppingCart.frame.maxY,width: self.viewContent.frame.width - 341, height: viewContent.frame.height - self.viewShoppingCart.frame.maxY)
        self.imagePromotion.frame = CGRect(x: self.viewContent.frame.width - 341, y: self.viewHerader.frame.maxY, width: 341, height: 434)
        self.totalsView.frame = CGRect(x: self.viewContent.frame.width - 341, y: self.imagePromotion.frame.maxY, width: 341, height: 168)
        
        self.viewSeparator.frame = CGRect(x: 0,y: self.viewShoppingCart.frame.maxY,width: self.viewShoppingCart.frame.width,height: AppDelegate.separatorHeigth())
        
        var x : CGFloat = 16
        var wShop : CGFloat =  341 - 82
        if UserCurrentSession.sharedInstance().userSigned != nil {
            if UserCurrentSession.sharedInstance().isAssociated == 1{
                if buttonAsociate ==  nil {
                    buttonAsociate = UIButton(frame: CGRect(x: 16, y: 16, width: 34, height: 34))
                }else{
                    buttonAsociate.frame =  CGRect(x: 16, y: 16, width: 40, height: 40)
                }
                x = buttonAsociate.frame.maxX + 16
                wShop = 341 - 135
            }
        }
        
        self.buttonWishlist.frame = CGRect(x: x,y: self.buttonWishlist.frame.minY,width: 40,height: self.buttonWishlist.frame.height)
        
        self.buttonShop.frame = CGRect( x: buttonWishlist.frame.maxX + 16, y: self.buttonShop.frame.minY, width: wShop , height: self.buttonShop.frame.height)
        //customlabel = CurrencyCustomLabel(frame: self.buttonShop.bounds)
        
        self.titleView.frame = CGRect(x: 16, y: self.viewHerader.bounds.minY, width: self.view.bounds.width - 32, height: self.viewHerader.bounds.height)
        self.editButton.frame = CGRect(x: self.view.frame.width - 71, y: 12, width: 55, height: 22)
        self.closeButton.frame = CGRect(x: 0, y: 0, width: viewHerader.frame.height, height: viewHerader.frame.height)
        if self.customlabel != nil {
            self.customlabel.frame = self.buttonShop.bounds
        }
        if self.deleteall != nil {
            self.deleteall.frame = CGRect(x: editButton.frame.minX - 82, y: 12, width: 75, height: 22)
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
    
    override func loadShoppingCartService() {
        
        idexesPath = []
        
        self.itemsInShoppingCart =  []
        if UserCurrentSession.sharedInstance().itemsMG != nil {
            self.itemsInShoppingCart = UserCurrentSession.sharedInstance().itemsMG!["items"] as! [Any] as [Any]
        }
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewController(animated: true)
        }

        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            self.subtotal = UserCurrentSession.sharedInstance().itemsMG!["subtotal"] as! NSNumber
            self.ivaprod = UserCurrentSession.sharedInstance().itemsMG!["ivaSubtotal"] as! NSNumber
            self.totalest = UserCurrentSession.sharedInstance().itemsMG!["totalEstimado"] as! NSNumber
        }else{
            self.subtotal = NSNumber(value: 0 as Int32)
            self.ivaprod = NSNumber(value: 0 as Int32)
            self.totalest = NSNumber(value: 0 as Int32)
        }
        
        
        let totalsItems = self.totalItems()
        let total = totalsItems["total"] as String!
        let totalSaving = totalsItems["totalSaving"] as String!
        let subTotalText = totalsItems["subtotal"] as String!
        let iva = totalsItems["iva"] as String!
        if self.buttonShop != nil {
            self.updateShopButton(total)
        }
        
        if self.totalsView != nil {
            self.totalsView.setValues(subTotalText, iva: iva, total:total,totalSaving:totalSaving)
        }
        
        self.viewShoppingCart.delegate = self
        self.viewShoppingCart.dataSource = self
        self.viewShoppingCart.reloadData()
       
        
        self.loadCrossSell()
        self.removeLoadingView()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInShoppingCart.count
    }
    
    func openShoppingCart(){
        if self.viewContent != nil {
            let originalY : CGFloat = self.navigationController!.view.frame.minY
            self.navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX,y: -self.navigationController!.view.frame.height , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.navigationController!.view.frame = CGRect(x: self.navigationController!.view.frame.minX,y: originalY , width: self.navigationController!.view.frame.width,  height: self.navigationController!.view.frame.height)
                }, completion: { (completed:Bool) -> Void in
            }) 
            loadShoppingCartService()
            self.updateTotalItemsRow()
        }
    }
    
    override func deleteRowAtIndexPath(_ indexPath : IndexPath){
        let itemWishlist = itemsInShoppingCart[indexPath.row] as! [String:Any]
        if !UserCurrentSession.hasLoggedUser() {
            BaseController.sendAnalyticsAddOrRemovetoCart([itemWishlist], isAdd: false)
        }
        let upc = itemWishlist["upc"] as! String
        let deleteShoppingCartService = ShoppingCartDeleteProductsService()
        deleteShoppingCartService.callCoreDataService(upc, successBlock: { (result:[String:Any]) -> Void in
            self.itemsInShoppingCart.remove(at: indexPath.row)
            
            if self.itemsInShoppingCart.count > 0 {
                self.viewShoppingCart.reloadData()
                self.updateTotalItemsRow()
            } else {
                 self.onClose?(isClose: true)
                self.navigationController?.popViewController(animated: true)
            }
            
            }, errorBlock: { (error:NSError) -> Void in
                print("delete pressed Errro \(error)")
        })
    }
    

    override func showloginshop() {
        self.canceledAction = false
        self.buttonShop.isEnabled = false
        self.buttonShop.alpha = 0.7
        //let storyboard = self.loadStoryboardDefinition()
        let addressService = AddressByUserService()
        self.buttonShop.isEnabled = true
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
            cont!.noAccount?.isHidden = true
            cont!.registryButton?.isHidden = true
            cont!.valueEmail = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email?.text = UserCurrentSession.sharedInstance().userSigned!.email as String
            cont!.email!.isEnabled = false
            user = UserCurrentSession.sharedInstance().userSigned!.email as String
        }
        cont!.isMGLogin =  true
        cont!.successCallBack = {() in
            if UserCurrentSession.hasLoggedUser() {
                if user !=  UserCurrentSession.sharedInstance().userSigned!.email as String {
                     NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
                    self.reloadShoppingCart()
                }
            }
           
            addressService.callService({ (resultCall:[String:Any]) -> Void in
                if let shippingAddress = resultCall["shippingAddresses"] as? [Any]
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
                    self.buttonShop.isEnabled = true
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
            crossService.callService(upcValue, successBlock: { (result:[Any]?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: 0) == self.itemsInShoppingCart.count + 2 {
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC as [Any]
                        arrayUPCS.sort(by: { (before, after) -> Bool in
                            let priceB = before["price"] as! NSString
                            let priceA = after["price"] as! NSString
                            return priceB.doubleValue < priceA.doubleValue
                        })
                        var resultArray : [Any] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = [Any](array:resultArray)
                        
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemsInShoppingCart.count > indexPath.row && !isSelectingProducts  {
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems() as [Any]
            controller.ixSelected = indexPath.row
            controller.detailOf = "Shopping Cart"
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
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMURLServices") as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        return serviceURL
    }
    
    override func userShouldChangeQuantity(_ cell:ProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRect(x: 0, y: 0, width: 320, height: 568)
            selectQuantity = ShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),upcProduct:cell.upc as String)
            let text = String(cell.quantity).characters.count < 2 ? "0" : ""
            self.selectQuantity!.lblQuantity.text = "\(text)"+"\(cell.quantity)"
            self.selectQuantity!.updateQuantityBtn()
            selectQuantity!.closeAction = { () in
                self.popup!.dismiss(animated: true)
            }
            selectQuantity!.addToCartAction = { (quantity:String) in
                let maxProducts = (cell.onHandInventory.integerValue <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory.integerValue : 5
                if maxProducts >= Int(quantity) {
                    let updateService = ShoppingCartUpdateProductsService()
                    updateService.isInCart = true
                    updateService.callCoreDataService(cell.upc, quantity: String(quantity), comments: "", desc:cell.desc,price:cell.price as String,imageURL:cell.imageurl,onHandInventory:cell.onHandInventory,isPreorderable:cell.isPreorderable,category:cell.productDeparment ,successBlock: nil,errorBlock: nil)
                    self.reloadShoppingCart()
                    self.popup!.dismiss(animated: false)
                } else {
                     self.popup!.dismiss(animated: false)
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
            popup!.setContentSize(CGSize(width: 320,height: 394), animated: true)
            popup!.backgroundColor = WMColor.light_blue
            popup!.present(from: cell.priceSelector.bounds, in: cell.priceSelector, permittedArrowDirections: UIPopoverArrowDirection.right, animated: true)
        }
    }

    
    //On Close
    override func closeShoppingCart() {
        onClose?(false)
        self.navigationController?.popViewController(animated: true)
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
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }

        BaseController.sendAnalyticsAddOrRemovetoCart(self.itemsInShoppingCart , isAdd: false)
        serviceSCDelete.callService(serviceSCDelete.builParamsMultiple(upcs), successBlock: { (result:[String:Any]) -> Void in
            print("Error not done")
            
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
            }
            
            self.onClose?(isClose:true)
            self.navigationController?.popViewController(animated: true)
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
    override func associateDiscount (_ message: String ){
        super.associateDiscount(message)
        self.imageView?.frame = CGRect(x: (self.view.frame.width/2) + 178, y: viewFooter.frame.minY - 28, width: self.viewFooter.frame.minY - 100, height: 38)  }
}
