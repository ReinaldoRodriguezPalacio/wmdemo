//
//  PreferencesController.swift
//  WalMart
//
//  Created by Joel Juarez on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

enum PreferenceOptionsController : String {
    
    case Category = "Category"
    case Notifications = "Notifications"
    case ProductNotAvailable = "ProductNotAvailable"
    case LegalInformation = "LegalInformation"
    
}

class PreferencesController : NavigationViewController,UITableViewDataSource,UITableViewDelegate {
    
    var tablePreferences : UITableView!
    
    // "Categorías de mi interés", "Alertas y Notificaciones", "En caso de producto no disponible", "Información Legal"
    
    let preferenceOptions = [PreferenceOptionsController.Category.rawValue, PreferenceOptionsController.Notifications.rawValue, PreferenceOptionsController.ProductNotAvailable.rawValue, PreferenceOptionsController.LegalInformation.rawValue]

    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREFERENCES.rawValue
    }

    
    override func viewDidLoad() {
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.hiddenBack =  IS_IPAD 
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel!.text = NSLocalizedString("preferences.myPreferences", comment: "")
        
        tablePreferences = UITableView()
        tablePreferences.dataSource = self
        tablePreferences.delegate = self
        
        tablePreferences.registerClass(MoreMenuViewCell.self, forCellReuseIdentifier: "Cell")
        tablePreferences.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.view.addSubview(tablePreferences)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tablePreferences.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tablePreferences?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferenceOptions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tablePreferences.dequeueReusableCellWithIdentifier("Cell") as! MoreMenuViewCell
        let srtOption = preferenceOptions[indexPath.row]
        
        cell.isSeparatorComplete = true
        cell.setPreferenceValues(srtOption, size: 16, colorText: WMColor.light_blue, colorSeparate: WMColor.light_gray)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
        let optionTxt = self.preferenceOptions[indexPath.row]
        
        switch (PreferenceOptionsController(rawValue: optionTxt)!) {
        case .Category:
            let controller = InterestCategoryController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Notifications:
            let controller = NotificationPreferencesViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .ProductNotAvailable:
            let noProductController = GRCheckOutCommentsViewController()
            noProductController.isPreferencesView = true
            self.navigationController?.pushViewController(noProductController, animated: true)
        case .LegalInformation:
            let legalController = ChangeInfoLegalViewController()
            legalController.isPreferences = true
            self.navigationController?.pushViewController(legalController, animated: true)
        }
        
    }
    
}