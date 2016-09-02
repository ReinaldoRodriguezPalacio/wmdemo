//
//  SearchViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 08/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func selectKeyWord(keyWord:String,upc:String?, truncate:Bool,upcs:[String]?)
    func searchControllerScanButtonClicked()
    func searchControllerCamButtonClicked(controller: CameraViewControllerDelegate!)
    func closeSearch(addShoping:Bool, sender:UIButton?)
    func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType)
}

class SearchViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CameraViewControllerDelegate, UIScrollViewDelegate {
    var table: UITableView!
    var elements: [AnyObject]?
    var upcItems: [String]?
    var elementsCategories: [AnyObject]?
    var currentKey: String?
    var header: UIView?
    var field: UITextField?
    //    var fieldArrow: UIImageView?
    var delegate:SearchViewControllerDelegate!
    var scanButton: UIButton?
    var camButton: UIButton?
    var scanLabel: UILabel?
    var camLabel: UILabel?
    var cancelButton: UIButton?
    var clearButton: UIButton?
    var viewTapClose: UIView?
    var viewBackground: UIView?
    var upsSearch: Bool? = false
    var labelHelpScan : UILabel?
    var headerTable: UIView?
    var resultLabel: UILabel?
    var errorView : FormFieldErrorView? = nil
    var all: Bool = false
    var cancelSearch: Bool = true
    var dataBase : FMDatabaseQueue! = WalMartSqliteDB.instance.dataBase
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_OPTIONSEARCHPRODUCT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
 
