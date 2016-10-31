//
//  TermViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 04/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


protocol TermViewControllerDelegate {
    func selectedDetail(_ row:Int, item: NSDictionary)
}

class TermViewController: NavigationViewController,UITableViewDataSource,UITableViewDelegate {// NavigationViewController,  UITableViewDelegate, UITableViewDataSource {
    

    var selectedFamily : IndexPath! = nil
    var delegate:TermViewControllerDelegate!
    var familyTable: UITableView!
    var families : [[String:AnyObject]] = []
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_TERMSANDCONDITIONS.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        familyTable = UITableView()
        familyTable.register(IPOFamilyTableViewCell.self, forCellReuseIdentifier: "familyCell")
        familyTable.register(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        
        familyTable.backgroundColor = UIColor.white
        
        familyTable.separatorStyle = .none
        familyTable.autoresizingMask = UIViewAutoresizing()
        self.titleLabel!.text = NSLocalizedString("help.item.terms.condition", comment: "")

        let filePath =  Bundle.main.path(forResource: "termAndConditions", ofType: "json")
        let jsonData: Data?
        do {
            jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: NSData.ReadingOptions.mappedIfSafe)
        } catch let error as NSError {
            print(error.localizedDescription)
            jsonData = nil
        }
        let resultArray = (try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)) as! [[String:AnyObject]]
        
        families = resultArray

        //familyTable.delegate = self
        //familyTable.dataSource = self
        
        self.view.addSubview(familyTable)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        familyTable.frame =  CGRect(x: 0,  y: self.header!.frame.maxY , width: bounds.width, height: bounds.height - self.header!.frame.maxY )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         let bounds = self.view.bounds
        familyTable.frame =  CGRect(x: 0,  y: self.header!.frame.maxY , width: bounds.width, height: bounds.height - self.header!.frame.maxY )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if delegate == nil || familyTable.delegate == nil {
            familyTable.delegate = self
            familyTable.dataSource = self
            familyTable.reloadData()
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return families.count + 1
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
        
        if (indexPath as NSIndexPath).section == 3 {
            let cellFamily = familyTable.dequeueReusableCell(withIdentifier: familyReuseIdentifier(), for: indexPath) as! IPOFamilyTableViewCell
            let majorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let minorVersion =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
           
            let nameFamily = "Versión \(majorVersion) (\(minorVersion))"
            cellFamily.setTitle(nameFamily)
            cell = cellFamily
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell!
        }
        
        if (indexPath as NSIndexPath).row == 0 {
            let cellFamily = familyTable.dequeueReusableCell(withIdentifier: familyReuseIdentifier(), for: indexPath) as! IPOFamilyTableViewCell
            let selectedSection = families[(indexPath as NSIndexPath).section]
            let nameFamily = selectedSection["name"] as! String
            cellFamily.setTitle(nameFamily)
            cell = cellFamily
        } else {
            let cellLine = familyTable.dequeueReusableCell(withIdentifier: lineReuseIdentifier(), for: indexPath) as! IPOLineTableViewCell
            let selectedSection = families[(indexPath as NSIndexPath).section]
            let linesArr = selectedSection["line"] as! NSArray
            let itemLine = linesArr[(indexPath as NSIndexPath).row - 1] as! NSDictionary
            cellLine.setTitle(itemLine["title"] as! String)
            cellLine.showSeparator =  linesArr.count == (indexPath as NSIndexPath).row
            cell = cellLine
        }
         //cell.selectionStyle = UITableViewCellSelectionStyle.None
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
            
        }
        else {//news
            
            //selected = indexPath.row
            self.familyTable.reloadData()
            
            let selectedSection = families[(indexPath as NSIndexPath).section]
            let linesArr = selectedSection["line"] as! NSArray
            let item = linesArr[(indexPath as NSIndexPath).row - 1] as! NSDictionary
            
            
            if delegate != nil {
                delegate!.selectedDetail((indexPath as NSIndexPath).row, item: item)
            }
            else {
                let controller = PreviewHelpViewController()
                let name = item["title"] as! String
                controller.titleText = NSLocalizedString(name, comment: "") as NSString!
                controller.resource = item["resource"] as! String as NSString!
                controller.type = item["type"] as! String as NSString!
                
                if  let imgFile = item["imgFile"] as? String{
                    controller.imgFile = imgFile as NSString?
                }
                self.navigationController!.pushViewController(controller, animated: true)
            }
            
            var action : String = item["title"] as! String
            action =  action.replacingOccurrences(of: " ", with:"")
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TERMS_CONDITION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_TERMS_CONDITION_NO_AUTH.rawValue , action:"A_\(action)" , label:"")
            
        }
        
        
    }
    
    func numberOfRowsInSection(_ section:Int) -> Int {
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
    
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TERMS_CONDITION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_TERMS_CONDITION_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label:"")
        super.back()
    }
    
    
}


