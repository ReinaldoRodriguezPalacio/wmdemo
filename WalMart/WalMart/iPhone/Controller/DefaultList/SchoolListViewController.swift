//
//  SchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolListViewController : DefaultListDetailViewController {
    
   
    var familyId: String?
    
    var departmentId: String?
    var selectAllButton: UIButton?
    var wishlistButton: UIButton?
    var listPrice: String?
    var quantitySelectorMg: ShoppingCartQuantitySelectorView?
    var loading: WMLoadingView?
    var showWishList: Bool = false
    var isWishListProcess: Bool = false
    
    var emptyView: IPOGenericEmptyView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SCHOOLLIST.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = self.schoolName
        self.tableView!.registerClass(SchoolListTableViewCell.self, forCellReuseIdentifier: "schoolCell")
        self.tableView!.registerClass(SchoolProductTableViewCell.self, forCellReuseIdentifier: "schoolProduct")
        self.tableView!.registerClass(ShoppingCartTotalsTableViewCell.self, forCellReuseIdentifier: "totalsCell")
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.selectAllButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.selectAllButton!.setImage(UIImage(named: "check_off"), forState: .Normal)
        self.selectAllButton!.setImage(UIImage(named: "check_full_green"), forState: .Selected)
        self.selectAllButton!.setImage(UIImage(named: "check_off"), forState: .Disabled)
        self.selectAllButton!.addTarget(self, action: #selector(SchoolListViewController.selectAll as (SchoolListViewController) -> () -> ()), forControlEvents: .TouchUpInside)
        
        self.wishlistButton = UIButton(frame: CGRectMake(66.0, y, 34.0, 34.0))
        self.wishlistButton!.setImage(UIImage(named:"detail_list"), forState: UIControlState.Normal)
        self.wishlistButton!.setImage(UIImage(named:"detail_list_selected"), forState: UIControlState.Selected)
        self.wishlistButton!.setImage(UIImage(named:"detail_list_selected"), forState: UIControlState.Highlighted)
        //self.wishlistButton!.setImage(UIImage(named:"wish_list_deactivated"), forState: UIControlState.Disabled)
        self.wishlistButton!.addTarget(self, action: #selector(SchoolListViewController.addToWishList), forControlEvents: .TouchUpInside)
        
        if self.showWishList {
            self.footerSection!.addSubview(self.wishlistButton!)
            self.shareButton?.removeFromSuperview()
        }
        
        self.footerSection!.addSubview(self.selectAllButton!)
        self.duplicateButton?.removeFromSuperview()
        self.addViewLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomBarNotification.TapBarFinish.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(DefaultListDetailViewController.tabBarActions),name:CustomBarNotification.TapBarFinish.rawValue, object: nil)
        self.tabBarActions()
    }
    
    override func setup() {
        super.setup()
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableView!.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.getDetailItems()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        super.tableView?.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + self.footerSection!.frame.height))
    }
    
    /**
     Shows loadding view
     */
    func addViewLoad(){
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    /**
     Removes loading view
     */
    func removeViewLoad(){
        if self.loading != nil {
            self.loading!.stopAnnimating()
            self.loading!.removeFromSuperview()
        }
    }
    
    //MARK: TableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 98
        }
        return indexPath.row == self.detailItems!.count ? 64 : 109
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return  self.detailItems == nil ? 0 : self.detailItems!.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
           let schoolCell = tableView.dequeueReusableCellWithIdentifier("schoolCell", forIndexPath: indexPath) as! SchoolListTableViewCell
            let range = (self.gradeName!.lowercaseString as NSString).rangeOfString(self.schoolName.lowercaseString)
            var grade = self.gradeName!
            if range.location != NSNotFound {
                grade = grade.substringFromIndex(grade.startIndex.advancedBy(range.length))
            }
            let itemsCount = self.detailItems == nil ? 0 : self.detailItems!.count
            self.listPrice = self.listPrice ?? "0.0"
            schoolCell.selectionStyle = .None
            schoolCell.setValues(self.schoolName, grade: grade, listPrice: self.listPrice!, numArticles:itemsCount, savingPrice: "Ahorras 245.89")
            return schoolCell
        }
        
        
        
        if indexPath.row == self.detailItems!.count {
            let totalCell = tableView.dequeueReusableCellWithIdentifier("totalsCell", forIndexPath: indexPath) as! ShoppingCartTotalsTableViewCell
            let total = self.calculateTotalAmount()
            //totalCell.setValuesBTS("", iva: "", total: "\(total)", totalSaving: "", numProds:"\(self.selectedItems!.count)")
            //totalCell.setValues(articles: "\(self.selectedItems!.count)", subtotal: "", shippingCost: "", iva: "", saving: "", total: "\(total)")
            totalCell.setValuesArtSubtTotal(articles: "\(self.selectedItems!.count)", subtotal: "", total: "\(total)")
            totalCell.selectionStyle = .None
            return totalCell
        }
        
        let listCell = tableView.dequeueReusableCellWithIdentifier("schoolProduct", forIndexPath: indexPath) as! SchoolProductTableViewCell
        listCell.setValuesDictionary(self.detailItems![indexPath.row],disabled:!self.selectedItems!.containsObject(indexPath.row), productPriceThrough: "", isMoreArts: false)
        listCell.detailDelegate = self
        listCell.selectionStyle = .None
        listCell.hideUtilityButtonsAnimated(false)
        listCell.setLeftUtilityButtons([], withButtonWidth: 0.0)
        listCell.setRightUtilityButtons([], withButtonWidth: 0.0)
    
        
        self.removeDisabled(self.detailItems![indexPath.row],indexPath:indexPath)
        return listCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 || indexPath.row == self.detailItems!.count {
            return
        }
        
        let controller = ProductDetailPageViewController()
        var productsToShow:[AnyObject] = []
        for idx in 0 ..< self.detailItems!.count {
            let product = self.detailItems![idx]
            let upc = product["upc"] as! NSString
            let description = product["description"] as! NSString
            
            productsToShow.append(["upc":upc, "description":description, "type":ResultObjectType.Mg.rawValue, "saving":""])
        }
        controller.itemsToShow = productsToShow
        controller.ixSelected = indexPath.row
        
        let product = self.detailItems![indexPath.row]
        let upc = product["upc"] as! NSString
        let description = product["description"] as! NSString
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL_PRACTILISTA.rawValue, label: "\(description) - \(upc)")
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    /**
     Removes disabled products
     
     - parameter product:   product
     - parameter indexPath: indexpath
     */
    func removeDisabled(product:[String:AnyObject],indexPath:NSIndexPath){
        
        if let stock = product["stock"] as? NSString {
            if stock == "false" {
                self.selectedItems!.removeObject(indexPath.row)
                self.updateTotalLabel()
            }
        }
        
        if let nameLines = product["nameLine"] as? NSString {
            self.nameLine = nameLines as String
        }
        
    }
    
    /**
     Get products list
     */
    func getDetailItems(){
        //let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" :GRBaseService.getUseSignalServices()])
        let service = GRProductBySearchService()
        //let params = service.buildParamsForSearch(text: "", family:"f-papeleria-escolar", line: "l-escolar-cuadernos", sort:"rankingASC", departament: "d-papeleria", start: 0, maxResult: 20)
        let params = service.buildParamsForSearch(text: "", family:self.familyId, line: self.lineId, sort:"rankingASC", departament: self.departmentId, start: 0, maxResult: 100, brand: nil)
        service.callService(params,
                            successBlock:{ (arrayProduct,facet:NSArray?) in
                                self.detailItems = arrayProduct as? [[String:AnyObject]]
                                
                                if self.detailItems?.count == 0 || self.detailItems == nil {
                                    self.selectedItems = []
                                    self.showEmptyView()
                                }
                                else{
                                    self.selectedItems = NSMutableArray()
                                    for i in 0...self.detailItems!.count - 1 {
                                        let product = self.detailItems![i]
                                        if let stock = product["stock"] as? NSString {
                                            if stock == "true" {
                                                self.selectedItems?.addObject(i)
                                            }
                                        }
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.tableView?.reloadData()
                                    self.listPrice = "\(self.calculateTotalAmount())"
                                    self.updateTotalLabel()
                                    self.removeViewLoad()
                                })
                                
            },
                            errorBlock: {(error: NSError) in
                                self.showEmptyView()
                                self.removeViewLoad()
                                
        })
    }
    
    /**
     Calculates total amount of list
     
     - returns: returns total amount
     */
    override func calculateTotalAmount() -> Double {
        var total: Double = 0.0
        //var totalSaving: Double = 0.0
        for idxVal  in selectedItems! {
            let idx = idxVal as! Int
            let item = self.detailItems![idx]
            if let typeProd = item["type"] as? NSString {
                var quantity: Double = 0.0
                if let quantityString = item["quantity"] as? NSString {
                    quantity = quantityString.doubleValue
                }
                if let quantityNumber = item["quantity"] as? NSNumber {
                    quantity = quantityNumber.doubleValue
                }
                let price = item["price"] as! NSNumber
                //totalSaving += (item["saving"] as! NSString).doubleValue
                
                if typeProd.integerValue == 0 {
                    total += (quantity * price.doubleValue)
                }
                else {
                    let kgrams = quantity / 1000.0
                    total += (kgrams * price.doubleValue)
                }
            }
        }
        return total
    }
    
    //MARK: Delegate item cell
   override func didChangeQuantity(cell:DetailListViewCell){
        
        if self.quantitySelectorMg == nil {
            
            let indexPath = self.tableView!.indexPathForCell(cell)
            if indexPath == nil {
                return
            }
            var price: String? = nil
            
            let item = self.detailItems![indexPath!.row]
            price = item["price"] as? String
            
            let width:CGFloat = self.view.frame.width
            var height:CGFloat = (self.view.frame.height - self.header!.frame.height) + 2.0
            if TabBarHidden.isTabBarHidden {
                height += 45.0
            }
            let selectorFrame = CGRectMake(0, self.view.frame.height, width, height)
            
            self.quantitySelectorMg = ShoppingCartQuantitySelectorView(frame: selectorFrame, priceProduct: NSNumber(double:Double(price!)!),upcProduct:cell.upcVal!)
            
            self.view.addSubview(self.quantitySelectorMg!)
            self.quantitySelectorMg!.closeAction = { () in
                self.removeSelector()
            }
            self.quantitySelectorMg!.generateBlurImage(self.view, frame:CGRectMake(0.0, 0.0, width, height))
            self.quantitySelectorMg!.addToCartAction = { (quantity:String) in
                let maxProducts = (cell.onHandInventory <= 5 || cell.productDeparment == "d-papeleria") ? cell.onHandInventory : 5
                if maxProducts >= Int(quantity) {
                    var item = self.detailItems![indexPath!.row]
                    //var upc = item["upc"] as? String
                    item["quantity"] = NSNumber(integer:Int(quantity)!)
                    self.detailItems![indexPath!.row] = item
                    self.tableView?.reloadData()
                    self.removeSelector()
                    self.updateTotalLabel()
                }else {
                    let alert = IPOWMAlertViewController.showAlert(UIImage(named:"noAvaliable"),imageDone:nil,imageError:UIImage(named:"noAvaliable"))
                    
                    let firstMessage = NSLocalizedString("productdetail.notaviableinventory",comment:"")
                    let secondMessage = NSLocalizedString("productdetail.notaviableinventoryart",comment:"")
                    let msgInventory = "\(firstMessage)\(maxProducts) \(secondMessage)"
                    alert!.setMessage(msgInventory)
                    alert!.showErrorIcon(NSLocalizedString("shoppingcart.keepshopping",comment:""))
                    self.quantitySelectorMg?.lblQuantity?.text = maxProducts < 10 ? "0\(maxProducts)" : "\(maxProducts)"
                }
            }
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.quantitySelectorMg!.frame = CGRectMake(0.0, 0.0, width, height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    /**
     Disable or enable cell
     
     - parameter disaable: bool
     - parameter cell:     product cell
     */
    override func didDisable(disaable:Bool, cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPathForCell(cell)
        if disaable {
            self.selectedItems?.removeObject(indexPath!.row)
        } else {
            self.selectedItems?.addObject(indexPath!.row)
        }
        
        self.selectAllButton!.selected = !(self.selectedItems?.count == self.detailItems?.count)
        self.tableView!.reloadRowsAtIndexPaths([NSIndexPath(forRow:self.detailItems!.count, inSection: 1)], withRowAnimation:UITableViewRowAnimation.None)
        self.updateTotalLabel()
    }
    
    /**
     Removes quantitySelector 
     */
    override func removeSelector() {
        if   self.quantitySelectorMg != nil {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                let width:CGFloat = self.view.frame.width
                let height:CGFloat = self.view.frame.height - self.header!.frame.height
                self.quantitySelectorMg!.frame = CGRectMake(0.0, self.view.frame.height, width, height)
                },
                completion: { (finished:Bool) -> Void in
                if finished {
                    self.quantitySelectorMg!.removeFromSuperview()
                    self.quantitySelectorMg = nil
                }
                }
            )
        }
    }
    
    /**
     Add selected products to cart
     */
    override func addListToCart() {
        
        //ValidateActives
        var hasActive = false
        for product in self.detailItems! {
            let item = product
            let stock = (item["stock"] as! String) == "true"
            let active = item["isActive"] as! String
            if stock && active == "true" {
                hasActive = true
                break
            }
        }
        
        
        if !hasActive {
            self.noProductsAvailableAlert()
            return
        }
        
        if self.selectedItems != nil && self.selectedItems!.count > 0 {
            var upcs: [AnyObject] = []
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                var params: [String:AnyObject] = [:]
                let item = self.detailItems![idx]
                params["upc"] = item["upc"] as! String
                params["desc"] = item["description"] as! String
                var imageUrl: String? = ""
                if let imageArray = item["imageUrl"] as? NSArray {
                    if imageArray.count > 0 {
                        imageUrl = imageArray[0] as? String
                    }
                } else if let imageUrlTxt = item["imageUrl"] as? String {
                    imageUrl = imageUrlTxt
                }
                params["imgUrl"] = imageUrl
                if let price = item["price"] as? NSNumber {
                    params["price"] = "\(price)"
                }
                if let price = item["price"] as? NSString {
                    params["price"] = "\(price)"
                }
                if let quantity = item["quantity"] as? NSNumber {
                    params["quantity"] = "\(quantity)"
                }
                if let quantity = item["quantity"] as? NSString {
                    params["quantity"] = "\(quantity)"
                }
                if let category = item["category"] as? NSString {
                    params["category"] = "\(category)"
                }
                if let onHandInventory = item["onHandInventory"] as? NSString {
                    params["onHandInventory"] = "\(onHandInventory)"
                }else{
                    params["onHandInventory"] = "99"
                }

                
                params["pesable"] = false
                params["wishlist"] = false
                params["type"] = ResultObjectType.Mg.rawValue
                params["comments"] = ""
                upcs.append(params)
            }
            if upcs.count > 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image":"alert_cart"])
            }else{
                self.noProductsAvailableAlert()
                return
            }
        }else{
            self.noProductsAvailableAlert()
            return
        }
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PRACTILISTA_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PRACTILISTA_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ADD_ALL_TO_SHOPPING_CART.rawValue, label: self.defaultListName!)
    }

    //MARK: Utils
    /**
     Present Empty view in case error or no items in array
     */
    func showEmptyView(){
        
        if  self.emptyView == nil {
            self.emptyView = IPOGenericEmptyView(frame:CGRectMake(0,self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - 46))
            
            
        }else{
            self.emptyView.removeFromSuperview()
            self.emptyView =  nil
            self.emptyView = IPOGenericEmptyView(frame:CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width, self.view.bounds.height - 46))
        }
        
        if IS_IPAD {
            self.emptyView.iconImageView.image = UIImage(named:"oh-oh_bts")
            self.emptyView.returnButton.hidden =  true
        }
     
        self.emptyView.descLabel.text = NSLocalizedString("empty.bts.title.list",comment:"")
        self.emptyView.returnAction = { () in
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.view.addSubview(self.emptyView)
    }
    
    /**
     Selects all products
     */
    func selectAll() {
        let selected = !self.selectAllButton!.selected
        if selected {
            self.selectedItems = NSMutableArray()
            self.tableView?.reloadData()
            self.selectAllButton!.selected = true
        }else{
            self.selectedItems = NSMutableArray()
            for i in 0...self.detailItems!.count - 1 {
                let product = self.detailItems![i]
                if let stock = product["stock"] as? NSString {
                    if stock == "true" {
                        self.selectedItems?.addObject(i)
                    }
                }
                
            }
            self.tableView?.reloadData()
            self.selectAllButton!.selected = false
        }
        self.updateTotalLabel()
    }
    
    /**
     Add selected products to WishList
     */
    func addToWishList () {
        
        if !self.isWishListProcess && selectedItems!.count >  0 {
            self.isWishListProcess = true
            let animation = UIImageView(frame: CGRectMake(0, 0,36, 36));
            animation.center = self.wishlistButton!.center
            animation.image = UIImage(named:"detail_addToList")
            self.runSpinAnimationOnView(animation, duration: 100, rotations: 1, repeats: 100)
            self.footerSection!.addSubview(animation)
            var ixCount = 1
            
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.MG_CATEGORY_SHOPPING_CART_AUTH.rawValue,categoryNoAuth: WMGAIUtils.MG_CATEGORY_SHOPPING_CART_NO_AUTH.rawValue,action:WMGAIUtils.ACTION_ADD_ALL_WISHLIST.rawValue , label: "")
            
            for idxVal  in selectedItems! {
                let idx = idxVal as! Int
                let shoppingCartProduct = self.detailItems![idx]
                let upc = shoppingCartProduct["upc"] as! String
                let desc = shoppingCartProduct["description"] as! String
                let price = shoppingCartProduct["price"] as! String
                //let quantity = shoppingCartProduct["quantity"] as! String
                
                var onHandInventory = "0"
                if let inventory = shoppingCartProduct["onHandInventory"] as? String {
                    onHandInventory = inventory
                }
                
                let imageArray = shoppingCartProduct["imageUrl"] as! NSArray
                var imageUrl = ""
                if imageArray.count > 0 {
                    imageUrl = imageArray.objectAtIndex(0) as! String
                }
                
                var preorderable = "false"
                if let preorder = shoppingCartProduct["isPreorderable"] as? String {
                    preorderable = preorder
                }
                
                var category = ""
                if let categoryVal = shoppingCartProduct["category"] as? String {
                    category = categoryVal
                }
                
                
//                let serviceAdd = AddItemWishlistService()
//                if ixCount < self.selectedItems!.count {
//                    serviceAdd.callService(upc, quantity: "1", comments: "", desc: desc, imageurl: imageUrl, price: price as String, isActive: "true", onHandInventory: onHandInventory, isPreorderable: preorderable,category:category, mustUpdateWishList: false, successBlock: { (result:NSDictionary) -> Void in
//                        //let path = NSIndexPath(forRow: , inSection: 0)
//                        
//                        
//                        }, errorBlock: { (error:NSError) -> Void in
//                    })
//                }else {
//                    serviceAdd.callService(upc, quantity: "1", comments: "", desc: desc, imageurl: imageUrl, price: price, isActive: "true", onHandInventory: onHandInventory, isPreorderable: preorderable,category:category,mustUpdateWishList: true, successBlock: { (result:NSDictionary) -> Void in
//                        self.showMessageWishList(NSLocalizedString("shoppingcart.wishlist.ready",comment:""))
//                        animation.removeFromSuperview()
//                        }, errorBlock: { (error:NSError) -> Void in
//                            animation.removeFromSuperview()
//                    })
//                }
                ixCount += 1
                
            }
        }
        
    }
    
    /**
     Add Spin Animation in alert view
     
     - parameter view:      alert view
     - parameter duration:  time duration
     - parameter rotations: rotation
     - parameter repeats:   repeats
     */
    func runSpinAnimationOnView(view:UIView,duration:CGFloat,rotations:CGFloat,repeats:CGFloat) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * CGFloat(2.0) * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(repeats)
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
    /**
     Shows wish list mesage
     
     - parameter message: message to show
     */
    func showMessageWishList(message:String) {
        let addedAlertWL = WishlistAddProductStatus(frame: CGRectMake(self.footerSection!.frame.minX, self.footerSection!.frame.minY , self.footerSection!.frame.width, 0))
        addedAlertWL.generateBlurImage(self.view,frame:CGRectMake(self.footerSection!.frame.minX, -96, self.footerSection!.frame.width, 96))
        addedAlertWL.clipsToBounds = true
        addedAlertWL.imageBlurView.frame = CGRectMake(self.footerSection!.frame.minX, -96, self.footerSection!.frame.width, 96)
        addedAlertWL.textView.text = message
        self.view.addSubview(addedAlertWL)
        self.isWishListProcess = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            addedAlertWL.frame = CGRectMake(self.footerSection!.frame.minX,self.footerSection!.frame.minY - 48, self.footerSection!.frame.width, 48)
        }) { (complete:Bool) -> Void in
            UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                addedAlertWL.frame = CGRectMake(addedAlertWL.frame.minX, self.footerSection!.frame.minY , addedAlertWL.frame.width, 0)
            }) { (complete:Bool) -> Void in
                addedAlertWL.removeFromSuperview()
            }
        }
        
        
    }
    
    //MARK: ScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        self.tabBarActions()
    }
}