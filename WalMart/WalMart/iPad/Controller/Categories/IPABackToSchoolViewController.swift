//
//  IPABackToSchoolViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol IPABackToSchoolViewControllerDelegate {
    func schoolSelected(familyId:String,schoolName:String)
}

class IPABackToSchoolViewController: BackToSchoolCategoryViewController {
    
    var header: UIView? = nil
    var backButton : UIButton? = nil
    var titleLabel: UILabel? = nil
    var btsDelegate: IPABackToSchoolViewControllerDelegate?
    var showGrades: Bool = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.showGrades {
            self.schoolsTable!.selectRowAtIndexPath(NSIndexPath(forRow: 0,inSection:0), animated: false, scrollPosition: .Top)
            self.tableView(self.schoolsTable!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0,inSection:0))
            self.showGrades = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.header = UIView()
        self.titleLabel = UILabel()
        self.titleLabel?.textColor =  WMColor.light_blue
        self.titleLabel?.text = "Escuelas"
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.numberOfLines = 2
        self.header?.backgroundColor = WMColor.light_light_gray
        self.header?.addSubview(self.titleLabel!)
        self.view.addSubview(self.header!)
        self.backButton = UIButton()
        self.backButton!.setImage(UIImage(named:"detail_close"), forState: UIControlState.Normal)
        self.backButton!.addTarget(self, action: #selector(BaseCategoryViewController.closeDepartment), forControlEvents: UIControlEvents.TouchUpInside)
        self.header?.addSubview(self.backButton!)
        self.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
        self.titleLabel!.frame = CGRectMake(46, 0, self.header!.frame.width - 92, self.header!.frame.maxY)
        self.backButton!.frame = CGRectMake(0, 0  ,46,46)
        self.searchView.frame = CGRectMake(0, self.header!.frame.maxY, self.view.frame.width, 72)
        self.schoolsTable.frame = CGRectMake(0, self.searchView!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.searchView!.frame.maxY)
    }
    
    override func willHideTabbar() {}
    
    override func willShowTabbar() {}
    
    override func hideImageHeader() {}
    
    override func showImageHeader() {}
    
    override  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let school = self.filterList![indexPath.row]
            self.btsDelegate?.schoolSelected(school["id"] as! String,schoolName:school["name"] as! String)
    }
    
    override func invokeServiceFamilyByCategory(){
        let service =  FamilyByCategoryService()
        service.callService(requestParams: ["id":self.departmentId], successBlock: { (response:NSDictionary) -> Void in
            let schools  =  response["responseArray"] as! NSArray
            self.schoolsList = schools as? [[String : AnyObject]]
            self.filterList = self.schoolsList
            self.schoolsTable.reloadData()
            self.loading?.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
}
