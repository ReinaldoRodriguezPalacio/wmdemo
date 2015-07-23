//
//  IPACategoriesViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPACategoriesViewController : BaseController ,UICollectionViewDataSource, UICollectionViewDelegate, IPAFamilyViewControllerDelegate  {
    
    
    @IBOutlet var categories: UICollectionView!
    var items: [AnyObject] = []
    var selectedIndex: NSIndexPath!
    var selectedLine: Bool = false
    var controllerAnimateView : IPACategoriesResultViewController!
    var selIdDepartment :String!
    var selIdFamily :String!
    var selIdLine:String!
    var selName:String!
    var landingItem : [String:String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let serviceBanner = BannerService()
        if let landingUse = serviceBanner.getLanding() {
            if landingUse.count > 0 {
                landingItem = landingUse[0]
            }
            
        }

        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_CATEGORIES.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        
        
        let serviceCategory = CategoryService()
        items = serviceCategory.getCategoriesContent()
        
        categories.registerClass(IPACategoryCollectionViewClass.self, forCellWithReuseIdentifier: "categoryCell")
        categories.delegate = self
        categories.dataSource = self
        categories.multipleTouchEnabled = false
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count //+ 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let categoryCell = categories.dequeueReusableCellWithReuseIdentifier("categoryCell", forIndexPath: indexPath) as IPACategoryCollectionViewClass
        
        var currentItem = indexPath.row
        if indexPath.item == 0 && landingItem != nil  {
            
            let itemBannerPhone = landingItem!["bannerUrlTablet"]
            categoryCell.setValuesLanding("http://\(itemBannerPhone!)")
            return categoryCell
            
        }// if indexPath.item == 0 {
        
        let item = items[currentItem] as [String:AnyObject]
        let descDepartment = item["description"] as NSString
        let bgDepartment = item["idDepto"] as NSString
        let departmentId = item["idDepto"] as NSString
        /*var selected = false
        if selectedIndex != nil {
        selected = indexPath.row == selectedIndex.row
        }*/
        
        categoryCell.setValues(descDepartment, imageBackgroundURL: bgDepartment + ".png", imageIconURL: "i_" + bgDepartment + ".png")
        
        //categoryCell.setValues(descDepartment, imageBackgroundURL: "\(bgDepartment).png", imageIconURL: "i_\(bgDepartment).png" ,selected:false,departmentId: departmentId,itemsFam:itemsFam,showWhite:selectedLine)
        
        
        
        
        return categoryCell
    }

    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        if landingItem != nil {
            switch (indexPath.section,indexPath.row) {
            case (0,0):
                return CGSizeMake(self.view.frame.width - 16, 216)
            default:
                println("")
            }
        }
        return CGSizeMake(((self.view.frame.width - 34 ) / 3) , 216)

    }
    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//        return CGSizeMake(((self.view.frame.width - 32 ) / 3) , 216)
//    }
//    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        /*if selectedLine == false {
            if selectedIndex != nil {
                let reloadBk = NSIndexPath(forRow: selectedIndex.row, inSection: 0)
                selectedIndex = nil
                collectionView.reloadItemsAtIndexPaths([reloadBk])
            }
            selectedIndex = indexPath
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }*/

        if indexPath.row == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        
        if self.selectedIndex == nil {
            self.selectedIndex = indexPath
            
            let item = items[indexPath.row] as [String:AnyObject]
            let idDepartment = item["idDepto"] as NSString
            let famArray : AnyObject = item["family"] as AnyObject!
            let itemsFam : [[String:AnyObject]] = famArray as [[String:AnyObject]]
            let famSelected = itemsFam[0]
            let idFamDefault = famSelected["id"] as NSString
            
            let lineArray : AnyObject = famSelected["line"] as AnyObject!
            let itemsLine : [[String:AnyObject]] = lineArray as [[String:AnyObject]]
            let lineSelected = itemsLine[0]
            let idLineDefault = lineSelected["id"] as NSString
            let nameLineDefault = lineSelected["name"] as NSString
            
            
            
            selIdDepartment = idDepartment
            selIdFamily = idFamDefault
            selIdLine = idLineDefault
            selName = nameLineDefault
            
            self.categories.contentInset = UIEdgeInsetsMake(0, 0, self.categories.frame.height, 0)
            let cellSelected = categories.cellForItemAtIndexPath(selectedIndex) as IPACategoryCollectionViewClass
            UIView.animateWithDuration(0.35, animations: { () -> Void in
                self.categories.scrollToItemAtIndexPath(self.selectedIndex, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                }) { (complete:Bool) -> Void in
                    if complete {
                        self.didSelectLine(self.selIdDepartment,family:self.selIdFamily,line:self.selIdLine, name:self.selName,imageDepartment:cellSelected.imageBackground.image,imageIcon:cellSelected.imageIcon.image)
                    }
            }
        }
        
        
       
    }
    

    func didSelectLine(department:String,family:String,line:String, name:String) {
        
    }
    
    func didSelectLine(department:String,family:String,line:String, name:String,imageDepartment:UIImage?,imageIcon:UIImage?) {
        if selectedIndex != nil &&  self.selectedLine == false {
            selectedLine = true
            let cellSelected = categories.cellForItemAtIndexPath(selectedIndex) as IPACategoryCollectionViewClass
            
            let item = items[selectedIndex.row] as [String:AnyObject]
            let idDepartment = item["idDepto"] as NSString
            let famArray : AnyObject = item["family"] as AnyObject!
            let itemsFam : [[String:AnyObject]] = famArray as [[String:AnyObject]]
            
            categories.scrollEnabled = false
       
            CategoryShouldShowFamily.shouldshowfamily = true
            controllerAnimateView = IPACategoriesResultViewController()
            controllerAnimateView.setValues(department, family: family, line: line, name:name)
            controllerAnimateView.imgCategory =  imageDepartment
            controllerAnimateView.frameStart = CGRectMake(cellSelected.frame.minX, 0, cellSelected.frame.width, cellSelected.frame.height)
            controllerAnimateView.frameEnd = CGRectMake(0, 0, categories.frame.width, categories.frame.height)
            controllerAnimateView.imgIcon = imageIcon
            controllerAnimateView.titleStr = cellSelected.titleLabel.text
            controllerAnimateView.families = itemsFam
            controllerAnimateView.name = name
            controllerAnimateView.searchContextType = SearchServiceContextType.WithCategoryForMG
            controllerAnimateView.actionClose = {() in
                self.categories.scrollEnabled = true
                self.selectedLine = false
                self.controllerAnimateView = nil
                self.selectedIndex = nil
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.categories.contentInset = UIEdgeInsetsZero
                    }, completion: { (complete:Bool) -> Void in
                        self.categories.reloadData()
                })
              
            }
            
            self.addChildViewController(controllerAnimateView)
            self.view.addSubview(controllerAnimateView.view)
            
        }
    }
    
    func reloadSelectedCell() {
        if controllerAnimateView != nil {
            let currentCell = controllerAnimateView.searchProduct.collection!.cellForItemAtIndexPath(controllerAnimateView.searchProduct.currentCellSelected) as IPASearchProductCollectionViewCell!
            currentCell.showImageView()
        }
    }
    
    
    func handleLandingEvent(strAction:String) {
        var components = strAction.componentsSeparatedByString("_")
        if(components.count > 1){
            let window = UIApplication.sharedApplication().keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController {
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