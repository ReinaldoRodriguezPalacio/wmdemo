//
//  BackToSchoolCategoryViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 25/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class BackToSchoolCategoryViewController: IPOCategoriesViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    var schoolsTable : UITableView!
    var buttonClose : UIButton!
    var imageBackground : UIImageView!
    var urlTicer : String!
    var departmentId : String!
    var loading: WMLoadingView?
    var schoolsList :[[String:AnyObject]]! = [[:]]
    var filterList :[[String:AnyObject]]! = [[:]]
    var searchView: UIView!
    var clearButton : UIButton?
    var searchField: FormFieldSearch!
    var errorView: FormFieldErrorView?
    var separator: CALayer!
    var searchFieldSpace: CGFloat = 0.0
    var startView: CGFloat = 0.0
    
    override func viewDidLoad() {
        self.view.backgroundColor =  UIColor.whiteColor()
        
        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.Left
        imageBackground.clipsToBounds = true
        
        self.imageBackground.setImageWithURL(NSURL(string: "http://\(urlTicer)"), placeholderImage:UIImage(named: "header_default"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageBackground.image = image
        }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
            print("Error al presentar imagen")
        }
        
        buttonClose = UIButton()
        buttonClose.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: #selector(BaseCategoryViewController.closeDepartment), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.searchView = UIView(frame: CGRectMake(0, self.imageBackground!.frame.maxY, self.view.frame.width, 72))
        self.searchView.backgroundColor = UIColor.whiteColor()
        
        self.separator = CALayer()
        self.separator.backgroundColor = WMColor.light_light_gray.CGColor
        self.separator.frame = CGRectMake(0, self.searchView!.frame.maxY - 1, self.view.frame.width, 1)
        self.searchView.layer.insertSublayer(separator, atIndex: 0)
        
        self.searchField = FormFieldSearch(frame: CGRectMake(16, 16, self.view.frame.width - 32, 40.0))
        self.searchField!.returnKeyType = .Search
        self.searchField!.autocapitalizationType = .None
        self.searchField!.autocorrectionType = .No
        self.searchField!.enablesReturnKeyAutomatically = true
        self.searchField!.placeholder = "Buscar por nombre de escuela"
        self.searchField!.backgroundColor = WMColor.light_light_gray
        self.searchField!.delegate = self
        self.searchView.addSubview(self.searchField)
        
        self.clearButton = UIButton(type: .Custom)
        self.clearButton!.setTitle("Cancelar", forState: .Normal)
        self.clearButton!.setTitleColor(WMColor.light_blue, forState: .Normal)
        self.clearButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.clearButton!.addTarget(self, action: #selector(StoreLocatorViewController.clearSearch), forControlEvents: UIControlEvents.TouchUpInside)
        self.clearButton!.alpha = 0.0
        self.searchView!.addSubview(self.clearButton!)
        
        self.view.addSubview(imageBackground)
        self.view.addSubview(buttonClose)
        self.view.addSubview(searchView)
        
        self.schoolsTable = UITableView()
        self.schoolsTable.delegate = self
        self.schoolsTable.dataSource = self
        self.schoolsTable.registerClass(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        self.schoolsTable.separatorStyle = .None
        self.view.addSubview(self.schoolsTable)
        self.invokeServiceFamilyByCategory()
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        self.imageBackground.frame = CGRectMake(0,startView ,self.view.frame.width , CELL_HEIGHT)
        self.buttonClose.frame = CGRectMake(0, startView, 40, 40)
        self.searchView.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.frame.width, 72)
        self.separator.frame = CGRectMake(0, self.searchView!.bounds.maxY - 1, self.view.frame.width, 1)
        self.clearButton!.frame = CGRectMake(self.searchView.frame.width - self.searchFieldSpace, 16, 55, 40)
        self.searchField.frame = CGRectMake(16, 16, self.view.frame.width - (self.searchFieldSpace + 32), 40.0)
        self.schoolsTable.frame = CGRectMake(0, self.searchView!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.searchView!.frame.maxY)
    }
    
    
    /**
     Call family by category service
     */
    func invokeServiceFamilyByCategory(){
        let service =  FamilyByCategoryService()
        service.callService(requestParams: ["id":self.departmentId], successBlock: { (response:NSDictionary) -> Void in
            let schools  =  response["responseArray"] as! NSArray
            self.schoolsList = schools as? [[String : AnyObject]]
            self.filterList = self.schoolsList
            self.schoolsTable.reloadData()
            self.loading?.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
   //MARK: TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterList!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let school = self.filterList![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("lineCell", forIndexPath: indexPath) as! IPOLineTableViewCell
        cell.titleLabel?.text = school["name"] as? String
        cell.showSeparator = true
        cell.oneLine =  true
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let school = self.filterList![indexPath.row]
        let gradesController = GradesListViewController()
        gradesController.departmentId = self.departmentId
        gradesController.familyId = school["id"] as! String
        gradesController.schoolName = school["name"] as! String
        self.navigationController?.pushViewController(gradesController, animated: true)
    }
    
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        if txtAfterUpdate.length >= 25 {
            return false
        }
        
        if self.validateSearch(txtAfterUpdate as String) {
            self.filterList = self.searchForItems(txtAfterUpdate as String)
            self.schoolsTable!.reloadData()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.showImageHeader(false)
        self.showClearSearchButton(true)
        self.searchField.layer.borderColor = WMColor.light_blue.CGColor
        self.searchField.layer.borderWidth = 0.5
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.searchField.layer.borderColor = WMColor.light_light_gray.CGColor
        self.searchField.layer.borderWidth = 0.0
        if textField.text == "" {
          self.showClearSearchButton(false)
        }
    }
    
    func searchForItems(textUpdate:String) -> [[String:AnyObject]]? {
        if textUpdate == "" {
            return self.schoolsList
        }
        let filterList = self.schoolsList.filter({ (catego) -> Bool in
            return (catego["name"] as! String).lowercaseString.containsString(textUpdate.lowercaseString)})
        
        return filterList
    }
    
    //MARK: Animations
    func showImageHeader(didShow:Bool) {
        if didShow {
            self.startView = 0.0
            UIView.animateWithDuration(0.3, animations: {() in
                self.imageBackground.frame = CGRectMake(0,0 ,self.view.frame.width , 98)
                self.buttonClose.frame = CGRectMake(0, 0, 40, 40)
                self.searchView.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.frame.width, 72)
                self.schoolsTable.frame = CGRectMake(0, self.searchView!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.searchView!.frame.maxY)
            })
        }else{
            self.startView = -98
            UIView.animateWithDuration(0.3, animations: {
                self.imageBackground.frame = CGRectMake(0,self.startView,self.view.frame.width , 98)
                self.buttonClose.frame = CGRectMake(0, self.startView, 40, 40)
                self.searchView.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.frame.width, 72)
                self.schoolsTable.frame = CGRectMake(0, self.searchView!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.searchView!.frame.maxY)
                }, completion: {(finish) in
            })
        }
    }
    
    func showClearSearchButton(didShow:Bool){
        if didShow{
            self.searchFieldSpace = 71
            UIView.animateWithDuration(0.3, animations: {() in
                self.clearButton!.alpha = 1.0
                self.clearButton!.frame = CGRectMake(self.searchView.frame.width - self.searchFieldSpace, 16, 55, 40)
                self.searchField.frame = CGRectMake(16, 16, self.view.frame.width - (self.searchFieldSpace + 32), 40.0)
            })
        }else{
            self.searchFieldSpace = 0
            UIView.animateWithDuration(0.3, animations: {() in
                self.clearButton!.alpha = 0.0
                self.clearButton!.frame = CGRectMake(self.searchView.frame.width - self.searchFieldSpace, 16, 55, 40)
                self.searchField.frame = CGRectMake(16, 16, self.view.frame.width - (self.searchFieldSpace + 32), 40.0)
            })
        }
        
    }
    
   override func willHideTabbar() {
        super.willHideTabbar()
        self.showImageHeader(false)
    }
    
    override func willShowTabbar() {
        super.willShowTabbar()
        self.showImageHeader(true)
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
            if self.errorView?.superview != nil {
                self.errorView?.removeFromSuperview()
            }
            self.errorView?.focusError = nil
            self.errorView = nil
            return true
        }
        
        if self.errorView == nil{
            self.errorView = FormFieldErrorView()
        }
        SignUpViewController.presentMessage(self.searchField!, nameField:"Busqueda", message: "Texto no permitido" , errorView:self.errorView! , becomeFirstResponder: true)
        
        return false
    }
    
    func clearSearch(){
        self.searchField!.text = ""
        self.searchField.resignFirstResponder()
        self.searchField.layer.borderColor = WMColor.light_light_gray.CGColor
        self.filterList = self.schoolsList
        self.schoolsTable!.reloadData()
        self.showImageHeader(true)
        self.showClearSearchButton(false)
    }

    //MARK: ScrollViewDelegate
    override func scrollViewWillBeginDragging(scrollView: UIScrollView){
        self.searchField.resignFirstResponder()
    }
    
    /**
     Return to home
     */
    override func closeDepartment() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}