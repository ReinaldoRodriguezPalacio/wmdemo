//
//  IPASearchLastViewTableViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 11/25/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPASearchLastViewTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    
    var table: UITableView!
    var elements: [AnyObject]?
    var elementsCategories: [AnyObject]?
    var searchText: String! = ""
    var delegate:SearchViewControllerDelegate!
    var afterselect : (() -> Void)? = nil
    var endEditing : (() -> Void)? = nil
    var all: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table = UITableView()
        self.table.registerClass(SearchSingleViewCell.self, forCellReuseIdentifier: "ProductsCell")
        self.table.registerClass(SearchCategoriesViewCell.self, forCellReuseIdentifier: "SearchCell")
        
        self.table?.backgroundColor = UIColor.whiteColor()
        self.table?.alpha = 0.8
        self.table?.frame = self.view.bounds
        
        self.table.separatorStyle = .None
        self.table.autoresizingMask = UIViewAutoresizing.None
        table.delegate = self
        table.dataSource = self
        self.view.addSubview(self.table!)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.table!.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height )
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        switch  indexPath.section {
//        case 0:
//            return 46.0
//        default:
            return 56.0
//        }
    }


    /*func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductsCell", forIndexPath: indexPath) as SearchSingleViewCell
        if self.elements != nil && self.elements!.count > 0 {
            let item = self.elements![indexPath.row] as? NSDictionary
            cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as NSString, forKey:searchText, andPrice:item!["price"] as NSString  )
        }
        return cell
    }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as SearchCategoriesViewCell
            if self.elementsCategories != nil && self.elementsCategories!.count > 0 {
                let item = self.elementsCategories![indexPath.row] as? NSDictionary
                cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as NSString, forKey:searchText, andDepartament:item!["departament"] as NSString  )
            }
            
            return cell
//        }
        
    }
    
    /*
    *@method: Create a section view and return
    */
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        let generic : UIView = UIView(frame: CGRectMake(0,0,self.view.frame.width,36.0))
        let titleView : UILabel = UILabel(frame:CGRectMake(16,0,self.view.frame.width,36.0))
        titleView.textColor = WMColor.searchTitleSectionColor
        titleView.font = WMFont.fontMyriadProRegularOfSize(11)
        titleView.backgroundColor = UIColor.clearColor()
//        if section == 0 {
//            var checkTermOff : UIImage = UIImage(named:"filter_check_blue")!
//            var checkTermOn : UIImage = UIImage(named:"filter_check_blue_selected")!
//            var allButton = UIButton()
//            allButton.setTitleColor(WMColor.searchCategoriesAllColor , forState: UIControlState.Normal)
//            allButton.setImage(checkTermOff, forState: UIControlState.Normal)
//            allButton.setImage(checkTermOn, forState: UIControlState.Selected)
//            allButton.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
//            allButton.titleLabel?.textColor = WMColor.searchCategoriesAllColor
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
        generic.backgroundColor =  WMColor.searchProductHeaderTableViewColor
        return generic
    }

    func checkSelected(sender:UIButton) {
        
        sender.selected = !(sender.selected)
        self.all = sender.selected
        if let count = self.elements?.count {
            self.table.reloadData()
        }
    }

    
    func searchProductKeywords(string:String) {
        searchText = string
        var keywords = Array<AnyObject>()
       
         var load = false
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            WalMartSqliteDB.instance.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                var select = WalMartSqliteDB.instance.buildSearchProductKeywordsQuery(keyword: string)
                
                if let rs = db.executeQuery(select, withArgumentsInArray:nil) {
                    var keywords = Array<AnyObject>()
                    while rs.next() {
                        var keyword = rs.stringForColumn(KEYWORD_TITLE_COLUMN)
                        var upc = rs.stringForColumn("upc")
                        var price = rs.stringForColumn("price")
                        
                        keywords.append([KEYWORD_TITLE_COLUMN:keyword , "upc":upc , "price":price  ])
                    }// while rs.next() {
                    rs.close()
                    rs.setParentDB(nil)
                    self.elements = keywords
                    load = true;
                }
                
                var selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesKeywordsQuery(keyword: string)
                if let rs = db.executeQuery(selectCategories, withArgumentsInArray:nil) {
                    var keywords = Array<AnyObject>()
                    while rs.next() {
                        var keyword = rs.stringForColumn(KEYWORD_TITLE_COLUMN)
                        var description = rs.stringForColumn("departament")
                        var idLine = rs.stringForColumn("idLine")
                        var idDepto = rs.stringForColumn("idDepto")
                        var idFamily = rs.stringForColumn("idFamily")
                        var type = rs.stringForColumn("type")
                        
                        keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
                    }// while rs.next() {
                    rs.close()
                    rs.setParentDB(nil)
                    self.elementsCategories = keywords
                    load = true;
                }
                
                if load {
                    self.table.reloadData()
                }
            }
        });
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.section == 0 {
            let item = self.elements![indexPath.row] as? NSDictionary
            self.delegate.selectKeyWord(item![KEYWORD_TITLE_COLUMN] as NSString, upc: item!["upc"] as NSString, truncate:false )
        }else{
            let item = self.elementsCategories![indexPath.row] as? NSDictionary
            self.delegate.showProducts(forDepartmentId: item!["idDepto"] as NSString, andFamilyId: item!["idFamily"] as NSString, andLineId: item!["idLine"] as NSString, andTitleHeader:item!["title"] as NSString , andSearchContextType:item!["type"] as NSString == ResultObjectType.Mg.rawValue ? .WithCategoryForMG: .WithCategoryForGR )
        }
        let item = self.elements![indexPath.row] as? NSDictionary
        if afterselect != nil {
            afterselect!()
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView!) {
        if endEditing != nil {
            endEditing!()
        }
       
        
    }
    
}