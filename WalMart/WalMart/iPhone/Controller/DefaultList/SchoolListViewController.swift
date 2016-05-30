//
//  SchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolListViewController : DefaultListDetailViewController {
    
    var schoolName: String! = ""
    var gradeName: String?
    var familyId: String?
    
    var departmentId: String?
    var selectAllButton: UIButton?
    var listPrice: String?
    var quantitySelectorMg: ShoppingCartQuantitySelectorView?
    var loading: WMLoadingView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SCHOOLLIST.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = self.schoolName
        self.tableView!.registerClass(SchoolListTableViewCell.self, forCellReuseIdentifier: "schoolCell")
        self.tableView!.registerClass(SchoolProductTableViewCell.self, forCellReuseIdentifier: "schoolProduct")
        
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.selectAllButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.selectAllButton!.setImage(UIImage(named: "check_off"), forState: .Normal)
        self.selectAllButton!.setImage(UIImage(named: "check_full_green"), forState: .Selected)
        self.selectAllButton!.setImage(UIImage(named: "check_off"), forState: .Disabled)
        self.selectAllButton!.addTarget(self, action: "selectAll", forControlEvents: .TouchUpInside)
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
        self.getDetailItems()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func addViewLoad(){
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
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
        return 109
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return  self.detailItems == nil ? 0 : self.detailItems!.count
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
            schoolCell.setValues(self.schoolName, grade: grade, listPrice: self.listPrice!, numArticles:itemsCount, savingPrice: "Ahorras 245.89")
            return schoolCell
        }
        
        let listCell = tableView.dequeueReusableCellWithIdentifier("schoolProduct", forIndexPath: indexPath) as! SchoolProductTableViewCell
        listCell.setValuesDictionary(self.detailItems![indexPath.row],disabled:!self.selectedItems!.containsObject(indexPath.row))
        listCell.detailDelegate = self
        listCell.hideUtilityButtonsAnimated(false)
        listCell.setLeftUtilityButtons([], withButtonWidth: 0.0)
        listCell.setRightUtilityButtons([], withButtonWidth: 0.0)
        return listCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
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
    
    func getDetailItems(){
        let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" :GRBaseService.getUseSignalServices()])
        let service = ProductbySearchService(dictionary:signalsDictionary)
        let params = service.buildParamsForSearch(text: "", family:self.familyId, line: self.lineId, sort:"rankingASC", departament: self.departmentId, start: 0, maxResult: 20)
        //let params = service.buildParamsForSearch(text: "", family:"f-papeleria-escolar", line: "l-escolar-cuadernos", sort:"rankingASC", departament: "d-papeleria", start: 0, maxResult: 20)
        service.callService(params,
                            successBlock:{ (arrayProduct:NSArray?,facet:NSArray) in
                                self.detailItems = arrayProduct as? [[String:AnyObject]]
                                if self.detailItems?.count == 0 || self.detailItems == nil {
                                    self.selectedItems = []
                                }
                                else{
                                    self.selectedItems = NSMutableArray()
                                    for i in 0...self.detailItems!.count - 1 {
                                        self.selectedItems?.addObject(i)
                                    }
                                }
                                self.tableView?.reloadData()
                                self.updateTotalLabel()
                                self.removeViewLoad()
                            },
                            errorBlock: {(error: NSError) in
               
            })
    }
    
    override func calculateTotalAmount() -> Double {
        var total: Double = 0.0
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
                let price = item["price"] as! NSString
                
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
                var item = self.detailItems![indexPath!.row]
                //var upc = item["upc"] as? String
                item["quantity"] = NSNumber(integer:Int(quantity)!)
                self.detailItems![indexPath!.row] = item
                self.tableView?.reloadData()
                self.removeSelector()
                self.updateTotalLabel()
                //TODO: Update quantity
            }
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.quantitySelectorMg!.frame = CGRectMake(0.0, 0.0, width, height)
            })
            
        }
        else {
            self.removeSelector()
        }
    }
    
    override func didDisable(disaable:Bool, cell:DetailListViewCell) {
        let indexPath = self.tableView?.indexPathForCell(cell)
        if disaable {
            self.selectedItems?.removeObject(indexPath!.row)
        } else {
            self.selectedItems?.addObject(indexPath!.row)
        }
        
        self.selectAllButton!.selected = !(self.selectedItems?.count == self.detailItems?.count)
        self.updateTotalLabel()
    }
    
    
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
                params["pesable"] = false
                params["wishlist"] = false
                params["type"] = ResultObjectType.Mg.rawValue
                params["comments"] = ""
                params["onHandInventory"] = "99"
                upcs.append(params)
            }
            if upcs.count > 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.AddItemsToShopingCart.rawValue, object: self, userInfo: ["allitems":upcs, "image":"list_alert_addToCart"])
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

    
    func selectAll() {
        let selected = !self.selectAllButton!.selected
        if selected {
            self.selectedItems = NSMutableArray()
            self.tableView?.reloadData()
            self.selectAllButton!.selected = true
        }else{
            self.selectedItems = NSMutableArray()
            for i in 0...self.detailItems!.count - 1 {
                self.selectedItems?.addObject(i)
            }
            self.tableView?.reloadData()
            self.selectAllButton!.selected = false
        }
        self.updateTotalLabel()
    }
}