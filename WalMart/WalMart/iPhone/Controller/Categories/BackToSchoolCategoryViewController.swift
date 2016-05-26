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
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    var urlTicer : String!
    var idFamily : String!
    var loading: WMLoadingView?
    var schoolsList :[[String:AnyObject]]! = [[:]]
    var filterList :[[String:AnyObject]]! = [[:]]
    var searchView: UIView!
    var clearButton : UIButton?
    var searchField: FormFieldSearch!
    var separator: CALayer!
    
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
        
        imageIcon = UIImageView()
        imageIcon.image = UIImage(named: "default")
        
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(16)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.text = ""
        
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
        self.searchField!.placeholder = "Buscar por nombre de la escuela"
        self.searchField!.backgroundColor = WMColor.light_light_gray
        self.searchField!.delegate = self
        self.searchView.addSubview(self.searchField)
        
        self.clearButton = UIButton(type: .Custom)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Normal)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Highlighted)
        self.clearButton!.setImage(UIImage(named:"searchClear"), forState: .Selected)
        self.clearButton!.addTarget(self, action: #selector(StoreLocatorViewController.clearSearch), forControlEvents: UIControlEvents.TouchUpInside)
        self.clearButton!.hidden = true
        self.searchField!.addSubview(self.clearButton!)
        
        self.view.addSubview(imageBackground)
        self.view.addSubview(imageIcon)
        self.view.addSubview(titleLabel)
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
        self.imageBackground.frame = CGRectMake(0,0 ,self.view.frame.width , CELL_HEIGHT)
        self.titleLabel.frame = CGRectMake(0, 66, self.view.frame.width , 16)
        self.imageIcon.frame = CGRectMake((self.view.frame.width / 2) - 14, 22 , 28, 28)
        self.buttonClose.frame = CGRectMake(0, 0, 40, 40)
        self.searchView.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.frame.width, 72)
        self.separator.frame = CGRectMake(0, self.searchView!.bounds.maxY - 1, self.view.frame.width, 1)
        self.searchField.frame = CGRectMake(16, 16, self.view.frame.width - 32, 40.0)
        self.clearButton!.frame = CGRectMake(self.searchField.frame.width - 40 , 0, 48, 40)
        self.schoolsTable.frame = CGRectMake(0, self.searchView!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.searchView!.frame.maxY)
    }
    
    
    /**
     Call family by category service
     */
    func invokeServiceFamilyByCategory(){
        let service =  FamilyByCategoryService()
        service.buildParams("d-lp-bts-listas-utiles")
        
        service.callService(requestParams: ["id":self.idFamily], successBlock: { (response:NSDictionary) -> Void in
            let schools  =  response["responseArray"] as! NSArray
            self.schoolsList = schools as? [[String : AnyObject]]
            self.filterList = self.schoolsList
            self.schoolsTable.reloadData()
            self.loading!.stopAnnimating()
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
        cell.showSeparator =  true
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let school = self.filterList![indexPath.row]
        let gradesController = GradesListViewController()
        gradesController.familyName = school["id"] as! String
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
        
        self.filterList = self.searchForItems(txtAfterUpdate as String)
        self.schoolsTable!.reloadData()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func searchForItems(textUpdate:String) -> [[String:AnyObject]]? {
        if textUpdate == "" {
            self.clearButton?.hidden = true
            return self.schoolsList
        }
        self.clearButton?.hidden = false
        let filterList = self.schoolsList.filter({ (catego) -> Bool in
            return (catego["name"] as! String).lowercaseString.containsString(textUpdate.lowercaseString)})
        
        return filterList
    }
    
    func clearSearch(){
        self.searchField!.text = ""
        self.searchField.layer.borderColor = WMColor.light_light_gray.CGColor
        self.clearButton?.hidden = true
        self.filterList = self.schoolsList
        self.schoolsTable!.reloadData()
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