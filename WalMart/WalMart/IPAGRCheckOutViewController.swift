//
//  IPAGRCheckOutViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 3/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IPAGRCheckOutViewControllerDelegate {
    func shareShoppingCart()
    func closeIPAGRCheckOutViewController()
}

class IPAGRCheckOutViewController : GRCheckOutViewController,ListSelectorDelegate {
    
    var addToListButton: UIButton!
    var buttonShare: UIButton!
    var itemsInCart: NSArray!
    var listSelectorController: ListsSelectorViewController?
    var delegateCheckOut : IPAGRCheckOutViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.header!.hidden = true
        
        self.addToListButton = UIButton(frame: CGRectMake(8 ,0, 50, footer!.frame.height))
        self.addToListButton!.setImage(UIImage(named: "detail_list"), forState: .Normal)
        self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), forState: .Selected)
        self.addToListButton!.addTarget(self, action: "addCartToList", forControlEvents: .TouchUpInside)
        
        buttonShare = UIButton(frame: CGRectMake(self.addToListButton!.frame.maxX, 0, 50, footer!.frame.height))
        buttonShare.setImage(UIImage(named: "detail_shareOff"), forState: UIControlState.Normal)
        buttonShare.addTarget(self, action: "shareShoppingCart", forControlEvents: UIControlEvents.TouchUpInside)
        
        footer!.addSubview(self.addToListButton!)
        footer!.addSubview(self.buttonShare)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.frame.size
        var resumeHeight:CGFloat = 75.0
        var footerHeight:CGFloat = 60.0
        
        //self.viewLoad.frame = self.view.bounds
        self.totalView.frame = CGRectMake(0, self.confirmation!.frame.maxY + 10, self.view.bounds.width, 60)
        self.content!.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height - footerHeight)
        self.content.contentSize = CGSizeMake(self.view.bounds.width, totalView.frame.maxY + 20.0)
        
        
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        
        
        self.footer!.frame = CGRectMake(0.0, self.view.bounds.height - footerHeight, bounds.width, footerHeight)
        
        var margin: CGFloat = 15.0
        var widthField = self.view.bounds.width - (2*margin)
        var fheight: CGFloat = 44.0
        var lheight: CGFloat = 25.0
        
        self.paymentOptions!.frame = CGRectMake(margin, self.paymentOptions!.frame.minY, widthField, fheight)
        self.address!.frame = CGRectMake(margin, self.address!.frame.minY, widthField, fheight)
        self.shipmentType!.frame = CGRectMake(margin, self.address!.frame.maxY + 5.0, widthField, fheight)
        self.deliveryDate!.frame = CGRectMake(margin, self.shipmentType!.frame.maxY + 5.0, widthField, fheight)
        self.deliverySchedule!.frame = CGRectMake(margin, self.deliveryDate!.frame.maxY + 5.0, widthField, fheight)
        self.comments!.frame = CGRectMake(margin, self.deliverySchedule!.frame.maxY + 5.0, widthField, fheight)
        self.confirmation!.frame = CGRectMake(margin, self.confirmation!.frame.minY , widthField, fheight)
        
        self.addToListButton.frame = CGRectMake(8 ,0, 50, footer!.frame.height)
        buttonShare.frame = CGRectMake(self.addToListButton!.frame.maxX, 0, 50, footer!.frame.height)
        self.buttonShop!.frame = CGRectMake(buttonShare.frame.maxX + 8, (footer!.frame.height / 2) - 17, self.view.frame.width - buttonShare.frame.maxX - 24, 34)
        
        self.customlabel.frame = self.buttonShop!.bounds
        if self.viewLoad != nil {
            self.viewLoad.frame = self.view.bounds
            self.viewLoad.startAnnimating(true)
        }
        
    }
    
    
    func addCartToList() {
        if self.listSelectorController == nil {
            self.addToListButton!.selected = true
            var frame = self.view.frame
            
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.hiddenOpenList = true
            self.listSelectorController!.delegate = self
            //self.listSelectorController!.productUpc = self.upc
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRectMake(0.0, frame.height, frame.width, frame.height)
            //self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMoveToParentViewController(self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorController!.generateBlurImage(self.view, frame: CGRectMake(0, 0, frame.width, frame.height))
            self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, -frame.height, frame.width, frame.height)
            self.view.addSubview(self.listSelectorController!.view)
            
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                    self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
//                        var footerFrame = self.viewFooter!.frame
//                        self.listSelectorController!.tableView!.contentInset = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
//                        self.listSelectorController!.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, footerFrame.height, 0)
                    }
                }
            )
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
            })
        }
        else {
            self.removeListSelector(action: nil)
        }
    }
    
    func removeListSelector(#action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                options: .LayoutSubviews,
                animations: { () -> Void in
                    var frame = self.view.frame
                    self.listSelectorController!.view.frame = CGRectMake(0, frame.height, frame.width, 0.0)
                    self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, -frame.height, frame.width, frame.height)
                }, completion: { (complete:Bool) -> Void in
                    if complete {
                        if self.listSelectorController != nil {
                            self.listSelectorController!.willMoveToParentViewController(nil)
                            self.listSelectorController!.view.removeFromSuperview()
                            self.listSelectorController!.removeFromParentViewController()
                            self.listSelectorController = nil
                        }
                        self.addToListButton!.selected = false
                        
                        action?()
                    }
                }
            )
        }
    }
    
    //MARK: - ListSelectorDelegate
    
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    func listSelectorDidAddProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        var service = GRAddItemListService()
        var products: [AnyObject] = []
        for var idx = 0; idx < self.itemsInCart.count; idx++ {
            let item = self.itemsInCart[idx] as [String:AnyObject]
            
            let upc = item["upc"] as String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? Int {
                quantity = qIntProd
            }
            if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            
            var pesable = "0"
            if  let qIntProd = item["type"] as? NSString {
                pesable = qIntProd
            }
            
            var isActive = true
            if let stockSvc = item["stock"] as?  Bool {
                isActive  = stockSvc
            }
            
            products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:isActive))
        }
        
        service.callService(service.buildParams(idList: listId, upcs: products),
            successBlock: { (result:NSDictionary) -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                self.alertView!.showDoneIcon()
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }, errorBlock: { (error:NSError) -> Void in
                println("Error at add product to list: \(error.localizedDescription)")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }
        )
    }
    
    func listSelectorDidAddProductLocally(inList list:List) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var products: [AnyObject] = []
        for var idx = 0; idx < self.itemsInCart.count; idx++ {
            let item = self.itemsInCart[idx] as [String:AnyObject]
            
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? Int {
                quantity = qIntProd
            }
            if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            
            var price: Double = 0.0
            if  let qIntProd = item["price"] as? NSNumber {
                price = qIntProd.doubleValue
            }
            if  let qIntProd = item["price"] as? NSString {
                price = qIntProd.doubleValue
            }
            
            var typeProdVal: Int = 0
            if let typeProd = item["type"] as? NSString {
                typeProdVal = typeProd.integerValue
            }
            
            var detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
            detail!.upc = item["upc"] as String
            detail!.desc = item["description"] as String
            detail!.price = "\(price)"
            detail!.quantity = NSNumber(integer: quantity)
            detail!.type = NSNumber(integer: typeProdVal)
            detail!.list = list
            detail!.img = item["imageUrl"] as String
        }
        
        var error: NSError? = nil
        context.save(&error)
        if error != nil {
            println(error!.localizedDescription)
        }
        
        var count:Int = list.products.count
        list.countItem = NSNumber(integer: count)
        
        error = nil
        context.save(&error)
        if error != nil {
            println(error!.localizedDescription)
        }
        
        self.removeListSelector(action: nil)
        
    }
    
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
    }
    
    func listSelectorDidDeleteProduct(inList listId:String) {
    }
    
    func listSelectorDidShowList(listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func listSelectorDidShowListLocally(list: List) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func shouldDelegateListCreation() -> Bool {
        return true
    }
    
    func listSelectorDidCreateList(name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [AnyObject] = []
        for var idx = 0; idx < self.itemsInCart.count; idx++ {
            let item = self.itemsInCart[idx] as [String:AnyObject]
            
            let upc = item["upc"] as String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? NSNumber {
                quantity = qIntProd.integerValue
            }
            else if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            var price: String? = nil
            if  let priceNum = item["price"] as? NSNumber {
                price = "\(priceNum)"
            }
            else if  let priceTxt = item["price"] as? NSString {
                price = priceTxt
            }
            
            let imgUrl = item["imageUrl"] as? String
            let description = item["description"] as? String
            let type = item["type"] as? NSString
            
            var serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl, description: description, price: price, type: type)
            products.append(serviceItem)
        }
        
        service.callService(service.buildParams(name, items: products),
            successBlock: { (result:NSDictionary) -> Void in
                self.listSelectorController!.loadLocalList()
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                self.alertView!.showDoneIcon()
            },
            errorBlock: { (error:NSError) -> Void in
                println(error)
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
    }
    
    //Share 
    func shareShoppingCart() {
        self.delegateCheckOut.shareShoppingCart()
    }
    
 
    override func didFinishConfirm() {
        self.delegateCheckOut.closeIPAGRCheckOutViewController()
    }
    
    override func getDeviceNum() -> String {
        return "25"
    }
    
    
}