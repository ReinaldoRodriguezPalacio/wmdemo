//
//  SearchViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 08/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol SearchViewControllerDelegate: class {
    func selectKeyWord(_ keyWord:String,upc:String?, truncate:Bool,upcs:[String]?)
    func searchControllerScanButtonClicked()
    func searchControllerCamButtonClicked(_ controller: CameraViewControllerDelegate!)
    func closeSearch(_ addShoping:Bool, sender:UIButton?)
    func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?, andTitleHeader title:String , andSearchContextType searchContextType:SearchServiceContextType)
    func showTiresSearch()
}

class SearchViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CameraViewControllerDelegate, UIScrollViewDelegate {
    var table: UITableView!
    var elements: [Any]?
    var upcItems: [String]?
    var elementsCategories: [Any]?
    var currentKey: String?
    var header: UIView?
    var field: UITextField?
    //    var fieldArrow: UIImageView?
    weak var delegate:SearchViewControllerDelegate?
    var scanButton: UIButton?
    var camButton: UIButton?
    var scanLabel: UILabel?
    var camLabel: UILabel?
    var cancelButton: UIButton?
    var clearButton: UIButton?
    var viewTapClose: UIView?
    var viewBackground: UIView?
    var tiresBarView: SearchTiresBarView?
    var upsSearch: Bool? = false
    var labelHelpScan : UILabel?
    var headerTable: UIView?
    var resultLabel: UILabel?
    var errorView : FormFieldErrorView? = nil
    var all: Bool = false
    var cancelSearch: Bool = true
    var dataBase : FMDatabaseQueue! = WalMartSqliteDB.instance.dataBase
    var keyboardHeight: CGFloat = 0.0
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_OPTIONSEARCHPRODUCT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        viewTapClose = UIView()
        self.viewBackground = UIView()
        self.viewBackground?.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
        self.view.addSubview(self.viewBackground!)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self,action:#selector(SearchViewController.handleTap(_:)))
        self.viewTapClose?.addGestureRecognizer(tapGestureRecognizer)
        self.viewTapClose?.backgroundColor = UIColor.clear
        self.view.addSubview(self.viewTapClose!)
        
