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
    var recentProductItems : [[String:Any]] = []
    var viewLoad : WMLoadingView!
    var emptyView : IPOGenericEmptyView!
    var invokeStop  = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_TOPPURCHASED.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleProducts = NSLocalizedString("profile.misarticulos",comment: "")
        self.titleLabel?.text = titleProducts
        
        recentProducts = UITableView()
        
        recentProducts.register(RecentProductsTableViewCell.self, forCellReuseIdentifier: "recentCell")
        recentProducts.delegate = self
        recentProducts.dataSource = self
        recentProducts.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(recentProducts)
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Recent.rawValue
        self.emptyView = IPOGenericEmptyView(frame: CGRect.zero)
        invokeRecentProducts()
        BaseController.setOpenScreenTagManager(titleScreen:  NSLocalizedString("profile.misarticulos",comment: ""), screenName: self.getScreenGAIName())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.recentProducts.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
        let model =  UIDevice.current.modelName
        let heightEmptyView = self.view.bounds.height

        self.emptyView.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: heightEmptyView)
        
        self.emptyView.paddingBottomReturnButton = 57
        if model.contains("4"){
            self.emptyView.paddingBottomReturnButton += 88
        }
        self.emptyView.returnAction = {() in
            self.back()
        }
        if IS_IPAD_MINI || IS_IPAD {
            self.emptyView.showReturnButton = false
        }
        self.view.addSubview(self.emptyView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRect(x: self.view.bounds.minX, y: 46, width: self.view.bounds.width, height: self.view.frame.height -  self.header!.frame.maxY))
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
            recentProducts.reloadData()
        }
        if invokeStop{
            self.viewLoad.stopAnnimating()
        }
        
        var heightEmptyView = self.view.bounds.height
        if !IS_IPAD {
            if !IS_IOS8_OR_LESS {
                heightEmptyView -= 46
            }else{
                heightEmptyView -= 109
            }
            let model = UIDevice.current.modelName
            if model.contains("Plus") {
                heightEmptyView -= 44
            }
            
        }
    
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: heightEmptyView)
    }

   
    func invokeRecentProducts(){
        let service = GRRecentProductsService()
        service.callService({ (resultado:[String:Any]) -> Void in
            self.recentProductItems = resultado["responseArray"] as! [[String : Any]]
            self.recentProducts.reloadData()
            if self.viewLoad != nil {
                self.viewLoad.stopAnnimating()
            }
            self.invokeStop = true
            self.viewLoad = nil
            self.emptyView!.isHidden = true
        }, errorBlock: { (error:NSError) -> Void in
            print("Error")
            self.viewLoad?.stopAnnimating()
            self.viewLoad = nil
        })

    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  recentProductItems.count == 0{
            self.viewLoad?.stopAnnimating()
            self.viewLoad = nil
        }
        return self.recentProductItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
      
        
        let cellRecentProducts = tableView.dequeueReusableCell(withIdentifier: "recentCell") as! RecentProductsTableViewCell
        cellRecentProducts.selectionStyle = .none
        let objProduct = recentProductItems[indexPath.row] 
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
        
        
        cellRecentProducts.setValues(upc, productImageURL: img, productShortDescription: description, productPrice: price.stringValue, saving: promoDescription, isActive: isActive, onHandInventory: 99, isPreorderable: false, isInShoppingCart: UserCurrentSession.sharedInstance.userHasUPCShoppingCart(upc),pesable:pesable)
        cellRecentProducts.resultObjectType = ResultObjectType.Groceries
        return cellRecentProducts
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 109
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_OPEN_PRODUCT_DETAIL.rawValue , label: self.recentProductItems[indexPath.row]["description"] as! String)
        
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = getUPCItems() as [Any]
        controller.ixSelected = indexPath.row
        controller.detailOf = "Recent Products"
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
         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TOP_PURCHASED.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label: "")
        super.back()
    }
    
    override func swipeHandler(swipe: UISwipeGestureRecognizer) {
        self.back()
    }
    
    
}
