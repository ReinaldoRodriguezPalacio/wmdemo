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
    
    override func viewDidLoad() {
        
        let serviceBanner = BannerService()
        if let landingUse = serviceBanner.getLanding() {
            if landingUse.count > 0 {
                landingItem = landingUse[0]
            }
        }
        
        
        self.datasource = self
        self.delegate = self
        
        super.viewDidLoad()
        //screen
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_CATEGORIES.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }

        self.viewFamily = UIView()
        self.viewFamily.backgroundColor = UIColor.whiteColor()
        
        self.familyController = FamilyViewController()
        self.familyController.categoriesType = .CategoryForMG
        self.addChildViewController(self.familyController)
        self.viewFamily.addSubview(self.familyController.view)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewFamily.frame = CGRectMake(0, CELL_HEIGHT, self.view.bounds.width, self.view.bounds.height - CELL_HEIGHT)
        categories.frame = self.view.bounds
        familyController.view.frame = viewFamily.bounds
    }
    
    func loadDepartments() ->  [AnyObject]? {
        let serviceCategory = CategoryService()
        items = serviceCategory.getCategoriesContent()
        return items
    }
    
    func getServiceURLIcon() -> String {
        return "WalmartMG.CategoryIcon"
    }
    
    
    func getServiceURLHeader() -> String {
        return "WalmartMG.HeaderCategory"
    }
    
    func didSelectDeparmentAtIndex(indexPath: NSIndexPath){
        
        var currentItem = indexPath.row
        if indexPath.row == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
    
        let item = items![currentItem] as [String:AnyObject]
        let famArray : AnyObject = item["family"] as AnyObject!
        let itemsFam : [[String:AnyObject]] = famArray as [[String:AnyObject]]
        let descDepartment = item["description"] as? NSString
        let tracker = GAI.sharedInstance().defaultTracker
      
        familyController.departmentId = item["idDepto"] as NSString
        familyController.families = itemsFam
        familyController.selectedFamily = nil
        familyController.familyTable.reloadData()
        
        var categoryCell = self.categories.cellForItemAtIndexPath(indexPath) as? DepartmentCollectionViewCell
        if categoryCell == nil {
            self.categories.reloadItemsAtIndexPaths([indexPath])
            categoryCell = self.categories.cellForItemAtIndexPath(indexPath) as? DepartmentCollectionViewCell
        }
        let frameOriginal = self.categories.convertRect(categoryCell!.frame, toView:  self.view)
        selectedView = IPODepartmentCollectionViewCell(frame:frameOriginal)
        selectedView.isOpen = true
        selectedView.setValuesFromCell(categoryCell!)
        self.view.addSubview(selectedView)
        
        selectedView.onclose = {() in
            println("Close")
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.viewFamily.alpha = 0
            })
            self.closeDepartment()
        }
        
        selectedView.animateToOpenDepartment(self.view.frame.width, endAnumating: { () -> Void in
            
            self.viewFamily.alpha = 0
            self.familyController.familyTable.reloadData()
            self.view.addSubview(self.viewFamily)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.viewFamily.alpha = 1
            })
            
            println("End")

        })

    }
    
    func openGroceriesCategories() {
        let grController = self.storyboard?.instantiateViewControllerWithIdentifier("GrCaregory") as UIViewController
        self.navigationController?.pushViewController(grController, animated: true)
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.GR_SCREEN_PRODUCTSCATEGORY.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        
        return
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let categoryCell = categories.dequeueReusableCellWithReuseIdentifier("DepartmentCell", forIndexPath: indexPath) as DepartmentCollectionViewCell
        
        let svcUrl = delegate?.getServiceURLIcon()
        let svcUrlCar = delegate?.getServiceURLHeader()
        
        var hideView = false
        if self.currentIndexSelected != nil {
            hideView = self.currentIndexSelected?.row != indexPath.row
        }
        var currentItem = indexPath.row
        if indexPath.item == 0 && landingItem != nil  {
            
            let itemBannerPhone = landingItem!["bannerUrlPhone"]
            categoryCell.setValuesLanding("http://\(itemBannerPhone!)")
            return categoryCell
            
        }// if indexPath.item == 0 {
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
        
        let item = items![currentItem] as [String:AnyObject]
        let descDepartment = item["description"] as NSString
        let bgDepartment = item["idDepto"] as NSString
        let departmentId = item["idDepto"] as NSString
        
        categoryCell.setValues(descDepartment,imageBackgroundURL: bgDepartment + ".png",keyBgUrl:svcUrlCar!,imageIconURL:"i_" + bgDepartment + ".png",keyIconUrl:svcUrl!,hideImage:hideView)
        
        return categoryCell
    }
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        if landingItem != nil {
            switch (indexPath.section,indexPath.row) {
            case (0,0):
                return CGSizeMake(312, 98)
            default:
                return CGSizeMake(154, 98)
            }
        }
        return CGSizeMake(154, 98)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    
    func handleLandingEvent(strAction:String) {
        var components = strAction.componentsSeparatedByString("_")
        if(components.count > 1){
            let window = UIApplication.sharedApplication().keyWindow
            if let customBar = window!.rootViewController as? CustomBarViewController {
                let cmpStr  = components[0] as String
                let strValue = strAction.stringByReplacingOccurrencesOfString("\(cmpStr)_", withString: "")
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
                
                
                customBar.handleNotification(strAction,name:"",value:strValue)
            }
        }
    }
   

}