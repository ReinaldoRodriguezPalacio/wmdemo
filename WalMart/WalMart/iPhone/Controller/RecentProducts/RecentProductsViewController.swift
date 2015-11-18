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
    var viewLoad : WMLoadingView!
    var emptyView : IPOGenericEmptyView!
    
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
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Recent.rawValue
        emptyView = IPOGenericEmptyView(frame: CGRectZero)
        emptyView.returnAction = {() in
            self.back()
        }
        self.view.addSubview(emptyView)
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
        
        let service = GRRecentProductsService()
        service.callService({ (resultado:NSDictionary) -> Void in
            self.recentProductItems = resultado["responseArray"] as! [AnyObject]
            self.recentProducts.reloadData()
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            self.emptyView!.hidden = true
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
        })
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentProductItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellRecentProducts = tableView.dequeueReusableCellWithIdentifier("recentCell") as! RecentProductsTableViewCell
        let objProduct = recentProductItems[indexPath.row] as! NSDictionary
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
            
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue , label: self.recentProductItems[indexPath.row]["description"] as! String)
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems()
        controller.ixSelected = indexPath.row
        self.navigationController!.pushViewController(controller, animated: true)
        
        
    }

    func getUPCItems() -> [[String:String]] {
        var upcItems : [[String:String]] = []
        for shoppingCartProduct in  recentProductItems {
            let upc = shoppingCartProduct["upc"] as! String
            let desc = shoppingCartProduct["description"] as! String
            upcItems.append(["upc":upc,"description":desc,"type":ResultObjectType.Groceries.rawValue])
        }
        return upcItems
    }
    
    override func back() {
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTION.rawValue , label: "")
        super.back()
    }
    
    
}