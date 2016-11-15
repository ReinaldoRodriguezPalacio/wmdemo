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
    func showViewBackground(_ show:Bool)
}

class IPAGRCheckOutViewController : GRCheckOutDeliveryViewController,ListSelectorDelegate {
    
    var addToListButton: UIButton!
    var buttonShare: UIButton!
    var itemsInCart: NSArray!
    var listSelectorController: ListsSelectorViewController?
    var delegateCheckOut : IPAGRCheckOutViewControllerDelegate!
    var footer: UIView?
    var buttonShop: UIButton?
    var totalView : TotalView!
    var customlabel : CurrencyCustomLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.footer = UIView()
        self.footer!.backgroundColor = UIColor.white
        self.view.addSubview(self.footer!)
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        self.buttonShop = UIButton(type: .custom) as UIButton
        self.buttonShop!.frame = CGRect(x: 16, y: (footerHeight / 2) - 17, width: bounds.width - 32, height: 34)
        self.buttonShop!.backgroundColor = WMColor.green
        self.buttonShop!.layer.cornerRadius = 17
        self.buttonShop!.addTarget(self, action: #selector(getter: IPAGRCheckOutViewController.next), for: UIControlEvents.touchUpInside)
        self.buttonShop!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0)
        self.footer!.addSubview(self.buttonShop!)
        
