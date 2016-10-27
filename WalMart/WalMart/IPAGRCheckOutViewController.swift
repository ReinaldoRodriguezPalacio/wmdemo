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
    func showViewBackground(show:Bool)
}

class IPAGRCheckOutViewController : GRCheckOutDeliveryViewController,ListSelectorDelegate {
    
    var addToListButton: UIButton!
    var buttonShare: UIButton!
    var itemsInCart: NSArray!
    var listSelectorController: ListsSelectorViewController?
    var delegateCheckOut : IPAGRCheckOutViewControllerDelegate!
    var footer: UIView?
    var buttonShop: UIButton?
    var totalView : IPOCheckOutTotalView!
    var customlabel : CurrencyCustomLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.footer!)
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton(type: .Custom) as UIButton
        self.buttonShop!.frame = CGRectMake(16, (footerHeight / 2) - 17, bounds.width - 32, 34)
        self.buttonShop!.backgroundColor = WMColor.green
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: #selector(IPAGRCheckOutViewController.next), forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonShop!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        self.footer!.addSubview(self.buttonShop!)
        
        self.addToListButton = UIButton(frame: CGRectMake(8 ,0, 50, footer!.frame.height))
        self.addToListButton!.setImage(UIImage(named: "detail_list"), forState: .Normal)
        self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), forState: .Selected)
        self.addToListButton!.addTarget(self, action: #selector(IPAGRCheckOutViewController.addCartToList), forControlEvents: .TouchUpInside)
        
        self.buttonShare = UIButton(frame: CGRectMake(self.addToListButton!.frame.maxX, 0, 50, footer!.frame.height))
        self.buttonShare.setImage(UIImage(named: "detail_shareOff"), forState: UIControlState.Normal)
        self.buttonShare.addTarget(self, action: #selector(IPAGRCheckOutViewController.shareShoppingCart), forControlEvents: UIControlEvents.TouchUpInside)
        self.footer!.addSubview(self.addToListButton!)
        self.footer!.addSubview(self.buttonShare)
        
        totalView = IPOCheckOutTotalView(frame:CGRectMake(0, self.toolTipLabel!.frame.maxY + 10, self.view.frame.width, 60))
        totalView.backgroundColor = WMColor.light_light_gray
        totalView.setValues("\(UserCurrentSession.sharedInstance().numberOfArticlesGR())",
            subtotal: "\(UserCurrentSession.sharedInstance().estimateTotalGR())",
            saving: UserCurrentSession.sharedInstance().estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance().estimateSavingGR())")
        self.updateShopButton("\(UserCurrentSession.sharedInstance().estimateTotalGR()-UserCurrentSession.sharedInstance().estimateSavingGR())")
        self.view.addSubview(totalView)
        self.view.addSubview(footer!)
        
        self.cancelButton?.removeFromSuperview()
        self.saveButton?.removeFromSuperview()
        self.removeViewLoad()
        self.addViewLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds.size
        let footerHeight:CGFloat = 65.0
        
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view!.frame.height - 206)
        self.layerLine.frame = CGRectMake(0, self.content!.frame.maxY,  self.view.frame.width, 1)
        self.totalView.frame = CGRectMake(0, self.view!.frame.height - 160, self.view.bounds.width, 95)
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        self.footer!.frame = CGRectMake(0.0, self.view!.bounds.height - footerHeight, bounds.width, footerHeight)
        self.addToListButton.frame = CGRectMake(8 ,0, 50, footer!.frame.height)
        self.buttonShare.frame = CGRectMake(self.addToListButton!.frame.maxX, 0, 50, footer!.frame.height)
        self.buttonShop!.frame = CGRectMake(buttonShare.frame.maxX + 8, (footer!.frame.height / 2) - 17, self.view.frame.width - buttonShare.frame.maxX - 24, 34)
        
        self.customlabel.frame = self.buttonShop!.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.delegateCheckOut?.showViewBackground(false)
    }
    
    /**
     send all items to list selected.
     */
    func addCartToList() {
        if self.listSelectorController == nil {
            self.addToListButton!.selected = true
            let frame = self.view.frame
            
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
                completion: nil)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRectMake(0, 0, frame.width, frame.height)
                self.listSelectorController!.imageBlurView!.frame = CGRectMake(0, 0, frame.width, frame.height)
            })
        }
        else {
            self.removeListSelector(action: nil)
        }
    }
    
    /**
     Remove list lselector in view cart
     
     - parameter action: actiton finish anumation
     */
    func removeListSelector(action action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                options: .LayoutSubviews,
                animations: { () -> Void in
                    let frame = self.view.frame
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
    /**
     Close list selector
     */
    func listSelectorDidClose() {
        self.removeListSelector(action: nil)
    }
    
    /**
     Add items to list selected , and call service Add Item List Service
     
     - parameter listId: id list Selected.
     */
    func listSelectorDidAddProduct(inList listId:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRAddItemListService()
        var products: [AnyObject] = []
        let itemsCart =  UserCurrentSession.sharedInstance().itemsGR!["items"] as! [AnyObject]
        for idx in 0 ..< itemsCart.count {
            
            let item = itemsCart[idx] as! [String:AnyObject]
            
            let upc = item["upc"] as! String
            let desc = item["description"] as! String
            let price = item["price"] as! Int
            
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? Int {
                quantity = qIntProd
            }
            if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            var pesable = "0"
            if  let pesableP = item["type"] as? String {
                pesable = pesableP
            }
            var active = true
            if let stock = item["stock"] as? Bool {
                active = stock
            }
            
            products.append(service.buildProductObject(upc: upc, quantity: quantity, pesable: pesable, active: active))
            
            // 360 Event
            BaseController.sendAnalyticsProductToList(upc, desc: desc, price: "\(price)")
        }
        
        service.callService(service.buildParams(idList: listId, upcs: products),
            successBlock: { (result:NSDictionary) -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                self.alertView!.showDoneIcon()
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }, errorBlock: { (error:NSError) -> Void in
                print("Error at add product to list: \(error.localizedDescription)")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView!.afterRemove = {
                    self.removeListSelector(action: nil)
                }
            }
        )
    }
    
    /**
     Add items to list selected, and call service Add Item List Service
     
     - parameter list: list object to add product
     */
    func listSelectorDidAddProductLocally(inList list:List) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //var products: [AnyObject] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:AnyObject]
            
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
            
            let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as? Product
            detail!.upc = item["upc"] as! String
            detail!.desc = item["description"] as! String
            detail!.price = "\(price)"
            detail!.quantity = NSNumber(integer: quantity)
            detail!.type = NSNumber(integer: typeProdVal)
            detail!.list = list
            detail!.img = item["imageUrl"] as! String
            
            // 360 Event
            BaseController.sendAnalyticsProductToList(detail!.upc, desc: detail!.desc, price: detail!.price as String)

        }
        
        var error: NSError? = nil
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print(error!.localizedDescription)
        }
        
        let count:Int = list.products.count
        list.countItem = NSNumber(integer: count)
        
        error = nil
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print(error!.localizedDescription)
        }
        
        self.removeListSelector(action: nil)
        
    }
    
    /**
     Delete product Locally
     
     - parameter product: product object to delete
     - parameter list:    list object to delete product
     */
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List) {
    }
    
    /**
     Delete prtoduct with service
     
     - parameter listId: idList
     */
    func listSelectorDidDeleteProduct(inList listId:String) {
    }
    
    /**
     Shows List
     
     - parameter listId: listId
     - parameter name:   List Name
     */
    func listSelectorDidShowList(listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listId = listId
            vc.listName = name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    /**
     Shows list locally
     
     - parameter list: List object
     */
    func listSelectorDidShowListLocally(list: List) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? UserListDetailViewController {
            vc.listEntity = list
            vc.listName = list.name
            vc.enableScrollUpdateByTabBar = false
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    /**
     Can delegate create a list
     
     - returns: Bool
     */
    func shouldDelegateListCreation() -> Bool {
        return true
    }
    
    /**
     Creates list
     
     - parameter name: list name
     */
    func listSelectorDidCreateList(name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [AnyObject] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:AnyObject]
            
            let upc = item["upc"] as! String
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
                price = priceTxt as String
            }
            
            let imgUrl = item["imageUrl"] as? String
            let description = item["description"] as? String
            let type = item["type"] as! String
            
            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl!, description: description!, price: price!, type: type)
            products.append(serviceItem)
        }
        
        service.callService(service.buildParams(name, items: products),
            successBlock: { (result:NSDictionary) -> Void in
                self.listSelectorController!.loadLocalList()
                self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToListDone", comment:""))
                self.alertView!.showDoneIcon()
            },
            errorBlock: { (error:NSError) -> Void in
                print(error)
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
    }
    
    /**
     Share shoppingCart
     */
    func shareShoppingCart() {
        self.delegateCheckOut?.shareShoppingCart()
    }
    
    /**
     Update total in shop button
     
     - parameter total: total in string
     */
    func updateShopButton(total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop!.bounds)
            customlabel.backgroundColor = UIColor.clearColor()
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop!.addSubview(customlabel)
            buttonShop!.sendSubviewToBack(customlabel)
        }
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.whiteColor(), interLine: false)
    }
    //MARK: - IPAGRCheckOutViewControllerDelegate
    
    /**
     Close IPAGRCheckout delegate
     */
    func didFinishConfirm() {
        self.delegateCheckOut.closeIPAGRCheckOutViewController()
    }
    
    /**
     Go to next checkout pass
     */
    override func next() {
        self.delegateCheckOut?.showViewBackground(true)
        super.next()
    }
}