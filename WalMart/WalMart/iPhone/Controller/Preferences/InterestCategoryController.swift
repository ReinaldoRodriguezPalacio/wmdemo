//
//  InterestCategoryController.swift
//  WalMart
//
//  Created by Jesus Santa Olalla on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import UIKit

class InterestCategoryController: NavigationViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct InterestCategory {
        var categoryDescription = ""
        var categoryId = ""
        var isSelected = false
    }
    
    var interestCategories = [InterestCategory]()
    var selectedInterestCategories = [String]()
    var userPreferences: NSMutableDictionary = [:]
    
    var viewLoad: WMLoadingView!
    var tableCategories: UITableView!
    var checkAllButton: UIButton? = nil
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var layerLineHeader: CALayer!
    var tableHeaderView: UIView?
    var headerLabel: UILabel?
    var alertView: IPOWMAlertViewController?

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREFERENCES_CATEGORY.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        if !IS_IPAD {
            self.titleLabel!.frame.origin.x = 30
        }
        
        self.titleLabel!.text = NSLocalizedString("preferences.title.Category", comment: "")
        
        tableCategories = UITableView()
        tableCategories.dataSource = self
        tableCategories.delegate = self
        
        tableCategories.register(CategoryInterestTableViewCell.self, forCellReuseIdentifier: "CategoryInterestCell")
        tableCategories.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.view.addSubview(tableCategories)
        
        self.checkAllButton = UIButton()
        
        self.checkAllButton?.setTitle(NSLocalizedString("preferences.category.all.button",comment:""), for: UIControlState())
        self.checkAllButton!.setImage(UIImage(named:"filter_check_gray"), for: UIControlState())
        self.checkAllButton!.setImage(UIImage(named:"check_blue"), for: UIControlState.selected)
        self.checkAllButton!.titleLabel?.font = IS_IPAD ?  WMFont.fontMyriadProRegularOfSize(14) : WMFont.fontMyriadProRegularOfSize(12)
        self.checkAllButton!.setTitleColor(WMColor.light_blue, for: UIControlState())
        self.checkAllButton?.addTarget(self, action: #selector(InterestCategoryController.markAllInterestCategories(_:)), for: UIControlEvents.touchUpInside)
        self.checkAllButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.checkAllButton!.titleEdgeInsets = UIEdgeInsetsMake(2, 8, 0, 0)
        self.checkAllButton?.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0)
        self.header?.addSubview(self.checkAllButton!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view!.layer.insertSublayer(layerLine, at: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), for: UIControlEvents.touchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(InterestCategoryController.savePreferences(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveButton!)
        
        tableHeaderView = UIView()
        headerLabel = UILabel()
        headerLabel!.numberOfLines = 2
        headerLabel!.lineBreakMode = .byWordWrapping
        headerLabel!.font = IS_IPAD ?  WMFont.fontMyriadProRegularOfSize(14) : WMFont.fontMyriadProRegularOfSize(12)
        headerLabel!.textColor = WMColor.reg_gray
        headerLabel!.text = NSLocalizedString("preferences.category.headerTitle", comment:"")
        tableHeaderView!.addSubview(headerLabel!)
        
        loadPreferences()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.titleLabel!.frame = CGRect(x: 5, y: 1, width: self.header!.frame.width - 92, height: self.header!.frame.maxY)
        self.checkAllButton!.frame = CGRect(x: self.header!.frame.width - 80, y: 1, width: 80, height: 46)
        checkAllButton!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        checkAllButton!.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        checkAllButton!.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        
        self.layerLineHeader = CALayer()
        layerLineHeader.backgroundColor = WMColor.light_light_gray.cgColor
        self.tableHeaderView!.layer.insertSublayer(layerLineHeader, at: 1000)
        
        self.tableHeaderView!.frame = CGRect(x: 0, y: 0,  width: self.view.frame.width, height: 46)
        self.headerLabel!.frame = CGRect(x: 16, y: 0,  width: self.view.frame.width - 32, height: 46)
        self.layerLineHeader.frame = CGRect(x: 0, y: self.tableHeaderView!.frame.height - 1,  width: self.tableHeaderView!.frame.width, height: 1)
        self.tableCategories.tableHeaderView = tableHeaderView
        
        if TabBarHidden.isTabBarHidden || IS_IPAD {
            self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 66,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 50, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 50, width: 140, height: 34)
            self.tableCategories.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.frame.height - 112)
        } else {
            self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 112,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 96, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 96, width: 140, height: 34)
            self.tableCategories.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.frame.height - 158)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willShowTabbar() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 112,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 96, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 96, width: 140, height: 34)
            self.tableCategories.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.frame.height - 158)
        })
    }
    
    override func willHideTabbar() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.layerLine.frame = CGRect(x: 0, y: self.view.frame.height - 66,  width: self.view.frame.width, height: 1)
            self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: self.view.frame.height - 50, width: 140, height: 34)
            self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 , y: self.view.frame.height - 50, width: 140, height: 34)
            self.tableCategories.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.frame.height - 112)
        })
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRect(x: 0, y: 0, width: 341, height: 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.white
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    // MARK: - Get / Set Preferences
    
    func loadPreferences() {
        self.addViewLoad()
        invokePreferenceService()
    }
    
    func savePreferences(_ sender:UIButton) {
        self.invokeSavepeferences()
    }
    
    fileprivate func invokePreferenceService(){
        
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:[String:Any]) in
            
            self.userPreferences.addEntries(from: result)
            let categories = result["categories"] as! [[String:Any]]
            let userPreferencesCategories = result["userPreferences"] as! [[String:Any]]
            
            self.selectedInterestCategories = [String]()
            self.interestCategories = [InterestCategory]()
            
            for category in userPreferencesCategories {
                self.selectedInterestCategories.append(category as! String)
            }
            
            var newCategory = InterestCategory()
            
            for category in categories {
                newCategory = InterestCategory()
                newCategory.categoryId = category["idDepto"] as! String
                newCategory.categoryDescription = category["description"] as! String
                if self.selectedInterestCategories.contains(newCategory.categoryDescription) {
                    newCategory.isSelected = true
                }
                self.interestCategories.append(newCategory)
            }
            
            self.interestCategories.sort(by: { $0.categoryDescription < $1.categoryDescription })
            self.tableCategories.reloadData()
            self.removeViewLoad()
            
            self.alertView?.setMessage(NSLocalizedString("preferences.message.saved", comment:""))
            self.alertView?.showDoneIcon()
            
        }, errorBlock: { (error:NSError) in
            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"alert_ups"),imageDone:UIImage(named:"alert_ups"),imageError:UIImage(named:"alert_ups"))
            alertView!.setMessage(NSLocalizedString("preferences.message.errorLoad", comment:""))
            alertView!.showErrorIcon("Ok")
            self.removeViewLoad()
            print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    fileprivate func invokeSavepeferences(){
        
        // TODO preguntar por valor:: acceptConsent
        
        let peferencesService = SetPreferencesService()
        let params = peferencesService.buildParams(self.getSelectedInterestCategories() as [String], onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as? String ?? "", abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.userPreferences["receivePromoEmail"] as! String, forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: true, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
        peferencesService.jsonFromObject(params as AnyObject!)
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"icon_alert_saving"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"alert_ups"))
        self.alertView!.setMessage(NSLocalizedString("preferences.message.saving", comment:""))
            
        peferencesService.callService(requestParams:params as AnyObject , successBlock: { (result:[String:Any]) in
            print("Preferencias Guardadas")
            
            self.invokePreferenceService()
        }, errorBlock: { (error:NSError) in
            print("Hubo un error al guardar las Preferencias")
            self.alertView!.setMessage(NSLocalizedString("preferences.message.errorSave", comment:""))
            self.alertView!.showErrorIcon("Ok")
        })
        
    }
    
    fileprivate func getSelectedInterestCategories()-> [String] {
        
        let interestCategoriesPreferences = self.interestCategories.filter({$0.isSelected == true})
        var filteredCategories = [String]()
        
        for category in interestCategoriesPreferences {
            filteredCategories.append(category.categoryDescription)
        }
        
        return filteredCategories
    }
    
    func markInterestCategory(_ sender:UIButton) {
        
        interestCategories[sender.tag].isSelected = !interestCategories[sender.tag].isSelected
        sender.isSelected = !sender.isSelected
        
        if self.interestCategories.filter({$0.isSelected}).count == self.interestCategories.count {
            self.checkAllButton!.isSelected = true
        } else {
            self.checkAllButton!.isSelected = false
        }
        
    }
    
    func markAllInterestCategories(_ sender:UIButton) {
        
        self.checkAllButton!.isSelected = !self.checkAllButton!.isSelected
        
        var interestTemporalCategories = [InterestCategory]()
        
        for var interestCategory in interestCategories {
            interestCategory.isSelected = self.checkAllButton!.isSelected ? true : false
            interestTemporalCategories.append(interestCategory)
        }
        
        interestCategories = interestTemporalCategories
        
        self.tableCategories.reloadData()
    }
    
    // MARK: - TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interestCategories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableCategories.dequeueReusableCell(withIdentifier: "CategoryInterestCell") as! CategoryInterestTableViewCell
        let interestCategory = interestCategories[(indexPath as NSIndexPath).row]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.categoryButton!.setTitle(interestCategory.categoryDescription, for: UIControlState())
        cell.categoryButton!.isSelected = interestCategory.isSelected
        cell.categoryButton!.addTarget(self, action: #selector(InterestCategoryController.markInterestCategory(_:)), for: UIControlEvents.touchUpInside)
        cell.categoryButton!.tag = (indexPath as NSIndexPath).row
        
        return cell
    }
    
}

