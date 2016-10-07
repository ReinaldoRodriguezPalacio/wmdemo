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
    var isPresentView = false
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

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREFERENCES_CATEGORY.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if !IS_IPAD {
            self.titleLabel!.frame.origin.x = 30
        }
        
        self.titleLabel!.text = NSLocalizedString("preferences.title.Category", comment: "")
        
        tableCategories = UITableView()
        tableCategories.dataSource = self
        tableCategories.delegate = self
        
        tableCategories.registerClass(CategoryInterestTableViewCell.self, forCellReuseIdentifier: "CategoryInterestCell")
        tableCategories.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.view.addSubview(tableCategories)
        
        self.checkAllButton = UIButton()
        
        self.checkAllButton?.setTitle(NSLocalizedString("preferences.category.all.button",comment:""), forState: UIControlState.Normal)
        self.checkAllButton!.setImage(UIImage(named:"filter_check_gray"), forState: UIControlState.Normal)
        self.checkAllButton!.setImage(UIImage(named:"check_blue"), forState: UIControlState.Selected)
        self.checkAllButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.checkAllButton!.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        self.checkAllButton?.addTarget(self, action: #selector(InterestCategoryController.markAllInterestCategories(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.checkAllButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.checkAllButton!.titleEdgeInsets = UIEdgeInsetsMake(2, 5, 0, 0);
        self.header?.addSubview(self.checkAllButton!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view!.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("profile.save", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(InterestCategoryController.savePreferences(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
        
        tableHeaderView = UIView()
        headerLabel = UILabel()
        headerLabel!.numberOfLines = 2
        headerLabel!.lineBreakMode = .ByWordWrapping
        headerLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        headerLabel!.textColor = WMColor.reg_gray
        headerLabel!.text = NSLocalizedString("preferences.category.headerTitle", comment:"")
        tableHeaderView!.addSubview(headerLabel!)

        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
        
        loadPreferences()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.titleLabel!.frame = CGRectMake(5, 1, self.header!.frame.width - 92, self.header!.frame.maxY)
        self.checkAllButton!.frame = CGRectMake(self.header!.frame.width - 70, 1, 60, 46)
        checkAllButton!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        checkAllButton!.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        checkAllButton!.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
        self.layerLineHeader = CALayer()
        layerLineHeader.backgroundColor = WMColor.light_light_gray.CGColor
        self.tableHeaderView!.layer.insertSublayer(layerLineHeader, atIndex: 1000)
        
        self.tableHeaderView!.frame = CGRectMake(0, 0,  self.view.frame.width, 46)
        self.headerLabel!.frame = CGRectMake(16, 0,  self.view.frame.width - 32, 46)
        self.layerLineHeader.frame = CGRectMake(0, self.tableHeaderView!.frame.height - 1,  self.tableHeaderView!.frame.width, 1)
        self.tableCategories.tableHeaderView = tableHeaderView
        
        if !isPresentView {
            self.layerLine.frame = CGRectMake(0, self.view.frame.height - 66,  self.view.frame.width, 1)
            self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148, self.view.frame.height - 50, 140, 34)
            self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.view.frame.height - 50, 140, 34)
            self.tableCategories.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.frame.height - 112)
            isPresentView = true
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willShowTabbar() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.layerLine.frame = CGRectMake(0, self.view.frame.height - 112,  self.view.frame.width, 1)
            self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148, self.view.frame.height - 96, 140, 34)
            self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.view.frame.height - 96, 140, 34)
            self.tableCategories.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.frame.height - 158)
        })
    }
    
    override func willHideTabbar() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.layerLine.frame = CGRectMake(0, self.view.frame.height - 66,  self.view.frame.width, 1)
            self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148, self.view.frame.height - 50, 140, 34)
            self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.view.frame.height - 50, 140, 34)
            self.tableCategories.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.frame.height - 112)
        })
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            let bounds = IS_IPAD ? CGRectMake(0, 0, 341, 705) : self.view.bounds
            viewLoad = WMLoadingView(frame: bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
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
    
    func savePreferences(sender:UIButton) {
        self.addViewLoad()
        self.invokeSavepeferences()
    }
    
    private func invokePreferenceService(){
        
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:NSDictionary) in
            self.userPreferences.addEntriesFromDictionary(result as [NSObject : AnyObject])
            let categories = result["categories"] as! NSArray
            let userPreferencesCategories = result["userPreferences"] as! NSArray
            
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
            
            self.interestCategories.sortInPlace({ $0.categoryDescription < $1.categoryDescription })
            self.tableCategories.reloadData()
            self.removeViewLoad()
            
        }, errorBlock: { (error:NSError) in
            let alertView = IPOWMAlertViewController.showAlert(UIImage(named:"alert_ups"),imageDone:UIImage(named:"alert_ups"),imageError:UIImage(named:"alert_ups"))
            alertView!.setMessage("Error al guardar tus preferencias, intenta más tarde.")
            alertView!.showErrorIcon("Ok")
            self.removeViewLoad()
            print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    private func invokeSavepeferences(){
        
        // TODO preguntar por valor:: acceptConsent
        
        let peferencesService = SetPreferencesService()
        let params = peferencesService.buildParams(self.getSelectedInterestCategories(), onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as! String, abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.userPreferences["receivePromoEmail"] as! String, forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: true, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
        peferencesService.jsonFromObject(params)
        peferencesService.callService(requestParams:params , successBlock: { (result:NSDictionary) in
            print("Preferencias Guardadas")
            self.invokePreferenceService()
            self.removeViewLoad()
        }, errorBlock: { (error:NSError) in
            print("Hubo un error al guardar las Preferencias")
            self.removeViewLoad()
        })
        
    }
    
    private func getSelectedInterestCategories()-> [String] {
        
        let interestCategoriesPreferences = self.interestCategories.filter({$0.isSelected == true})
        var filteredCategories = [String]()
        
        for category in interestCategoriesPreferences {
            filteredCategories.append(category.categoryDescription)
        }
        
        return filteredCategories
    }
    
    func markInterestCategory(sender:UIButton) {
        
        interestCategories[sender.tag].isSelected = !interestCategories[sender.tag].isSelected
        sender.selected = !sender.selected
        
        if self.interestCategories.filter({$0.isSelected}).count == self.interestCategories.count {
            self.checkAllButton!.selected = true
        } else {
            self.checkAllButton!.selected = false
        }
        
    }
    
    func markAllInterestCategories(sender:UIButton) {
        
        self.checkAllButton!.selected = !self.checkAllButton!.selected
        
        var interestTemporalCategories = [InterestCategory]()
        
        for var interestCategory in interestCategories {
            interestCategory.isSelected = self.checkAllButton!.selected ? true : false
            interestTemporalCategories.append(interestCategory)
        }
        
        interestCategories = interestTemporalCategories
        
        self.tableCategories.reloadData()
    }
    
    // MARK: - TableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interestCategories.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableCategories.dequeueReusableCellWithIdentifier("CategoryInterestCell") as! CategoryInterestTableViewCell
        let interestCategory = interestCategories[indexPath.row]
        
        cell.categoryButton!.setTitle(interestCategory.categoryDescription, forState: .Normal)
        cell.categoryButton!.selected = interestCategory.isSelected
        cell.categoryButton!.addTarget(self, action: #selector(InterestCategoryController.markInterestCategory(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.categoryButton!.tag = indexPath.row
        
        return cell
    }
    
}

