//
//  GradesListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class GradesListViewController: NavigationViewController,UITableViewDelegate,UITableViewDataSource {
    
    var schoolName: String! = ""
    var familyId: String! = ""
    var departmentId: String?
    var gradesList :[[String:Any]]! = [[:]]
    var gradesTable : UITableView!
    var loading: WMLoadingView?
    var emptyView: IPOGenericEmptyView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRADESLIST.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel!.text = schoolName
        
        self.gradesTable = UITableView()
        self.gradesTable.delegate = self
        self.gradesTable.dataSource = self
        self.gradesTable.register(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        self.gradesTable.separatorStyle = .none
        self.view.addSubview(self.gradesTable)
        self.invokeServiceLines()
        
        if IS_IPAD {
            self.backButton?.isHidden = true 
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.gradesTable.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.loading == nil {
            if IS_IPHONE {
              self.loading = WMLoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            }else{
              self.loading = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: 682.0, height: 658.0))
            }
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gradesList!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let grades = self.gradesList![(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath) as! IPOLineTableViewCell
        cell.titleLabel?.text = grades["subCategoryName"] as? String
        cell.showSeparator =  true
        cell.oneLine = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grade = self.gradesList![(indexPath as NSIndexPath).row]
        let listController = IS_IPAD ? IPASchoolListViewController() : SchoolListViewController()
        listController.lineId = grade["subCategoryId"] as? String
        listController.schoolName = self.schoolName
        listController.familyId = self.familyId
        listController.departmentId = self.departmentId
        listController.gradeName = grade["subCategoryName"] as? String
        listController.listPrice = ""//grade["price"] as? String //TODO
        self.navigationController?.pushViewController(listController, animated: true)
    }
    
    /**
     Call lines service , to paint the grades in BST section
     */
    func invokeServiceLines(){
        let service =  LineService()
        service.callService(requestParams: self.familyId as AnyObject, successBlock: { (response:[String:Any]) -> Void in
            let grades  =  response["subCategories"] as! [[String:Any]]
            self.gradesList = grades as? [[String : Any]]
            if  self.gradesList.count == 0 {
                self.loading?.stopAnnimating()
                self.showEmptyView()
            }else{
                self.gradesTable.reloadData()
                self.loading?.stopAnnimating()
            }
            
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.loading?.stopAnnimating()
                self.showEmptyView()
        })
    }
    
    //MARK: Utils
    /**
     Present Empty View in case necesary
     */
    func showEmptyView(){

        if  self.emptyView == nil {
            self.emptyView = IPOGenericEmptyView(frame:CGRect(x: 0,  y: self.header!.frame.maxY , width: self.view.bounds.width, height: self.view.bounds.height - 46))
            
        }else{
            self.emptyView.removeFromSuperview()
            self.emptyView =  nil
            self.emptyView = IPOGenericEmptyView(frame:CGRect(x: 0,y: self.header!.frame.maxY , width: self.view.bounds.width, height: self.view.bounds.height - 46))
        }
        
        if IS_IPAD {
            self.emptyView.iconImageView.image = UIImage(named:"oh-oh_bts")
            self.emptyView.returnButton.isHidden =  true
        }
        
        self.emptyView.descLabel.text = NSLocalizedString("empty.bts.title.school",comment:"")
        
        self.emptyView.returnAction = { () in
            //self.emptyView.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
        }
        
        self.view.addSubview(self.emptyView)
    }

}