        self.table = UITableView()
        self.table.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 64.0)
        self.table.register(SearchSingleViewCell.self, forCellReuseIdentifier: "ProductsCell")
        self.table.register(SearchCategoriesViewCell.self, forCellReuseIdentifier: "SearchCell")
        
        self.table?.backgroundColor = UIColor.white
        self.table?.alpha = 0.8
        
        self.table.separatorStyle = .none
        self.table.autoresizingMask = UIViewAutoresizing()
        table.delegate = self
        table.dataSource = self
        
        self.view.addSubview(self.table!)
        
        self.header = UIView()
        self.header?.backgroundColor = WMColor.blue
        self.view.addSubview(self.header!)
        
        self.headerTable = UIView()
        self.headerTable?.backgroundColor = WMColor.light_light_gray
        
        self.resultLabel = UILabel()
        self.resultLabel!.backgroundColor = UIColor.clear
        self.resultLabel!.textColor = WMColor.gray
        self.resultLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.resultLabel?.text = NSLocalizedString("product.searh.shown.recent",comment:"")
        
        self.field = FormFieldSearch()
        self.field!.delegate = self
        self.field!.returnKeyType = .search
        self.field!.autocapitalizationType = .none
        self.field!.autocorrectionType = .no
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
        
        self.clearButton = UIButton(type: .custom)
        self.clearButton!.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: UIControlState())
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), for: .selected)
        self.clearButton!.addTarget(self, action: #selector(SearchViewController.clearSearch), for: UIControlEvents.touchUpInside)
        self.header!.addSubview(self.clearButton!)
        
        self.camButton = UIButton(type: .custom)
        self.camButton!.setImage(UIImage(named:"search_by_photo"), for: UIControlState())
        self.camButton!.setImage(UIImage(named:"search_by_photo_active"), for: .highlighted)
        self.camButton!.setImage(UIImage(named:"search_by_photo"), for: .selected)
        self.camButton!.addTarget(self, action: #selector(SearchViewController.showCamera(_:)), for: UIControlEvents.touchUpInside)
        self.view!.addSubview(self.camButton!)
        
        self.tiresBarView = SearchTiresBarView()
        self.tiresBarView?.isHidden = true
        self.tiresBarView?.delegate = self
        self.view!.addSubview(self.tiresBarView!)
        
        self.camLabel = UILabel()
        self.camLabel!.textAlignment = .center
        self.camLabel!.numberOfLines = 2
        self.camLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.camLabel!.textColor = UIColor.white
        self.camLabel!.text = NSLocalizedString("search.info.button.camera",comment:"")
        self.view!.addSubview(self.camLabel!)
        
        self.scanButton = UIButton(type: .custom)
        self.scanButton!.setImage(UIImage(named:"search_by_code"), for: UIControlState())
        self.scanButton!.setImage(UIImage(named:"search_by_code_active"), for: .highlighted)
        self.scanButton!.setImage(UIImage(named:"search_by_code"), for: .selected)
        self.scanButton!.addTarget(self, action: #selector(SearchViewController.showBarCode(_:)), for: UIControlEvents.touchUpInside)
        self.view!.addSubview(self.scanButton!)
        
        self.scanLabel = UILabel()
        self.scanLabel!.textAlignment = .center
        self.scanLabel!.numberOfLines = 2
        self.scanLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.scanLabel!.textColor = UIColor.white
        self.scanLabel!.text = NSLocalizedString("search.info.button.barcode",comment:"")
        self.view!.addSubview(self.scanLabel!)
        
        self.cancelButton = UIButton(type: .custom)
        self.cancelButton!.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        self.cancelButton!.addTarget(self, action: #selector(SearchViewController.cancel(_:)), for: UIControlEvents.touchUpInside)
        self.cancelButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.setTitle(NSLocalizedString("product.searh.cancel",  comment: ""), for: UIControlState())
        
        self.header!.addSubview(self.cancelButton!)
        
        self.view.backgroundColor = UIColor.clear
        
        self.clearSearch()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        let bounds = self.view.frame.size

        let separation:Int = 16
        let btnCancelWidth:Int = 55
        let btnFieldWidth = ( Int(bounds.width) - Int(separation * 3 + btnCancelWidth) )
        let btnCancelX = Int(self.field!.frame.maxX) + separation
        
        self.header!.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 73 )
        self.headerTable!.frame = CGRect(x: 0.0, y: 73 , width: bounds.width, height: 24.0)
        self.field!.frame = CGRect(x: separation, y: 15, width: Int(btnFieldWidth), height: 40)
        //        self.labelHelpScan!.frame = CGRectMake(40 , 17.0, self.field!.frame.width  -  49 - 24 - 20, 40.0)
        
        self.clearButton!.frame = CGRect(x: self.field!.frame.maxX - 49 , y: self.field!.frame.midY - 20.0, width: 48, height: 40)
        self.cancelButton!.frame = CGRect(x: btnCancelX , y: 0 , width: btnCancelWidth, height: Int(self.header!.frame.height))

        
        //        self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
        //        self.fieldArrow!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 - 24 , (self.header!.frame.height - 24.0) / 2, 24 , 24)
        self.resultLabel!.frame = CGRect(x: 20, y: 0, width: bounds.width - 140.0, height: self.headerTable!.frame.height)
        self.viewBackground!.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.maxY)
        self.viewTapClose!.frame = CGRect(x: 0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.maxY)
        
        let showCamFind = Bundle.main.object(forInfoDictionaryKey: "showCamFind") as! Bool
        self.camButton!.isHidden = !showCamFind
        self.camLabel!.isHidden = !showCamFind
        
        if showCamFind {
            if IS_IPHONE_4_OR_LESS {
                self.camButton!.frame = CGRect(x: (self.view!.frame.width / 2) - 96, y: self.header!.frame.height + 10, width: 64, height: 64)
                self.scanButton!.frame = CGRect(x: (self.view!.frame.width / 2) + 32, y: self.header!.frame.height + 10, width: 64, height: 64)
            }
            else{
                self.camButton!.frame = CGRect(x: (self.view!.frame.width / 2) - 96, y: self.header!.frame.height + 38, width: 64, height: 64)
                self.scanButton!.frame = CGRect(x: (self.view!.frame.width / 2) + 32, y: self.header!.frame.height + 38, width: 64, height: 64)
            }
        
            self.camLabel!.frame = CGRect(x: self.camButton!.frame.origin.x - 28, y: self.camButton!.frame.origin.y + self.camButton!.frame.height + 16, width: 120, height: 34)
            self.scanLabel!.frame = CGRect(x: self.scanButton!.frame.origin.x - 28, y: self.scanButton!.frame.origin.y + self.scanButton!.frame.height + 16, width: 120, height: 34)
        }else{
            if IS_IPHONE_4_OR_LESS {
                self.scanButton!.frame = CGRect(x: (self.view!.frame.width - 64) / 2, y: self.header!.frame.height + 10, width: 64, height: 64)
            }
            else{
                self.scanButton!.frame = CGRect(x: (self.view!.frame.width - 64) / 2, y: self.header!.frame.height + 38, width: 64, height: 64)
            }
            self.scanLabel!.frame = CGRect(x: self.scanButton!.frame.origin.x - 28, y: self.scanButton!.frame.origin.y + self.scanButton!.frame.height + 16, width: 120, height: 34)
        }
        
        self.tiresBarView!.frame = CGRect(x: 0, y: self.view!.frame.height - (keyboardHeight + 46), width: self.view.frame.width, height: 46)
   }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func generateBlurImage() -> UIImageView {
        var blurredImage : UIImage? = nil
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 1.0);
            self.parent!.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
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
                    
                    self.table?.backgroundColor = UIColor.white
                    self.table?.alpha = 0.8
                    self.viewTapClose?.backgroundColor = UIColor.clear
                    
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
                self.viewTapClose?.backgroundColor = UIColor.white
                self.viewTapClose?.alpha = 0.8
                self.table.backgroundColor = UIColor.clear
                
                
                UIView.animate(withDuration: 0.25,
                    animations: {
                        self.table.frame = CGRect(x: 0.0, y: 73, width: bounds.width, height: bounds.height - self.header!.frame.maxY - 44.0)
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
        let generic : UIView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.width,height: 36.0))
        let titleView : UILabel = UILabel(frame:CGRect(x: 16,y: 0,width: tableView.frame.width,height: 36.0))
        titleView.textColor = WMColor.gray
        titleView.font = WMFont.fontMyriadProRegularOfSize(11)
        titleView.backgroundColor = UIColor.clear
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
        //                let item = self.elements![indexPath.row] as? [String:Any]
        //                cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as NSString, forKey:field!.text, andPrice:item!["price"] as NSString  )
        //            }
        //
        //            return cell
        //        default:
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCategoriesViewCell
        if self.elementsCategories != nil && self.elementsCategories!.count > 0 {
            if indexPath.row < self.elementsCategories?.count {
                let item = self.elementsCategories![indexPath.row] as? [String:Any]
                cell.setValueTitle(item![KEYWORD_TITLE_COLUMN] as! String, forKey:field!.text!, andDepartament:item!["departament"] as! String  )
            }
        }
        
        return cell
        //        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        IPOGenericEmptyViewSelected.Selected = IPOGenericEmptyViewKey.Text.rawValue
        
        if textField.text != nil && textField.text!.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            
            let toValidate : NSString = textField.text! as NSString
            let trimValidate = toValidate.trimmingCharacters(in: CharacterSet.whitespaces)
            
            if trimValidate.lengthOfBytes(using: String.Encoding.utf16) < 4 {
                showMessageValidation(NSLocalizedString("product.search.minimum",comment:""))
                return true
            }
            
            if !validateSearch(textField.text!)  {
                showMessageValidation(NSLocalizedString("field.validate.text",comment:""))
                return true
            }
            let bounds = self.view.frame.size
            let separation:Int = 16
            let btnCancelWidth:Int = 55
            let btnFieldWidth = ( Int(bounds.width) - Int(separation * 3 + btnCancelWidth) )
            
            self.field!.frame = CGRect(x: 16.0, y: 15, width: CGFloat(btnFieldWidth), height: 40.0)
            self.clearButton!.frame = CGRect(x: self.field!.frame.maxX - 49 , y: self.field!.frame.midY - 20.0, width: 48, height: 40)
            self.errorView?.removeFromSuperview()
            
            if textField.text!.lengthOfBytes(using: String.Encoding.utf8) >= 12 && textField.text!.lengthOfBytes(using: String.Encoding.utf8) <= 16 {
                
                let strFieldValue = textField.text! as NSString
                if strFieldValue.integerValue > 0 &&  textField.text!.isNumeric(){
                    let code = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                    var character = code
                    if self.isBarCodeUPC(code as NSString) {
                        character = code.substring(to: code.characters.index(code.startIndex, offsetBy: code.characters.count-1))
                    }
                    delegate?.selectKeyWord("", upc: character, truncate:true,upcs:nil)
                    return true
                }
                
                if strFieldValue.substring(to: 1).uppercased() == "B" {
                    let validateNumeric: NSString = strFieldValue.substring(from: 1) as NSString
                    if validateNumeric.doubleValue > 0 {
              
                        delegate?.selectKeyWord("", upc: textField.text!.uppercased(), truncate:false,upcs:nil)
                        return true
                    }
                }
                
            }
            
            delegate?.selectKeyWord(textField.text!, upc: nil, truncate:false,upcs: self.upcItems)
            
        } else {
            UIView.animate(withDuration: 1.0, animations: {
                self.camButton!.alpha = 1;
                self.scanButton!.alpha = 1;
                self.camLabel!.alpha = 1;
                self.scanLabel!.alpha = 1;
                self.tiresBarView!.alpha = self.tiresBarView!.tiresSearch ? 1.0 : 0.0
            })
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        var  keyword = strNSString.replacingCharacters(in: range, with: string)
        if keyword.length() > 51 {
            return false
        }
        
        if keyword.length() < 2 {
            keyword = ""
        }
        
        //self.searchProductKeywords(keyword) //por peticionwm
        self.showClearButtonIfNeeded(forTextValue: keyword)
            
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        if indexPath.section == 0 {
        //            let item = self.elements![indexPath.row] as? [String:Any]
        //            self.delegate.selectKeyWord(item![KEYWORD_TITLE_COLUMN] as NSString, upc: item!["upc"] as NSString, truncate:false)
        //        }else{
        let item = self.elementsCategories![indexPath.row] as? [String:Any]
        self.delegate?.showProducts(forDepartmentId: item!["idDepto"] as? String, andFamilyId: item!["idFamily"] as? String, andLineId: item!["idLine"] as? String, andTitleHeader:item!["title"] as! String , andSearchContextType:item!["type"] as! String == ResultObjectType.Mg.rawValue ? .withCategoryForMG: .withCategoryForGR )
        //        }
    }
    
    //func
    
    func searchProductKeywords(_ string:String) {
        self.cancelSearch = true
        
        if  string.lengthOfBytes(using: String.Encoding.utf8) < 2 {
            
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
            self.dataBase.inDatabase { (db:FMDatabase?) -> Void in
                let select = WalMartSqliteDB.instance.buildSearchProductKeywordsQuery(keyword: string)
                var load = false
                self.cancelSearch = false
                if let rs = db?.executeQuery(select, withArgumentsIn:nil) {
                    
                    var keywords = Array<[String:Any]>()
                    while rs.next() {
                        if  self.cancelSearch {
                            break
                        }
                        let keyword = rs.string(forColumn: KEYWORD_TITLE_COLUMN)
                        let upc = rs.string(forColumn: "upc")
                        let price = rs.string(forColumn: "price")
                        keywords.append([KEYWORD_TITLE_COLUMN:keyword! , "upc":upc! , "price":price!  ])
                    }// while rs.next() {
                    rs.close()
                    rs.setParentDB(nil)
                    self.elements = keywords
                    load = true;
                }
                
                if  !self.cancelSearch {
                    let selectCategories = WalMartSqliteDB.instance.buildSearchCategoriesKeywordsQuery(keyword: string)
                    self.cancelSearch = false
                    if let rs = db?.executeQuery(selectCategories, withArgumentsIn:nil) {
                        var keywords = Array<[String:Any]>()
                        
                        while rs.next() {
                            if  self.cancelSearch {
                                break
                            }
                            
                            let depto = rs.string(forColumn: "departament")
                            let family = rs.string(forColumn: "family")
                            
                            let keyword = rs.string(forColumn: KEYWORD_TITLE_COLUMN)
                            let description = "\(depto!) > \(family!)"
                            let idLine = rs.string(forColumn: "idLine")
                            let idDepto = rs.string(forColumn: "idDepto")
                            let idFamily = rs.string(forColumn: "idFamily")
                            let type = rs.string(forColumn: "type")
                            
                            keywords.append([KEYWORD_TITLE_COLUMN:keyword! , "departament":description, "idLine":idLine!, "idFamily":idFamily!, "idDepto":idDepto!, "type":type!])
                        }// while rs.next() {
                        rs.close()
                        rs.setParentDB(nil)
                        self.elementsCategories = keywords
                        load = true;
                        
                        if  !self.cancelSearch {
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
        if text.lengthOfBytes(using: String.Encoding.utf8) > 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.clearButton!.alpha = 1
                self.camButton!.alpha = 0
                self.scanButton!.alpha = 0
                self.camLabel!.alpha = 0
                self.scanLabel!.alpha = 0
                self.viewBackground!.alpha = 0
                self.tiresBarView!.alpha =  0.0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.clearButton!.alpha = 0
                self.camButton!.alpha = 1
                self.scanButton!.alpha = 1
                self.camLabel!.alpha = 1
                self.scanLabel!.alpha = 1
                self.viewBackground!.alpha = 1
                self.tiresBarView!.alpha = self.tiresBarView!.tiresSearch ? 1.0 : 0.0
            })
        }
    }
    
    func showBarCode(_ sender:UIButton) {
        if self.field!.isFirstResponder {
            self.field!.resignFirstResponder()
        }
        self.delegate?.searchControllerScanButtonClicked()
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_OPEN_BARCODE_SCANNED_UPC.rawValue, label: "")
    }
    
    func showCamera(_ sender:UIButton) {
        if self.field!.isFirstResponder {
            self.field!.resignFirstResponder()
        }
        self.delegate?.searchControllerCamButtonClicked(self)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
    }
    
    func cancel(_ sender:UIButton) {
        delegate?.closeSearch(false, sender:nil)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_SEARCH_PRODUCT.rawValue, action: WMGAIUtils.ACTION_CANCEL.rawValue, label: "")
    }
    
    // MARK: - CameraViewControllerDelegate
    func photoCaptured(_ value: String?,upcs:[String]?,done: (() -> Void)) {
        self.field!.becomeFirstResponder()
        if value != nil && value?.trim() != "" {
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }

            let params = ["upcs": upcArray!, "keyWord":value!] as [String : Any]
            NotificationCenter.default.post(name: .camFindSearch, object: params, userInfo: nil)
            done()
        }
        if value != nil {
          delegate?.closeSearch(false, sender:nil)
        }
    }
    
    func handleTap(_ recognizer:UITapGestureRecognizer){
        delegate?.closeSearch(false, sender:nil)
    }
    
    func showMessageValidation(_ message:String){
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        
        self.errorView!.frame = CGRect(x: self.field!.frame.minX - 5, y: 0, width: self.field!.frame.width, height: self.field!.frame.height )
        self.errorView!.focusError = self.field!
        if self.field!.frame.minX < 20 {
            self.errorView!.setValues(280, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRect(x: self.field!.frame.minX - 5, y: self.field!.frame.minY , width: self.errorView!.frame.width , height: self.errorView!.frame.height)
        }
        else{
            self.errorView!.setValues(field!.frame.width, strLabel:"Buscar", strValue: message)
            self.errorView!.frame =  CGRect(x: field!.frame.minX - 5, y: field!.frame.minY, width: errorView!.frame.width , height: errorView!.frame.height)
        }
        let contentView = self.field!.superview!
        contentView.addSubview(self.errorView!)
        UIView.animate(withDuration: 0.2, animations: {
            self.field!.frame = CGRect(x: 16.0, y: 15, width: 225, height: 40.0)
            self.clearButton!.frame = CGRect(x: self.field!.frame.maxX - 49 , y: self.field!.frame.midY - 20.0, width: 48, height: 40)
            //            self.scanButton!.frame = CGRectMake(CGRectGetMaxX(self.field!.frame) - 49 , self.field!.frame.midY - 20.0, 48, 40)
            
            self.errorView!.frame =  CGRect(x: self.field!.frame.minX - 5 , y: self.field!.frame.minY - self.errorView!.frame.height , width: self.errorView!.frame.width , height: self.errorView!.frame.height)
            
            }, completion: {(bool : Bool) in
                if bool {
                    self.field!.becomeFirstResponder()
                }
        })
    }
    
    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-zñÑÁáÉéÍíÓóÚú& /]{0,100}[._-]{0,2}$";
        return validateRegEx(regString,toValidate:toValidate)
    }
    
    func validateRegEx(_ pattern:String,toValidate:String) -> Bool {
        
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatches(in: toValidate, options: [], range: NSMakeRange(0, toValidate.characters.count))
        
        if matches > 0 {
            return true
        }
        return false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.view.endEditing(true)
    }
    
    func isBarCodeUPC(_ codeUPC: NSString) -> Bool {
        
        var fullBarcode = codeUPC as String
        
        if codeUPC.length == 14 {
            return false
        }
        
        if codeUPC.length < 14 {
            let toFill = "".padding(toLength: 14 - codeUPC.length, withPad: "0", startingAt: 0)
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
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
            self.tiresBarView!.frame = CGRect(x: 0, y: self.view!.frame.height - (keyboardHeight + 46), width: self.view.frame.width, height: 46)
            if self.tiresBarView!.tiresSearch {
                self.tiresBarView!.isHidden = false
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.keyboardHeight = 46.0
        self.tiresBarView!.frame = CGRect(x: 0, y: self.view!.frame.height - (keyboardHeight + 46), width: self.view.frame.width, height: 46)
        if self.tiresBarView!.tiresSearch {
            self.tiresBarView!.isHidden = false
        }
    }
}

extension SearchViewController: SearchTiresBarViewDelegate {
    func showTiresSearch() {
        delegate?.showTiresSearch()
    }
}
