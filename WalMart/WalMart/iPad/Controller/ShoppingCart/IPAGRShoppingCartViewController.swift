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
    
   
    var onSuccessOrder : (() -> Void)? = nil
    
    @IBOutlet var containerGROrder : UIView!
    var viewShowLogin : IPAGRLoginUserOrderView? = nil
    var ctrlCheckOut : UINavigationController? = nil
    var checkoutVC : IPAGRCheckOutViewController? = nil
    var popup : UIPopoverController?
    var viewSeparator : UIView!
    var viewTitleCheckout : UILabel!
    var backgroundView: UIView?

    //MARK: - ViewCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTitleCheckout = UILabel(frame: viewHerader.bounds)
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
    }
    
    func openclose(){
        self.closeShoppingCart()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewHerader.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: 46)
        self.tableShoppingCart.frame =  CGRect(x: 0, y: self.viewHerader.frame.maxY , width: self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), height: self.view.frame.height  - self.viewHerader.frame.maxY)
        viewSeparator!.frame = CGRect(x: self.tableShoppingCart.frame.maxX, y: 0, width: 1.0, height: self.view.bounds.width)
        viewShowLogin?.frame = containerGROrder.bounds
        checkoutVC?.view.frame = containerGROrder.bounds
        ctrlCheckOut?.view.frame = containerGROrder.bounds
        self.editButton.frame = CGRect(x: self.viewSeparator.frame.maxX - 71, y: 12, width: 55, height: 22)
        self.viewTitleCheckout.frame = CGRect(x: self.viewSeparator.frame.maxX , y: 0, width: self.view.frame.width - self.viewSeparator.frame.maxX, height: self.viewHerader.frame.height )
        self.deleteall.frame = CGRect(x: self.editButton.frame.minX - 80, y: 12, width: 75, height: 22)
        self.titleView.frame = CGRect(x: 0, y: 0, width: self.viewSeparator.frame.maxX,height: self.viewHerader.frame.height)

    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IPAGRShoppingCartViewController.openclose), name: NSNotification.Name(rawValue: "CLOSE_GRSHOPPING_CART"), object: nil)

    }
    override func viewDidDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CLOSE_GRSHOPPING_CART"), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInCart.count
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
        let _ = self.checkoutVC?.navigationController?.popToRootViewController(animated: true)
    }
    
    override func closeShoppingCart() {
        onClose?(false)
        let _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    override func deleteRowAtIndexPath(_ indexPath : IndexPath){
        let itemGRSC = itemsInCart[indexPath.row] 
        let upc = itemGRSC["upc"] as! String
        //360 delete
        BaseController.sendAnalyticsAddOrRemovetoCart([itemGRSC], isAdd: false)
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        var allUPCS : [String] = []
        allUPCS.append(upc)
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }
            
        serviceWishDelete.callService(allUPCS, successBlock: { (result:[String:Any]) -> Void in
            UserCurrentSession.sharedInstance.loadGRShoppingCart({ () -> Void in
                
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
                        
                    }
                    
                    self.checkoutVC?.totalView.setValues("\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
                        subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
                        saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())")
                    
                    self.checkoutVC?.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR() -  UserCurrentSession.sharedInstance.estimateSavingGR())")
                     NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.SuccessAddItemsToShopingCart.rawValue), object: self, userInfo: nil)
                    
                    //self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR())")
                } else {
                    self.navigationController!.popViewController(animated: true)
                    self.onClose?(true)
                  
                }
                
            })
            }, errorBlock: { (error:NSError) -> Void in
                print("error")
        })
        
        
      
        
    }
    
   
    override func shareShoppingCart() {
        self.removeListSelector(action: nil)
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(from: self.viewHerader)
        let screen = self.tableShoppingCart.screenshot()
        let imgResult = UIImage.verticalImage(from: [imageHead!,imageHeader!,screen!])
        let controller = UIActivityViewController(activityItems: [imgResult!], applicationActivities: nil)
        popup = UIPopoverController(contentViewController: controller)
        popup!.present(from: CGRect(x: 620, y: 650, width: 300, height: 250), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.down, animated: true)
        
        controller.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed && activityType != UIActivityType.print &&   activityType != UIActivityType.saveToCameraRoll {
                BaseController.sendAnalyticsPush(["event": "compartirRedSocial", "tipoInteraccion" : "share", "redSocial": activityType!])
            }
        }
    }

    override func userShouldChangeQuantity(_ cell:GRProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRect(x: 0, y: 0, width: 320, height: 568)
            if cell.typeProd == 1 {
                selectQuantityGR = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc)
                
            }else{
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(value: cell.price.doubleValue as Double),quantity:cell.quantity,upcProduct:cell.upc)
            }
            
            
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                //self.ctrlCheckOut?.addViewLoad()
                if cell.onHandInventory.integerValue >= Int(quantity) {
                    self.selectQuantityGR?.closeAction()
                    let params = self.buildParamsUpdateShoppingCart(cell,quantity: quantity)
                    
                    NotificationCenter.default.post(name:NSNotification.Name(rawValue: CustomBarNotification.AddUPCToShopingCart.rawValue), object: self, userInfo: params)
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
                let paramsToSC = self.buildParamsUpdateShoppingCart(cell,quantity: "\(cell.quantity)")
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
            selectQuantityGR?.userSelectValue(String(cell.quantity))
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
    
    
    
    //MARK: IPAGRLoginUserOrderViewDelegate
    func showlogin() {
        var cont = IPALoginController.showLogin()
        cont!.closeAlertOnSuccess = false
        cont!.successCallBack = {() in
                NotificationCenter.default.post(name: Notification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
                UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
                    
                    if cont!.alertView != nil {
                        cont!.closeAlert(true, messageSucesss: true)
                    }else {
                        cont!.closeModal()
                    }
                    cont = nil
                     self.loadGRShoppingCart()
                    
                    if self.itemsInCart.count == 0 {
                            self.navigationController!.popViewController(animated: true)
                            self.onClose?(true)
                    }else{
                    
                   
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
    

    override func reloadGRShoppingCart(){
        UserCurrentSession.sharedInstance.loadGRShoppingCart { () -> Void in
           
            self.loadGRShoppingCart()
        }
    }
    
    func shareCart(){
        self.shareShoppingCart()
    }
    
    func addCartProductToList() {
        self.addCartToList()
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

    }
    
    //MARK: - IPAGRCheckOutViewControllerDelegate
    func closeIPAGRCheckOutViewController() {
        if onSuccessOrder != nil {
            onSuccessOrder?()
        }
    }
    
    func showViewBackground(_ show:Bool){
        self.showBackgroundView(show)
    }
    
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
            
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRect(x: originX, y: 0, width: frame.width, height: frame.height)
                    self.listSelectorController!.imageBlurView!.frame = CGRect(x: originX, y: 0, width: frame.width, height: frame.height)
                },
                    completion: { (finished:Bool) -> Void in
                    if finished {
                    }
                }
            )
        }
        else {
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
                                        self.listSelectorController!.imageBlurView!.frame = CGRect(x: originX, y: -frame.height, width: frame.width, height: frame.height)
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

    
}
