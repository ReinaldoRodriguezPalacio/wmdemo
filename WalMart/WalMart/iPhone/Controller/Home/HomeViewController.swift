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
    //var exclusiveItems :  [[String:AnyObject]]? = nil
    var selectedIndexCategory :  Int = 0
    var categories :  [String] = []
    var categoryCell : CategoryCollectionViewCell!
    var bannerCell: BannerCollectionViewCell?
    var alertBank: UIView?
    var viewContents : UIView?
    var titleView : UILabel?
    var plecaItems :  NSDictionary? = nil
    var detailsButton : UIButton!
    var imageNotification : UIImageView?
    var categoryType :  [String:String]!
    //var carouselItems : [[String:String]]
    var timmerPleca : NSTimer!
    var itntervalPleca : NSTimeInterval = 5.0

    
    
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
        NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: #selector(HomeViewController.removePleca), userInfo: nil, repeats: false)
        
        self.recommendItems = []
        
        self.categories = getCategories()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.updatecontent(_:)), name: UpdateNotification.HomeUpdateServiceEnd.rawValue, object: nil)
        
        self.view.clipsToBounds = true
        collection!.clipsToBounds = true
        
        let servicecarousel = CarouselService()
        self.recommendItems = servicecarousel.getCarouselContent()
        
        
    }
    
    func removePleca(){
        
        UIView.animateWithDuration(0.2 , animations: {
            print(":::removePleca::::")
           
            self.titleView?.alpha = 0
            self.detailsButton?.alpha = 0
            self.imageNotification?.alpha = 0
             self.alertBank?.frame = CGRectMake(0, 0, self.view.frame.width, 0)
            }, completion: {(bool : Bool) in
                    self.alertBank?.alpha = 0
                    self.alertBank?.removeFromSuperview()
                    self.alertBank = nil
                self.stopTimmerPleca()

        })
    }
    
    func startTimmerPleca() {
        
            if timmerPleca != nil {
                timmerPleca.invalidate()
            }
            timmerPleca = NSTimer.scheduledTimerWithTimeInterval(itntervalPleca, target: self, selector: #selector(HomeViewController.removePleca), userInfo: nil, repeats: true)
        
        
    }
    func stopTimmerPleca() {
        if timmerPleca != nil {
            timmerPleca.invalidate()
        }
    }
    
    func showPleca (){
        print(":::showPleca::::")
        if plecaItems !=  nil && plecaItems!.count > 0 {
            if alertBank == nil {
                alertBank = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 0))
                alertBank!.backgroundColor = WMColor.dark_blue.colorWithAlphaComponent(0.9)
                self.view.addSubview(alertBank!)
            }
            
            if titleView ==  nil {
                titleView =  UILabel()
                
            }
            titleView!.font = WMFont.fontMyriadProRegularOfSize(12)
            titleView!.textColor = UIColor.whiteColor()
            titleView!.text = plecaItems?["terms"] as? String
            titleView!.textAlignment = .Left
            titleView?.numberOfLines = 2
            titleView?.alpha = 0
            self.alertBank!.addSubview(titleView!)
            
            
            
            if detailsButton ==  nil {
                detailsButton =  UIButton()
            }
            detailsButton.backgroundColor = WMColor.green
            detailsButton!.layer.cornerRadius = 11.0
            detailsButton!.setTitle("Detalles", forState:.Normal)
            detailsButton!.addTarget(self, action: #selector(HomeViewController.openUrl), forControlEvents: .TouchUpInside)
            detailsButton!.setTitleColor(WMColor.light_light_gray, forState: .Normal)
            detailsButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
            detailsButton?.alpha = 0
            self.alertBank!.addSubview(detailsButton!)
            if imageNotification ==  nil {
                self.imageNotification = UIImageView()
            }
            self.imageNotification?.image = UIImage(named: "notification_icon")
            self.alertBank!.addSubview(imageNotification!)
            imageNotification?.alpha = 0
            
            UIView.animateWithDuration(0.2, animations: {
                self.alertBank?.frame = CGRectMake(0, 0, self.view.frame.width, 46)
                self.titleView!.frame = CGRectMake(28, 0, self.view.frame.width-91, self.alertBank!.frame.height)
                self.detailsButton.frame = CGRectMake(self.view.frame.width-60, 12, 55, 22)
                self.imageNotification?.frame = CGRectMake(8,self.alertBank!.frame.midY-6,12,12)
                
                }, completion: {(bool : Bool) in
                        self.alertBank?.alpha = 1
                        self.titleView?.alpha = 1
                        self.detailsButton?.alpha = 1
                        self.imageNotification?.alpha = 1
                    self.startTimmerPleca()
                    
            })
            
        }
    }
    
    func openUrl (){
     self.termsSelect (plecaItems?["eventUrl"] as! String)
     self.alertBank!.alpha = 0
    
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowBar.rawValue, object: nil)
        self.bannerCell?.startTimmer()
        self.showPleca()

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.bannerCell?.stopTimmer()
        self.removePleca()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        


       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


        
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
            //let arrayItemsResult =  arrayItems as! [AnyObject]
            return arrayItems.count
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
                bannerCell!.plecaEnd = {() in
                    self.removePleca()
                }

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
                } else if let imageStr = recommendProduct["image"] as? String 	 {
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
                    listPrice = savingVal != "0.0" ? true : false
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
            let type = self.categoryType[catNameFilter]! == "gr" ? "groceries" : "mg"

            
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
    
    
    func bannerDidSelect(queryBanner:String,type:String,urlTteaser:String?) {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Banner.rawValue
        
        //var params : Dictionary<String,String>?  = nil
        var components = queryBanner.componentsSeparatedByString("_")
        if urlTteaser !=  nil  {
            components[0] = "lc"
        }
        if(components.count <= 1 && urlTteaser == nil){
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
        case "lc":
            self.openLandinCampaign(urlTteaser!,idFamily:queryBanner)
            print("Hacer busqueda por lines ")
   
        default:
            return
        }
       
              
    }
    
    
    func openLandinCampaign(urlTicer:String,idFamily:String){
        
        let controller = IPOLinesViewController()
        controller.urlTicer = urlTicer
        controller.familyName = idFamily
        self.navigationController!.pushViewController(controller, animated: true)

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
        
        //let specialsCat : [AnyObject] = RecommendedCategory.cagtegories as [AnyObject]
        self.categoryType = [:]
        var categories : [String] = []
        self.recommendCategoryItems = [:]
        
        for itemRec in self.recommendItems! {
            var nameCategory = "Otros"
            let categoryname = itemRec["name"] as! String
            let categorytype = itemRec["type"] as! String
            self.categoryType[categoryname] = categorytype
            categories.append(itemRec["name"] as! String)
            let upcs = itemRec["upcs"] as! NSArray

            
                    nameCategory = itemRec["name"] as! String
                    if categories.filter({ (catName) -> Bool in return catName == nameCategory }).count == 0 {
                        categories.append(nameCategory)
                    }
                    
                    if let catItem : AnyObject = recommendCategoryItems[nameCategory] {
                        var array = catItem as! [AnyObject]
                        array.append(itemRec)
                        recommendCategoryItems.updateValue(array, forKey: nameCategory)
                    } else {
                        recommendCategoryItems[nameCategory] = upcs
                    }
            }

        
        categories.sortInPlace { (item, seconditem) -> Bool in
            let first = self.recommendItems!.filter({ (catego) -> Bool in return (catego["name"] as! String!) == item })
            let second = self.recommendItems!.filter({ (catego) -> Bool in return (catego["name"] as! String!) == seconditem })
            let firstItem = first[0] as NSDictionary
            let firstOrder = firstItem["orden"] as! String
            let secondItem = second[0] as NSDictionary
            let secondOrder = secondItem["orden"] as! String
            return  Int(firstOrder) < Int(secondOrder)
        }
        
        return categories
        
    }
    
    func updatecontent(sender:AnyObject) {
        //Read a banner list
        let serviceBanner = BannerService()
      
        self.bannerItems = serviceBanner.getBannerContent()
        self.plecaItems = serviceBanner.getPleca()
        
        let servicecarousel = CarouselService()
        self.recommendItems = servicecarousel.getCarouselContent()
        
        
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