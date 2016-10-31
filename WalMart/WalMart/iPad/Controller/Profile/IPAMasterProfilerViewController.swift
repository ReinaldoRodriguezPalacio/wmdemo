//
//  IPAMasterProfilerViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 13/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

enum ProfileNotification : String {
    case updateProfile = "kUpdateProfileNotification"
}

class IPAMasterProfilerViewController: UISplitViewController, UISplitViewControllerDelegate , IPAProfileViewControllerDelegate{

    var selected : Int? = nil
    var navigation : UINavigationController!
    var profile = IPAProfileViewController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        //self.split = UISplitViewController()
        self.delegate = self
        self.profile.delegate = self
        self.navigation = UINavigationController()
        let recent = IPARecentProductsViewController()
        self.navigation.pushViewController(recent, animated: true)
        selected = 0
        self.viewControllers = [profile, navigation];
        
        if(self.responds(to: #selector(getter: UISplitViewController.maximumPrimaryColumnWidth)))
        {
            self.maximumPrimaryColumnWidth = 342.0
            self.minimumPrimaryColumnWidth = 342.0
            
        }
       // self.view.addSubview(self.split.view)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func selectedDetail(_ row: Int){
        if selected == row{
            self.navigation.popToRootViewController(animated: true)
            return
        }
        self.navigation = UINavigationController()
        self.navigation!.popViewController(animated: true)
        
        switch row {
        case 0:
            self.profile.editProfileButton!.isSelected = false
            let recent = IPARecentProductsViewController()
            self.navigation.pushViewController(recent, animated: true)
        case 1:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action: WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label: "")
            self.profile.editProfileButton!.isSelected = false
            let myAddres = IPAMyAddressViewController()
            self.navigation.pushViewController(myAddres, animated: true)
        case 2:
            self.profile.editProfileButton!.isSelected = false
            let order = IPAOrderViewController()
            
            self.navigation.pushViewController(order, animated: true)
        case 3:
            let edit = IPAEditProfileViewController()
            let indexPath = IndexPath(item:Int(selected!), section:0)
            self.profile.table.deselectRow(at: indexPath, animated: true)
            edit.delegate  = self.profile
            self.navigation.pushViewController(edit, animated: true)
        default :
            print("other pressed")
        }
        
        selected = row
        self.viewControllers = [profile, navigation];
    }
    
    func closeSession() {
        self.navigation!.popToRootViewController(animated: true)
    }
    
    
        
    
}
