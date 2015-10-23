//
//  BaseCategoryViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/3/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol BaseCategoryViewControllerDataSource {
    func loadDepartments() ->  [AnyObject]?
}

protocol BaseCategoryViewControllerDelegate {
    func getServiceURLIcon() -> String
    func getServiceURLHeader() -> String
    
    func didSelectDeparmentAtIndex(indexPath: NSIndexPath)
}

class BaseCategoryViewController : IPOBaseController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var categories: UICollectionView!
    var delegate : BaseCategoryViewControllerDelegate?
    var datasource : BaseCategoryViewControllerDataSource?
    var currentIndexSelected : NSIndexPath?
    var items : [AnyObject]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = self.datasource?.loadDepartments()

        categories.delegate = self
        categories.dataSource = self
        
    }
   
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items!.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let categoryCell = categories.dequeueReusableCellWithReuseIdentifier("DepartmentCell", forIndexPath: indexPath) as! DepartmentCollectionViewCell
        
        let item = items![indexPath.row] as! [String:AnyObject]
        let descDepartment = item["description"] as! String
        let bgDepartment = item["idDepto"] as! String
        //let departmentId = item["idDepto"] as! String
        
        let svcUrl = delegate?.getServiceURLIcon()
        let svcUrlCar = delegate?.getServiceURLHeader()
        
        var hideView = false
        if self.currentIndexSelected != nil {
            hideView = self.currentIndexSelected?.row != indexPath.row
        }
        
        categoryCell.setValues(descDepartment,imageBackgroundURL: bgDepartment + ".png",keyBgUrl:svcUrlCar!,imageIconURL:"i_" + bgDepartment + ".png",keyIconUrl:svcUrl!,hideImage:hideView)
        
        
        
        return categoryCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            self.delegate?.didSelectDeparmentAtIndex(indexPath)
            return
        }
        
        self.currentIndexSelected = indexPath
        self.categories.scrollEnabled = false
        self.categories.userInteractionEnabled = false
        self.categories.contentInset = UIEdgeInsetsMake(0, 0, self.categories.frame.height, 0)
        self.categories.reloadData()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.categories.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        }) { (Bool) -> Void in
            print("")
           self.delegate?.didSelectDeparmentAtIndex(indexPath)
        }
    }
    
    
    
    func closeSelectedDepartment() {
    }
    
    
    func closeDepartment() {
        self.currentIndexSelected = nil
        self.categories.reloadData()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.categories.contentInset = UIEdgeInsetsZero
            }) { (end:Bool) -> Void in
                self.categories.scrollEnabled = true
                self.categories.userInteractionEnabled = true
        }
    }
    
    
}