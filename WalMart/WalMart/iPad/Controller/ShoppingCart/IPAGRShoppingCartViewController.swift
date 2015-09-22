//
//  IPAGRShoppingCartViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPAGRShoppingCartViewController : GRShoppingCartViewController,IPAGRCheckOutViewControllerDelegate,IPAGRLoginUserOrderViewDelegate {
    
   
    var onSuccessOrder : (() -> Void)? = nil
    
    @IBOutlet var containerGROrder : UIView!
    var viewShowLogin : IPAGRLoginUserOrderView? = nil
    var ctrlCheckOut : IPAGRCheckOutViewController? = nil
    var popup : UIPopoverController?
    var viewSeparator : UIView!
    var viewTitleCheckout : UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTitleCheckout = UILabel(frame: viewHerader.bounds)
        viewTitleCheckout.font = WMFont.fontMyriadProRegularOfSize(14)
        viewTitleCheckout.textColor = WMColor.shoppingCartHeaderTextColor
        viewTitleCheckout.text = "Verifica tu pedido"
        viewTitleCheckout.textAlignment = .Center
        self.viewHerader.addSubview(viewTitleCheckout)
        
        self.viewFooter.hidden = true
        self.view.backgroundColor = UIColor.clearColor()
        if UserCurrentSession.sharedInstance().userSigned == nil {
            viewShowLogin = IPAGRLoginUserOrderView(frame:containerGROrder.bounds)
            viewShowLogin!.delegate = self
            containerGROrder.addSubview(viewShowLogin!)
            self.viewShowLogin?.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
                subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
                saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
        } else {
            ctrlCheckOut = IPAGRCheckOutViewController()
            ctrlCheckOut?.itemsInCart = itemsInCart
            ctrlCheckOut?.delegateCheckOut = self
            self.addChildViewController(ctrlCheckOut!)
            containerGROrder.addSubview(ctrlCheckOut!.view)
        }
        viewSeparator = UIView(frame: CGRectZero)
        viewSeparator.backgroundColor = WMColor.lineSaparatorColor
        self.view.addSubview(viewSeparator!)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewHerader.frame = CGRectMake(0, 0, self.view.frame.width, 46)
        self.tableShoppingCart.frame =  CGRectMake(0, self.viewHerader.frame.maxY , self.view.bounds.width - 341 +  AppDelegate.separatorHeigth(), self.view.frame.height  - self.viewHerader.frame.maxY)
        viewSeparator!.frame = CGRectMake(self.tableShoppingCart.frame.maxX, self.tableShoppingCart.frame.minY, AppDelegate.separatorHeigth(), self.tableShoppingCart.frame.height)
        viewShowLogin?.frame = containerGROrder.bounds
        ctrlCheckOut?.view.frame = containerGROrder.bounds
        self.editButton.frame = CGRectMake(self.viewSeparator.frame.maxX - 71, 12, 55, 22)
        self.viewTitleCheckout.frame = CGRectMake(self.viewSeparator.frame.maxX , 0, self.view.frame.width - self.viewSeparator.frame.maxX, self.viewHerader.frame.height )
        self.deleteall.frame = CGRectMake(self.editButton.frame.minX - 80, 12, 75, 22)
        self.titleView.frame = CGRectMake(0, 0, self.viewSeparator.frame.maxX,self.viewHerader.frame.height)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInCart.count
    }
    
    override func closeShoppingCart() {
        onClose?(isClose:false)
        
    }
    
    
    override func deleteRowAtIndexPath(indexPath : NSIndexPath){
        let itemGRSC = itemsInCart[indexPath.row] as! [String:AnyObject]
        let upc = itemGRSC["upc"] as! String
        
        let serviceWishDelete = GRShoppingCartDeleteProductsService()
        var allUPCS : [String] = []
        allUPCS.append(upc)
        
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(false)
            self.view.addSubview(viewLoad)
        }
            
        serviceWishDelete.callService(allUPCS, successBlock: { (result:NSDictionary) -> Void in
            UserCurrentSession.sharedInstance().loadGRShoppingCart({ () -> Void in
                
                self.itemsInCart.removeAtIndex(indexPath.row)
                if self.itemsInCart.count > 0 {
                    self.tableShoppingCart.reloadData()
                    
                    if self.viewLoad != nil {
                        self.viewLoad.stopAnnimating()
                        self.viewLoad = nil
                    }
                    
                    if self.viewShowLogin != nil {
                        self.viewShowLogin?.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
                            subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
                            saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
                        
                    }
                    
                    self.ctrlCheckOut?.totalView.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
                        subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
                        saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
                    
                    self.ctrlCheckOut?.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR() -  UserCurrentSession.sharedInstance().estimateSavingGR())")
                    //self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR())")
                } else {
                    //self.navigationController!.popToRootViewControllerAnimated(true)
                    self.onClose?(isClose:true)
                  
                }
                
            })
            }, errorBlock: { (error:NSError) -> Void in
                println("error")
        })
        
        
      
        
    }
    
   
    override func shareShoppingCart() {
        self.removeListSelector(action: nil)
        let imageHead = UIImage(named:"detail_HeaderMail")
        let imageHeader = UIImage(fromView: self.viewHerader)
        let screen = self.tableShoppingCart.screenshot()
        let imgResult = UIImage.verticalImageFromArray([imageHead!,imageHeader,screen])
        var controller = UIActivityViewController(activityItems: [imgResult], applicationActivities: nil)
        popup = UIPopoverController(contentViewController: controller)
        popup!.presentPopoverFromRect(CGRectMake(620, 650, 300, 250), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
        
        //self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }

    override     func userShouldChangeQuantity(cell:GRProductShoppingCartTableViewCell) {
        if self.isEdditing == false {
            let frameDetail = CGRectMake(0, 0, 320, 568)
            if cell.typeProd == 1 {
                selectQuantityGR = GRShoppingCartWeightSelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,equivalenceByPiece:cell.equivalenceByPiece,upcProduct:cell.upc)
                
            }else{
                selectQuantityGR = GRShoppingCartQuantitySelectorView(frame:frameDetail,priceProduct:NSNumber(double:cell.price.doubleValue),quantity:cell.quantity,upcProduct:cell.upc)
            }
            
            
            selectQuantityGR?.addToCartAction = { (quantity:String) in
                //let quantity : Int = quantity.toInt()!
                
                if cell.onHandInventory.integerValue >= quantity.toInt() {
                    self.selectQuantityGR?.closeAction()
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
            
            selectQuantityGR?.addUpdateNote = {() in
                let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
                var frame = vc!.view.frame
                
                
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
                
            }
            selectQuantityGR?.userSelectValue(String(cell.quantity))
            selectQuantityGR?.first = true
            if cell.comments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "" {
                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.updateNote",comment:""))
            }else {
                selectQuantityGR.setTitleCompleteButton(NSLocalizedString("shoppingcart.addNote",comment:""))
            }
            selectQuantityGR?.showNoteButtonComplete()
            selectQuantityGR?.closeAction = { () in
                self.popup!.dismissPopoverAnimated(true)
                
            }
            
            let viewController = UIViewController()
            viewController.view = selectQuantityGR
            popup = UIPopoverController(contentViewController: viewController)
            popup!.presentPopoverFromRect(CGRectMake(cell.changeQuantity.frame.origin.x - 10, (cell.frame.minY - self.tableShoppingCart.contentOffset.y - 165) , 320, 568), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Right, animated: true)
            
        } else {
            let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
            var frame = vc!.view.frame
            
            
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if itemsInCart.count > indexPath.row   {
            let controller = IPAProductDetailPageViewController()
            controller.itemsToShow = getUPCItems()
            
            controller.ixSelected = indexPath.row
            self.navigationController!.delegate = nil
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    
    
    func showlogin() {
        
        var cont = IPALoginController.showLogin()
        cont!.closeAlertOnSuccess = false
        cont!.successCallBack = {() in
           
           
                NSNotificationCenter.defaultCenter().postNotificationName(ProfileNotification.updateProfile.rawValue, object: nil)
                UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
                    
                    if cont!.alertView != nil {
                        cont!.closeAlert(true, messageSucesss: true)
                    }else {
                        cont!.closeModal()
                    }
                    cont = nil
                    
                    self.loadGRShoppingCart()
                    self.ctrlCheckOut = IPAGRCheckOutViewController()
                    self.ctrlCheckOut?.view.frame = self.containerGROrder.bounds
                    self.ctrlCheckOut?.itemsInCart = self.itemsInCart
                    self.ctrlCheckOut?.delegateCheckOut = self
                    self.addChildViewController(self.ctrlCheckOut!)
                    self.containerGROrder.addSubview(self.ctrlCheckOut!.view)
                    self.viewShowLogin?.alpha = 0
                    self.viewShowLogin?.removeFromSuperview()
                    self.viewShowLogin = nil
                    
                }
            
            
        }
        return
    }
    

    override func reloadGRShoppingCart(){
        UserCurrentSession.sharedInstance().loadGRShoppingCart { () -> Void in
           
            self.loadGRShoppingCart()
        }
    }
    
    
    
    override func loadGRShoppingCart() {
        super.loadGRShoppingCart()
        
        
        if viewShowLogin != nil {
            self.viewShowLogin?.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
                subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
                saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
            
        }
        
        self.ctrlCheckOut?.totalView.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
            subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
            saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
        
        
        self.ctrlCheckOut?.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR() -  UserCurrentSession.sharedInstance().estimateSavingGR())")
    }
    
    func closeIPAGRCheckOutViewController() {
        if onSuccessOrder != nil {
            onSuccessOrder?()
        }
    }
    
    
    
}