        viewTapClose = UIView()
        self.viewBackground = UIView()
        self.viewBackground?.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.9)
        self.view.addSubview(self.viewBackground!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(SearchViewController.handleTap(_:)))
        self.viewTapClose?.addGestureRecognizer(tapGestureRecognizer)
        self.viewTapClose?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.viewTapClose!)
        
        self.table = UITableView()
        self.table.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 64.0)
        self.table.registerClass(SearchSingleViewCell.self, forCellReuseIdentifier: "ProductsCell")
        self.table.registerClass(SearchCategoriesViewCell.self, forCellReuseIdentifier: "SearchCell")
        
        self.table?.backgroundColor = UIColor.whiteColor()
        self.table?.alpha = 0.8
        
        self.table.separatorStyle = .None
        self.table.autoresizingMask = UIViewAutoresizing.None
        table.delegate = self
        table.dataSource = self
        
        self.view.addSubview(self.table!)
        
        self.header = UIView()
        self.header?.backgroundColor = WMColor.blue
        self.view.addSubview(self.header!)
        
        self.headerTable = UIView()
        self.headerTable?.backgroundColor = WMColor.light_light_gray
        
        self.resultLabel = UILabel()
        self.resultLabel!.backgroundColor = UIColor.clearColor()
        self.resultLabel!.textColor = WMColor.gray_reg
        self.resultLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.resultLabel?.text = NSLocalizedString("product.searh.shown.recent",comment:"")
        
        self.field = FormFieldSearch()
        self.field!.delegate = self
        self.field!.returnKeyType = .Search
        self.field!.autocapitalizationType = .None
        self.field!.autocorrectionType = .No
        self.field!.enablesReturnKeyAutomatically = true
        self.field!.placeholder = NSLocalizedString("search.info.placeholder",comment:"")
        self.header!.addSubview(self.field!)
        
        //        self.fieldArrow = UIImageView(image: UIImage(named: "fieldArrow"))
        
        //        self.labelHelpScan = UILabel()
        //        self.labelHelpScan!.textAlignment = .Right
        //        self.labelHelpScan!.numberOfLines = 2
        //        self.labelHelpScan!.font = WMFont.fontMyriadProRegularOfSize(14)
        //        self.labelHelpScan!.text = NSLocalizedString("product.searh.field.barcode",comment:"")
        //        self.labelHelpScan!.backgroundColor = UIColor.clearColor()
        
        //self.header!.addSubview(self.labelHelpScan!)
        //self.header!.addSubview(self.fieldArrow!)
        
        self.clearButton = UIButton(type: .Custom)
        self.clearButton!.frame = CGRectMake(0.0, 0.0, 44.0, 44.0)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Normal)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Selected)
        self.clearButton!.addTarget(self, action: #selector(SearchViewController.clearSearch), forControlEvents: UIControlEvents.TouchUpInside)
        self.clearButton!.hidden = true
        self.header!.addSubview(self.clearButton!)
        
        self.camButton = UIButton(type: .Custom)
        self.camButton!.setImage(UIImage(named:"search_by_photo"), forState: .Normal)
        self.camButton!.setImage(UIImage(named:"search_by_photo_active"), forState: .Highlighted)
        self.camButton!.setImage(UIImage(named:"search_by_photo"), forState: .Selected)
        self.camButton!.addTarget(self, action: #selector(SearchViewController.showCamera(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view!.addSubview(self.camButton!)
        
        self.camLabel = UILabel()
        self.camLabel!.textAlignment = .Center
        self.camLabel!.numberOfLines = 2
        self.camLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.camLabel!.textColor = UIColor.whiteColor()
        self.camLabel!.text = NSLocalizedString("search.info.button.camera",comment:"")
        self.view!.addSubview(self.camLabel!)
        
        self.scanButton = UIButton(type: .Custom)
        self.scanButton!.setImage(UIImage(named:"search_by_code"), forState: .Normal)
        self.scanButton!.setImage(UIImage(named:"search_by_code_active"), forState: .Highlighted)
        self.scanButton!.setImage(UIImage(named:"search_by_code"), forState: .Selected)
        self.scanButton!.addTarget(self, action: #selector(SearchViewController.showBarCode(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view!.addSubview(self.scanButton!)
        
        self.scanLabel = UILabel()
        self.scanLabel!.textAlignment = .Center
        self.scanLabel!.numberOfLines = 2
        self.scanLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.scanLabel!.textColor = UIColor.whiteColor()
        self.scanLabel!.text = NSLocalizedString("search.info.button.barcode",comment:"")
        self.view!.addSubview(self.scanLabel!)
        
        self.cancelButton = UIButton(type: .Custom)
        self.cancelButton!.frame = CGRectMake(0.0, 0.0, 44.0, 44.0)
        self.cancelButton!.addTarget(self, action: #selector(SearchViewController.cancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.setTitle(NSLocalizedString("product.searh.cancel",  comment: ""), forState: UIControlState.Normal)
        
        self.header!.addSubview(self.cancelButton!)
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.clearSearch()
    }
    
    override func viewDidLayoutSubviews() {
        let bounds = self.view.frame.size
        self.header!.frame = CGRectMake(0.0, 0.0, bounds.width, 97.0 - 24 )
        self.headerTable!.frame = CGRectMake(0.0, 73 , bounds.width, 24.0)
        self.field!.frame = CGRectMake(16.0, 15, 225, 40.0)
        //        self.labelHelpScan!.frame = CGRectMake(40 , 17.0, self.field!.frame.width  -  49 - 24 - 20, 40.0)
        
        self.clearButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
        self.cancelButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) , 0 , bounds.width - CGRectGetMaxX(self.field!.frame), self.header!.frame.height)
        
        //        self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
        //        self.fieldArrow!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 - 24 , (self.header!.frame.height - 24.0) / 2, 24 , 24)
        self.resultLabel!.frame = CGRectMake(20, 0, bounds.width - 140.0, self.headerTable!.frame.height)
        self.viewBackground!.frame = CGRectMake(0, CGRectGetMaxY(self.header!.frame), bounds.width, bounds.height - CGRectGetMaxY(self.header!.frame))
        self.viewTapClose!.frame = CGRectMake(0, CGRectGetMaxY(self.header!.frame), bounds.width, bounds.height - CGRectGetMaxY(self.header!.frame))
        
        let showCamFind = NSBundle.mainBundle().objectForInfoDictionaryKey("showCamFind") as! Bool
        self.camButton!.hidden = !showCamFind
        self.camLabel!.hidden = !showCamFind
        
        if showCamFind {
            if IS_IPHONE_4_OR_LESS {
                self.camButton!.frame = CGRectMake((self.view!.frame.width / 2) - 96, self.header!.frame.height + 10, 64, 64)
                self.scanButton!.frame = CGRectMake((self.view!.frame.width / 2) + 32, self.header!.frame.height + 10, 64, 64)
            }
            else{
                self.camButton!.frame = CGRectMake((self.view!.frame.width / 2) - 96, self.header!.frame.height + 38, 64, 64)
                self.scanButton!.frame = CGRectMake((self.view!.frame.width / 2) + 32, self.header!.frame.height + 38, 64, 64)
            }
        
            self.camLabel!.frame = CGRectMake(self.camButton!.frame.origin.x - 28, self.camButton!.frame.origin.y + self.camButton!.frame.height + 16, 120, 34)
            self.scanLabel!.frame = CGRectMake(self.scanButton!.frame.origin.x - 28, self.scanButton!.frame.origin.y + self.scanButton!.frame.height + 16, 120, 34)
        }else{
            if IS_IPHONE_4_OR_LESS {
                self.scanButton!.frame = CGRectMake((self.view!.frame.width - 64) / 2, self.header!.frame.height + 10, 64, 64)
            }
            else{
                self.scanButton!.frame = CGRectMake((self.view!.frame.width - 64) / 2, self.header!.frame.height + 38, 64, 64)
            }
            self.scanLabel!.frame = CGRectMake(self.scanButton!.frame.origin.x - 28, self.scanButton!.frame.origin.y + self.scanButton!.frame.height + 16, 120, 34)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func generateBlurImage() -> UIImageView {
        var blurredImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 1.0);
            self.parentViewController!.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            blurredImage = cloneImage.applyLightEffect()
        }
        
        let imageView = UIImageView()
        imageView.frame = self.view.bounds
        imageView.clipsToBounds = true
        imageView.image = blurredImage
        return imageView
    }
    
    func showTableIfNeeded() {
        let bounds = self.view.frame.size
        if (self.elements == nil || self.elements!.count == 0)
            && (self.elementsCategories == nil || self.elementsCategories!.count == 0) {
                
                if self.table.frame.minY != 0.0 {
                    
                    self.table?.backgroundColor = UIColor.whiteColor()
                    self.table?.alpha = 0.8
                    self.viewTapClose?.backgroundColor = UIColor.clearColor()
                    
                    UIView.animateWithDuration(0.25,
                        animations: {
                            self.table.frame = CGRectMake(0.0, 0.0, bounds.width, 64.0)
                        },completion: {(bool : Bool) in
                            if bool {
                            }
                        }
                    )
                }
        }
        else {
            
            if self.table.frame.minY == 0.0{
                self.viewTapClose?.backgroundColor = UIColor.whiteColor()
                self.viewTapClose?.alpha = 0.8
                self.table.backgroundColor = UIColor.clearColor()
                
                
                UIView.animateWithDuration(0.25,
                    animations: {
                        self.table.frame = CGRectMake(0.0, 73, bounds.width, bounds.height - CGRectGetMaxY(self.header!.frame))
                    },completion: {(bool : Bool) in
                        if bool {
                            
                        }
                    }
                )
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generic : UIView = UIView(frame: CGRectMake(0,0,tableView.frame.width,36.0))
        let titleView : UILabel = UILabel(frame:CGRectMake(16,0,tableView.frame.width,36.0))
        titleView.textColor = WMColor.gray_reg
        titleView.font = WMFont.fontMyriadProRegularOfSize(11)
        titleView.backgroundColor = UIColor.clearColor()
        //        if section == 0 {
        //            var checkTermOff : UIImage = UIImage(named:"filter_check_blue")!
        //            var checkTermOn : UIImage = UIImage(named:"filter_check_blue_selected")!
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
        //            allButton.frame = CGRectMake(tableView.frame.width - 110 , 0, 110, 36 )
        //            allButton.selected = self.all
        //            var titleSize = allButton.titleLabel?.frame.size;
        //
        //            allButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -(titleSize!.width * 2) - 10);
        //            allButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, (checkTermOn.size.width * 2) + 10 );
        //            generic.addSubview(titleView)
        //             generic.addSubview(allButton)
        //        }
        //        else{
        titleView.text = NSLocalizedString("product.searh.shown.categories",comment:"")
        generic.addSubview(titleView)
        //        }
        generic.backgroundColor =  WMColor.light_light_gray
        return generic
    }
    
    func checkSelected(sender:UIButton) {
        sender.selected = !(sender.selected)
        self.all = sender.selected
        if self.elements?.count > 0 {
            self.table.reloadData()
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var size = 0
        //        if section == 0 {
        //
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
        //        }
        return size
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //        switch  indexPath.section {
        //        case 0:
        //            return 46.0
        //        default:
        return 56.0
        //        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //        switch  indexPath.section {
        //        case 0:
        //            let cell = tableView.dequeueReusableCellWithIdentifier("ProductsCell", forIndexPath: indexPath) as SearchSingleViewCell
        //            if self.elements != nil && self.elements!.count > 0 {
        //                let item = self.elements![indexPath.row] as? NSDictionary
        //                cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as NSString, forKey:field!.text, andPrice:item!["price"] as NSString  )
        //            }
        //
        //            return cell
        //        default:
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchCategoriesViewCell
        if self.elementsCategories != nil && self.elementsCategories!.count > 0 {
            if indexPath.row < self.elementsCategories?.count {
                let item = self.elementsCategories![indexPath.row] as? NSDictionary
                cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as! String, forKey:field!.text!, andDepartament:item!["departament"] as! String  )
            }
        }
        
        return cell
        //        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        if textField.text != nil && textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            let toValidate : NSString = textField.text!
            let trimValidate = toValidate.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if trimValidate.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) < 4 {
                showMessageValidation(NSLocalizedString("product.search.minimum",comment:""))
                return true
            }
            if !validateSearch(textField.text!)  {
                showMessageValidation("Texto no permitido")
                return true
            }
            
            self.field!.frame = CGRectMake(16.0, 15, 225, 40.0)
            self.clearButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
            //            self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
            
            self.errorView?.removeFromSuperview()
            
            if textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= 12 && textField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 16 {
                
                let strFieldValue = textField.text! as NSString
                if strFieldValue.integerValue > 0 {
                    let code = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    var character = code
                    if self.isBarCodeUPC(code) {
                        character = code.substringToIndex(code.startIndex.advancedBy(code.characters.count-1 ))
                    }
                    delegate.selectKeyWord("", upc: character, truncate:true,upcs:nil)
                    return true
                }
                if strFieldValue.substringToIndex(1).uppercaseString == "B" {
                    let validateNumeric: NSString = strFieldValue.substringFromIndex(1)
                    if validateNumeric.doubleValue > 0 {
              
                        delegate.selectKeyWord("", upc: textField.text!.uppercaseString, truncate:false,upcs:nil)
                        return true
                    }
                }
            }
            delegate.selectKeyWord(textField.text!, upc: nil, truncate:false,upcs: self.upcItems)
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action:WMGAIUtils.ACTION_TEXT_SEARCH.rawValue , label: textField.text!)
        }
        else{
            UIView.animateWithDuration(1.0, animations: {
                self.camButton!.alpha = 1;
                self.scanButton!.alpha = 1;
                self.camLabel!.alpha = 1;
                self.scanLabel!.alpha = 1;
            })
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        var  keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        if keyword.length() > 51 {
            return false
        }
        
        if keyword.length() < 2 {
            keyword = ""
        }
        
        self.searchProductKeywords(keyword)
        self.showClearButtonIfNeeded(forTextValue: keyword)
            
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        if indexPath.section == 0 {
        //            let item = self.elements![indexPath.row] as? NSDictionary
        //            self.delegate.selectKeyWord(item![KEYWORD_TITLE_COLUMN] as NSString, upc: item!["upc"] as NSString, truncate:false)
        //        }else{
        let item = self.elementsCategories![indexPath.row] as? NSDictionary
        self.delegate.showProducts(forDepartmentId: item!["idDepto"] as! NSString as String, andFamilyId: item!["idFamily"] as! NSString as String, andLineId: item!["idLine"] as! NSString as String, andTitleHeader:item!["title"] as! NSString as String , andSearchContextType:item!["type"] as? NSString == ResultObjectType.Mg.rawValue ? .WithCategoryForMG: .WithCategoryForGR )
        //        }
    }
    
    //func
    
    func searchProductKeywords(string:String) {
        self.cancelSearch = true
        
        if  string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 2 {
            
            self.elements = nil
            self.elementsCategories = nil
            self.table.reloadData()
            self.showTableIfNeeded()
            
            return
        }
        
        _ = { () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.table.reloadData()
                self.showTableIfNeeded()
            })
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.dataBase.inDatabase { (db:FMDatabase!) -> Void in
                let select = WalMartSqliteDB.instance.buildSearchProductKeywordsQuery(keyword: string)
                var load = false
                self.cancelSearch = false
                if let rs = db.executeQuery(select, withArgumentsInArray:nil) {
                    
                    var keywords = Array<AnyObject>()
                    while rs.next() {
                        if  self.cancelSearch {
                            break
                        }
                        let keyword = rs.stringForColumn(KEYWORD_TITLE_COLUMN)
                        let upc = rs.stringForColumn("upc")
                        let price = rs.stringForColumn("price")
                        keywords.append([KEYWORD_TITLE_COLUMN:keyword , "upc":upc , "price":price  ])
                    }// while rs.next() {
                    rs.close()
                    rs.setParentDB(nil)
                    self.elements = keywords
                    load = true;
                }
                
                if  !self.cancelSearch {
                    let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesKeywordsQuery(keyword: string)
                    self.cancelSearch = false
                    if let rs = db.executeQuery(selectCategories, withArgumentsInArray:nil) {
                        var keywords = Array<AnyObject>()
                        
                        while rs.next() {
                            if  self.cancelSearch {
                                break
                            }
                            
                            let depto = rs.stringForColumn("departament")
                            let family = rs.stringForColumn("family")
                            
                            let keyword = rs.stringForColumn(KEYWORD_TITLE_COLUMN)
                            let description = "\(depto) > \(family)"
                            let idLine = rs.stringForColumn("idLine")
                            let idDepto = rs.stringForColumn("idDepto")
                            let idFamily = rs.stringForColumn("idFamily")
                            let type = rs.stringForColumn("type")
                            
                            keywords.append([KEYWORD_TITLE_COLUMN:keyword , "departament":description, "idLine":idLine, "idFamily":idFamily, "idDepto":idDepto, "type":type])
                        }// while rs.next() {
                        rs.close()
                        rs.setParentDB(nil)
                        self.elementsCategories = keywords
                        load = true;
                        
                        if  !self.cancelSearch {
                            if load {
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
    
    func clearSearch(){
        upsSearch = false
        self.field!.text = ""
        self.elements = nil
        self.elementsCategories = nil
        self.showClearButtonIfNeeded(forTextValue: self.field!.text!)
        self.showTableIfNeeded()
        if self.errorView != nil {
            self.errorView?.removeFromSuperview()
        }
    }
    
    func showClearButtonIfNeeded(forTextValue text:String) {
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            UIView.animateWithDuration(0.5, animations: {
                self.clearButton!.alpha = 1
                self.camButton!.alpha = 0
                self.scanButton!.alpha = 0
                self.camLabel!.alpha = 0
                self.scanLabel!.alpha = 0
                self.viewBackground!.alpha = 0
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.clearButton!.alpha = 0
                self.camButton!.alpha = 1
                self.scanButton!.alpha = 1
                self.camLabel!.alpha = 1
                self.scanLabel!.alpha = 1
                self.viewBackground!.alpha = 1
            })
        }
    }
    
    func showBarCode(sender:UIButton) {
        if self.field!.isFirstResponder() {
            self.field!.resignFirstResponder()
        }
        self.delegate?.searchControllerScanButtonClicked()
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_OPEN_BARCODE_SCANNED_UPC.rawValue, label: "")
    }
    
    func showCamera(sender:UIButton) {
        if self.field!.isFirstResponder() {
            self.field!.resignFirstResponder()
        }
        self.delegate?.searchControllerCamButtonClicked(self)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
    }
    
    func cancel(sender:UIButton) {
        delegate.closeSearch(false, sender:nil)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
    }
    
    // MARK: - CameraViewControllerDelegate
    func photoCaptured(value: String?,upcs:[String]?,done: (() -> Void)) {
        self.field!.becomeFirstResponder()
        if value != nil && value?.trim() != "" {
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }

            let params = ["upcs": upcArray!, "keyWord":value!]
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.CamFindSearch.rawValue, object: params, userInfo: nil)
            done()
        }
        delegate.closeSearch(false, sender:nil)
    }
    
    func handleTap(recognizer:UITapGestureRecognizer){
        delegate.closeSearch(false, sender:nil)
    }
    
    func showMessageValidation(message:String){
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        
        self.errorView!.frame = CGRectMake(self.field!.frame.minX - 5, 0, self.field!.frame.width, self.field!.frame.height )
        self.errorView!.focusError = self.field!
        if self.field!.frame.minX < 20 {
            self.errorView!.setValues(280, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRectMake(self.field!.frame.minX - 5, self.field!.frame.minY , self.errorView!.frame.width , self.errorView!.frame.height)
        }
        else{
            self.errorView!.setValues(field!.frame.width, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRectMake(field!.frame.minX - 5, field!.frame.minY, errorView!.frame.width , errorView!.frame.height)
        }
        let contentView = self.field!.superview!
        contentView.addSubview(self.errorView!)
        UIView.animateWithDuration(0.2, animations: {
            self.field!.frame = CGRectMake(16.0, 15, 225, 40.0)
            self.clearButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
            //            self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
            
            self.errorView!.frame =  CGRectMake(self.field!.frame.minX - 5 , self.field!.frame.minY - self.errorView!.frame.height , self.errorView!.frame.width , self.errorView!.frame.height)
            
            }, completion: {(bool : Bool) in
                if bool {
                    self.field!.becomeFirstResponder()
                }
        })
    }
    
    func validateSearch(toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-zñÑÁáÉéÍíÓóÚú ]{0,100}[._-]{0,2}$";
        return validateRegEx(regString,toValidate:toValidate)
    }
    
    func validateRegEx(pattern:String,toValidate:String) -> Bool {
        
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatchesInString(toValidate, options: [], range: NSMakeRange(0, toValidate.characters.count))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView){
        super.scrollViewWillBeginDragging(scrollView)
        self.view.endEditing(true)
    }
    
    func isBarCodeUPC(codeUPC:NSString) -> Bool {
        var fullBarcode = codeUPC as String
        if codeUPC.length < 14 {
            let toFill = "".stringByPaddingToLength(14 - codeUPC.length, withString: "0", startingAtIndex: 0)
            fullBarcode = "\(toFill)\(codeUPC)"
        }
        if Int(fullBarcode) == nil {
            return false
        }
        var firstVal = (Int(fullBarcode.substring(0, length: 1))! +
            Int(fullBarcode.substring(2, length: 1))! +
            Int(fullBarcode.substring(4, length: 1))! +
            Int(fullBarcode.substring(6, length: 1))! +
            Int(fullBarcode.substring(8, length: 1))! +
            Int(fullBarcode.substring(10, length: 1))! +
            Int(fullBarcode.substring(12, length: 1))!)
            firstVal = firstVal * 3
        
        let secondVal = Int(fullBarcode.substring(1, length: 1))! +
            Int(fullBarcode.substring(3, length: 1))! +
            Int(fullBarcode.substring(5, length: 1))! +
            Int(fullBarcode.substring(7, length: 1))! +
            Int(fullBarcode.substring(9, length: 1))! +
            Int(fullBarcode.substring(11, length: 1))!
        
        let verificationInt = Int(fullBarcode.substring(13, length: 1))!
        
        let result = firstVal + secondVal
        let resultVerInt : Int! = result != 0 ? 10 - (result % 10 ) : 0
        
        return verificationInt == resultVerInt
        
    }
    
    
}
