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
    var items: [Any] = []
    var selectedIndex: IndexPath!
    var selectedLine: Bool = false
    var controllerAnimateView : IPACategoriesResultViewController!
    var selIdDepartment :String!
    var selIdFamily :String!
    var selIdLine:String!
    var selName:String!
    var landingItem : [String:String]? = nil
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MGDEPARTMENT.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        let serviceCategory = CategoryService()
        items = serviceCategory.getCategoriesContent(from: "mg") as [Any]
        
        categories.register(IPACategoryCollectionViewClass.self, forCellWithReuseIdentifier: "categoryCell")
        categories.delegate = self
        categories.dataSource = self
        categories.isMultipleTouchEnabled = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count //+ 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = categories.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! IPACategoryCollectionViewClass
        
        let currentItem = (indexPath as NSIndexPath).row
        if (indexPath as NSIndexPath).item == 0 && landingItem != nil  {
            
            let itemBannerPhone = landingItem!["bannerUrlTablet"]
            categoryCell.setValuesLanding("https://\(itemBannerPhone!)")
            return categoryCell
            
        }// if indexPath.item == 0 {
        
        let item = items[currentItem] as! [String:Any]
        let descDepartment = item["DepartmentName"] as! String
        let bgDepartment = item["idDept"] as! String
        /*var selected = false
        if selectedIndex != nil {
        selected = indexPath.row == selectedIndex.row
        }*/
        
        categoryCell.setValues(descDepartment, imageBackgroundURL: bgDepartment + ".png", imageIconURL: "i_" + bgDepartment + ".png")
        
        //categoryCell.setValues(descDepartment, imageBackgroundURL: "\(bgDepartment).png", imageIconURL: "i_\(bgDepartment).png" ,selected:false,departmentId: departmentId,itemsFam:itemsFam,showWhite:selectedLine)
        return categoryCell
    }

    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        
        if landingItem != nil {
            switch (indexPath.section,indexPath.row) {
            case (0,0):
                return CGSize(width: self.view.frame.width - 16, height: 216)
            default:
                print("")
            }
        }
        return CGSize(width: ((self.view.frame.width - 34 ) / 3) , height: 216)

    }
    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//        return CGSizeMake(((self.view.frame.width - 32 ) / 3) , 216)
//    }
//    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*if selectedLine == false {
            if selectedIndex != nil {
                let reloadBk = NSIndexPath(forRow: selectedIndex.row, inSection: 0)
                selectedIndex = nil
                collectionView.reloadItemsAtIndexPaths([reloadBk])
            }
            selectedIndex = indexPath
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }*/

        if (indexPath as NSIndexPath).row == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        
        if self.selectedIndex == nil {
            self.selectedIndex = indexPath
            
            let item = items[(indexPath as NSIndexPath).row] as! [String:Any]
            let idDepartment = item["idDept"] as! String
            let famArray : AnyObject = item["familyContent"] as AnyObject!
            let itemsFam : [[String:Any]] = famArray as! [[String:Any]]
            var famSelected = itemsFam[0]
            var idFamDefault = famSelected["familyId"] as! String
            
            var lineArray : AnyObject = famSelected["fineContent"] as AnyObject!
            var itemsLine : [[String:Any]] = lineArray as! [[String:Any]]
            
            if itemsLine.count == 0 {
                famSelected = itemsFam[1]
                idFamDefault = famSelected["id"] as! String
                lineArray = famSelected["fineContent"] as AnyObject!
                itemsLine = lineArray as! [[String:Any]]
            }
            
            if itemsLine.count == 0{
                self.categories.contentInset = UIEdgeInsetsMake(0, 0, self.categories.frame.height, 0)
                let cellSelected = categories.cellForItem(at: selectedIndex) as! IPACategoryCollectionViewClass
                self.didSelectLine("", family: "", line: "", name: "", imageDepartment: cellSelected.imageBackground.image, imageIcon: cellSelected.imageIcon.image)
                return
            }
            
                let lineSelected =  itemsLine[0]
                let idLineDefault = lineSelected["id"] as! String
                let nameLineDefault = lineSelected["displayName"] as! String
                
                selIdDepartment = idDepartment
                selIdFamily = idFamDefault
                selIdLine = idLineDefault
                selName = nameLineDefault
                
                self.categories.contentInset = UIEdgeInsetsMake(0, 0, self.categories.frame.height, 0)
                let cellSelected = categories.cellForItem(at: selectedIndex) as! IPACategoryCollectionViewClass
                UIView.animate(withDuration: 0.35, animations: { () -> Void in
                    self.categories.scrollToItem(at: self.selectedIndex, at: UICollectionViewScrollPosition.top, animated: false)
                    }, completion: { (complete:Bool) -> Void in
                        if complete {
                            self.didSelectLine(self.selIdDepartment,family:self.selIdFamily,line:self.selIdLine, name:self.selName,imageDepartment:cellSelected.imageBackground.image,imageIcon:cellSelected.imageIcon.image)
                        }
                }) 
        //}
    }
    
        
        
       
    }
    

    func didSelectLine(_ department:String,family:String,line:String, name:String) {
        
    }
    
    func didSelectLine(_ department:String,family:String,line:String, name:String,imageDepartment:UIImage?,imageIcon:UIImage?) {
        if selectedIndex != nil &&  self.selectedLine == false {
            selectedLine = true
            let cellSelected = categories.cellForItem(at: selectedIndex) as! IPACategoryCollectionViewClass
            
            let item = items[selectedIndex.row] as! [String:Any]
            let famArray : AnyObject = item["familyContent"] as AnyObject!
            let itemsFam : [[String:Any]] = famArray as! [[String:Any]]
            
            categories.isScrollEnabled = false
       
            CategoryShouldShowFamily.shouldshowfamily = true
            controllerAnimateView = IPACategoriesResultViewController()
            controllerAnimateView.setValues(department, family: family, line: line, name:name)
            controllerAnimateView.imgCategory =  imageDepartment
            controllerAnimateView.frameStart = CGRect(x: cellSelected.frame.minX, y: 0, width: cellSelected.frame.width, height: cellSelected.frame.height)
            controllerAnimateView.frameEnd = CGRect(x: 0, y: 0, width: categories.frame.width, height: categories.frame.height)
            controllerAnimateView.imgIcon = imageIcon
            controllerAnimateView.titleStr = cellSelected.titleLabel.text
            controllerAnimateView.families = itemsFam
            controllerAnimateView.name = name
            controllerAnimateView.searchContextType = SearchServiceContextType.withCategoryForMG
            controllerAnimateView.actionClose = {() in
                self.categories.isScrollEnabled = true
                self.selectedLine = false
                self.controllerAnimateView = nil
                self.selectedIndex = nil
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.categories.contentInset = UIEdgeInsets.zero
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
            let currentCell = controllerAnimateView.searchProduct.collection!.cellForItem(at: controllerAnimateView.searchProduct.currentCellSelected as IndexPath) as! IPASearchProductCollectionViewCell!
            currentCell?.showImageView()
        }
    }
    
    
    func handleLandingEvent(_ strAction:String) {
        var components = strAction.components(separatedBy: "_")
        if(components.count > 1){
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController {
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
                
                
                customBar.handleNotification(strAction,name:"",value:strValue,bussines:"mg")
            }
        }
    }
    
    
  
    
}
