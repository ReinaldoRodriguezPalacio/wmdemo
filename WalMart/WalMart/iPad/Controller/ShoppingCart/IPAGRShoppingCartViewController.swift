//
//  IPAGRShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
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


class IPAGRShoppingCartViewController : GRShoppingCartViewController,IPAGRCheckOutViewControllerDelegate,IPAGRLoginUserOrderViewDelegate {
    
    @IBOutlet var containerGROrder : UIView!
    
    var onSuccessOrder : (() -> Void)? = nil
    var viewShowLogin : IPAGRLoginUserOrderView? = nil
    var ctrlCheckOut : UINavigationController? = nil
    var checkoutVC : IPAGRCheckOutViewController? = nil
    var popup : UIPopoverController?
    var viewSeparator : UIView!
    var viewSeparator2 : UIView!
    var viewTitleCheckout : UILabel!
    var backgroundView: UIView?
    var beforeLeave : IPAShoppingCartBeforeToLeave!

    //MARK: - ViewCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        viewTitleCheckout = UILabel(frame: viewHeader.bounds)
        viewTitleCheckout.font = WMFont.fontMyriadProRegularOfSize(14)
        viewTitleCheckout.textColor = WMColor.light_blue
        viewTitleCheckout.text = "Verifica tu pedido"
        viewTitleCheckout.textAlignment = .center
        viewTitleCheckout.backgroundColor = WMColor.light_light_gray
        self.view.addSubview(viewTitleCheckout)
        
        self.viewFooter.isHidden = true
        self.view.backgroundColor = UIColor.clear
        if UserCurrentSession.sharedInstance.userSigned == nil {
            viewShowLogin = IPAGRLoginUserOrderView(frame:containerGROrder.bounds)
            viewShowLogin!.delegate = self
            containerGROrder.addSubview(viewShowLogin!)
            self.viewShowLogin?.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
                subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
                saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
        } else {
            self.viewTitleCheckout.isHidden = true
            self.checkoutVC = IPAGRCheckOutViewController()
            checkoutVC!.view.frame = containerGROrder.bounds
            ctrlCheckOut = UINavigationController(rootViewController: checkoutVC!)
            ctrlCheckOut?.view.frame = containerGROrder.bounds
            //checkoutVC!.hiddenBack = true
            ctrlCheckOut!.isNavigationBarHidden = true
            checkoutVC?.itemsInCart = itemsInCart as [Any]!
            checkoutVC?.delegateCheckOut = self
            self.addChildViewController(ctrlCheckOut!)
            containerGROrder.addSubview(ctrlCheckOut!.view)
        }
        
        viewSeparator = UIView(frame: CGRect.zero)
        viewSeparator.backgroundColor = WMColor.light_light_gray
        self.view.addSubview(viewSeparator!)
        
