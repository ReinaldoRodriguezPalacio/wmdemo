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
        
        recentProducts.register(RecentProductsTableViewCell.self, forCellReuseIdentifier: "recentCell")
        recentProducts.delegate = self
        recentProducts.dataSource = self
        recentProducts.separatorStyle = UITableViewCellSeparatorStyle.none
        recentProducts.backgroundColor =  UIColor.white
        recentProducts.layoutMargins = UIEdgeInsets.zero
        self.view.addSubview(recentProducts)
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Recent.rawValue
        emptyView = IPOGenericEmptyView(frame: CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 109))
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
        invokeRecentProducts()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.recentProducts.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRect(x: self.view.bounds.minX,y: 46, width: self.view.bounds.width, height: self.view.bounds.height -  self.header!.frame.maxY))
            viewLoad.backgroundColor = UIColor.white
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
            recentProducts.reloadData()
        }
        if invokeStop{
            self.viewLoad.stopAnnimating()
        }
        
        if IS_IOS8_OR_LESS {
            self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        }else{
            self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 109)
        }
    }
   
    func invokeRecentProducts(){
        let service = GRRecentProductsService()
        service.callService({ (resultado:NSDictionary) -> Void in
            self.contResult(resultado)
            // TODO : Servicios En walmart validar con servicio
            self.recentProductItems = RecentProductsViewController.adjustDictionary(resultado["responseArray"]! , isShoppingCart: false) as! [AnyObject]
            self.recentProducts.reloadData()
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
            }
            self.invokeStop = true
            self.viewLoad = nil
            self.emptyView!.isHidden = true
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
        })
    }
    
    func contResult(_ resultDictionary: NSDictionary) {
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
    class func adjustDictionary(_ resultDictionary: AnyObject, isShoppingCart:Bool) -> AnyObject {
        var recentLineItems : [AnyObject] = []
        
        var productItemsOriginal:[AnyObject] = []
        
        if let resultArray = resultDictionary as? [AnyObject] {
            productItemsOriginal = resultArray
        }else{
           productItemsOriginal = isShoppingCart ? resultDictionary["commerceItems"] as! [AnyObject] : resultDictionary  as! [[String:Any]] //["responseArray"] as! [AnyObject]
        }
        
        var objectsFinal : [NSDictionary] = []
        var indi = 0
    
        //search different lines and add in NSDictionary
        if productItemsOriginal.count > 0 {
            var flagOther = false
            for objProduct in productItemsOriginal {
                if (objProduct["familyName"] as? String) != nil {
                    var lineObj :  NSDictionary = [:]
                    lineObj = objProduct as! NSDictionary
                    
                    if lineObj.count > 0 {
                        if indi == 0 {
                            recentLineItems.append(lineObj["fineLineName"] as! String == "" ? "Otros" : lineObj["fineLineName"] as! String as AnyObject)
                            indi = indi + 1
                            flagOther = false
                        } else {
                            //Compare
                            var flagInsert = true
                            for obj in recentLineItems {
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
                                recentLineItems.append(lineObj["fineLineName"] as! String as AnyObject)
                                indi = indi + 1
                            }
                        }
                    } else {
                        recentLineItems.append("Otros" as AnyObject)
                    }
                } else {
                    flagOther = true
                }
            }
            
            //Order Ascending array final
            let sortedArray = recentLineItems.sorted {$0.localizedCaseInsensitiveCompare($1 as! String) == ComparisonResult.orderedAscending }
            recentLineItems = sortedArray
            
            if flagOther{
                if recentLineItems.count == 0 {
                    recentLineItems.append("Otros" as AnyObject)
                }
                if recentLineItems[0] as! String != "" && recentLineItems.count != 1 {
                    recentLineItems.append("Otros" as AnyObject)
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
                
                var lineObj : NSDictionary = [:]
                if isShoppingCart {
                    if let lineObjValue = objProduct["fineContent"] as? NSDictionary {
                        lineObj = lineObjValue
                    }
                } else {
                    lineObj = objProduct
                }
                
                if lineObj.count > 0 {
                    if obj as? String == "Otros"{
                        if objProduct["fineContent"] != nil || !isShoppingCart{
                            
                            if lineObj["fineLineName"] as! String == "" || lineObj["fineLineName"] as! String == "Otros" {
                                objectsLine.insert(objProduct, at: indLine)
                                lineString = "Otros"
                                indLine = indLine + 1
                            }
                        } else {
                            objectsLine.insert(objProduct, at: indLine)
                            lineString = "Otros"
                            indLine = indLine + 1
                        }
                    } else {
                        if objProduct["fineContent"] != nil || !isShoppingCart{
                            
                            if obj as? String == lineObj["fineLineName"] as? String {
                                objectsLine.insert(objProduct, at: indLine)
                                lineString = lineObj["fineLineName"] as! String
                                indLine = indLine + 1
                            }
                        }
                    }
                } else {
                    objectsLine.append(objProduct)
                    lineString = "Otros"
                }
            }
            objectsFinal.append(["name": lineString, "products": objectsLine])
        }
        
        //Add Dictionay final in self.recentProductItems
        //self.recentProductItems = objectsFinal
        return objectsFinal as AnyObject
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let listObj = self.recentProductItems[section] as! NSDictionary
        let prodObj = listObj["products"]
        return (prodObj! as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightHeaderTable
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.recentProductItems.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: heightHeaderTable))
        headerView.backgroundColor = UIColor.white
        let titleLabel = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: self.view.frame.width, height: heightHeaderTable))
        
        let listObj = self.recentProductItems[section] as! NSDictionary
        titleLabel.text = listObj["name"] as? String
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cellRecentProducts = tableView.dequeueReusableCell(withIdentifier: "recentCell") as! RecentProductsTableViewCell
        
        let listObj = self.recentProductItems[(indexPath as NSIndexPath).section] as! NSDictionary
        let prodObj = listObj["products"] as! NSArray
        let objProduct = prodObj[(indexPath as NSIndexPath).row] as! NSDictionary
        //image
        let parentProd = objProduct["parentProducts"] as! NSArray
        
        let img = parentProd[0]["thumbnailImageUrl"] as! String
        
        let description = parentProd[0]["description"] as! String
        let price = objProduct["specialPrice"] as? String
        let skuid = objProduct["id"] as? String
        let upc = objProduct["itemNumber"] as! String
        
        //Falta pesable
        var pesable = "false"
        if let pesableValue = objProduct["pesable"] as? NSString {
            pesable = pesableValue as String
        }
        var promoDescription : NSString = ""
        var isActive = true
        
        //Falta stock
        if let active = objProduct["stock"] as? Bool {
            isActive = active
        }
        let plpArray = UserCurrentSession.sharedInstance().getArrayPLP(objProduct)
        //Falta priceEvent
        promoDescription = plpArray["promo"] as! String == "" ? promoDescription : plpArray["promo"] as! String
        
        cellRecentProducts.selectionStyle = .none
        cellRecentProducts.delegateProduct = self
        cellRecentProducts.setValues(skuid!, upc:upc, productImageURL: img, productShortDescription: description, productPrice: price!, saving: promoDescription, isMoreArts: plpArray["isMore"] as! Bool,  isActive: isActive, onHandInventory: 99, isPreorderable: false, isInShoppingCart: UserCurrentSession.sharedInstance().userHasUPCShoppingCart(upc),pesable:pesable)

        let controller = self.view.window!.rootViewController
        cellRecentProducts.viewIpad = controller!.view
        cellRecentProducts.setValueArray(plpArray["arrayItems"] as! NSArray)
        cellRecentProducts.resultObjectType = ResultObjectType.Groceries
        return cellRecentProducts
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let line = self.recentProductItems[(indexPath as NSIndexPath).section]
        let productsline = line["products"]
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue , label: productsline![(indexPath as NSIndexPath).row]["description"] as! String)
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems((indexPath as NSIndexPath).section, row: (indexPath as NSIndexPath).row) as [AnyObject]
        controller.ixSelected = self.itemSelect //indexPath.row
        self.navigationController!.pushViewController(controller, animated: true)
    }

    func getUPCItems(_ section: Int, row: Int) -> [[String:String]] {
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
    
    func deleteFromWishlist(_ UPC:String){
        
    }
    
    override func back() {
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label: "")
        super.back()
    }
    
}
