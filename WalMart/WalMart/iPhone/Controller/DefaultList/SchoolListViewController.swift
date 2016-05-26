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
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SCHOOLLIST.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = self.schoolName
        self.tableView!.registerClass(SchoolListTableViewCell.self, forCellReuseIdentifier: "schoolCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CustomBarNotification.TapBarFinish.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(DefaultListDetailViewController.tabBarActions),name:CustomBarNotification.TapBarFinish.rawValue, object: nil)
        self.tabBarActions()
    }
    
    override func setup() {
        super.setup()
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
            schoolCell.schoolNameLabel!.text = self.schoolName
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
}