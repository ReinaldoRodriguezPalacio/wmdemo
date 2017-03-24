//
//  BaseCategoryViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/3/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol BaseCategoryViewControllerDataSource: class {
    func loadDepartments() ->  [Any]?
}

protocol BaseCategoryViewControllerDelegate: class {
    func getServiceURLIcon() -> String
    func getServiceURLHeader() -> String
    
    func didSelectDeparmentAtIndex(_ indexPath: IndexPath)
}

class BaseCategoryViewController : IPOBaseController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var categories: UICollectionView?
    weak var delegate : BaseCategoryViewControllerDelegate?
    var datasource : BaseCategoryViewControllerDataSource?
    var currentIndexSelected : IndexPath?
    var items : [Any]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = self.datasource?.loadDepartments()

        categories!.delegate = self
        categories!.dataSource = self
        BaseController.setOpenScreenTagManager(titleScreen: "Categories", screenName: self.getScreenGAIName())
    
    }
   
     //MARK: CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = categories!.dequeueReusableCell(withReuseIdentifier: "DepartmentCell", for: indexPath) as! DepartmentCollectionViewCell
        
        let item = items![indexPath.row] as! [String:Any]
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.delegate?.didSelectDeparmentAtIndex(indexPath)
            return
        }
        
        self.currentIndexSelected = indexPath
        self.categories!.isScrollEnabled = false
        self.categories!.isUserInteractionEnabled = false
        self.categories!.contentInset = UIEdgeInsetsMake(0, 0, self.categories!.frame.height, 0)
        self.categories!.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.categories!.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: false)
        }, completion: { (Bool) -> Void in
            print("")
           self.delegate?.didSelectDeparmentAtIndex(indexPath)
        }) 
    }
    
    
    
    func closeSelectedDepartment() {
    }
    
    /**
     Animation at close category 
     */
    func closeDepartment() {
        self.currentIndexSelected = nil
        self.categories!.reloadData()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.categories!.contentInset = UIEdgeInsets.zero
            }, completion: { (end:Bool) -> Void in
                self.categories!.isScrollEnabled = true
                self.categories!.isUserInteractionEnabled = true
        }) 
    }
    
    
}
