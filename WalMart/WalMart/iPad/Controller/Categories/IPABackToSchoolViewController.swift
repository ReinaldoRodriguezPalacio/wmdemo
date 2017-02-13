//
//  IPABackToSchoolViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol IPABackToSchoolViewControllerDelegate {
    func schoolSelected(_ familyId:String,schoolName:String)
}

class IPABackToSchoolViewController: BackToSchoolCategoryViewController {
    
    var header: UIView? = nil
    var backButton : UIButton? = nil
    var titleLabel: UILabel? = nil
    var btsDelegate: IPABackToSchoolViewControllerDelegate?
    var showGrades: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.showGrades {
            self.schoolsTable!.selectRow(at: IndexPath(row: 0,section:0), animated: false, scrollPosition: .top)
            self.tableView(self.schoolsTable!, didSelectRowAt: IndexPath(row: 0,section:0))
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
        self.backButton!.setImage(UIImage(named:"detail_close"), for: UIControlState())
        self.backButton!.addTarget(self, action: #selector(BaseCategoryViewController.closeDepartment), for: UIControlEvents.touchUpInside)
        self.header?.addSubview(self.backButton!)
        self.titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 46)
        self.titleLabel!.frame = CGRect(x: 46, y: 0, width: self.header!.frame.width - 92, height: self.header!.frame.maxY)
        self.backButton!.frame = CGRect(x: 8, y: 8,width: 30,height: 30)
        self.searchView.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.frame.width, height: 84)
        self.separator.frame = CGRect(x: 0, y: self.searchView!.bounds.maxY - 1, width: self.view.frame.width, height: 1)
        self.clearButton!.frame = CGRect(x: self.searchView.frame.width - self.searchFieldSpace, y: 22, width: 55, height: 40)
        self.searchField.frame = CGRect(x: 16, y: 22, width: self.view.frame.width - (self.searchFieldSpace + 32), height: 40.0)
        self.schoolsTable.frame = CGRect(x: 0, y: self.searchView!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.searchView!.frame.maxY)
    }
    
    /**
     Shows or hides image header only in iPhone
     
     - parameter didShow: Bool
     */
    override func showImageHeader(_ didShow:Bool) {}
    
    
    //MARK: TableViewDelegate
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let school = self.filterList![(indexPath as NSIndexPath).row]
        if school.count == 0 {
            return
        }
        self.searchField.resignFirstResponder()
        self.btsDelegate?.schoolSelected(school["id"] as! String,schoolName:school["name"] as! String)
    }
    
    /**
     Invoke Family service
     */
    override func invokeServiceFamilyByCategory(){
        let service =  FamilyByCategoryService()
        service.callService(requestParams: ["id":self.departmentId as AnyObject], successBlock: { (response:[String:Any]) -> Void in
            let schools  =  response["responseArray"] as! [[String : Any]]
            self.schoolsList = schools as? [[String : Any]]
            self.filterList = self.schoolsList
            self.schoolsTable.reloadData()
            self.loading?.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.navigationController?.popToRootViewController(animated: true)
        })
    }
}
