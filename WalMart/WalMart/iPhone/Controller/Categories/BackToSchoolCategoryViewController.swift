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
        self.view.backgroundColor =  UIColor.white
        
        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.scaleAspectFill
        imageBackground.clipsToBounds = true
        
        self.imageBackground.setImageWith(URL(string: "http://\(urlTicer)"), placeholderImage:UIImage(named: "header_default"), success: { (request:URLRequest!, response:HTTPURLResponse!, image:UIImage!) -> Void in
            self.imageBackground.image = image
        }) { (request:URLRequest!, response:HTTPURLResponse!, error:NSError!) -> Void in
            print("Error al presentar imagen")
        }
        
        buttonClose = UIButton()
        buttonClose.setImage(UIImage(named: "close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(BaseCategoryViewController.closeDepartment), for: UIControlEvents.touchUpInside)
        
        self.searchView = UIView(frame: CGRect(x: 0, y: self.imageBackground!.frame.maxY, width: self.view.frame.width, height: 72))
        self.searchView.backgroundColor = UIColor.white
        
        self.separator = CALayer()
        self.separator.backgroundColor = WMColor.light_light_gray.cgColor
        self.separator.frame = CGRect(x: 0, y: self.searchView!.frame.maxY - 1, width: self.view.frame.width, height: 1)
        self.searchView.layer.insertSublayer(separator, at: 0)
        
        self.searchField = FormFieldSearch(frame: CGRect(x: 16, y: 22, width: self.view.frame.width - 32, height: 40.0))
        self.searchField!.returnKeyType = .search
        self.searchField!.autocapitalizationType = .none
        self.searchField!.autocorrectionType = .no
        self.searchField!.enablesReturnKeyAutomatically = true
        self.searchField!.placeholder = "Buscar por nombre de escuela"
        self.searchField!.backgroundColor = WMColor.light_light_gray
        self.searchField!.delegate = self
        self.searchView.addSubview(self.searchField)
        
        self.clearButton = UIButton(type: .custom)
        self.clearButton!.setTitle("Cancelar", for: UIControlState())
        self.clearButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
        self.clearButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.clearButton!.addTarget(self, action: #selector(StoreLocatorViewController.clearSearch), for: UIControlEvents.touchUpInside)
        self.clearButton!.alpha = 0.0
        self.searchView!.addSubview(self.clearButton!)
        
        self.view.addSubview(imageBackground)
        self.view.addSubview(buttonClose)
        self.view.addSubview(searchView)
        
        self.schoolsTable = UITableView()
        self.schoolsTable.delegate = self
        self.schoolsTable.dataSource = self
        self.schoolsTable.register(IPOLineTableViewCell.self, forCellReuseIdentifier: "lineCell")
        self.schoolsTable.separatorStyle = .none
        self.view.addSubview(self.schoolsTable)
        self.invokeServiceFamilyByCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        self.imageBackground.frame = CGRect(x: 0,y: startView ,width: self.view.frame.width , height: CELL_HEIGHT)
        self.buttonClose.frame = CGRect(x: 0, y: startView, width: 40, height: 40)
        self.searchView.frame = CGRect(x: 0, y: self.imageBackground!.frame.maxY, width: self.view.frame.width, height: 84)
        self.separator.frame = CGRect(x: 0, y: self.searchView!.bounds.maxY - 1, width: self.view.frame.width, height: 1)
        self.clearButton!.frame = CGRect(x: self.searchView.frame.width - self.searchFieldSpace, y: 22, width: 55, height: 40)
        self.searchField.frame = CGRect(x: 16, y: 22, width: self.view.frame.width - (self.searchFieldSpace + 32), height: 40.0)
        self.schoolsTable.frame = CGRect(x: 0, y: self.searchView!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.searchView!.frame.maxY)
    }
    
    
    /**
     Call family by category service
     */
    func invokeServiceFamilyByCategory(){
        let service =  FamilyByCategoryService()
        service.callService(requestParams: ["id":self.departmentId as AnyObject], successBlock: { (response:NSDictionary) -> Void in
            let schools  =  response["responseArray"] as! NSArray
            self.schoolsList = schools as? [[String : AnyObject]]
            self.filterList = self.schoolsList
            self.schoolsTable.reloadData()
            self.loading?.stopAnnimating()
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
   //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterList!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let school = self.filterList![(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath) as! IPOLineTableViewCell
        cell.titleLabel?.text = school["name"] as? String
        cell.showSeparator = true
        cell.oneLine =  true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let school = self.filterList![(indexPath as NSIndexPath).row]
        let gradesController = GradesListViewController()
        gradesController.departmentId = self.departmentId
        gradesController.familyId = school["id"] as! String
        gradesController.schoolName = school["name"] as! String
        self.navigationController?.pushViewController(gradesController, animated: true)
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
        if txtAfterUpdate.length >= 25 {
            return false
        }
        
        if self.validateSearch(txtAfterUpdate as String) {
            self.filterList = self.searchForItems(txtAfterUpdate as String)
            self.schoolsTable!.reloadData()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.showImageHeader(false)
        self.showClearSearchButton(true)
        self.searchField.layer.borderColor = WMColor.light_blue.cgColor
        self.searchField.layer.borderWidth = 0.5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchField.layer.borderColor = WMColor.light_light_gray.cgColor
        self.searchField.layer.borderWidth = 0.0
        if textField.text == "" {
          self.showClearSearchButton(false)
        }
    }
    
    /**
     Filters school results by text
     
     - parameter textUpdate: text by searching
     
     - returns: Array of Schools
     */
    func searchForItems(_ textUpdate:String) -> [[String:AnyObject]]? {
        if textUpdate == "" {
            return self.schoolsList
        }
        let filterList = self.schoolsList.filter({ (catego) -> Bool in
            return (catego["name"] as! String).lowercased().contains(textUpdate.lowercased())})
        
        return filterList
    }
    
    //MARK: Animations
    /**
     Show or hides image Header
     
     - parameter didShow: Bool
     */
    func showImageHeader(_ didShow:Bool) {
        if didShow {
            self.startView = 0.0
            UIView.animate(withDuration: 0.3, animations: {() in
                self.imageBackground.frame = CGRect(x: 0,y: 0 ,width: self.view.frame.width , height: 98)
                self.buttonClose.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                self.searchView.frame = CGRect(x: 0, y: self.imageBackground!.frame.maxY, width: self.view.frame.width, height: 72)
                self.schoolsTable.frame = CGRect(x: 0, y: self.searchView!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.searchView!.frame.maxY)
            })
        }else{
            self.startView = -98
            UIView.animate(withDuration: 0.3, animations: {
                self.imageBackground.frame = CGRect(x: 0,y: self.startView,width: self.view.frame.width , height: 98)
                self.buttonClose.frame = CGRect(x: 0, y: self.startView, width: 40, height: 40)
                self.searchView.frame = CGRect(x: 0, y: self.imageBackground!.frame.maxY, width: self.view.frame.width, height: 72)
                self.schoolsTable.frame = CGRect(x: 0, y: self.searchView!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.searchView!.frame.maxY)
                }, completion: {(finish) in
            })
        }
    }
    
    /**
     Shows or hides cancel button in searchView
     
     - parameter didShow: Bool
     */
    func showClearSearchButton(_ didShow:Bool){
        if didShow{
            self.searchFieldSpace = 71
            UIView.animate(withDuration: 0.3, animations: {() in
                self.clearButton!.alpha = 1.0
                self.clearButton!.frame = CGRect(x: self.searchView.frame.width - self.searchFieldSpace, y: 22, width: 55, height: 40)
                self.searchField.frame = CGRect(x: 16, y: 22, width: self.view.frame.width - (self.searchFieldSpace + 32), height: 40.0)
            })
        }else{
            self.searchFieldSpace = 0
            UIView.animate(withDuration: 0.3, animations: {() in
                self.clearButton!.alpha = 0.0
                self.clearButton!.frame = CGRect(x: self.searchView.frame.width - self.searchFieldSpace, y: 22, width: 55, height: 40)
                self.searchField.frame = CGRect(x: 16, y: 22, width: self.view.frame.width - (self.searchFieldSpace + 32), height: 40.0)
            })
        }
        
    }
    
    /**
     Hides tap bar and hides image header
     */
   override func willHideTabbar() {
        super.willHideTabbar()
        self.showImageHeader(false)
    }
    
    /**
     Shows tap bar and hiddes image header
     */
    override func willShowTabbar() {
        super.willShowTabbar()
        self.showImageHeader(true)
    }
    
    /**
     Validates search text with regular expression
     
     - parameter toValidate: text to validate
     
     - returns: true or false if the expression is valid
     */
    func validateSearch(_ toValidate:String) -> Bool{
        let regString : String = "^[A-Z0-9a-zñÑÁáÉéÍíÓóÚú ]{0,100}[._-]{0,2}$";
        return validateRegEx(regString,toValidate:toValidate)
    }
    
    /**
     Validates text with a regular expression
     
     - parameter pattern:    regular expression
     - parameter toValidate: text to validate
     
     - returns: true or false if the expression is valid
     */
    func validateRegEx(_ pattern:String,toValidate:String) -> Bool {
        
        var regExVal: NSRegularExpression?
        do {
            regExVal = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            regExVal = nil
        }
        let matches = regExVal!.numberOfMatches(in: toValidate, options: [], range: NSMakeRange(0, toValidate.characters.count))
        
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
    
    /**
     Clear search field
     */
    func clearSearch(){
        self.searchField!.text = ""
        self.searchField.resignFirstResponder()
        self.searchField.layer.borderColor = WMColor.light_light_gray.cgColor
        self.filterList = self.schoolsList
        self.schoolsTable!.reloadData()
        self.showImageHeader(true)
        self.showClearSearchButton(false)
    }

    //MARK: ScrollViewDelegate
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.searchField.resignFirstResponder()
    }
    
    /**
     Return to home
     */
    override func closeDepartment() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
