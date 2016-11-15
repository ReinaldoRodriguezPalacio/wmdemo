//
//  HomeViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/27/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



enum UpdateNotification : String {
    case HomeUpdateServiceEnd = "HomeUpdateServices"
}


class HomeViewController : IPOBaseController,UICollectionViewDataSource,UICollectionViewDelegate,BannerCollectionViewCellDelegate,CategoryCollectionViewCellDelegate ,UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var collection: UICollectionView!
    
    var bannerItems :  [[String:String]]? = nil
    var recommendCategoryItems :  [String:Any]!
    var recommendItems :  [[String:Any]]? = nil
    //var exclusiveItems :  [[String:Any]]? = nil
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
    var timmerPleca : Timer!
    var itntervalPleca : TimeInterval = 5.0
    
    var valueTerms = ""
    var typeAction =  ""
    var bussinesTerms = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_HOME.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: "bannerHome")
        collection.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "categoryHome")
        collection.register(ProductHomeCollectionViewCell.self, forCellWithReuseIdentifier: "productHome")
        
        //Read a banner list
        let serviceBanner = BannerService()
        self.bannerItems = serviceBanner.getBannerContent()
        self.plecaItems = serviceBanner.getPleca()
      

    
        Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(HomeViewController.removePleca), userInfo: nil, repeats: false)
        
        self.recommendItems = []
        
        self.categories = getCategories()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updatecontent(_:)), name: NSNotification.Name(rawValue: UpdateNotification.HomeUpdateServiceEnd.rawValue), object: nil)
        
        self.view.clipsToBounds = true
        collection!.clipsToBounds = true
        
        let servicecarousel = CarouselService()
        self.recommendItems = servicecarousel.getCarouselContent()
    }
    
    func removePleca(){
        
        UIView.animate(withDuration: 0.2 , animations: {
            self.titleView?.alpha = 0
            self.detailsButton?.alpha = 0
            self.imageNotification?.alpha = 0
             self.alertBank?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
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
        timmerPleca = Timer.scheduledTimer(timeInterval: itntervalPleca, target: self, selector: #selector(HomeViewController.removePleca), userInfo: nil, repeats: true)
    }
    
    func stopTimmerPleca() {
        if timmerPleca != nil {
            timmerPleca.invalidate()
        }
    }
    
    func showPleca (){
        if plecaItems !=  nil && plecaItems!.count > 0 {
            if alertBank == nil {
                alertBank = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
                alertBank!.backgroundColor = WMColor.dark_blue.withAlphaComponent(0.9)
                self.view.addSubview(alertBank!)
            }
            
            if titleView ==  nil {
                titleView =  UILabel()
                
            }
            titleView!.font = WMFont.fontMyriadProRegularOfSize(12)
            titleView!.textColor = UIColor.white
            titleView!.text = plecaItems?["terms"] as? String
            titleView!.textAlignment = .left
            titleView?.numberOfLines = 2
            titleView?.alpha = 0
            self.alertBank!.addSubview(titleView!)
            
            
            
            if detailsButton ==  nil {
                detailsButton =  UIButton()
            }
            detailsButton.backgroundColor = WMColor.green
            detailsButton!.layer.cornerRadius = 11.0
            detailsButton!.setTitle("Detalles", for:UIControlState())
            detailsButton!.addTarget(self, action: #selector(HomeViewController.openDetailPleca), for: .touchUpInside)
            detailsButton!.setTitleColor(WMColor.light_light_gray, for: UIControlState())
            detailsButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
            detailsButton?.alpha = 0
            self.alertBank!.addSubview(detailsButton!)
            if imageNotification ==  nil {
                self.imageNotification = UIImageView()
            }
            self.imageNotification?.image = UIImage(named: "notification_icon")
            self.alertBank!.addSubview(imageNotification!)
            imageNotification?.alpha = 0
            
            UIView.animate(withDuration: 0.2, animations: {
                self.alertBank?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46)
                self.titleView!.frame = CGRect(x: 28, y: 0, width: self.view.frame.width-91, height: self.alertBank!.frame.height)
                self.detailsButton.frame = CGRect(x: self.view.frame.width-60, y: 12, width: 55, height: 22)
                self.imageNotification?.frame = CGRect(x: 8,y: self.alertBank!.frame.midY-6,width: 12,height: 12)
                
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
    
    func openDetailPleca(){
        if let type  = plecaItems?["type"] as? String{
         self.typeAction = type
        }
        if let value  = plecaItems?["eventUrl"] as? String{
            self.valueTerms = value
        }
        if let business  = plecaItems?["business"] as? String{
            self.bussinesTerms = business
        }
   
        let window = UIApplication.shared.keyWindow
        if let customBar = window!.rootViewController as? CustomBarViewController {
            customBar.handleNotification(self.typeAction,name:"",value:self.valueTerms,bussines:self.bussinesTerms)
            self.alertBank!.alpha = 0
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowBar.rawValue), object: nil)
        self.bannerCell?.startTimmer()
        self.showPleca()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        }
        
        if self.categories.count > 0 {
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]! as AnyObject
            //let arrayItemsResult =  arrayItems as! [Any]
            return arrayItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell : UICollectionViewCell
        switch ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row) {
            case (0,0):
                bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellIdentifier() , for: indexPath) as? BannerCollectionViewCell
                bannerCell!.delegate = self
                bannerCell!.dataSource = self.bannerItems
                bannerCell!.setup()
                bannerCell!.plecaEnd = {() in
                    self.removePleca()
                }

                cell = bannerCell!
                break;
            case (0,1):
                let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryHome", for: indexPath) as! CategoryCollectionViewCell
                categoryCell.delegate = self
                categoryCell.setCategoriesAndReloadData(categories)
                cell = categoryCell
                break;
            default:
                let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: productCellIdentifier(), for: indexPath) as! ProductHomeCollectionViewCell
                
                let catNameFilter = self.categories[selectedIndexCategory]
                let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]! as AnyObject
                let arrayItemsResult =  arrayItems as! [Any]
                let recommendProduct = arrayItemsResult[(indexPath as NSIndexPath).row] as! [String:Any]
               
                var desc = ""
                var imageUrl = ""
                var preorderable = false
                
                if let sku = recommendProduct["sku"] as? NSDictionary {
                    if let parentProducts = sku.object(forKey: "parentProducts") as? NSArray{
                        if let item =  parentProducts.object(at: 0) as? NSDictionary {
                            desc = item["longDescription"] as? String ?? (item["description"] as? String)!
                            imageUrl = item["largeImageUrl"] as! String
                        }
                    }
                    preorderable = sku.object(forKey: "weighable") as! String  == "N" ? false : true
                }
                
                var price = ""
                if let priceStr = recommendProduct["specialPrice"] as? String {
                    price = priceStr
                }else  if let priceNum = recommendProduct["specialPrice"] as? NSNumber {
                    price = "\(priceNum)"
                }
                
                
                var saving = ""
                if let savingVal  = recommendProduct["promoDescription"] as? String {
                    saving = savingVal
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch  ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row) {
        case (0,0):
            return CGSize(width: 320, height: 217)
        case (0,1):
            return CGSize(width: 320, height: 44)
        default:
            return CGSize(width: 106.66, height: 146)
        }
    }
       
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            
            let controller = ProductDetailPageViewController()
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]! as AnyObject
            let arrayItemsResult =  arrayItems as! [Any]
            let recommendProduct = arrayItemsResult[(indexPath as NSIndexPath).row] as! [String:Any]
            var upc = ""
            var desc = ""
            var skuId =  ""
            
            if let sku = recommendProduct["sku"] as? NSDictionary {
                skuId =  sku.object(forKey: "id") as! String
                if let parentProducts = sku.object(forKey: "parentProducts") as? NSArray{
                    if let item =  parentProducts.object(at: 0) as? NSDictionary {
                        upc = item["repositoryId"] as? String ?? item["id"] as! String
                        desc = item["longDescription"] as? String ?? item["description"] as! String
                    }
                }
            }
            
            
            let type = self.categoryType[catNameFilter]! == "gr" ? "groceries" : "mg"

            
            controller.itemsToShow = [["upc":upc,"description":desc,"type":type,"sku":skuId]]//pendiente sku en carrucel
            
            
            //EVENT
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SPECIAL_DETAILS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_SPECIAL_DETAILS.rawValue, action: WMGAIUtils.ACTION_VIEW_SPECIAL_DETAILS.rawValue, label: "\(desc) - \(upc)")


            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    
    func bannerDidSelect(_ queryBanner:String,type:String,urlTteaser:String?) {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Banner.rawValue
        
        //var params : Dictionary<String,String>?  = nil
        var components = queryBanner.components(separatedBy: "_")
        if urlTteaser !=  nil  {
            components[0] = "lc"
        }
        //Pendiente validar bts
        let componentsBts = queryBanner.components(separatedBy: "bts")
        if componentsBts.count > 1 && urlTteaser != nil {
            components[0] = "bts"
        }
        
        if(components.count <= 1 && urlTteaser == nil){
            return
        }
        let bannerStr : NSString = queryBanner as NSString
        switch components[0] {
        case "f":
            let val = bannerStr.substring(from: 2)
            showProducts(forDepartmentId: nil, andFamilyId: val, andLineId: nil,type:type)
        case "c":
            let val = bannerStr.substring(from: 2)
            showProducts(forDepartmentId: val, andFamilyId: nil, andLineId: nil,type:type)
        case "l":
            let val = bannerStr.substring(from: 2)
            if type == ResultObjectType.Mg.rawValue  {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_LINE.rawValue , label: "\(val)")
            } else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_LINE.rawValue , label: "\(val)")
            }
            showProducts(forDepartmentId: nil, andFamilyId: nil, andLineId: val,type:type)
        case "UPC":
            let val = bannerStr.substring(from: 4)
            if type == ResultObjectType.Mg.rawValue  {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MG_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MG_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_PRODUCT.rawValue , label: "\(val)")
            } else {
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_GR_BANNER_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_GR_BANNER_NO_AUTH.rawValue, action:WMGAIUtils.ACTION_VIEW_BANNER_PRODUCT.rawValue , label: "\(val)")
            }
            if val.range(of: ",") != nil {
                let upcss :NSString = val as NSString
                let myStringArr = upcss.components(separatedBy: ",")
                self.showFindUpc(myStringArr as NSArray ,type: type)
                
            }else{
                showProductDetail(val,type: type)
            }
        case "lc":
            self.openLandinCampaign(urlTteaser!,idFamily:queryBanner)
        case "bts":
                self.openBackToSchoolCategory(urlTteaser!,idFamily:queryBanner)
        default:
            return
        }
       
              
    }
    
    /**
     Open BackToSchoolCategory
     */
    func openBackToSchoolCategory(_ urlTicer:String,idFamily:String){
        let controller = BackToSchoolCategoryViewController()
        controller.urlTicer = urlTicer
        controller.departmentId = idFamily
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    /**
     Open linescontroller
     
     - parameter urlTicer: url of image
     - parameter idFamily: family search
     */
    func openLandinCampaign(_ urlTicer:String,idFamily:String){
        
        let controller = IPOLinesViewController()
        controller.urlTicer = urlTicer
        controller.familyName = idFamily
        self.navigationController!.pushViewController(controller, animated: true)

    }
    
    /**
     Open controller
     
     - parameter urlTicer:   image use in next controller
     - parameter idCategory: idCategory Search
     */
    func opnenLandingCategory(_ urlTicer:String,idCategory:String){

        print("Abrir categorias de escuelas")
        print(urlTicer)
        print(idCategory)
        print("::::::::")
        
    }
    
    
    
    
    func showFindUpc(_ upcs:NSArray,type:String){
        let controller = SearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .WithCategoryForMG
        }else {
            controller.searchContextType = .WithCategoryForGR
        }
        controller.findUpcsMg = upcs as? [String] as NSArray?
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

    
    func showProductDetail(_ upcProduct:String,type:String){
        let controller = ProductDetailPageViewController()
        controller.itemsToShow = [["upc":upcProduct,"description":"","type":type,"sku":upcProduct]]//sku
        
        willHideTabbar()
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.HideBar.rawValue), object: nil)
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
   
    func getCategories() -> [String]{
        
        //let specialsCat : [Any] = RecommendedCategory.cagtegories as [Any]
        self.categoryType = [:]
        var categories : [String] = []
        self.recommendCategoryItems = [:]
        
        if  self.recommendItems!.count == 0 {
            let servicecarousel = CarouselService()
            self.recommendItems = servicecarousel.getCarouselContent()
        }
        
        for itemRec in self.recommendItems! {
            var nameCategory = "Otros"
            let categoryname = itemRec["name"] as! String
            let categorytype = itemRec["type"] as! String
            
            self.categoryType[categoryname] = categorytype
            
            categories.append(itemRec["name"] as! String)
           
            let upcs = itemRec["upcs"] as? NSArray

                    nameCategory = itemRec["name"] as! String
                    if categories.filter({ (catName) -> Bool in return catName == nameCategory }).count == 0 {
                        categories.append(nameCategory)
                    }
                    
                    if let catItem : AnyObject = recommendCategoryItems[nameCategory] {
                        var array = catItem as! [Any]
                        array.append(itemRec as AnyObject)
                        recommendCategoryItems.updateValue(array as AnyObject, forKey: nameCategory)
                    } else {
                        recommendCategoryItems[nameCategory] = upcs
                    }
            }

        
        categories.sort { (item, seconditem) -> Bool in
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
    
    func updatecontent(_ sender:AnyObject) {
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
    
    func didSelectCategory(_ index:Int) {
        
        if self.selectedIndexCategory != index {
            var indexesPathsUpdate : [IndexPath] = []
            var indexesPathsDelete : [IndexPath] = []
            var indexesPathsInsert : [IndexPath] = []
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]! as AnyObject
            let arrayItemsResult =  arrayItems as! [Any]
            
            let catNameFilterNew = self.categories[index]
            let arrayItemsNew : AnyObject = self.recommendCategoryItems[catNameFilterNew]! as AnyObject
            let arrayItemsResultNew =  arrayItemsNew as! [Any]
            
            for ix in 0...arrayItemsResult.count - 1 {
                if arrayItemsResultNew.count > ix {
                    indexesPathsUpdate.append(IndexPath(row: ix , section: 1))
                }
            }
            
            
            if arrayItemsResultNew.count > arrayItemsResult.count {
                for ix in arrayItemsResult.count...arrayItemsResultNew.count - 1 {
                    indexesPathsInsert.append(IndexPath(row: ix , section: 1))
                }
            } else if arrayItemsResultNew.count < arrayItemsResult.count {
                for ix in arrayItemsResultNew.count...arrayItemsResult.count - 1 {
                    indexesPathsDelete.append(IndexPath(row: ix , section: 1))
                }
            }
            
            self.selectedIndexCategory = index
            if indexesPathsDelete.count > 0 {
                collection.performBatchUpdates({ () -> Void in
                    
                    self.collection.deleteItems(at: indexesPathsDelete)
                    }, completion: { (complete:Bool) -> Void in
                    self.collection.performBatchUpdates({ () -> Void in
                        if indexesPathsUpdate.count > 0 {
                            self.collection.reloadItems(at: indexesPathsUpdate)
                        }
                        }, completion: { (complete:Bool) -> Void in
                         //println("Termina")
                    })
                })
            }
            if indexesPathsInsert.count > 0 {
                collection.performBatchUpdates({ () -> Void in
                     self.collection.insertItems(at: indexesPathsInsert)
                    
                    }, completion: { (complete:Bool) -> Void in
                        self.collection.performBatchUpdates({ () -> Void in
                            self.collection.reloadItems(at: indexesPathsUpdate)
                            }, completion: { (complete:Bool) -> Void in
                                //println("Termina")
                        })
                })
            }
            if indexesPathsDelete.count == 0 && indexesPathsInsert.count == 0 {
                collection.performBatchUpdates({ () -> Void in
                    self.collection.reloadItems(at: indexesPathsUpdate)
                    }, completion: { (complete:Bool) -> Void in
                    //println("Termina")
                })
            }
            //collection.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            if let layoutFlow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                return layoutFlow.sectionInset
            }
        }
        return UIEdgeInsets.zero
    }
    
    func termsSelect(_ url: String) {
        let ctrlWeb = IPOWebViewController()
        ctrlWeb.openURL(url)
        self.present(ctrlWeb, animated: true, completion: nil)
    }
    
    
    
}
