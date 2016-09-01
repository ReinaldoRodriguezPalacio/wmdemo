//
//  RecentProductsViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class RecentProductsViewController : NavigationViewController, UITableViewDataSource, RecentProductsTableViewCellDelegate, UITableViewDelegate {
    
    //@IBOutlet var recentProducts : UITableView!
    var recentProducts : UITableView!
    var recentProductItems : [AnyObject] = []
    
    var viewLoad : WMLoadingView!
    var emptyView : IPOGenericEmptyView!
    var invokeStop  = false
    var heightHeaderTable : CGFloat = 26.0
    var itemSelect = 0
    //var legendView : LegendView?
    var plpView : PLPLegendView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_TOPPURCHASED.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleProducts = NSLocalizedString("profile.misbasicos.title",comment: "")
        self.titleLabel?.text = titleProducts
        
        recentProducts = UITableView()
        
        recentProducts.registerClass(RecentProductsTableViewCell.self, forCellReuseIdentifier: "recentCell")
        recentProducts.delegate = self
        recentProducts.dataSource = self
        recentProducts.separatorStyle = UITableViewCellSeparatorStyle.None
        recentProducts.backgroundColor =  UIColor.whiteColor()
        recentProducts.layoutMargins = UIEdgeInsetsZero
        self.view.addSubview(recentProducts)
        
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
        self.recentProducts.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
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
            self.contResult(resultado)
            self.recentProductItems = RecentProductsViewController.adjustDictionary(resultado["responseArray"]!) as! [AnyObject]
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
    
    func contResult(resultDictionary: NSDictionary) {
        let productItemsOriginal = resultDictionary["responseArray"] as! [AnyObject]
        
        if productItemsOriginal.count > 0{
            let titleBasic = self.titleLabel?.text
            self.titleLabel?.text = productItemsOriginal.count == 1 ? titleBasic! + " (\(productItemsOriginal.count))" : titleBasic! + " (\(productItemsOriginal.count))"
        }
    }
    
    /**
     Create a dictionary of items by grouping them sections
     
     - parameter resultDictionary: NSDictionary recent products service
     */
    class func adjustDictionary(resultDictionary: AnyObject) -> AnyObject {
        var recentLineItems : [AnyObject] = []
        
        let productItemsOriginal = resultDictionary  as! [AnyObject] //["responseArray"] as! [AnyObject]
        var objectsFinal : [NSDictionary] = []
        var indi = 0
    
        //search different lines and add in NSDictionary
        if productItemsOriginal.count > 0 {
            var flagOther = false
            
            for idx in 0 ..< productItemsOriginal.count {
                
                let objProduct = productItemsOriginal[idx]
                
                if objProduct["fineContent"] != nil {
                    let lineObj = objProduct["fineContent"] as! NSDictionary
                    
                    
                    if indi == 0 {
                        //self.recentLineItems.insert(lineObj, atIndex: indi)
                        recentLineItems.append(lineObj["fineLineName"] as! String == "" ? "Otros" : lineObj["fineLineName"] as! String)
                        indi = indi + 1
                        flagOther = false
                    } else {
                        //Compare
                        var flagInsert = true
                        for indx in 0 ..< recentLineItems.count {
                            let obj =  recentLineItems[indx]
                            //if obj["name"] as! String == lineObj["name"] as! String{
                            if obj as! String == lineObj["fineLineName"] as! String{
                                flagOther = false
                                flagInsert = false
                            }
                            if lineObj["fineLineName"] as! String == "Otros" || lineObj["fineLineName"] as! String == ""{//obj
                                flagOther = true
                                flagInsert = false
                            }
                        }
                        if flagInsert {
                            //self.recentLineItems.insert(lineObj, atIndex: indi)
                            recentLineItems.append(lineObj["fineLineName"] as! String)
                            indi = indi + 1
                        }
                    }
                } else {
                    flagOther = true
                }
            }
            
            //Order Ascending array final
            let sortedArray = recentLineItems.sort {$0.localizedCaseInsensitiveCompare($1 as! String) == NSComparisonResult.OrderedAscending }
            recentLineItems = sortedArray
            
            if flagOther{
                //self.recentLineItems.append(["id" : 0, "name" : "Otros"])
                if recentLineItems[0] as! String != "" && recentLineItems.count != 1 {
                    recentLineItems.append("Otros")
                }
            }
        }
        
        //add products NSDictionary in each lines
        for indx in 0 ..< recentLineItems.count {
            var objectsLine : [NSDictionary] = []
            var indLine = 0
            var lineString = ""
            
            for idx in 0 ..< productItemsOriginal.count {
                let objProduct = productItemsOriginal[idx] as! NSDictionary
                let obj = recentLineItems[indx]
                
                if obj as? String == "Otros"{
                    if objProduct["fineContent"] != nil {
                        let lineObj = objProduct["fineContent"] as! NSDictionary
                        if lineObj["fineLineName"] as! String == "" || lineObj["fineLineName"] as! String == "Otros" {
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
                    if objProduct["fineContent"] != nil {
                        let lineObj = objProduct["fineContent"] as! NSDictionary
                        
                        if obj as? String == lineObj["fineLineName"] as? String {
                            objectsLine.insert(objProduct, atIndex: indLine)
                            lineString = lineObj["fineLineName"] as! String
                            indLine = indLine + 1
                        }
                    }
                }
            }
            objectsFinal.append(["name": lineString, "products": objectsLine])
        }
        
        //Add Dictionay final in self.recentProductItems
        //self.recentProductItems = objectsFinal
        return objectsFinal
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
        let price = objProduct["specialPrice"] as? String
        let upc = objProduct["upc"] as! String
        var pesable = "false"
        if let pesableValue = objProduct["pesable"] as? NSString {
            pesable = pesableValue as String
        }
        var promoDescription : NSString = ""
        var isActive = true
        
        if let active = objProduct["stock"] as? Bool {
            isActive = active
        }
        let plpArray = UserCurrentSession.sharedInstance().getArrayPLP(objProduct)
        
        promoDescription = plpArray["promo"] as! String == "" ? promoDescription : plpArray["promo"] as! String
        
        cellRecentProducts.selectionStyle = .None
        cellRecentProducts.delegateProduct = self
        cellRecentProducts.setValues(upc, productImageURL: img, productShortDescription: description, productPrice: price!, saving: promoDescription, isMoreArts: plpArray["isMore"] as! Bool,  isActive: isActive, onHandInventory: 99, isPreorderable: false, isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),pesable:pesable)

        let controller = self.view.window!.rootViewController
        cellRecentProducts.viewIpad = controller!.view
        cellRecentProducts.setValueArray(plpArray["arrayItems"] as! NSArray)
        cellRecentProducts.resultObjectType = ResultObjectType.Groceries
        return cellRecentProducts
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128
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
    
    func deleteFromWishlist(UPC:String){
        
    }
    
    override func back() {
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label: "")
        super.back()
    }
    
}