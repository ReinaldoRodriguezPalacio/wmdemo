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
