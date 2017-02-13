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
        viewFamily.frame = CGRect(x: 0, y: CELL_HEIGHT, width: self.view.bounds.width, height: self.view.bounds.height - CELL_HEIGHT)
        categories!.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        familyController.view.frame = viewFamily.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CustomBarNotification.TapBarFinish.rawValue), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(IPOCategoriesViewController.tabBarFinish),name:NSNotification.Name(rawValue: CustomBarNotification.TapBarFinish.rawValue), object: nil)
        self.tabBarFinish()
    }
    
    func loadDepartments() ->  [Any]? {
        let serviceCategory = CategoryService()
        items = serviceCategory.getCategoriesContent(from: "mg") as [Any]?
        return items
    }
    
    func getServiceURLIcon() -> String {
        return "WalmartMG.CategoryIcon"
    }
    
    
    func getServiceURLHeader() -> String {
        return "WalmartMG.HeaderCategory"
    }
    
    func didSelectDeparmentAtIndex(_ indexPath: IndexPath){
        
        var currentItem = (indexPath as NSIndexPath).row
        if (indexPath as NSIndexPath).row == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
    
        let item = items![currentItem] as! [String:Any]
        let famArray : AnyObject = item["familyContent"] as AnyObject!
        let itemsFam : [[String:Any]] = famArray as! [[String:Any]]
      
        familyController.departmentId = item["idDept"] as! String
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
        self.view.addSubview(selectedView)
        
        selectedView.onclose = {() in
            print("Close")
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
            
            print("End")

        })

    }
    
    func openGroceriesCategories() {
        let grController = self.storyboard?.instantiateViewController(withIdentifier: "GrCaregory")
        self.navigationController?.pushViewController(grController!, animated: true)
        return
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = categories!.dequeueReusableCell(withReuseIdentifier: "DepartmentCell", for: indexPath) as! DepartmentCollectionViewCell
        
        let svcUrl = delegate?.getServiceURLIcon()
        let svcUrlCar = delegate?.getServiceURLHeader()
        
        var hideView = false
        if self.currentIndexSelected != nil {
            hideView = (self.currentIndexSelected as NSIndexPath?)?.row != (indexPath as NSIndexPath).row
        }
        var currentItem = (indexPath as NSIndexPath).row
        if (indexPath as NSIndexPath).item == 0 && landingItem != nil  {
            let scale = UIScreen.main.scale
            var itemBannerPhone = landingItem!["bannerUrlPhone"]
            itemBannerPhone = itemBannerPhone!.replacingOccurrences(of: "@2x.jpg", with: ".jpg" )
            itemBannerPhone = itemBannerPhone!.replacingOccurrences(of: ".jpg", with: "@\(Int(scale))x.jpg" )
            categoryCell.setValuesLanding("https://\(itemBannerPhone!)")
            categoryCell.imageBackground.contentMode = UIViewContentMode.left
            return categoryCell
            
        }// if indexPath.item == 0 {
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
        
        let item = items![currentItem] as! [String:Any]
        let descDepartment = item["DepartmentName"] as? String ?? ""
        let bgDepartment = item["idDept"] as! String
        
        categoryCell.setValues(descDepartment,imageBackgroundURL: bgDepartment + ".png",keyBgUrl:svcUrlCar!,imageIconURL:"i_" + bgDepartment + ".png",keyIconUrl:svcUrl!,hideImage:hideView)
        categoryCell.imageBackground.contentMode = UIViewContentMode.left
        return categoryCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        if landingItem != nil {
            switch (indexPath.section,indexPath.row) {
            case (0,0):
                return CGSize(width: 312, height: 98)
            default:
                return CGSize(width: 154, height: 98)
            }
        }
        return CGSize(width: (self.view.frame.width - (4*3)) / 2, height: 98)
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

    func tabBarFinish(){
        if let layoutFlow = self.categories?.collectionViewLayout as? UICollectionViewFlowLayout {
            if TabBarHidden.isTabBarHidden {
                let insetToUse: CGFloat = (layoutFlow.sectionInset.bottom  - 49) < 0 ? layoutFlow.sectionInset.bottom : CGFloat(4.0)
                layoutFlow.sectionInset = UIEdgeInsetsMake(layoutFlow.sectionInset.top, layoutFlow.sectionInset.left, insetToUse, layoutFlow.sectionInset.right)
            }else{
                layoutFlow.sectionInset = UIEdgeInsetsMake(layoutFlow.sectionInset.top, layoutFlow.sectionInset.left, 49, layoutFlow.sectionInset.right)
            }
        }
    }
}
