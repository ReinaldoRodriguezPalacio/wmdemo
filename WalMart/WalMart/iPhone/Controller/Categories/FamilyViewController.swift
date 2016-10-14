//
//  FamilyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

enum CategoriesType {
    case CategoryForMG
    case CategoryForGR
}

class FamilyViewController : IPOBaseController,UITableViewDataSource,UITableViewDelegate {
    
    var selectedFamily : NSIndexPath! = nil
    
    var familyTable: UITableView!
    var departmentId : String = ""
    var families : [[String:AnyObject]] = []
    
    var categoriesType: CategoriesType?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        familyTable = UITableView()
        familyTable.registerClass(IPOFamilyTableViewCell.self, forCellReuseIdentifier: "familyCell")
        familyTable.registerClass(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        
        familyTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        familyTable.delegate = self
        familyTable.dataSource = self
        
        self.view.addSubview(familyTable)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        familyTable.frame = self.view.bounds
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return families.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedFamily != nil {
            if selectedFamily.section == section {
                return numberOfRowsInSection(section) + 1
            }
        }
        return 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
        if indexPath.row == 0 {
            let cellFamily = familyTable.dequeueReusableCellWithIdentifier(familyReuseIdentifier(), forIndexPath: indexPath) as! IPOFamilyTableViewCell
            let selectedSection = families[indexPath.section]
            let nameFamily = selectedSection["name"] as! String
            cellFamily.setTitle(nameFamily)
            cell = cellFamily
        } else {
            let cellLine = familyTable.dequeueReusableCellWithIdentifier(lineReuseIdentifier(), forIndexPath: indexPath) as! IPOLineTableViewCell
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["line"] as! NSArray
            let itemLine = linesArr[indexPath.row - 1] as! NSDictionary
            let selectedItem = itemLine["id"] as! String
            cellLine.setTitle(itemLine["name"] as! String)
            cellLine.showSeparator =  linesArr.count == indexPath.row 
            cell = cellLine
            
            if selectedItem == self.departmentId
            {
                cell.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 249.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.backgroundColor = UIColor.whiteColor()
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0  {
            let changeSelection = (selectedFamily == nil || (selectedFamily != nil && selectedFamily.section != indexPath.section) )
            if selectedFamily != nil {
                deSelectSection(selectedFamily)
            }
            if changeSelection {
                selectSection(indexPath)
                self.familyTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
            let label = families[indexPath.section]["name"] as! String
            let labelCategory = label.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
            //BaseController.sendAnalytics("\(labelCategory)_AUTH", categoryNoAuth:"MG\(labelCategory)_NO_AUTH", action: WMGAIUtils.ACTION_OPEN_ACCESSORY_LINES.rawValue, label:label)
        }
        else {
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["line"] as! NSArray
            let itemLine = linesArr[indexPath.row - 1] as! NSDictionary

            let controller = SearchProductViewController()
            controller.searchContextType = .WithCategoryForMG
            if self.categoriesType != nil {
                switch self.categoriesType! {
                case .CategoryForGR : controller.searchContextType = .WithCategoryForGR
                case .CategoryForMG : controller.searchContextType = .WithCategoryForMG
                //default : print("No se ha indicado tipo de categorias.")
                }
             
            }
            controller.titleHeader = itemLine["name"] as? String
            controller.idDepartment = departmentId
            controller.idFamily = selectedSection["id"] as? String
            controller.idLine = itemLine["id"] as? String

            self.navigationController!.pushViewController(controller, animated: true)
            let label = itemLine["name"] as! String
            let labelCategory = label.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
            //BaseController.sendAnalytics("\(labelCategory)_AUTH", categoryNoAuth:"MG\(labelCategory)_NO_AUTH", action: WMGAIUtils.ACTION_SELECTED_LINE.rawValue, label:label)
        }
    }
    
    func numberOfRowsInSection(section:Int) -> Int {
        if section < families.count {
            let selectedSection = families[section]
            let nameLine = selectedSection["line"] as! NSArray
            return nameLine.count
        }
        return 1
    }
    
    func selectSection(indexPath: NSIndexPath!) {
        selectedFamily = indexPath
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [NSIndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(NSIndexPath(forRow: index, inSection: indexPath.section))
            }
            self.familyTable.insertRowsAtIndexPaths(arratIndexes, withRowAnimation: .Automatic)
        }
    }
    
    func deSelectSection(indexPath: NSIndexPath!) {
        selectedFamily = nil
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [NSIndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(NSIndexPath(forRow: index, inSection: indexPath.section))
            }
            self.familyTable.deleteRowsAtIndexPaths(arratIndexes, withRowAnimation: .Automatic)
        }
    }
    
    func familyReuseIdentifier()  -> String {
        return "familyCell"
    }
    
    func lineReuseIdentifier()  -> String {
         return "lineCell"
    }
    
}