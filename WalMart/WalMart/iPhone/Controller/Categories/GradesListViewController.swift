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
    var familyName: String! = ""
    var gradesList :[[String:AnyObject]]! = [[:]]
    var gradesTable : UITableView!
    var loading: WMLoadingView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRADESLIST.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel!.text = schoolName
        
        self.gradesTable = UITableView()
        self.gradesTable.delegate = self
        self.gradesTable.dataSource = self
        self.gradesTable.registerClass(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        self.gradesTable.separatorStyle = .None
        self.view.addSubview(self.gradesTable)
        self.invokeServiceLines()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.gradesTable.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gradesList!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let grades = self.gradesList![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("lineCell", forIndexPath: indexPath) as! IPOLineTableViewCell
        cell.titleLabel?.text = grades["name"] as? String
        cell.showSeparator =  true
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let grade = self.gradesList![indexPath.row]
        let listController = SchoolListViewController()
        //listController.familyName = grade["id"] as! String
        listController.schoolName = self.schoolName
        self.navigationController?.pushViewController(listController, animated: true)
    }
    
    func invokeServiceLines(){
        let service =  LineService()
        service.callService(requestParams: familyName, successBlock: { (response:NSDictionary) -> Void in
            let grades  =  response["responseArray"] as! NSArray
            self.gradesList = grades as? [[String : AnyObject]]
            self.gradesTable.reloadData()
            self.loading!.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }

}
