//
//  IPAShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/20/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAShoppingCartViewController : ShoppingCartViewController, IPAGRCheckOutViewControllerDelegate, UIPopoverControllerDelegate {
    
    var totalsView : IPAShoppingCartTotalView!
    var beforeLeave : IPAShoppingCartBeforeToLeave!
    
    var ctrlCheckOut : UINavigationController? = nil
    var checkoutVC : IPAGRCheckOutViewController? = nil

    var viewSeparator : UIView!
    var popup : UIPopoverController?
    var onClose : ((isClose:Bool) -> Void)? = nil
    var backgroundView: UIView?
    var separatorRight : CALayer!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewFooter.backgroundColor  =  WMColor.light_light_gray
        
        viewShoppingCart.registerClass(ProductShoppingCartTableViewCell.self, forCellReuseIdentifier: "productCell")
        

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
        
        if UserCurrentSession.sharedInstance().userSigned != nil {
            self.addchekout()
            self.showAlertAddress()
        }
        
        self.backgroundView = UIView()
        self.backgroundView?.frame = CGRectMake(0.0, 0.0, 684.0, self.view.frame.height)
        self.backgroundView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(IPAGRShoppingCartViewController.hideBackgroundView))
        self.backgroundView?.addGestureRecognizer(tap)
        
        self.separatorRight = CALayer()
        self.separatorRight.backgroundColor = WMColor.light_light_gray.CGColor
        self.view!.layer.insertSublayer(separatorRight!, atIndex: 1000)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
    
        self.viewHerader.frame = CGRectMake(0, 0, self.view.frame.width, 46)
        self.viewContent.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.viewFooter.frame = CGRectMake(self.viewContent.frame.width - 341, viewContent.frame.height - 72 , 341 , 72)
        self.viewShoppingCart.frame =  CGRectMake(0, self.viewHerader.frame.maxY , self.viewContent.frame.width - 341, 434)
        self.beforeLeave.frame = CGRectMake(0,self.viewShoppingCart.frame.maxY,self.viewContent.frame.width - 341, viewContent.frame.height - self.viewShoppingCart.frame.maxY)
        self.totalsView.frame = CGRectMake(self.viewContent.frame.width - 341, self.beforeLeave.frame.maxY, 341, 168)
        
        self.viewSeparator.frame = CGRectMake(0,self.viewShoppingCart.frame.maxY,self.viewShoppingCart.frame.width,AppDelegate.separatorHeigth())
        
        let x : CGFloat = 16
        let wShop : CGFloat =  341 - 82
        
        self.buttonListSelect.frame = CGRectMake(x,self.buttonListSelect.frame.minY,40,self.buttonListSelect.frame.height)
        
        self.buttonShop.frame = CGRectMake( buttonListSelect.frame.maxX + 16, self.buttonShop.frame.minY, wShop , self.buttonShop.frame.height)
        
        self.titleView.frame = CGRectMake(0, 0, !self.emptyView.hidden ? self.view.frame.width:self.viewSeparator.frame.maxX,self.viewHerader.frame.height)
        self.editButton.frame = CGRectMake(self.viewSeparator.frame.maxX - 71, 12, 55, 22)
        
        if self.customlabel != nil {
            self.customlabel.frame = self.buttonShop.bounds
        }
        if self.deleteall != nil {
            self.deleteall.frame = CGRectMake(editButton.frame.minX - 82, 12, 75, 22)
        }
        
        ctrlCheckOut?.view.frame = CGRectMake(self.viewContent.frame.width - 341, 0, 341, self.viewContent.frame.height - 16)
        separatorRight!.frame = CGRectMake(self.viewSeparator.frame.maxX - 1, 0, 1.0, self.view.bounds.width)

    }

    func addchekout(){
        self.viewFooter.hidden = true
        self.checkoutVC = IPAGRCheckOutViewController()
        checkoutVC!.view.frame = CGRectMake(self.viewContent.frame.width - 341, 0, 341, self.viewContent.frame.height + 35)
        ctrlCheckOut = UINavigationController(rootViewController: checkoutVC!)
        ctrlCheckOut?.view.frame = CGRectMake(self.viewContent.frame.width - 341, 0, 341, self.viewContent.frame.height)
        ctrlCheckOut?.view.frame = CGRectMake(self.viewContent.frame.width - 341, 0, 341, self.viewContent.frame.height + 35)
        //checkoutVC!.hiddenBack = true
        ctrlCheckOut!.navigationBarHidden = true
        checkoutVC!.backButton?.hidden =  true
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
            let imgResult = UIImage.verticalImageFromArray([imageHead!,image])
            let controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
           
            popup = UIPopoverController(contentViewController: controller)
            popup!.presentPopoverFromRect(CGRectMake(620, 650, 300, 250), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
            
            self.popup!.delegate = self
        }
    }
    
    
    func closeIPAGRCheckOutViewController(){
        
    }
    
    func showViewBackground(show:Bool){
        self.showBackgroundView(show)
    }
    
    func showBackgroundView(show:Bool){
        if show {
            self.backgroundView?.alpha = 0.0
            self.view.addSubview(self.backgroundView!)
            UIView.animateWithDuration(0.3, animations: {
                self.backgroundView?.alpha = 1
                }, completion: nil)
        }else{
            UIView.animateWithDuration(0.3, animations: {
                self.backgroundView?.alpha = 0.0
                }, completion: {(complete) in
                    self.backgroundView!.removeFromSuperview()
            })
            
            
        }
    }
    
    func hideBackgroundView() {
        self.showBackgroundView(false)
        self.checkoutVC?.navigationController?.popToRootViewControllerAnimated(true)
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
            
             checkoutVC?.itemsInCart = itemsUserCurren["commerceItems"] as! [AnyObject]
            
            self.arrayItems()
        }
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }

        
        if self.itemsInShoppingCart.count == 0 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        if  self.itemsInShoppingCart.count > 0 {
            //let priceInfo = UserCurrentSession.sharedInstance().itemsMG!["priceInfo"] as! NSDictionary
            self.subtotal = Int(UserCurrentSession.sharedInstance().itemsMG!["rawSubtotal"] as? String ?? "0")//subtotal
            self.ivaprod = Int(UserCurrentSession.sharedInstance().itemsMG!["amount"] as? String ?? "0")//ivaSubtotal
            self.totalest = UserCurrentSession.sharedInstance().itemsMG!["total"] as! NSNumber//totalEstimado
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
        
        self.emptyView!.hidden = self.itemsInShoppingCart.count > 0
        self.editButton.hidden = self.itemsInShoppingCart.count == 0
        self.separatorRight.hidden = !self.emptyView!.hidden
        
        self.titleView.frame = CGRectMake(0, 0, !self.emptyView.hidden ? self.view.frame.width:self.viewSeparator.frame.maxX,self.viewHerader.frame.height)
        self.separatorRight.hidden = !(self.itemsInShoppingCart.count > 0)

       self.removeLoadingView()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.itemsInCartOrderSection.count + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        listObj = self.itemsInCartOrderSection[section - 1] as! NSDictionary
        productObje = listObj["products"] as! NSArray
        
        return productObje!.count
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
                
            }else{
                selectQuantity = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,upcProduct:cell.upc)
            }
            
            
            selectQuantity?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                //self.ctrlCheckOut?.addViewLoad()
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    self.selectQuantity?.closeAction()
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddUPCToShopingCart.rawValue, object: self, userInfo: params)
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
                let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
                var frame = vc!.view.frame
                if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
                    frame = CGRectMake(0, 0, vc!.view.frame.height, vc!.view.frame.width)
                }
                
                let addShopping = ShoppingCartUpdateController()
                let paramsToSC = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
                addShopping.params = paramsToSC
                vc!.addChildViewController(addShopping)
                addShopping.view.frame = frame
                vc!.view.addSubview(addShopping.view)
                addShopping.didMoveToParentViewController(vc!)
                addShopping.typeProduct = ResultObjectType.Groceries
                addShopping.comments = cell.comments
                addShopping.goToShoppingCart = {() in }
                addShopping.removeSpinner()
                addShopping.addActionButtons()
                addShopping.addNoteToProduct(nil)
                self.popup?.dismissPopoverAnimated(true)
                
            }
            selectQuantity?.userSelectValue(String(cell.quantity))
            selectQuantity?.first = true
            if cell.comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            }else {
                selectQuantity!.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            }
            selectQuantity?.showNoteButtonComplete()
            selectQuantity?.closeAction = { () in
                self.popup!.dismissPopoverAnimated(true)
                
            }
            
            let viewController = UIViewController()
            viewController.view = selectQuantity
            viewController.view.frame = frameDetail
            popup = UIPopoverController(contentViewController: viewController)
            popup!.backgroundColor = WMColor.light_blue
            popup!.setPopoverContentSize(CGSizeMake(320,394), animated: true)
            popup?.presentPopoverFromRect(cell.priceSelector.bounds, inView: cell.priceSelector, permittedArrowDirections: .Right, animated: true)
            
 
        } else {
            let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
            let frame = vc!.view.frame
            
            
            let addShopping = ShoppingCartUpdateController()
            let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
            addShopping.params = params
            vc!.addChildViewController(addShopping)
            addShopping.view.frame = frame
            vc!.view.addSubview(addShopping.view)
            addShopping.didMoveToParentViewController(vc!)
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