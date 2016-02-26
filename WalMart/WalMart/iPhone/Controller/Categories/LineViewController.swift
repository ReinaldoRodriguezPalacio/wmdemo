//
//  LineViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 2/25/16.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class LineViewController : FamilyViewController {
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
      
        familyTable = UITableView()
        familyTable.registerClass(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        familyTable.separatorStyle = UITableViewCellSeparatorStyle.None
        familyTable.delegate = self
        familyTable.dataSource = self
        familyTable.frame = self.view.bounds
        
        self.view.addSubview(familyTable)
    }
    
    override func viewDidLayoutSubviews() {

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return families.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
     
    
            let cellLine = familyTable.dequeueReusableCellWithIdentifier(lineReuseIdentifier(), forIndexPath: indexPath) as! IPOLineTableViewCell
            let selectedSection = families[indexPath.row]
            let selectedItem = selectedSection["line"] as! String
            cellLine.setTitle(selectedSection["nameLine"] as! String)
            cellLine.showSeparator =  true
            cell = cellLine
            
            if selectedItem == self.departmentId
            {
                cell.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 249.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.backgroundColor = UIColor.whiteColor()
            }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

            let selectedSection = families[indexPath.row]
            let controller = SearchProductViewController()
            controller.searchContextType = .WithCategoryForMG
            if self.categoriesType != nil {
                switch self.categoriesType! {
                case .CategoryForGR : controller.searchContextType = .WithCategoryForGR
                case .CategoryForMG : controller.searchContextType = .WithCategoryForMG
                //default : print("No se ha indicado tipo de categorias.")
                }
             
            }
            controller.titleHeader = selectedSection["nameLine"] as? String
            controller.idDepartment = "_"
            controller.idFamily = "_"
            controller.idLine = selectedSection["line"] as? String

            self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
}