        self.backgroundView = UIView()
        self.backgroundView?.frame = CGRect(x: 0.0, y: 0.0, width: 684.0, height: self.view.frame.height)
        self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(IPAGRShoppingCartViewController.hideBackgroundView))
        self.backgroundView?.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(IPAGRShoppingCartViewController.openclose), name: NSNotification.Name(rawValue: "CLOSE_GRSHOPPING_CART"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewHeader.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: 46)
        if self.itemsUPC.count > 0{
            
            self.tableShoppingCart.frame =  CGRect(x: 0, y: self.viewHeader.frame.maxY , width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: self.view.frame.height  - self.viewHeader.frame.maxY - 207)
            
            
        }else{
            
            self.tableShoppingCart.frame =  CGRect(x: 0, y: self.viewHeader.frame.maxY , width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: self.view.frame.height  - self.viewHeader.frame.maxY)
            
        }

        viewSeparator!.frame = CGRect(x: self.tableShoppingCart.frame.maxX, y: 0, width: 1.0, height: self.view.bounds.width)
        viewShowLogin?.frame = containerGROrder.bounds
        checkoutVC?.view.frame = containerGROrder.bounds
        ctrlCheckOut?.view.frame = containerGROrder.bounds
        self.editButton.frame = CGRect(x: self.viewSeparator.frame.maxX - 71, y: 12, width: 55, height: 22)
        self.viewTitleCheckout.frame = CGRect(x: self.viewSeparator.frame.maxX , y: 0, width: self.view.frame.width - self.viewSeparator.frame.maxX, height: self.viewHeader.frame.height )
        self.deleteall.frame = CGRect(x: self.editButton.frame.minX - 80, y: 12, width: 75, height: 22)
        self.titleView.frame = CGRect(x: 0, y: 0, width: self.viewSeparator.frame.maxX,height: self.viewHeader.frame.height)
        
        tableShoppingCart.backgroundColor=WMColor.light_light_gray
            }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadCrossSell()
    }

    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CLOSE_GRSHOPPING_CART"), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInCart.count
    }
    
    override func closeShoppingCart() {
        onClose?(false)
        let _ = self.navigationController?.popViewController(animated: true)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewSeparator.isHidden = !self.emptyView!.isHidden
        
    }
    
    override func deleteRowAtIndexPath(_ indexPath : IndexPath){
        let itemGRSC = itemsInCart[indexPath.row]
        let upc = itemGRSC["upc"] as! String
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        let allUPCS: [String] = [upc]
        
        //360 delete
        BaseController.sendAnalyticsAddOrRemovetoCart([itemGRSC], isAdd: false)
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }
        
        serviceWishDelete.callService(allUPCS, successBlock: { (result:[String:Any]) -> Void in
            
            self.itemsInCart.remove(at: indexPath.row)
            if self.itemsInCart.count > 0 {
                self.tableShoppingCart.reloadData()
                
                if self.viewLoad != nil {
                    self.viewLoad.stopAnnimating()
                    self.viewLoad = nil
                }
                
                if self.viewShowLogin != nil {
                    self.viewShowLogin?.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
                        subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
                        saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
                    
                    self.checkoutVC?.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR() -  UserCurrentSession.sharedInstance.estimateSavingGR())")
                    //NotificationCenter.default.post(name: .successUpdateItemsInShoppingCart, object: nil)
                    
                    //self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR())")
                 }
                } else {
                    self.navigationController!.popViewController(animated: true)
                    self.onClose?(true)
                    
                }
            }, errorBlock: { (error:NSError) -> Void in
            print("error")
        })
        
        
        
        
    }
    
    override func shareShoppingCart() {
        self.removeListSelector(action: nil)
      let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.viewHeader.frame.width, height: 70.0))
      let image = UIImage(named: "detail_HeaderMail")
      imageView.image = image
      let imageHead = UIImage(from: imageView) //(named:"detail_HeaderMail") //
      
        self.closeButton?.isHidden = true
        self.editButton?.isHidden = true
        let imageHeader = UIImage(from: self.viewHeader)
        self.closeButton?.isHidden = false
        self.closeButton?.isHidden = false
        
        let screen = self.tableShoppingCart.screenshot()
        let imgResult = UIImage.verticalImage(from: [imageHead!,imageHeader!,screen!])
        let urlWmart = UserCurrentSession.urlWithRootPath("https://www.walmart.com.mx")
        
        let controller = UIActivityViewController(activityItems: [self, imgResult!, urlWmart], applicationActivities: nil)
        popup = UIPopoverController(contentViewController: controller)
        popup!.present(from: CGRect(x: 620, y: 650, width: 300, height: 250), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.down, animated: true)
        
        controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
            }
        }
    }

    override func loadCrossSell() {
        if self.itemsInCart.count >  0 {
            let upcValue = getExpensive()
            let crossService = CrossSellingGRProductService()
            crossService.callService(upcValue, successBlock: { (result:[[String:Any]]?) -> Void in
                if result != nil {
                    
                    var isShowingBeforeLeave = false
                    if self.tableView(self.tableShoppingCart, numberOfRowsInSection: 0) == self.itemsInCart.count + 2 {
                        isShowingBeforeLeave = true
                    }
                    
                    self.itemsUPC = result!
                    
                    if self.itemsUPC.count > 0{
                       
                        
                        
                         self.beforeLeave = IPAShoppingCartBeforeToLeave(frame:CGRect(x: 0, y: 0, width: 682, height: 207))
                        self.beforeLeave.frame = CGRect(x : 0, y : self.tableShoppingCart.frame.maxY, width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: 207)
                        self.beforeLeave.backgroundColor = UIColor.white
                        self.view.addSubview(self.beforeLeave)
                        
                       
                    }else{
                        
                        self.beforeLeave.frame = CGRect(x : 0, y : self.tableShoppingCart.frame.maxY, width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: 0)
                        self.tableShoppingCart.frame =  CGRect(x: 0, y: self.viewHeader.frame.maxY , width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: self.view.frame.height  - self.viewHeader.frame.maxY)
                        
                    }

                    if self.itemsUPC.count > 3 {
                        var arrayUPCS = self.itemsUPC
                        arrayUPCS.sort(by: { (before, after) -> Bool in
                            let priceB = before["price"] as! NSString
                            let priceA = after["price"] as! NSString
                            return priceB.doubleValue < priceA.doubleValue
                        })
                        var resultArray : [Any] = []
                        for item in arrayUPCS[0...2] {
                            resultArray.append(item)
                        }
                        self.itemsUPC = resultArray as! [[String : Any]]
                        
                    }
                    if self.itemsInCart.count >  0  {
                        if self.itemsUPC.count > 0  && !isShowingBeforeLeave {
                            self.beforeLeave?.itemsUPC = self.itemsUPC
                            self.beforeLeave?.collection.reloadData()
                        }
                    }
                    //self.collection.reloadData()
                }
            }, errorBlock: { (error:NSError) -> Void in
                print("Termina sevicio app")
                
                self.tableShoppingCart.frame =  CGRect(x: 0, y: self.viewHeader.frame.maxY , width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: self.view.frame.height  - self.viewHeader.frame.maxY)
            })
        }
    }

    //MARK: activityViewControllerDelegate
    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any{
        return "Walmart"
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if activityType == UIActivityType.mail {
            return "Hola,\nMira estos productos que encontré en Walmart. ¡Te los recomiendo!"
        }
        return ""
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        if activityType == UIActivityType.mail {
            if UserCurrentSession.sharedInstance.userSigned == nil {
                return "Hola te quiero enseñar mi carrito de www.walmart.com.mx"
            } else {
                return "\(UserCurrentSession.sharedInstance.userSigned!.profile.name) \(UserCurrentSession.sharedInstance.userSigned!.profile.lastName) te quiere enseñar su carrito de www.walmart.com.mx"
            }
        }
        return ""
    }
    //----
    
    override func userShouldChangeQuantity(_ cell:GRProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            
            let frameDetail = CGRect(x: 0, y: 0, width: 320, height: 568)
            
            if cell.typeProd == 1 {
                selectQuantityGR = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc, isSearchProductView: false)
                
            } else{
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,upcProduct:cell.upc)
            }
            
            if cell.orderByPieces {
                selectQuantityGR?.validateOrderByPiece(orderByPiece: cell.orderByPieces, quantity: Double(cell.quantity), pieces: cell.pieces)
            } else {
                selectQuantityGR?.userSelectValue(String(cell.quantity))
                selectQuantityGR?.first = true
            }
            
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                //self.ctrlCheckOut?.addViewLoad()
                if quantity ==  "00"{
                    self.selectQuantityGR?.closeAction()
                    self.deleteRowAtIndexPath(self.tableShoppingCart.indexPath(for: cell)!)
                    return
                }
                
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    
                    self.selectQuantityGR?.closeAction()
                    cell.orderByPieces = self.selectQuantityGR!.orderByPiece
                    cell.pieces = Int(quantity)! // cell.equivalenceByPiece.intValue > 0 ? (Int(quantity)! / cell.equivalenceByPiece.intValue): (Int(quantity)!)
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity)
                    NotificationCenter.default.post(name: .addUPCToShopingCart, object: self, userInfo: params)
                    
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
            
            selectQuantityGR?.addUpdateNote = {() in
                let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
                var frame = vc!.view.frame
                if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
                    frame = CGRect(x: 0, y: 0, width: vc!.view.frame.height, height: vc!.view.frame.width)
                }
                
                let addShopping = ShoppingCartUpdateController()
                let paramsToSC = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity!)")
                addShopping.params = paramsToSC
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
            selectQuantityGR?.userSelectValue(String(cell.quantity!))
            selectQuantityGR?.first = true
            //            if cell.comments.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
            //                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            //            }else {
            //                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            //            }
            //            selectQuantityGR?.showNoteButtonComplete()
            selectQuantityGR?.closeAction = { () in
                self.popup!.dismiss(animated: true)
                
            }
            
            let viewController = UIViewController()
            viewController.view = selectQuantityGR
            viewController.view.frame = frameDetail
            popup = UIPopoverController(contentViewController: viewController)
            popup!.backgroundColor = WMColor.light_blue
            popup!.setContentSize(CGSize(width: 320,height: 394), animated: true)
            popup!.present(from: cell.changeQuantity.bounds, in: cell.changeQuantity, permittedArrowDirections: UIPopoverArrowDirection.right, animated: true)
            
        } else {
            let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
            let frame = vc!.view.frame
            
            
            let addShopping = ShoppingCartUpdateController()
            let params = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity!)")
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemsInCart.count > indexPath.row   {
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems() as [Any]
            controller.detailOf = "Shopping Cart"
            controller.ixSelected = indexPath.row
            self.navigationController!.delegate = nil
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func showBackgroundView(_ show:Bool) {
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
        let _ = self.checkoutVC?.navigationController?.popToRootViewController(animated: true)
    }
    
    func openclose() {
        self.closeShoppingCart()
    }
    
    
    //MARK: IPAGRLoginUserOrderViewDelegate
    
    override func reloadGRShoppingCart(){
        UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
            self.loadGRShoppingCart()
        }
    }
    
    override func loadGRShoppingCart() {
        super.loadGRShoppingCart()
        
        if viewShowLogin != nil {
            self.viewShowLogin?.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
                subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
                saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
        }
        
        self.checkoutVC?.totalView.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
            subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
            saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
        
        self.checkoutVC?.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR() -  UserCurrentSession.sharedInstance.estimateSavingGR())")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(name: Notification.Name(rawValue: "INVOKE_RELOAD_PROMOTION"), object: nil)
        /*if UserCurrentSession.hasLoggedUser() {
         self.ctrlCheckOut?.invokeGetPromotionsService(self.ctrlCheckOut!.picker.textboxValues!, discountAssociateItems: self.ctrlCheckOut!.picker.itemsToShow, endCallPromotions: { (finish) -> Void in
         print("End form Ipa Shpping cart")
         })
         }*/
        
        self.beforeLeave?.collection.reloadData()
        
    }
    
    func showlogin() {
       
        var cont = IPALoginController.showLogin()
        cont!.closeAlertOnSuccess = false
        cont!.successCallBack = {() in
            NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
            UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                
                if cont!.alertView != nil {
                    cont!.closeAlert(true, messageSucesss: true)
                } else {
                    cont!.closeModal()
                }
                
                cont = nil
                self.loadGRShoppingCart()
                
                if self.itemsInCart.count == 0 {
                    self.navigationController!.popViewController(animated: true)
                    self.onClose?(true)
                } else {
                    self.checkoutVC = IPAGRCheckOutViewController()
                    self.checkoutVC?.view.frame = self.containerGROrder.bounds
                    self.ctrlCheckOut = UINavigationController(rootViewController: self.checkoutVC!)
                    self.ctrlCheckOut?.view.frame = self.containerGROrder.bounds
                    self.checkoutVC?.itemsInCart = self.itemsInCart as [Any]!
                    self.checkoutVC?.delegateCheckOut = self
                    self.ctrlCheckOut!.isNavigationBarHidden = true
                    self.addChildViewController(self.ctrlCheckOut!)
                    self.containerGROrder.addSubview(self.ctrlCheckOut!.view)
                }
                
                self.viewShowLogin?.alpha = 0
                self.viewShowLogin?.removeFromSuperview()
                self.viewShowLogin = nil
            }
        }
        
        return
    }
    
    func shareCart(){
        self.shareShoppingCart()
    }
    
    func addCartProductToList() {
        self.addCartToList()
    }
    
    
    //MARK: - IPAGRCheckOutViewControllerDelegate
    
    override func addCartToList(){
        
        if self.listSelectorController == nil {
            
            self.addToListButton!.isSelected = true
            let frame = self.viewShowLogin!.frame
            let originX = self.view.frame.width - frame.width
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.hiddenOpenList = true
            self.listSelectorController!.delegate = self
            //self.listSelectorController!.productUpc = self.upc
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRect(x: originX, y: frame.height, width: frame.width, height: frame.height)
            //self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.view.addSubview(self.listSelectorController!.view)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRect(x: originX, y: 0, width: frame.width, height: frame.height)
                //self.listSelectorController!.imageBlurView!.frame = CGRect(x: originX, y: 0, width: frame.width, height: frame.height)
            })
            
        } else {
            self.removeListSelector(action: nil)
        }
    }
    
    override func removeListSelector(action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: .layoutSubviews,
                           animations: { () -> Void in
                            let frame = self.viewShowLogin!.frame
                            let originX = self.view.frame.width - frame.width
                            self.listSelectorController!.view.frame = CGRect(x: originX, y: frame.height, width: frame.width, height: 0.0)
                            //self.listSelectorController!.imageBlurView!.frame = CGRect(x: originX, y: -frame.height, width: frame.width, height: frame.height)
            }, completion: { (complete:Bool) -> Void in
                if complete {
                    if self.listSelectorController != nil {
                        self.listSelectorController!.willMove(toParentViewController: nil)
                        self.listSelectorController!.view.removeFromSuperview()
                        self.listSelectorController!.removeFromParentViewController()
                        self.listSelectorController = nil
                    }
                    self.addToListButton!.isSelected = false
                    
                    action?()
                }
            }
            )
        }
    }
    
    func closeIPAGRCheckOutViewController() {
        if onSuccessOrder != nil {
            onSuccessOrder?()
        }
    }
    
    func showViewBackground(_ show:Bool){
        self.showBackgroundView(show)
    }
    
    func showListDetail(_ listId: String, andName name:String){
        print("tap listSelectorDidShowList")
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func showListDetailLocally(_ list: List) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }

}
