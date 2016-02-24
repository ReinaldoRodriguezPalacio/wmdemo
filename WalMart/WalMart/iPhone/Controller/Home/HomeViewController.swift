//
//  HomeViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


enum UpdateNotification : String {
    case HomeUpdateServiceEnd = "HomeUpdateServices"
}


class HomeViewController : IPOBaseController,UICollectionViewDataSource,UICollectionViewDelegate,BannerCollectionViewCellDelegate,CategoryCollectionViewCellDelegate ,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var collection: UICollectionView!
    
    var bannerItems :  [[String:String]]? = nil
    var recommendCategoryItems :  [String:AnyObject]!
    var recommendItems :  [[String:AnyObject]]? = nil
    var exclusiveItems :  [[String:AnyObject]]? = nil
    var selectedIndexCategory :  Int = 0
    var categories :  [String] = []
    var categoryCell : CategoryCollectionViewCell!
    var bannerCell: BannerCollectionViewCell?
    var plecaItems :  NSDictionary? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_HOME.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.registerClass(BannerCollectionViewCell.self, forCellWithReuseIdentifier: "bannerHome")
        collection.registerClass(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "categoryHome")
        collection.registerClass(ProductHomeCollectionViewCell.self, forCellWithReuseIdentifier: "productHome")

        //Read a banner list
        let serviceBanner = BannerService()
        self.bannerItems = serviceBanner.getBannerContent()
        self.plecaItems = serviceBanner.getPleca()

        print("::::PLECA VALOR:::")
        if plecaItems !=  nil {
            print(plecaItems?["terms"] as! String)
            print(plecaItems?["eventUrl"] as! String)
        }
    
        
        //let recommendItemsService = RecommendedItemsService()
        self.recommendItems = []
        
        //let exclusiveItemsService = GRExclusiveItemsService()
        self.exclusiveItems = []
    
        
        self.categories = getCategories()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatecontent:", name: UpdateNotification.HomeUpdateServiceEnd.rawValue, object: nil)
        self.view.clipsToBounds = true
        collection!.clipsToBounds = true
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
        self.bannerCell?.startTimmer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.bannerCell?.stopTimmer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        //let offset = collection.frame.maxY - self.view.bounds.maxY
             
    }
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        }
        
        if self.categories.count > 0 {
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]!
            let arrayItemsResult =  arrayItems as! [AnyObject]
            return arrayItemsResult.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell : UICollectionViewCell
        switch (indexPath.section,indexPath.row) {
            case (0,0):
                bannerCell = collectionView.dequeueReusableCellWithReuseIdentifier(bannerCellIdentifier() , forIndexPath: indexPath) as? BannerCollectionViewCell
                bannerCell!.delegate = self
                bannerCell!.dataSource = self.bannerItems
                bannerCell!.setup()
                cell = bannerCell!
                break;
            case (0,1):
                let categoryCell = collectionView.dequeueReusableCellWithReuseIdentifier("categoryHome", forIndexPath: indexPath) as! CategoryCollectionViewCell
                categoryCell.delegate = self
                categoryCell.setCategoriesAndReloadData(categories)
                cell = categoryCell
                break;
            default:
                let productCell = collectionView.dequeueReusableCellWithReuseIdentifier(productCellIdentifier(), forIndexPath: indexPath) as! ProductHomeCollectionViewCell
                
                let catNameFilter = self.categories[selectedIndexCategory]
                let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]!
                let arrayItemsResult =  arrayItems as! [AnyObject]
                let recommendProduct = arrayItemsResult[indexPath.row] as! [String:AnyObject]
                
                let desc = recommendProduct["description"] as! String
                var price = ""
                if let priceStr = recommendProduct["price"] as? String {
                    price = priceStr
                }else  if let priceNum = recommendProduct["price"] as? NSNumber {
                    price = "\(priceNum)"
                }
                
                var imageUrl = ""
                if let imageArray = recommendProduct["imageUrl"] as? NSArray {
                   
                    if imageArray.count > 0 {
                        imageUrl = imageArray.objectAtIndex(0) as! String
                    }
                } else if let imageStr = recommendProduct["imageUrl"] as? String  {
                    imageUrl = imageStr
                }
                
                var saving = ""
                if let savingVal  = recommendProduct["promoDescription"] as? String {
                    saving = savingVal
                }
                
                var preorderable = false
                if let preorderableVal  = recommendProduct["isPreorderable"] as? Bool {
                    preorderable = preorderableVal
                }
                if let preorderableVal  = recommendProduct["isPreorderable"] as? String {
                    preorderable = preorderableVal == "false" ? false : true
                }
                
                var listPrice = false
                if let originalListprice =  recommendProduct["original_listprice"] as? String {
                    listPrice = originalListprice != "" ? true : false
                }
                
                if let savingVal  = recommendProduct["saving"] as? String {
                    listPrice = savingVal != "" ? true : false
                }

                
                productCell.setValues(imageUrl, productShortDescription: desc, productPrice: price,saving:saving,preorderable:preorderable,listPrice: listPrice)
               
                cell = productCell
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch  (indexPath.section,indexPath.row) {
        case (0,0):
            return CGSizeMake(320, 217)
        case (0,1):
            return CGSizeMake(320, 44)
        default:
            return CGSizeMake(106.66, 146)
        }
    }
       
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            
            let controller = ProductDetailPageViewController()
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]!
            let arrayItemsResult =  arrayItems as! [AnyObject]
            let recommendProduct = arrayItemsResult[indexPath.row] as! [String:AnyObject]
            
            let upc = recommendProduct["upc"] as! String
            let desc = recommendProduct["description"] as! String
            let type = recommendProduct["type"] as! String
            controller.itemsToShow = [["upc":upc,"description":desc,"type":type]]
            
            
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SPECIAL_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SPECIAL_DETAILS.rawValue, action: WMGAIUtils.ACTION_VIEW_SPECIAL_DETAILS.rawValue, label: "\(desc) - \(upc)")


            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 0
    }
    
    
    func bannerDidSelect(queryBanner:String,type:String) {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Banner.rawValue
        
        //var params : Dictionary<String,String>?  = nil
        var components = queryBanner.componentsSeparatedByString("_")
        if(components.count <= 1){
            return
        }
        let bannerStr : NSString = queryBanner
        switch components[0] {
        case "f":
            let val = bannerStr.substringFromIndex(2)
            showProducts(forDepartmentId: nil, andFamilyId: val, andLineId: nil,type:type)
        case "c":
            let val = bannerStr.substringFromIndex(2)
            showProducts(forDepartmentId: val, andFamilyId: nil, andLineId: nil,type:type)
        case "l":
            let val = bannerStr.substringFromIndex(2)
            if type == ResultObjectType.Mg.rawValue  {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_LINE.rawValue , label: "\(val)")
            } else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_LINE.rawValue , label: "\(val)")
            }
            showProducts(forDepartmentId: nil, andFamilyId: nil, andLineId: val,type:type)
        case "UPC":
            let val = bannerStr.substringFromIndex(4)
            if type == ResultObjectType.Mg.rawValue  {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_PRODUCT.rawValue , label: "\(val)")
            } else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_PRODUCT.rawValue , label: "\(val)")
            }
            if val.rangeOfString(",") != nil {
                let upcss :NSString = val
                let myStringArr = upcss.componentsSeparatedByString(",")
                self.showFindUpc(myStringArr ,type: type)
                
            }else{
                showProductDetail(val,type: type)
            }
   
            
        default:
            return
        }
       
              
    }
    
    func showFindUpc(upcs:NSArray,type:String){
        let controller = SearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .WithCategoryForMG
        }else {
            controller.searchContextType = .WithCategoryForGR
        }
        controller.findUpcsMg = upcs as? [String]
        controller.titleHeader = "Recomendados"
        self.navigationController!.pushViewController(controller, animated: true)
        
    
    }
    
    func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?,type:String){
        let controller = SearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .WithCategoryForMG
        }else {
            controller.searchContextType = .WithCategoryForGR
        }
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line
        controller.titleHeader = "Recomendados"
        self.navigationController!.pushViewController(controller, animated: true)
    }

    
    func showProductDetail(upcProduct:String,type:String){
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = [["upc":upcProduct,"description":"","type":type]]
        
        willHideTabbar()
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
        
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
   
    func getCategories() -> [String]{
        
        let specialsCat : [AnyObject] = RecommendedCategory.cagtegories as [AnyObject]
        //var specialsGRCat : [String:AnyObject] = RecommendedCategory.groceriescategory
        var categories : [String] = []
        self.recommendCategoryItems = [:]
        
        for itemRec in self.recommendItems! {
            var nameCategory = "Otros"
            let upc = itemRec["upc"] as! String!
            //var isCategorySpecial = false
            
            for special in  specialsCat {
                
                let upcs = special["upcs"] as! NSArray
                if upcs.containsObject(upc) {
                    nameCategory = special["name"] as! String
                    if categories.filter({ (catName) -> Bool in return catName == nameCategory }).count == 0 {
                        categories.append(nameCategory)
                    }
                    
                    if let catItem : AnyObject = recommendCategoryItems[nameCategory] {
                        var array = catItem as! [AnyObject]
                        array.append(itemRec)
                        recommendCategoryItems.updateValue(array, forKey: nameCategory)
                    } else {
                        let itemsRec = [itemRec]
                        recommendCategoryItems[nameCategory] = itemsRec
                    }
                    //isCategorySpecial = true
                    break
                }
            }
             //GRA: Se quitan otros Sprint 18 MG
//            if isCategorySpecial {
//                continue
//            }
//           
//            if categories.filter({ (catName) -> Bool in return catName == nameCategory }).count == 0 {
//                categories.append(nameCategory)
//            }
//            if let catItem : AnyObject = recommendCategoryItems[nameCategory] {
//                var array = catItem as [AnyObject]
//                array.append(itemRec)
//                recommendCategoryItems.updateValue(array, forKey: nameCategory)
//            } else {
//                var itemsRec = [itemRec]
//                recommendCategoryItems[nameCategory] = itemsRec
//            }

        }
        
        categories.sortInPlace { (item, seconditem) -> Bool in
            let first = specialsCat.filter({ (catego) -> Bool in return (catego["name"] as! String!) == item })
            let second = specialsCat.filter({ (catego) -> Bool in return (catego["name"] as! String!) == seconditem })
            let firstItem = first[0] as! NSDictionary
            let firstOrder = firstItem["order"] as! Int
            let secondItem = second[0] as! NSDictionary
            let secondOrder = secondItem["order"] as! Int
            return firstOrder < secondOrder
        }
        
        return categories
        
    }
    
    func updatecontent(sender:AnyObject) {
        //Read a banner list
        let serviceBanner = BannerService()
        self.bannerItems = serviceBanner.getBannerContent()
        self.plecaItems = serviceBanner.getPleca()
        
        print("::::PLECA VALOR:::")
        if self.plecaItems !=  nil {
            print(plecaItems!["terms"] as! String)
            print(plecaItems!["eventUrl"] as! String)
        }
        
        var toReturn :[[String:AnyObject]] = []
        
        let recommendItemsService = RecommendedItemsService()
        self.recommendItems = recommendItemsService.getRecommendedContent()
        
        for item in self.recommendItems! {
            var itemUpdate : [String:AnyObject] = item
            itemUpdate["type"] = ResultObjectType.Mg.rawValue
            toReturn.append(itemUpdate)
        }
        
        let exclusiveItemsService = GRExclusiveItemsService()
        self.exclusiveItems = exclusiveItemsService.getGrExclusiveContent()
        
        //Se agregan los especiales de groceries
        for item in self.exclusiveItems! {
            var itemUpdate : [String:AnyObject] = item
            itemUpdate["type"] = ResultObjectType.Groceries.rawValue
            toReturn.append(itemUpdate)
        }
        
        self.recommendItems = toReturn
        self.categories = getCategories()
        
        collection.reloadData()
    }
    
    
    
    
    func bannerCellIdentifier() -> String {
        return "bannerHome"
    }
    
    func productCellIdentifier() -> String {
        return "productHome"
    }
    
    func didSelectCategory(index:Int) {
        
        if self.selectedIndexCategory != index {
            var indexesPathsUpdate : [NSIndexPath] = []
            var indexesPathsDelete : [NSIndexPath] = []
            var indexesPathsInsert : [NSIndexPath] = []
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]!
            let arrayItemsResult =  arrayItems as! [AnyObject]
            
            let catNameFilterNew = self.categories[index]
            let arrayItemsNew : AnyObject = self.recommendCategoryItems[catNameFilterNew]!
            let arrayItemsResultNew =  arrayItemsNew as! [AnyObject]
            
            for ix in 0...arrayItemsResult.count - 1 {
                if arrayItemsResultNew.count > ix {
                    indexesPathsUpdate.append(NSIndexPath(forRow: ix , inSection: 1))
                }
            }
            
            
            if arrayItemsResultNew.count > arrayItemsResult.count {
                for ix in arrayItemsResult.count...arrayItemsResultNew.count - 1 {
                    indexesPathsInsert.append(NSIndexPath(forRow: ix , inSection: 1))
                }
            } else if arrayItemsResultNew.count < arrayItemsResult.count {
                for ix in arrayItemsResultNew.count...arrayItemsResult.count - 1 {
                    indexesPathsDelete.append(NSIndexPath(forRow: ix , inSection: 1))
                }
            }
            
            self.selectedIndexCategory = index
            if indexesPathsDelete.count > 0 {
                collection.performBatchUpdates({ () -> Void in
                    
                    self.collection.deleteItemsAtIndexPaths(indexesPathsDelete)
                    }, completion: { (complete:Bool) -> Void in
                    self.collection.performBatchUpdates({ () -> Void in
                        if indexesPathsUpdate.count > 0 {
                            self.collection.reloadItemsAtIndexPaths(indexesPathsUpdate)
                        }
                        }, completion: { (complete:Bool) -> Void in
                         //println("Termina")
                    })
                })
            }
            if indexesPathsInsert.count > 0 {
                collection.performBatchUpdates({ () -> Void in
                     self.collection.insertItemsAtIndexPaths(indexesPathsInsert)
                    
                    }, completion: { (complete:Bool) -> Void in
                        self.collection.performBatchUpdates({ () -> Void in
                            self.collection.reloadItemsAtIndexPaths(indexesPathsUpdate)
                            }, completion: { (complete:Bool) -> Void in
                                //println("Termina")
                        })
                })
            }
            if indexesPathsDelete.count == 0 && indexesPathsInsert.count == 0 {
                collection.performBatchUpdates({ () -> Void in
                    self.collection.reloadItemsAtIndexPaths(indexesPathsUpdate)
                    }, completion: { (complete:Bool) -> Void in
                    //println("Termina")
                })
            }
            //collection.reloadData()
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if section == 1 {
            if let layoutFlow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                return layoutFlow.sectionInset
            }
        }
        return UIEdgeInsetsZero
    }
    
    func termsSelect(url: String) {
        let ctrlWeb = IPOWebViewController()
        ctrlWeb.openURL(url)
        self.presentViewController(ctrlWeb, animated: true, completion: nil)
    }
    
    
    
}