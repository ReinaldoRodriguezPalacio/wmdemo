//
//  SchoolListViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class SchoolListViewController : DefaultListDetailViewController {
    
    var schoolName: String! = ""
    var gradeName: String?
    var familyId: String?
    var lineId: String?
    var departmentId: String?
    var selectAllButton: UIButton?
    var listPrice: String?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SCHOOLLIST.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = self.schoolName
        self.tableView!.registerClass(SchoolListTableViewCell.self, forCellReuseIdentifier: "schoolCell")
        
        let y = (self.footerSection!.frame.height - 34.0)/2
        self.selectAllButton = UIButton(frame: CGRectMake(16.0, y, 34.0, 34.0))
        self.selectAllButton!.setImage(UIImage(named: "check_off"), forState: .Normal)
        self.selectAllButton!.setImage(UIImage(named: "check_full"), forState: .Selected)
        self.selectAllButton!.setImage(UIImage(named: "check_off"), forState: .Disabled)
        self.selectAllButton!.addTarget(self, action: "selectAll", forControlEvents: .TouchUpInside)
        self.footerSection!.addSubview(self.selectAllButton!)
        self.duplicateButton?.removeFromSuperview()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomBarNotification.TapBarFinish.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(DefaultListDetailViewController.tabBarActions),name:CustomBarNotification.TapBarFinish.rawValue, object: nil)
        self.tabBarActions()
    }
    
    override func setup() {
        super.setup()
        self.getDetailItems()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    //MARK: TableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0  ? 98 :56
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailItems == nil { return 1 }
        return self.detailItems!.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
           let schoolCell = tableView.dequeueReusableCellWithIdentifier("schoolCell", forIndexPath: indexPath) as! SchoolListTableViewCell
            let range = (self.gradeName! as NSString).rangeOfString(self.schoolName)
            var grade = self.gradeName!
            if range.location != NSNotFound {
                grade = grade.substringFromIndex(grade.startIndex.advancedBy(range.length))
            }
            self.listPrice = self.listPrice ?? "0.0"
            schoolCell.setValues(self.schoolName, grade: grade, listPrice: self.listPrice!, numArticles: 19, savingPrice: "Ahorras 245.89")
            return schoolCell
        }
        
        let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID, forIndexPath: indexPath) as! DetailListViewCell
        listCell.setValuesDictionary(self.detailItems![indexPath.row - 1],disabled:!self.selectedItems!.containsObject(indexPath.row))
        listCell.detailDelegate = self
        listCell.hideUtilityButtonsAnimated(false)
        listCell.setLeftUtilityButtons([], withButtonWidth: 0.0)
        listCell.setRightUtilityButtons([], withButtonWidth: 0.0)
        return listCell
    }
    
    func getDetailItems(){
        //self.detailItems
        //TODO: Signals
        let signalsDictionary : NSDictionary = NSDictionary(dictionary: ["signals" :GRBaseService.getUseSignalServices()])
        let service = ProductbySearchService(dictionary:signalsDictionary)
        let params = service.buildParamsForSearch(text: "", family:self.familyId, line: self.lineId, sort:"rankingASC", departament: self.departmentId, start: 0, maxResult: 20)
        service.callService(params,
                            successBlock:{ (arrayProduct:NSArray?,facet:NSArray) in
                                
                                            },
                            errorBlock: {(error: NSError) in
               
            })
    }
    
    func selectAll() {
        
    }
}