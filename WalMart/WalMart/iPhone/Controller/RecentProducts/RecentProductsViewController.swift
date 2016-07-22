//
//  RecentProductsViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class RecentProductsViewController : NavigationViewController, UITableViewDataSource, UITableViewDelegate {
    
    //@IBOutlet var recentProducts : UITableView!
    
    var recentProducts : UITableView!
    var recentProductItems : [AnyObject] = []
    var recentLineItems : [AnyObject] = []
    var viewLoad : WMLoadingView!
    var emptyView : IPOGenericEmptyView!
    var invokeStop  = false
    var heightHeaderTable : CGFloat = IS_IPAD ? 40.0 : 20.0
    var headerView : UIView!
    var headerLabel : UILabel!
    var itemSelect = 0
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_TOPPURCHASED.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleProducts = NSLocalizedString("profile.misarticulos",comment: "")
        self.titleLabel?.text = titleProducts
        
        recentProducts = UITableView()
        
        recentProducts.registerClass(RecentProductsTableViewCell.self, forCellReuseIdentifier: "recentCell")
        recentProducts.delegate = self
        recentProducts.dataSource = self
        recentProducts.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(recentProducts)
        
        headerView = UIView()
        headerView.backgroundColor = WMColor.light_light_blue
        
        headerLabel = UILabel()
        headerLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        headerLabel!.textAlignment = .Left
        headerLabel!.textColor = WMColor.light_red
        headerLabel!.text = "0 artículos"
        headerLabel!.backgroundColor = UIColor.clearColor()
        
        self.headerView.addSubview(headerLabel)
        self.view.addSubview(headerView)
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Recent.rawValue
        emptyView = IPOGenericEmptyView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 109))
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        invokeRecentProducts()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headerView.frame = CGRectMake(0.0, 46, self.view.bounds.width, 20)
        self.headerLabel.frame = CGRectMake(15.0, 0.0, self.view.bounds.width, 20)
        self.recentProducts.frame = CGRectMake(0, 66, self.view.bounds.width, self.view.bounds.height - 66)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRectMake(self.view.bounds.minX,46, self.view.bounds.width, self.view.bounds.height -  self.header!.frame.maxY))
            viewLoad.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
            recentProducts.reloadData()
        }
        if invokeStop{
            self.viewLoad.stopAnnimating()
        }
        
        if IS_IOS8_OR_LESS {
            self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        }else{
            self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 109)
        }
    }
   
    func invokeRecentProducts(){
        let service = GRRecentProductsService()
        service.callService({ (resultado:NSDictionary) -> Void in
            self.adjustDictionary(resultado)
            self.recentProducts.reloadData()
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
            }
            self.invokeStop = true
            self.viewLoad = nil
            self.emptyView!.hidden = true
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
        })
    }
    
    /**
     Create a dictionary of items by grouping them sections
     
     - parameter resultDictionary: NSDictionary recent products service
     */
    func adjustDictionary(resultDictionary: NSDictionary){
        var productItemsOriginal = resultDictionary["responseArray"] as! [AnyObject]
        var objectsFinal : [NSDictionary] = []
        var indi = 0
    
        //search different lines and add in NSDictionary
        if productItemsOriginal.count > 0 {
            
            self.headerLabel.text = productItemsOriginal.count == 1 ? "\(productItemsOriginal.count) artículo" :"\(productItemsOriginal.count) artículos"
            var flagOther = false
            
            for idx in 0 ..< productItemsOriginal.count {
                let objProduct = productItemsOriginal[idx] as! NSDictionary
                
                if objProduct["line"] != nil {
                    let lineObj = objProduct["line"] as! NSDictionary
                    
                    if indi == 0 {
                        //self.recentLineItems.insert(lineObj, atIndex: indi)
                        self.recentLineItems.append(lineObj["name"] as! String)
                        indi = indi + 1
                    } else {
                        //Compare
                        var flagInsert = true
                        for indx in 0 ..< self.recentLineItems.count {
                            let obj =  self.recentLineItems[indx]
                            //if obj["name"] as! String == lineObj["name"] as! String{
                            if obj as! String == lineObj["name"] as! String{
                                flagInsert = false
                            }
                            if lineObj["name"] as! String == "Otros" || lineObj["name"] as! String == ""{//obj
                                flagOther = true
                                flagInsert = false
                            }
                        }
                        if flagInsert {
                            //self.recentLineItems.insert(lineObj, atIndex: indi)
                            self.recentLineItems.append(lineObj["name"] as! String)
                            indi = indi + 1
                        }
                    }
                } else {
                    flagOther = true
                }
            }
            
            //Order Ascending array final
            let sortedArray = self.recentLineItems.sort {$0.localizedCaseInsensitiveCompare($1 as! String) == NSComparisonResult.OrderedAscending }
            self.recentLineItems = sortedArray
            
            if flagOther{
                //self.recentLineItems.append(["id" : 0, "name" : "Otros"])
                self.recentLineItems.append("Otros")
            }
        }
        
        //add products NSDictionary in each lines
        for indx in 0 ..< self.recentLineItems.count {
            var objectsLine : [NSDictionary] = []
            var indLine = 0
            var lineString = ""
            
            for idx in 0 ..< productItemsOriginal.count {
                let objProduct = productItemsOriginal[idx] as! NSDictionary
                let obj = self.recentLineItems[indx]
                
                if obj as? String == "Otros"{
                    if objProduct["line"] != nil {
                        let lineObj = objProduct["line"] as! NSDictionary
                        if lineObj["name"] as! String == "" || lineObj["name"] as! String == "Otros" {
                            objectsLine.insert(objProduct, atIndex: indLine)
                            lineString = "Otros"
                            indLine = indLine + 1
                        }
                    } else {
                        objectsLine.insert(objProduct, atIndex: indLine)
                        lineString = "Otros"
                        indLine = indLine + 1
                    }
                } else {
                    if objProduct["line"] != nil {
                        let lineObj = objProduct["line"] as! NSDictionary
                        
                        if obj as? String == lineObj["name"] as? String {
                            objectsLine.insert(objProduct, atIndex: indLine)
                            lineString = lineObj["name"] as! String
                            indLine = indLine + 1
                        }
                    }
                }
            }
            objectsFinal.append(["name": lineString, "products": objectsLine])
        }
        
        //Add Dictionay final in self.recentProductItems
        self.recentProductItems = objectsFinal
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let listObj = self.recentProductItems[section] as! NSDictionary
        let prodObj = listObj["products"]
        return prodObj!.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightHeaderTable
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.recentProductItems.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.width, heightHeaderTable))
        headerView.backgroundColor = UIColor.whiteColor()
        let titleLabel = UILabel(frame: CGRectMake(15.0, 0.0, self.view.frame.width, heightHeaderTable))
        
        let listObj = self.recentProductItems[section] as! NSDictionary
        titleLabel.text = listObj["name"] as? String
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellRecentProducts = tableView.dequeueReusableCellWithIdentifier("recentCell") as! RecentProductsTableViewCell
        
        let listObj = self.recentProductItems[indexPath.section] as! NSDictionary
        let prodObj = listObj["products"] as! NSArray
        let objProduct = prodObj[indexPath.row] as! NSDictionary
        let img = objProduct["imageUrl"] as! String
        let description = objProduct["description"] as! String
        let price = objProduct["price"] as! NSNumber
        let upc = objProduct["upc"] as! String
        let pesable = objProduct["pesable"] as! NSString
        let promoDescription = objProduct["promoDescription"] as! NSString
        var isActive = true
        
        if let active = objProduct["stock"] as? Bool {
            isActive = active
        }
        
        cellRecentProducts.setValues(upc, productImageURL: img, productShortDescription: description, productPrice: price.stringValue, saving: promoDescription, isActive: isActive, onHandInventory: 99, isPreorderable: false, isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),pesable:pesable)
        cellRecentProducts.resultObjectType = ResultObjectType.Groceries
        return cellRecentProducts
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 109
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let line = self.recentProductItems[indexPath.section]
        let productsline = line["products"]
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue , label: productsline![indexPath.row]["description"] as! String)
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems(indexPath.section, row: indexPath.row)
        controller.ixSelected = self.itemSelect //indexPath.row
        self.navigationController!.pushViewController(controller, animated: true)
    }

    func getUPCItems(section: Int, row: Int) -> [[String:String]] {
        var upcItems : [[String:String]] = []
        var countItems = 0
        //Get UPC of All items
        for sect in 0 ..< self.recentProductItems.count {
            let lineItems = self.recentProductItems[sect]
            let productsline = lineItems["products"]
            for idx in 0 ..< productsline!.count {
                if section == sect && row == idx {
                    self.itemSelect = countItems
                }
                let upc = productsline![idx]["upc"] as! String
                let desc = productsline![idx]["description"] as! String
                upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Groceries.rawValue])
                countItems = countItems + 1
            }
        }
        return upcItems
    }
    
    override func back() {
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label: "")
        super.back()
    }
    
    
}