        self.addToListButton = UIButton(frame: CGRect(x: 8 ,y: 0, width: 50, height: footer!.frame.height))
        self.addToListButton!.setImage(UIImage(named: "detail_list"), for: UIControlState())
        self.addToListButton!.setImage(UIImage(named: "detail_list_selected"), for: .selected)
        self.addToListButton!.addTarget(self, action: #selector(IPAGRCheckOutViewController.addCartToList), for: .touchUpInside)
        
        self.buttonShare = UIButton(frame: CGRect(x: self.addToListButton!.frame.maxX, y: 0, width: 50, height: footer!.frame.height))
        self.buttonShare.setImage(UIImage(named: "detail_shareOff"), for: UIControlState())
        self.buttonShare.addTarget(self, action: #selector(IPAGRCheckOutViewController.shareShoppingCart), for: UIControlEvents.touchUpInside)
        self.footer!.addSubview(self.addToListButton!)
        self.footer!.addSubview(self.buttonShare)
        
        totalView = TotalView(frame:CGRect(x: 0, y: self.addressInvoice!.frame.maxY + 10, width: self.view.frame.width, height: 60))
        totalView.backgroundColor = WMColor.light_light_gray
        totalView.setValues(articles: "\(UserCurrentSession.sharedInstance.numberOfArticlesGR())",
            subtotal: "\(UserCurrentSession.sharedInstance.estimateTotalGR())",
            shippingCost: "",
            iva:"",
            saving: UserCurrentSession.sharedInstance.estimateSavingGR() == 0 ? "" : "\(UserCurrentSession.sharedInstance.estimateSavingGR())",
            total: "\(UserCurrentSession.sharedInstance.estimateTotalGR())")
        self.updateShopButton("\(UserCurrentSession.sharedInstance.estimateTotalGR()-UserCurrentSession.sharedInstance.estimateSavingGR())")
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
        
        self.content!.frame = CGRect(x: 0.0, y: 46.0, width: self.view.bounds.width, height: self.view!.frame.height - 206)
        self.layerLine.frame = CGRect(x: 0, y: self.content!.frame.maxY,  width: self.view.frame.width, height: 1)
        self.totalView.frame = CGRect(x: 0, y: self.view!.frame.height - 180, width: self.view.bounds.width, height: 115)
        var width = bounds.width - 32.0
        width = (width/2) - 75.0
        self.footer!.frame = CGRect(x: 0.0, y: self.view!.bounds.height - footerHeight, width: bounds.width, height: footerHeight)
        self.addToListButton.frame = CGRect(x: 8 ,y: 0, width: 50, height: footer!.frame.height)
        self.buttonShare.frame = CGRect(x: self.addToListButton!.frame.maxX, y: 0, width: 50, height: footer!.frame.height)
        self.buttonShop!.frame = CGRect(x: buttonShare.frame.maxX + 8, y: (footer!.frame.height / 2) - 17, width: self.view.frame.width - buttonShare.frame.maxX - 24, height: 34)
        
        self.customlabel.frame = self.buttonShop!.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegateCheckOut?.showViewBackground(false)
    }
    
    /**
     send all items to list selected.
     */
    func addCartToList() {
        if self.listSelectorController == nil {
            self.addToListButton!.isSelected = true
            let frame = self.view.frame
            
            self.listSelectorController = ListsSelectorViewController()
            self.listSelectorController!.hiddenOpenList = true
            self.listSelectorController!.delegate = self
            //self.listSelectorController!.productUpc = self.upc
            self.addChildViewController(self.listSelectorController!)
            self.listSelectorController!.view.frame = CGRect(x: 0.0, y: frame.height, width: frame.width, height: frame.height)
            //self.view.insertSubview(self.listSelectorController!.view, belowSubview: self.viewFooter!)
            self.listSelectorController!.titleLabel!.text = NSLocalizedString("gr.addtolist.super", comment: "")
            self.listSelectorController!.didMove(toParentViewController: self)
            self.listSelectorController!.view.clipsToBounds = true
            
            self.listSelectorController!.generateBlurImage(self.view, frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: -frame.height, width: frame.width, height: frame.height)
            self.view.addSubview(self.listSelectorController!.view)
            
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.listSelectorController!.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                    self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                },
                completion: nil)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.listSelectorController!.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
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
    func removeListSelector(action:(()->Void)?) {
        if self.listSelectorController != nil {
            UIView.animate(withDuration: 0.5,
                delay: 0.0,
                options: .layoutSubviews,
                animations: { () -> Void in
                    let frame = self.view.frame
                    self.listSelectorController!.view.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 0.0)
                    self.listSelectorController!.imageBlurView!.frame = CGRect(x: 0, y: -frame.height, width: frame.width, height: frame.height)
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
        var products: [Any] = []
        let itemsCart =  UserCurrentSession.sharedInstance.itemsGR!["items"] as! [Any]
        for idx in 0 ..< itemsCart.count {
            let item = itemsCart[idx] as! [String:Any]
            
            let upc = item["upc"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? Int {
                quantity = qIntProd
            }
            if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            
            var pesable = "0"
            if  let qIntProd = item["type"] as? NSString {
                pesable = qIntProd as String
            }
            
            var isActive = true
            if let stockSvc = item["stock"] as?  Bool {
                isActive  = stockSvc
            }
            
            products.append(service.buildProductObject(upc: upc, quantity: quantity,pesable:pesable,active:isActive) as AnyObject)
        }
        
        service.callService(service.buildParams(idList: listId, upcs: products) as NSDictionary,
                            successBlock: { (result:[String:Any]) -> Void in
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
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        //var products: [Any] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:Any]
            
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
            
            let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as? Product
            detail!.upc = item["upc"] as! String
            detail!.desc = item["description"] as! String
            detail!.price = "\(price)" as NSString
            detail!.quantity = NSNumber(value: quantity as Int)
            detail!.type =  NSNumber(value: typeProdVal as Int)
            detail!.list = list
            detail!.img = item["imageUrl"] as! String
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
        list.countItem = NSNumber(value: count as Int)
        
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
    func listSelectorDidDeleteProductLocally(_ product:Product, inList list:List) {
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
    func listSelectorDidShowList(_ listId: String, andName name:String) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
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
    func listSelectorDidShowListLocally(_ list: List) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? UserListDetailViewController {
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
    func listSelectorDidCreateList(_ name:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.addingProductInCartToList", comment:""))
        
        let service = GRSaveUserListService()
        
        var products: [Any] = []
        for idx in 0 ..< self.itemsInCart.count {
            let item = self.itemsInCart[idx] as! [String:Any]
            
            let upc = item["productId"] as! String
            var quantity: Int = 0
            if  let qIntProd = item["quantity"] as? NSNumber {
                quantity = qIntProd.intValue
            }
            else if  let qIntProd = item["quantity"] as? NSString {
                quantity = qIntProd.integerValue
            }
            var price: String = ""
            if  let priceNum = item["price"] as? NSNumber {
                price = "\(priceNum)"
            }
            else if  let priceTxt = item["price"] as? NSString {
                price = priceTxt as String
            }
            
            var imgUrl = ""
            if let image =  item["imageUrl"] as? String {
                imgUrl = image
            }
            
            var description = ""
            if let desc =  item["productDisplayName"] as? String {
                description =  desc
            }
            
            let type = item["isWeighable"] as! String
            
            var  nameLine = ""
            if let line = item["line"] as? NSDictionary {
                nameLine = line["name"] as! String
            }
            
            
            let serviceItem = service.buildProductObject(upc: upc, quantity: quantity, image: imgUrl, description: description, price: price, type: type,nameLine: nameLine)
            products.append(serviceItem as AnyObject)
        }
        
        service.callService(service.buildParams(name, items: products),
                            successBlock: { (result:[String:Any]) -> Void in
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
    func updateShopButton(_ total:String) {
        if customlabel == nil {
            customlabel = CurrencyCustomLabel(frame: self.buttonShop!.bounds)
            customlabel.backgroundColor = UIColor.clear
            customlabel.setCurrencyUserInteractionEnabled(true)
            buttonShop!.addSubview(customlabel)
            buttonShop!.sendSubview(toBack: customlabel)
        }
        let shopStr = NSLocalizedString("shoppingcart.shop",comment:"")
        let fmtTotal = CurrencyCustomLabel.formatString(total as NSString)
        let shopStrComplete = "\(shopStr) \(fmtTotal)"
        customlabel.updateMount(shopStrComplete, font: WMFont.fontMyriadProRegularOfSize(14), color: UIColor.white, interLine: false)
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
