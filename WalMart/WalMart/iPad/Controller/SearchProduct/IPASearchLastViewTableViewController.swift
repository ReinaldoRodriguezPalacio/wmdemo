//
//  IPASearchLastViewTableViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/25/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class IPASearchLastViewTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    
    var table: UITableView!
    var elements: [AnyObject]?
    var elementsCategories: [AnyObject]?
    var searchText: String! = ""
    var delegate:SearchViewControllerDelegate!
    var afterselect : (() -> Void)? = nil
    var endEditing : (() -> Void)? = nil
    var all: Bool = false
    
    var dataBase : FMDatabaseQueue! = WalMartSqliteDB.instance.dataBase
    var cancelSearch: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table = UITableView()
        self.table.register(SearchSingleViewCell.self, forCellReuseIdentifier: "ProductsCell")
        self.table.register(SearchCategoriesViewCell.self, forCellReuseIdentifier: "SearchCell")
        
        self.table?.backgroundColor = UIColor.white
        self.table?.alpha = 0.8
        self.table?.frame = self.view.bounds
        
        self.table.separatorStyle = .none
        self.table.autoresizingMask = UIViewAutoresizing()
        table.delegate = self
        table.dataSource = self
        self.view.addSubview(self.table!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.table!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )
    }
    
    func showTableIfNeeded() {
        let bounds = self.view.frame.size
        if (self.elements == nil || self.elements!.count == 0)
            && (self.elementsCategories == nil || self.elementsCategories!.count == 0) {
                
                if self.table.frame.minY != 0.0 {
                    
                    self.table?.backgroundColor = UIColor.white
                    self.table?.alpha = 0.8
                    
                    UIView.animate(withDuration: 0.25,
                        animations: {
                            self.table.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 64.0)
                        },completion: {(bool : Bool) in
                            if bool {
                            }
                        }
                    )
                }
        }
        else {
            
            if self.table.frame.minY == 0.0{
                self.table.backgroundColor = UIColor.clear
                
                
                UIView.animate(withDuration: 0.25,
                    animations: {
                        self.table.frame = CGRect(x: 0.0, y: 73, width: bounds.width, height: bounds.height - self.view!.frame.maxY)
                    },completion: {(bool : Bool) in
                        if bool {
                            
                        }
                    }
                )
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        switch section {
        //        case 0:
        //            if (self.elements == nil || self.elements!.count == 0){
        //                return 0;
        //            }
        //            return 36.0
        //        default:
        if (self.elementsCategories == nil || self.elementsCategories!.count == 0){
            return 0;
        }
        return 36.0
        //        }
    }
    
    /*
    *@method: Create a section view and return
    */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generic : UIView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: 36.0))
        let titleView : UILabel = UILabel(frame:CGRect(x: 16,y: 0,width: self.view.frame.width,height: 36.0))
        titleView.textColor = WMColor.reg_gray
        titleView.font = WMFont.fontMyriadProRegularOfSize(11)
        titleView.backgroundColor = UIColor.clear
        //        if section == 0 {
        //            var checkTermOff : UIImage = UIImage(named:"filter_check_blue")!
        //            var checkTermOn : UIImage = UIImage(named:"check_full")!
        //            var allButton = UIButton()
        //            allButton.setImage(checkTermOff, forState: UIControlState.Normal)
        //            allButton.setImage(checkTermOn, forState: UIControlState.Selected)
        //            allButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        //            allButton.addTarget(self, action: "checkSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        //
        //            allButton.setTitle(NSLocalizedString("product.searh.all",  comment: ""), forState: UIControlState.Normal)
        //
        //            titleView.text = NSLocalizedString("product.searh.shown.recent",comment:"")
        //            allButton.titleLabel?.sizeToFit()
        //
        //            allButton.frame = CGRectMake(self.view.frame.width - 110 , 0, 110, 36 )
        //            allButton.selected = self.all
        //            var titleSize = allButton.titleLabel?.frame.size;
        //
        //            allButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -(titleSize!.width * 2) - 10);
        //            allButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, (checkTermOn.size.width * 2) + 10 );
        //            generic.addSubview(titleView)
        //            generic.addSubview(allButton)
        //        }
        //        else{
        titleView.text = NSLocalizedString("product.searh.shown.categories",comment:"")
        generic.addSubview(titleView)
        //        }
        generic.backgroundColor =  WMColor.light_light_gray
        return generic
    }
    
    func checkSelected(_ sender:UIButton) {
        
        sender.isSelected = !(sender.isSelected)
        self.all = sender.isSelected
        if self.elements?.count > 0 {
            self.table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var size = 0
        //        if section == 0 {
        //            if let count = self.elements?.count {
        //                size = count
        //                if !self.all &&  size > 3{
        //                    size = 3
        //                }
        //            }
        //        }else {
        if let count = self.elementsCategories?.count {
            size = count
        }
        //}
        return size
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        switch  indexPath.section {
        //        case 0:
        //            return 46.0
        //        default:
        return 56.0
        //        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        switch  indexPath.section {
        //        case 0:
        //            let cell = tableView.dequeueReusableCellWithIdentifier("ProductsCell", forIndexPath: indexPath) as SearchSingleViewCell
        //            if self.elements != nil && self.elements!.count > 0 {
        //                let item = self.elements![indexPath.row] as? NSDictionary
        //                cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as NSString, forKey:searchText, andPrice:item!["price"] as NSString  )
        //            }
        //
        //            return cell
        //        default:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCategoriesViewCell
        if self.elementsCategories != nil && self.elementsCategories!.count > 0 {
            let item = self.elementsCategories![(indexPath as NSIndexPath).row] as? NSDictionary
            cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as! String, forKey:searchText, andDepartament:item!["departament"] as! String  )
        }
        
        return cell
        //        }
        
    }
    
    //    func searchProductKeywords(string:String) {
    //        searchText = string
    //        var keywords = Array<AnyObject>()
    //
    //         var load = false
    //        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
    //            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
    //                var select = WalMartSqliteDB.instance.buildSearchProductKeywordsQuery(keyword: string)
    //
    //                if let rs = db.executeQuery(select, withArgumentsInArray:nil) {
    //                    var keywords = Array<AnyObject>()
    //                    while rs.next() {
    //                        var keyword = rs.stringForColumn(KEYWORD_TITLE_COLUMN)
    //                        var upc = rs.stringForColumn("upc")
    //                        var price = rs.stringForColumn("price")
    //
    //                        keywords.append([KEYWORD_TITLE_COLUMN:keyword , "upc":upc , "price":price  ])
    //                    }// while rs.next() {
    //                    rs.close()
    //                    rs.setParentDB(nil)
    //                    self.elements = keywords
    //                    load = true;
    //                }
    //
    //                var selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesKeywordsQuery(keyword: string)
    //                if let rs = db.executeQuery(selectCategories, withArgumentsInArray:nil) {
    //                    var keywords = Array<AnyObject>()
    //                    while rs.next() {
    //                        var keyword = rs.stringForColumn(KEYWORD_TITLE_COLUMN)
    //                        var description = rs.stringForColumn("departament")
    //                        var idLine = rs.stringForColumn("idLine")
    //                        var idDepto = rs.stringForColumn("idDepto")
    //                        var idFamily = rs.stringForColumn("idFamily")
    //                        var type = rs.stringForColumn("type")
    //
    //                        keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
    //                    }// while rs.next() {
    //                    rs.close()
    //                    rs.setParentDB(nil)
    //                    self.elementsCategories = keywords
    //                    load = true;
    //                }
    //
    //                if load {
    //                    self.table.reloadData()
    //                }
    //            }
    //        });
    //    }
    
    func searchProductKeywords(_ string:String) {
        searchText = string
        if searchText.lengthOfBytes(using: String.Encoding.utf8) <  2 {
            
            self.elements = nil
            self.elementsCategories = nil
            self.table.reloadData()
            self.showTableIfNeeded()
            
            return
        }
        
        _ = { () -> Void in
            DispatchQueue.main.async(execute: {
                self.table.reloadData()
                self.showTableIfNeeded()
            })
        }
        
        DispatchQueue.main.async(execute: {
            self.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                let select = WalMartSqliteDB.instance.buildSearchProductKeywordsQuery(keyword: string)
                var load = false
                self.cancelSearch = false
                if let rs = db.executeQuery(select, withArgumentsIn:nil) {
                    var keywords = Array<AnyObject>()
                    while rs.next() {
                        if  self.cancelSearch {
                            break
                        }
                        let keyword = rs.string(forColumn: KEYWORD_TITLE_COLUMN)
                        let upc = rs.string(forColumn: "upc")
                        let price = rs.string(forColumn: "price")
                        keywords.append([KEYWORD_TITLE_COLUMN:keyword , "upc":upc , "price":price  ])
                    }
                    rs.close()
                    rs.setParentDB(nil)
                    self.elements = keywords
                    load = true;
                }
                
                if  !self.cancelSearch {
                    let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesKeywordsQuery(keyword: string)
                    self.cancelSearch = false
                    if let rs = db.executeQuery(selectCategories, withArgumentsIn:nil) {
                        var keywords = Array<AnyObject>()
                        
                        while rs.next() {
                            if self.cancelSearch {
                                break
                            }
                            let depto = rs.string(forColumn: "departament")
                            let family = rs.string(forColumn: "family")
                            
                            let keyword = rs.string(forColumn: KEYWORD_TITLE_COLUMN)
                            let description = "\(depto) > \(family)"
                            //                            var description = rs.stringForColumn("departament")
                            let idLine = rs.string(forColumn: "idLine")
                            let idDepto = rs.string(forColumn: "idDepto")
                            let idFamily = rs.string(forColumn: "idFamily")
                            let type = rs.string(forColumn: "type")
                            
                            keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
                        }
                        rs.close()
                        rs.setParentDB(nil)
                        self.elementsCategories = keywords
                        load = true;
                        
                        if !self.cancelSearch {
                            if load {
                                DispatchQueue.main.async(execute: { () -> Void in
                                    self.table.reloadData()
                                    self.showTableIfNeeded()
                                });
                            }
                        }
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if indexPath.section == 0 {
        //            let item = self.elements![indexPath.row] as? NSDictionary
        //            self.delegate.selectKeyWord(item![KEYWORD_TITLE_COLUMN] as NSString, upc: item!["upc"] as NSString, truncate:false )
        //        }else{
        let item = self.elementsCategories![(indexPath as NSIndexPath).row] as? NSDictionary
        self.delegate.showProducts(forDepartmentId: item!["idDepto"] as! NSString as String, andFamilyId: item!["idFamily"] as! NSString as String, andLineId: item!["idLine"] as! NSString as String, andTitleHeader:item!["title"] as! NSString as String , andSearchContextType:item!["type"] as? NSString == ResultObjectType.Mg.rawValue ? .withCategoryForMG: .withCategoryForGR )
        
        //        }
        //        let item = self.elements![indexPath.row] as? NSDictionary
        if afterselect != nil {
            afterselect!()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if endEditing != nil {
           // endEditing!()
        }
    }
}
