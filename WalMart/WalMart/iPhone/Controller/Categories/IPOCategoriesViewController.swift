//
//  IPOCategoriesViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/3/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPOCategoriesViewController : BaseCategoryViewController, BaseCategoryViewControllerDataSource,BaseCategoryViewControllerDelegate {
    
    let CELL_HEIGHT : CGFloat = 98
    var viewFamily: UIView!
    var familyController : FamilyViewController!
    var selectedView : IPODepartmentCollectionViewCell!
    var landingItem : [String:String]? = nil
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGDEPARTMENT.rawValue
    }
    
    override func viewDidLoad() {
        let serviceBanner = BannerService()
        if let landingUse = serviceBanner.getLanding() {
            if landingUse.count > 0 {
                for landing in landingUse {
                    let landingType = landing["type"]
                    if landingType != nil && landingType! == "mg" {
                        landingItem = landing
                        BaseController.sendLandingAnalitycs(landing: landing)
                    }
                }
            }
        }

        self.datasource = self
        self.delegate = self
        
        super.viewDidLoad()
        //screen
       
        self.viewFamily = UIView()
        self.viewFamily.backgroundColor = UIColor.white
        
        self.familyController = FamilyViewController()
        self.familyController.categoriesType = .categoryForMG
        self.addChildViewController(self.familyController)
        self.viewFamily.addSubview(self.familyController.view)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewFamily.frame = CGRect(x: 0, y: CELL_HEIGHT, width: self.view.bounds.width, height: self.view.bounds.height - CELL_HEIGHT - 44)
        categories!.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        familyController.view.frame = viewFamily.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func loadDepartments() ->  [Any]? {
        let serviceCategory = CategoryService()
        items = serviceCategory.getCategoriesContent() as [Any]?
        return items
    }
    
    func getServiceURLIcon() -> String {
        return "WalmartMG.CategoryIcon"
    }
    
    func getServiceURLHeader() -> String {
        return "WalmartMG.HeaderCategory"
    }
    
    func didSelectDeparmentAtIndex(_ indexPath: IndexPath){
        
        var currentItem = indexPath.row
        if indexPath.row == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
          var banner =  Banner()
          
          banner.id = landingItem!["eventCode"]!+""
          banner.name = landingItem!["eventCode"]!+""
          banner.creative = landingItem!["type"] ?? ""
          banner.position = "1"
          
          BaseController.sendAnalyticsClickBanner(banner)
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
    
        let item = items![currentItem] as! [String:Any]
        let famArray : AnyObject = item["family"] as AnyObject!
        let itemsFam : [[String:Any]] = famArray as! [[String:Any]]
      
        familyController.departmentId = item["idDepto"] as! String
        familyController.families = itemsFam
        familyController.selectedFamily = nil
        familyController.familyTable.reloadData()
        
        var categoryCell = self.categories!.cellForItem(at: indexPath) as? DepartmentCollectionViewCell
        
        if categoryCell == nil {
            self.categories!.reloadItems(at: [indexPath])
            categoryCell = self.categories!.cellForItem(at: indexPath) as? DepartmentCollectionViewCell
        }
        
        let frameOriginal = self.categories!.convert(categoryCell!.frame, to:  self.view)
        selectedView = IPODepartmentCollectionViewCell(frame:frameOriginal)
        selectedView.isOpen = true
        selectedView.setValuesFromCell(categoryCell!)
        selectedView.backgroundView?.contentMode = .scaleAspectFill
        self.view.addSubview(selectedView)
        
        selectedView.onclose = {() in
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.viewFamily.alpha = 0
            },completion: {(complete) -> Void in
                self.closeDepartment()
            })
        }
        
        selectedView.animateToOpenDepartment(self.view.frame.width, endAnumating: { () -> Void in
            
            self.viewFamily.alpha = 0
            self.familyController.familyTable.reloadData()
            self.view.addSubview(self.viewFamily)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.viewFamily.alpha = 1
            })

        })

    }
    
    func openGroceriesCategories() {
        let grController = self.storyboard?.instantiateViewController(withIdentifier: "GrCaregory")
        self.navigationController?.pushViewController(grController!, animated: true)
        return
    }
    
    func handleLandingEvent(_ strAction:String) {
        var components = strAction.components(separatedBy: "_")
        if(components.count > 1){
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? CustomBarViewController {
                let cmpStr  = components[0] as String
                let strValue = strAction.replacingOccurrences(of: "\(cmpStr)_", with: "")
                var strAction = ""
                switch components[0] {
                case "f":
                    strAction =  "FAM"
                case "c":
                    strAction =  "CAT"
                case "l":
                    strAction =  "LIN"
                case "UPC":
                    strAction =  "UPC"
                default:
                    return
                }
                let _ = customBar.handleNotification(strAction,name:"",value:strValue,bussines:"mg")
            }
        }
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        if landingItem != nil {
            switch (indexPath.section,indexPath.row) {
            case (0,0):
                return CGSize(width: (self.view.frame.width - (4*2)), height: 98)
            default:
                return CGSize(width: (self.view.frame.width - (4*3)) / 2, height: 98)
            }
        }
        return CGSize(width: (self.view.frame.width - (4*3)) / 2, height: 98)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let categoryCell = categories!.dequeueReusableCell(withReuseIdentifier: "DepartmentCell", for: indexPath) as! DepartmentCollectionViewCell
        let svcUrl = delegate?.getServiceURLIcon()
        let svcUrlCar = delegate?.getServiceURLHeader()
        
        var hideView = false
        if self.currentIndexSelected != nil {
            hideView = self.currentIndexSelected?.row != indexPath.row
        }
        
        var currentItem = indexPath.row
        if indexPath.item == 0 && landingItem != nil  {
            let model =  UIDevice.current.modelName
            let scale = model.contains("Plus") ? 3 : UIScreen.main.scale
            var itemBannerPhone = landingItem!["bannerUrlPhone"]
            itemBannerPhone = itemBannerPhone!.replacingOccurrences(of: "@2x.jpg", with: ".jpg" )
            itemBannerPhone = itemBannerPhone!.replacingOccurrences(of: ".jpg", with: "@\(Int(scale))x.jpg" )
            categoryCell.setValuesLanding("https://\(itemBannerPhone!)")
            return categoryCell
            
        }
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
        
        let item = items![currentItem] as! [String:Any]
        let descDepartment = item["description"] as! String
        let bgDepartment = item["idDepto"] as! String
        
        categoryCell.setValues(descDepartment,imageBackgroundURL: bgDepartment + ".png",keyBgUrl:svcUrlCar!,imageIconURL:"i_" + bgDepartment + ".png",keyIconUrl:svcUrl!,hideImage:hideView)
        
        return categoryCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if landingItem == nil {
            return items!.count
        }
        return items!.count + 1
    }

    override func closeSelectedDepartment() {
        if self.currentIndexSelected != nil {
            selectedView.closeDepartment()
        }
    }
   
}
