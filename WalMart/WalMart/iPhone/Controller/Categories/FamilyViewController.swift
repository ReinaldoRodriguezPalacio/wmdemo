//
//  FamilyViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/29/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

enum CategoriesType {
    case categoryForMG
    case categoryForGR
}

class FamilyViewController : IPOBaseController,UITableViewDataSource,UITableViewDelegate {
    
    var selectedFamily : IndexPath! = nil
    
    var familyTable: UITableView!
    var departmentId : String = ""
    var families : [[String:Any]] = []
    
    var categoriesType: CategoriesType?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRESHOPPINGCART.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        familyTable = UITableView()
        familyTable.register(IPOFamilyTableViewCell.self, forCellReuseIdentifier: "familyCell")
        familyTable.register(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        
        familyTable.separatorStyle = UITableViewCellSeparatorStyle.none
        
        familyTable.delegate = self
        familyTable.dataSource = self
        
        self.view.addSubview(familyTable)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        familyTable.frame = self.view.bounds
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return families.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedFamily != nil {
            if selectedFamily.section == section {
                return numberOfRowsInSection(section) + 1
            }
        }
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
        if (indexPath as NSIndexPath).row == 0 {
            let cellFamily = familyTable.dequeueReusableCell(withIdentifier: familyReuseIdentifier(), for: indexPath) as! IPOFamilyTableViewCell
            let selectedSection = families[(indexPath as NSIndexPath).section]
            var nameFamily = ""
            if let valueFamily = selectedSection["familyName"] as? String{
                nameFamily = valueFamily
            }
            if let valueSubCat = selectedSection["subCategoryName"] as? String{
                nameFamily = valueSubCat
            }
            cellFamily.setTitle(nameFamily)
            cell = cellFamily
        } else {
            let cellLine = familyTable.dequeueReusableCell(withIdentifier: lineReuseIdentifier(), for: indexPath) as! IPOLineTableViewCell
            let selectedSection = families[(indexPath as NSIndexPath).section]
            let linesArr = selectedSection["fineContent"] as! NSArray
            let itemLine = linesArr[(indexPath as NSIndexPath).row - 1] as! NSDictionary
            let selectedItem = itemLine["id"] as! String
            cellLine.setTitle(itemLine["displayName"] as! String)
            cellLine.showSeparator =  linesArr.count == (indexPath as NSIndexPath).row 
            cell = cellLine
            
            if selectedItem == self.departmentId
            {
                cell.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 249.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.backgroundColor = UIColor.white
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0  {
            let changeSelection = (selectedFamily == nil || (selectedFamily != nil && selectedFamily.section != (indexPath as NSIndexPath).section) )
            if selectedFamily != nil {
                deSelectSection(selectedFamily)
            }
            if changeSelection {
                selectSection(indexPath)
                self.familyTable.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            var label = ""
            if let valuefamilyNam = families[(indexPath as NSIndexPath).section]["familyName"] as? String {
                label = valuefamilyNam
            }
            
            if let valueSubCat = families[(indexPath as NSIndexPath).section]["subCategoryName"] as? String {
                label = valueSubCat
            }
            let labelCategory = label.uppercased().replacingOccurrences(of: " ", with: "_")
            BaseController.sendAnalytics("\(labelCategory)_AUTH", categoryNoAuth:"MG\(labelCategory)_NO_AUTH", action: WMGAIUtils.ACTION_OPEN_ACCESSORY_LINES.rawValue, label:label)
        }
        else {
            let selectedSection = families[(indexPath as NSIndexPath).section]
            let linesArr = selectedSection["fineContent"] as! NSArray
            let itemLine = linesArr[(indexPath as NSIndexPath).row - 1] as! NSDictionary

            let controller = SearchProductViewController()
            controller.searchContextType = .WithCategoryForMG
            if self.categoriesType != nil {
                switch self.categoriesType! {
                case .categoryForGR : controller.searchContextType = .WithCategoryForGR
                case .categoryForMG : controller.searchContextType = .WithCategoryForMG
                //default : print("No se ha indicado tipo de categorias.")
                }
             
            }
            controller.titleHeader = itemLine["displayName"] as? String
            controller.idDepartment = departmentId
            controller.idFamily = selectedSection["id"] as? String
            controller.idLine = itemLine["id"] as? String

            self.navigationController!.pushViewController(controller, animated: true)
            let label = itemLine["displayName"] as! String
            let labelCategory = label.uppercased().replacingOccurrences(of: " ", with: "_")
            BaseController.sendAnalytics("\(labelCategory)_AUTH", categoryNoAuth:"MG\(labelCategory)_NO_AUTH", action: WMGAIUtils.ACTION_SELECTED_LINE.rawValue, label:label)
        }
    }
    
    func numberOfRowsInSection(_ section:Int) -> Int {
        if section < families.count {
            let selectedSection = families[section]
            let nameLine = selectedSection["fineContent"] as! NSArray
            return nameLine.count
        }
        return 1
    }
    
    func selectSection(_ indexPath: IndexPath!) {
        selectedFamily = indexPath
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [IndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(IndexPath(row: index, section: indexPath.section))
            }
            self.familyTable.insertRows(at: arratIndexes, with: .automatic)
        }
    }
    
    func deSelectSection(_ indexPath: IndexPath!) {
        selectedFamily = nil
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [IndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(IndexPath(row: index, section: indexPath.section))
            }
            self.familyTable.deleteRows(at: arratIndexes, with: .automatic)
        }
    }
    
    func familyReuseIdentifier()  -> String {
        return "familyCell"
    }
    
    func lineReuseIdentifier()  -> String {
         return "lineCell"
    }
    
}
