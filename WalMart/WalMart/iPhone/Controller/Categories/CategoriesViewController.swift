//
//  CategoriesViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class CategoriesViewController : IPOBaseController,UITableViewDataSource,UITableViewDelegate,IPOCategoryViewDelegate{
    
    let CELL_HEIGHT : CGFloat = 98
    
    var items: [AnyObject] = []
    
    @IBOutlet weak var categoriesTable: UITableView!
    var indexPathSelected: NSIndexPath! = nil
    var scrollOffset: CGPoint!
    var viewFamily: UIView!
    var familyController : FamilyViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_CATEGORIES.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        

        let serviceCategory = CategoryService()
        items = serviceCategory.getCategoriesContent()
        
        categoriesTable.registerClass(IPOCategoryView.self, forCellReuseIdentifier: "categoryCell")
        
        viewFamily = UIView()
        viewFamily.backgroundColor = UIColor.whiteColor()
        
        familyController = FamilyViewController()
        self.addChildViewController(familyController)
        self.viewFamily.addSubview(familyController.view)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoriesTable.frame = self.view.bounds
        viewFamily.frame = CGRectMake(0, CELL_HEIGHT, self.view.bounds.width, self.view.bounds.height - CELL_HEIGHT)
        familyController.view.frame = viewFamily.bounds
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as IPOCategoryView
        
        let item = items[indexPath.row] as [String:AnyObject]
        let descDepartment = item["description"] as NSString
        let bgDepartment = item["idDepto"] as NSString
        categoryCell.setValues(descDepartment, imageBackgroundURL: bgDepartment + ".png", imageIconURL: "i_" + bgDepartment + ".png")
        categoryCell.selected = false
        categoryCell.delegate = self
        categoryCell.viewOverCellWhite.hidden = true
        if self.indexPathSelected != nil && indexPath.row != self.indexPathSelected.row {
            categoryCell.viewOverCellWhite.hidden = false
        }
        return categoryCell
    }
    
    
    
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if self.indexPathSelected  == nil {
            let item = items[indexPath.row] as [String:AnyObject]
            let famArray : AnyObject = item["family"] as AnyObject!
            let itemsFam : [[String:AnyObject]] = famArray as [[String:AnyObject]]
            let descDepartment = item["description"] as? NSString
            let tracker = GAI.sharedInstance().defaultTracker
            if tracker != nil && descDepartment != nil {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.MODULE_CATEGORIES.rawValue, action: WMGAIUtils.ACTION_BUTTON_PRESS.rawValue, label: "\(descDepartment)", value: nil).build())
            }
            familyController.departmentId = item["idDepto"] as NSString
            familyController.families = itemsFam
            familyController.selectedFamily = nil
            familyController.familyTable.reloadData()
            self.indexPathSelected = indexPath
            self.scrollOffset  = self.categoriesTable.contentOffset
            self.categoriesTable.scrollEnabled = false
            self.categoriesTable.contentInset = UIEdgeInsetsMake(0, 0, self.categoriesTable.frame.height, 0)
            let rectRow = self.categoriesTable.rectForRowAtIndexPath(indexPath)
            
            var rowsUpdate : [NSIndexPath] = []
            for ixNewRow in indexPath.row...items.count - 1 {
                let upRow = NSIndexPath(forRow: ixNewRow, inSection: indexPath.section)
                rowsUpdate.append(upRow)
            }
            
            self.categoriesTable.reloadRowsAtIndexPaths(rowsUpdate, withRowAnimation: UITableViewRowAnimation.Fade)
            
            let selectedCell = self.categoriesTable.cellForRowAtIndexPath(indexPath)
            if let selCell = selectedCell as? IPOCategoryView {
                selCell.viewOverCellWhite.hidden = true
            }
            
            if rectRow.minY == self.scrollOffset.y {
                startAnimating()
            }else{
                self.categoriesTable.scrollToRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            }
            
        } else {
            let cell = self.categoriesTable.cellForRowAtIndexPath(self.indexPathSelected) as IPOCategoryView
            cell.closeCategory()
        }
        
    }
    

    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView!) {
       startAnimating()
    }
    
    func startAnimating() {
        if self.indexPathSelected != nil {
            if let cellSelected = self.categoriesTable.cellForRowAtIndexPath(self.indexPathSelected) as? IPOCategoryView {
                cellSelected.selected = true
                cellSelected.animateAfterSelect()
                self.viewFamily.alpha = 0
                familyController.familyTable.reloadData()
                self.view.addSubview(viewFamily)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.viewFamily.alpha = 1
                })
            }
        }
    }
    
    func closeButtonPressedEndAnimation() {
        if self.indexPathSelected != nil {
            let currentRow = self.indexPathSelected.row
            self.indexPathSelected = nil
            
            self.categoriesTable.scrollEnabled = true
            //self.categoriesTable.setContentOffset(self.scrollOffset, animated: true)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.categoriesTable.contentInset = UIEdgeInsetsZero
            })
            
            var rowsUpdate : [NSIndexPath] = []
            for ixNewRow in currentRow...items.count - 1 {
                if ixNewRow != currentRow {
                    let upRow = NSIndexPath(forRow: ixNewRow, inSection: 0)
                    rowsUpdate.append(upRow)
                }
            }
            
            self.categoriesTable.reloadRowsAtIndexPaths(rowsUpdate, withRowAnimation: UITableViewRowAnimation.Fade)
            self.viewFamily.removeFromSuperview()
        }
        
    }
    
    func closeButtonPressed() {
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFamily.alpha = 0
            }) { (completition:Bool) -> Void in
                
                
             
        }
    }
   
    
    
    
    
}