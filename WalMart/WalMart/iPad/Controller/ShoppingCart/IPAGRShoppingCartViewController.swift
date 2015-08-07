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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        self.editButton.frame = CGRectMake(self.view.frame.width - 71, 12, 55, 22)
        
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