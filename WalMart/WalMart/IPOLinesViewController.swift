//
//  IPOLinesViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 25/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
class IPOLinesViewController : IPOCategoriesViewController {

    var lineController : LineViewController!
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        
        
        self.viewFamily = UIView()
        self.viewFamily.backgroundColor = UIColor.whiteColor()
        
        self.lineController = LineViewController()
        self.lineController.categoriesType = .CategoryForMG
        self.addChildViewController(self.lineController)
        self.viewFamily.addSubview(self.lineController.view)
    }
    
    
    override func viewWillLayoutSubviews() {
        viewFamily.frame = CGRectMake(0, CELL_HEIGHT, self.view.bounds.width, self.view.bounds.height - CELL_HEIGHT)
        lineController.view.frame = viewFamily.bounds
    }
    
    
    override func didSelectDeparmentAtIndex(indexPath: NSIndexPath){
        
        var currentItem = indexPath.row
        if indexPath.row == 0  && landingItem != nil  {
            let eventUrl = landingItem!["eventUrl"]
            self.handleLandingEvent(eventUrl!)
            return
        }
        
        if landingItem != nil {
            currentItem = currentItem - 1
        }
        
        let item = items![currentItem] as! [String:AnyObject]
        let famArray : AnyObject = item["family"] as AnyObject!
        let itemsFam : [[String:AnyObject]] = famArray as! [[String:AnyObject]]
        
        let label = item["description"] as! String
        let labelCategory = label.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
        BaseController.sendAnalytics("MG_\(labelCategory)_VIEW_AUTH", categoryNoAuth: "MG_\(labelCategory)_VIEW_NO_AUTH", action: WMGAIUtils.ACTION_SHOW_FAMILIES.rawValue, label: label)
        
        familyController.departmentId = item["idDepto"] as! String
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
            print("Close")
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
            
            print("End")
            
        })
        
    }
    
    
    

}
