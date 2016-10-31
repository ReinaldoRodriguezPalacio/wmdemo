//
//  IPAShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/20/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class IPAShoppingCartViewController : ShoppingCartViewController, IPAGRCheckOutViewControllerDelegate, UIPopoverControllerDelegate {
    
    var totalsView : IPAShoppingCartTotalView!
    var beforeLeave : IPAShoppingCartBeforeToLeave!
    
    var ctrlCheckOut : UINavigationController? = nil
    var checkoutVC : IPAGRCheckOutViewController? = nil

    var viewSeparator : UIView!
    var popup : UIPopoverController?
    var onClose : ((_ isClose:Bool) -> Void)? = nil
    var backgroundView: UIView?
    var separatorRight : CALayer!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewFooter.backgroundColor  =  WMColor.light_light_gray
        
        viewShoppingCart.register(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        

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
        
        if UserCurrentSession.sharedInstance().userSigned != nil {
            self.addchekout()
            self.showAlertAddress()
        }
        
        self.backgroundView = UIView()
        self.backgroundView?.frame = CGRect(x: 0.0, y: 0.0, width: 684.0, height: self.view.frame.height)
        self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(IPAGRShoppingCartViewController.hideBackgroundView))
        self.backgroundView?.addGestureRecognizer(tap)
        
        self.separatorRight = CALayer()
        self.separatorRight.backgroundColor = WMColor.light_light_gray.cgColor
        self.view!.layer.insertSublayer(separatorRight!, at: 1000)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
    
        self.viewHerader.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46)
        self.viewContent.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.viewFooter.frame = CGRect(x: self.viewContent.frame.width - 341, y: viewContent.frame.height - 72 , width: 341 , height: 72)
        self.viewShoppingCart.frame =  CGRect(x: 0, y: self.viewHerader.frame.maxY , width: self.viewContent.frame.width - 341, height: 434)
        self.beforeLeave.frame = CGRect(x: 0,y: self.viewShoppingCart.frame.maxY,width: self.viewContent.frame.width - 341, height: viewContent.frame.height - self.viewShoppingCart.frame.maxY)
        self.totalsView.frame = CGRect(x: self.viewContent.frame.width - 341, y: self.beforeLeave.frame.maxY, width: 341, height: 168)
        
        self.viewSeparator.frame = CGRect(x: 0,y: self.viewShoppingCart.frame.maxY,width: self.viewShoppingCart.frame.width,height: AppDelegate.separatorHeigth())
        
        let x : CGFloat = 16
        let wShop : CGFloat =  341 - 82
        
        self.buttonListSelect.frame = CGRect(x: x,y: self.buttonListSelect.frame.minY,width: 40,height: self.buttonListSelect.frame.height)
        
        self.buttonShop.frame = CGRect( x: buttonListSelect.frame.maxX + 16, y: self.buttonShop.frame.minY, width: wShop , height: self.buttonShop.frame.height)
        
        self.titleView.frame = CGRect(x: 0, y: 0, width: !self.emptyView.isHidden ? self.view.frame.width:self.viewSeparator.frame.maxX,height: self.viewHerader.frame.height)
        self.editButton.frame = CGRect(x: self.viewSeparator.frame.maxX - 71, y: 12, width: 55, height: 22)
        
        if self.customlabel != nil {
            self.customlabel.frame = self.buttonShop.bounds
        }
        if self.deleteall != nil {
            self.deleteall.frame = CGRect(x: editButton.frame.minX - 82, y: 12, width: 75, height: 22)
        }
        
        ctrlCheckOut?.view.frame = CGRect(x: self.viewContent.frame.width - 341, y: 0, width: 341, height: self.viewContent.frame.height - 16)
        separatorRight!.frame = CGRect(x: self.viewSeparator.frame.maxX - 1, y: 0, width: 1.0, height: self.view.bounds.width)

    }

    func addchekout(){
        self.viewFooter.isHidden = true
        self.checkoutVC = IPAGRCheckOutViewController()
        checkoutVC!.view.frame = CGRect(x: self.viewContent.frame.width - 341, y: 0, width: 341, height: self.viewContent.frame.height + 35)
        ctrlCheckOut = UINavigationController(rootViewController: checkoutVC!)
        ctrlCheckOut?.view.frame = CGRect(x: self.viewContent.frame.width - 341, y: 0, width: 341, height: self.viewContent.frame.height)
        ctrlCheckOut?.view.frame = CGRect(x: self.viewContent.frame.width - 341, y: 0, width: 341, height: self.viewContent.frame.height + 35)
        //checkoutVC!.hiddenBack = true
        ctrlCheckOut!.isNavigationBarHidden = true
        checkoutVC!.backButton?.isHidden =  true
        checkoutVC?.delegateCheckOut = self
        self.addChildViewController(ctrlCheckOut!)
        self.view.addSubview(ctrlCheckOut!.view)
    }
    
    func shareShoppingCart(){
        
        if self.isEdditing {
            return
        }
        
        self.viewShoppingCart!.setContentOffset(CGPoint.zero , animated: false)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LIST.rawValue, action:WMGAIUtils.ACTION_SHARE.rawValue , label: "")
        
        if let image = self.viewShoppingCart!.screenshot() {
            let imageHead = UIImage(named:"detail_HeaderMail")
            let imgResult = UIImage.verticalImage(from: [imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
           
            popup = UIPopoverController(contentViewController: controller)
            popup!.present(from: CGRect(x: 620, y: 650, width: 300, height: 250), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.down, animated: true)
            
            self.popup!.delegate = self
        }
    }
    
    
    func closeIPAGRCheckOutViewController(){
        
    }
    
    func showViewBackground(_ show:Bool){
        self.showBackgroundView(show)
    }
    
    func showBackgroundView(_ show:Bool){
        if show {
            self.backgroundView?.alpha = 0.0
            self.view.addSubview(self.backgroundView!)
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 1
                }, completion: nil)
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 0.0
                }, completion: {(complete) in
                    self.backgroundView!.removeFromSuperview()
            })
            
            
        }
    }
    
    func hideBackgroundView() {
        self.showBackgroundView(false)
        self.checkoutVC?.navigationController?.popToRootViewController(animated: true)
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
        super.loadShoppingCartService()
        idexesPath = []
        
        self.itemsInCartOrderSection =  []
        if UserCurrentSession.sharedInstance().itemsMG != nil {
            //self.itemsInShoppingCart = UserCurrentSession.sharedInstance().itemsMG!["items"] as! NSArray as [AnyObject]
            let itemsUserCurren = UserCurrentSession.sharedInstance().itemsMG! as! Dictionary<String, AnyObject>
            self.itemsInCartOrderSection = RecentProductsViewController.adjustDictionary(itemsUserCurren, isShoppingCart: true) as! [AnyObject]
            
             checkoutVC?.itemsInCart = itemsUserCurren["commerceItems"] as! [AnyObject] as NSArray!
            
            self.arrayItems()
        }
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewController(animated: true)
        }

        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            //let priceInfo = UserCurrentSession.sharedInstance().itemsMG!["priceInfo"] as! NSDictionary
            self.subtotal = Int(UserCurrentSession.sharedInstance().itemsMG!["rawSubtotal"] as? String ?? "0") as NSNumber!//subtotal
            self.ivaprod = Int(UserCurrentSession.sharedInstance().itemsMG!["amount"] as? String ?? "0") as NSNumber!//ivaSubtotal
            self.totalest = UserCurrentSession.sharedInstance().itemsMG!["total"] as! NSNumber//totalEstimado
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
        
        self.updateShopButton(total)
        
        if self.totalsView != nil {
            self.totalsView.setValues(subTotalText, iva: iva, total:total,totalSaving:totalSaving)
        }
        
        self.viewShoppingCart.delegate = self
        self.viewShoppingCart.dataSource = self
        self.viewShoppingCart.reloadData()
       
        
        self.loadCrossSell()
        
        self.emptyView!.isHidden = self.itemsInShoppingCart.count > 0
        self.editButton.isHidden = self.itemsInShoppingCart.count == 0
        self.separatorRight.isHidden = !self.emptyView!.isHidden
        
        self.titleView.frame = CGRect(x: 0, y: 0, width: !self.emptyView.isHidden ? self.view.frame.width:self.viewSeparator.frame.maxX,height: self.viewHerader.frame.height)
        self.separatorRight.isHidden = !(self.itemsInShoppingCart.count > 0)

       self.removeLoadingView()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.itemsInCartOrderSection.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        listObj = self.itemsInCartOrderSection[section - 1] as! NSDictionary
        productObje = listObj["products"] as! NSArray
        
        if section == (self.itemsInCartOrderSection.count) {
            return productObje!.count + (self.itemsUPC.count > 0 ? 1 : 0)
        } else {
            return productObje!.count
        }
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

    override func showloginshop() {
        self.canceledAction = false
        self.buttonShop.isEnabled = false
        self.buttonShop.alpha = 0.7
        //let storyboard = self.loadStoryboardDefinition()
        let addressService = ShippingAddressByUserService()
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
        cont!.successCallBack = {() in
            if UserCurrentSession.hasLoggedUser() {
                if user !=  UserCurrentSession.sharedInstance().userSigned!.email as String {
                     NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
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
    for itemSection in 0 ..< itemsInShoppingCart.count {
        let listObj = self.itemsInShoppingCart[itemSection] as! NSDictionary
        if listObj.count >  0 {
            let upcValue = getExpensive()
            let crossService = CrossSellingProductService()
            crossService.callService(requestParams: ["skuId":upcValue], successBlock: { (result:NSArray?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    if self.tableView(self.viewShoppingCart, numberOfRowsInSection: 0) == self.itemsInShoppingCart.count + 2 {
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC as [AnyObject]
//                        arrayUPCS.sortInPlace({ (before, after) -> Bool in
//                            let priceB = before["price"] as! NSString
//                            let priceA = after["price"] as! NSString
//                            return priceB.doubleValue < priceA.doubleValue
//                        })
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemsInCartOrderSection.count > (indexPath as NSIndexPath).row && !isSelectingProducts  {
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems((indexPath as NSIndexPath).section, row: (indexPath as NSIndexPath).row) as [AnyObject]
            controller.ixSelected = self.itemSelect //indexPath.row
            //self.navigationController!.delegate = nil
            self.navigationController!.pushViewController(controller, animated: true)
        }
    
       
    }
    
    override func getUPCItems(_ section: Int, row: Int) -> [[String:String]] {
        
        var upcItems : [[String:String]] = []
        var countItems = 0
        //Get UPC of All items
        for lineItems in self.itemsInCartOrderSection {
            let productsline = lineItems["products"] as! [[String:Any]]
            for product in productsline {
//                if section == sect && row == idx {
//                    self.itemSelect = countItems
//                }
                let upc = product["productId"] as! String
                let desc = product["productDisplayName"] as! String
                upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Mg.rawValue])
                countItems = countItems + 1
            }
        }
        
        
        return upcItems
    }
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMMustangURLServices") as! NSDictionary
        let environmentServices = services.object(forKey: environment) as! NSDictionary
        let serviceURL =  environmentServices.object(forKey: serviceName) as! String
        return serviceURL
    }
    
    override func userShouldChangeQuantity(_ cell:ProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRect(x: 0, y: 0, width: 320, height: 568)

            if cell.typeProd == 1 {
                selectQuantity = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.productId)
                
            }else{
                selectQuantity = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,upcProduct:cell.productId)
            }
            
            
            selectQuantity?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                //self.ctrlCheckOut?.addViewLoad()
                if cell.onHandInventory.integerValue <= Int(quantity) {
                    self.selectQuantity?.closeAction()
                    let updateOrderService = UpdateItemToOrderService()
                    let params = updateOrderService.buildParameter(cell.skuId, productId: cell.productId, quantity: quantity, quantityWithFraction: "0", orderedUOM: "EA", orderedQTYWeight: "0")
                    updateOrderService.callService(requestParams: params, succesBlock: {(result) in
                        self.reloadShoppingCart()
                        }, errorBlock: {(error) in
                         self.reloadShoppingCart()
                    })

                } else {
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    
                    var secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    
                    if cell.pesable {
                        secondMessage = NSLocalizedString("productdetail.notaviableinventorywe",comment:"")
                    }
                    
                    let msgInventory = "\(firstMessage)\(cell.onHandInventory) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                }
                
                
            }
            
            selectQuantity?.addUpdateNote = {() in
                let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                var frame = vc!.view.frame
                if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
                    frame = CGRect(x: 0, y: 0, width: vc!.view.frame.height, height: vc!.view.frame.width)
                }
                
                let addShopping = ShoppingCartUpdateController()
                let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
                addShopping.params = params
                vc!.addChildViewController(addShopping)
                addShopping.view.frame = frame
                vc!.view.addSubview(addShopping.view)
                addShopping.didMove(toParentViewController: vc!)
                addShopping.typeProduct = ResultObjectType.Groceries
                addShopping.comments = cell.comments
                addShopping.goToShoppingCart = {() in }
                addShopping.removeSpinner()
                addShopping.addActionButtons()
                addShopping.addNoteToProduct(nil)
                self.popup?.dismiss(animated: true)
                
            }
            selectQuantity?.userSelectValue(String(cell.quantity))
            selectQuantity?.first = true
            if cell.comments.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            }else {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            }
            selectQuantity?.showNoteButtonComplete()
            selectQuantity?.closeAction = { () in
                self.popup!.dismiss(animated: true)
                
            }
            
            let viewController = UIViewController()
            viewController.view = selectQuantity
            viewController.view.frame = frameDetail
            popup = UIPopoverController(contentViewController: viewController)
            popup!.backgroundColor = WMColor.light_blue
            popup!.setContentSize(CGSize(width: 320,height: 394), animated: true)
            popup?.present(from: cell.priceSelector.bounds, in: cell.priceSelector, permittedArrowDirections: .right, animated: true)
            
 
        } else {
            let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
            let frame = vc!.view.frame
            
            
            let addShopping = ShoppingCartUpdateController()
            let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
            addShopping.params = params
            vc!.addChildViewController(addShopping)
            addShopping.view.frame = frame
            vc!.view.addSubview(addShopping.view)
            addShopping.didMove(toParentViewController: vc!)
            addShopping.typeProduct = ResultObjectType.Groceries
            addShopping.comments = cell.comments
            addShopping.goToShoppingCart = {() in }
            addShopping.removeSpinner()
            addShopping.addActionButtons()
            addShopping.addNoteToProduct(nil)
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
            let upc = itemSClist["commerceItemId"] as! String
            upcs.append(upc)
        }
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
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
            self.navigationController?.popViewController(animated: true)
            //self.navigationController!.popToRootViewControllerAnimated(true)
            }) { (error:NSError) -> Void in
                print("error al eliminar todos los productos del carrito: ")
                print(error.localizedDescription)
                
                if self.viewLoad != nil {
                    self.viewLoad.stopAnnimating()
                    self.viewLoad = nil
                }
                
                self.editAction(self.editButton!)
                self.removeLoadingView()
                self.loadShoppingCartService()
                
        }
        
    }
    
    override func checkOutController() -> CheckOutViewController {
        return IPACheckOutViewController()
    }
   
}
