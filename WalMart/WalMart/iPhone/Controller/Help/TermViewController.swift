//
//  TermViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 04/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


protocol TermViewControllerDelegate {
    func selectedDetail(row:Int, item: NSDictionary)
}

class TermViewController: NavigationViewController,UITableViewDataSource,UITableViewDelegate {// NavigationViewController,  UITableViewDelegate, UITableViewDataSource {
    

    var selectedFamily : NSIndexPath! = nil
    var delegate:TermViewControllerDelegate!
    var familyTable: UITableView!
    var families : [[String:AnyObject]] = []
    
//    override func getScreenGAIName() -> String {
//        return WMGAIUtils.SCREEN_TERMSANDCONDITIONS.rawValue
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        familyTable = UITableView()
        familyTable.registerClass(IPOFamilyTableViewCell.self, forCellReuseIdentifier: "familyCell")
        familyTable.registerClass(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        
        familyTable.backgroundColor = UIColor.whiteColor()
        
        familyTable.separatorStyle = .None
        familyTable.autoresizingMask = UIViewAutoresizing.None
        self.titleLabel!.text = NSLocalizedString("help.item.terms.condition", comment: "")

        let filePath =  NSBundle.mainBundle().pathForResource("termAndConditions", ofType: "json")
        let jsonData: NSData?
        do {
            jsonData = try NSData(contentsOfFile:filePath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError {
            print(error.localizedDescription)
            jsonData = nil
        }
        let resultArray = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments)) as! [[String:AnyObject]]
        
        families = resultArray

        //familyTable.delegate = self
        //familyTable.dataSource = self
        
        self.view.addSubview(familyTable)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        familyTable.frame =  CGRectMake(0,  self.header!.frame.maxY , bounds.width, bounds.height - self.header!.frame.maxY )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         let bounds = self.view.bounds
        familyTable.frame =  CGRectMake(0,  self.header!.frame.maxY , bounds.width, bounds.height - self.header!.frame.maxY )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if delegate == nil || familyTable.delegate == nil {
            familyTable.delegate = self
            familyTable.dataSource = self
            familyTable.reloadData()
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return families.count + 1
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
        
        if indexPath.section == 3 {
            let cellFamily = familyTable.dequeueReusableCellWithIdentifier(familyReuseIdentifier(), forIndexPath: indexPath) as! IPOFamilyTableViewCell
            let majorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            let minorVersion =  NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
           
            let nameFamily = "Versión \(majorVersion) (\(minorVersion))"
            cellFamily.setTitle(nameFamily)
            cell = cellFamily
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell!
        }
        
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
            cellLine.setTitle(itemLine["title"] as! String)
            cellLine.showSeparator =  linesArr.count == indexPath.row
            cell = cellLine
        }
         //cell.selectionStyle = UITableViewCellSelectionStyle.None
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
            
        }
        else {//news
            
            //selected = indexPath.row
            self.familyTable.reloadData()
            
            let selectedSection = families[indexPath.section]
            let linesArr = selectedSection["line"] as! NSArray
            let item = linesArr[indexPath.row - 1] as! NSDictionary
            
            
            if delegate != nil {
                delegate!.selectedDetail(indexPath.row, item: item)
            }
            else {
                let controller = PreviewHelpViewController()
                let name = item["title"] as! String
                controller.titleText = NSLocalizedString(name, comment: "")
                controller.resource = item["resource"] as! String
                controller.type = item["type"] as! String
                
                if  let imgFile = item["imgFile"] as? String{
                    controller.imgFile = imgFile
                }
                self.navigationController!.pushViewController(controller, animated: true)
            }
            
            var action : String = item["title"] as! String
            action =  action.stringByReplacingOccurrencesOfString(" ", withString:"")
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TERMS_CONDITION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_TERMS_CONDITION_NO_AUTH.rawValue , action:"A_\(action)" , label:"")
            
        }
        
        
    }
    
    func numberOfRowsInSection(section:Int) -> Int {
        if section < families.count {
            let selectedSection = families[section]
            let nameLine = selectedSection["line"] as! NSArray
            return nameLine.count
        }
        
        if section == 3{
            return 0
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
    
    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TERMS_CONDITION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_TERMS_CONDITION_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label:"")
        super.back()
    }
    
    
}


