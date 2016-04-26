//
//  IPAMoreOptionsViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 04/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAMoreOptionsViewControllerDelegate {
    func selectedDetail(row: Int)
}

class IPAMoreOptionsViewController: MoreOptionsViewController{

    var delegate:IPAMoreOptionsViewControllerDelegate!
    var selected: NSIndexPath?
    
    @IBOutlet var imgProfile: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailLabel?.textAlignment = .Center
        
        options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.CamFind.rawValue,OptionsController.TicketList.rawValue,OptionsController.Invoice.rawValue,OptionsController.Notification.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IPAMoreOptionsViewController.reloadMenu), name:"MORE_OPTIONS_RELOAD", object: nil)
        print("Create MORE_OPTIONS_RELOAD")
        // Como usar el app
        self.selected = NSIndexPath(forRow: 0, inSection: 2)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()


        self.profileView?.frame = CGRectMake(0, 0, self.view.frame.width, 160)
        self.userName?.frame = CGRectMake(16 , 32, self.view.frame.width - 32, 25)
        self.emailLabel?.frame = CGRectMake(16 , 60, self.view.frame.width - 32, 25)
        passwordLabel?.textAlignment =  .Center
        self.passwordLabel?.frame = CGRectMake(16 , self.emailLabel!.frame.maxY + 5, self.view.frame.width - 32, 25)
        self.signInOrClose?.frame = CGRectMake((self.view.frame.width / 2) - 45 , self.passwordLabel!.frame.maxY + 5, 95, 24)
        self.tableView?.frame = CGRectMake(0, self.profileView!.frame.maxY, self.view.frame.width, self.view.frame.height - self.profileView!.frame.maxY)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView?.selectRowAtIndexPath(self.selected!, animated: false, scrollPosition: .None)
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "RELOAD_PROFILE", object: nil)
    }
  
    func reloadMenu(){
        self.reloadButtonSession()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "", object: nil)
    }



    // MARK: - TableView
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 3
        case 1:
            return 4
        case 2:
            return 3
        default:
            return 0
        }
    }
    
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        var cell: MoreMenuViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell") as! MoreMenuViewCell
//        
//        
//        var currentOption : Int = 0
//        switch(indexPath.section) {
//        case 0:
//            currentOption = indexPath.row
//        case 1:
//            currentOption = indexPath.row + 4
//        default:
//            println("")
//        }
//        
//        let srtOption = self.options[currentOption]
//        
//        var image: String?
//        switch (OptionsController(rawValue: srtOption)!) {
//        case .Profile : image = "Profile-icon"
//        case .Recents : image = "Recents-icon"
//        case .Address : image = "Address-icon"
//        case .Orders : image = "Orders-icon"
//        case .StoreLocator : image = "StoreLocator-icon"
//        case .Factura : image = "Factura-icon"
//        case .CamFind : image = "Camfind-icon"
//            case .CamFind : image = "Camfind-icon"
//        default :
//            println("option don't exist")
//        }
//        if UserCurrentSession.hasLoggedUser() || indexPath.section != 0 {
//            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.light_blue, colorSeparate: WMColor.light_gray)
//        } else if UserCurrentSession.sharedInstance().userSigned == nil && indexPath.section == 0 {
//            switch (OptionsController(rawValue: srtOption)!) {
//            case .Profile : image = "Profile-disable-icon"
//            case .Recents : image = "Recents-disable-icon"
//            case .Address : image = "Address-disable-icon"
//            case .Orders : image = "Orders-disable-icon"
//            default :
//                println("option don't exist")
//            }
//            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.gray, colorSeparate: WMColor.light_gray)
//        }
//        
//        return cell
//    }

//
//
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46.0
    }
    
    override  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 36.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if UserCurrentSession.sharedInstance().userSigned == nil && (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 1)) {
            self.openLoginOrProfile()
            self.selected = NSIndexPath(forRow: 0, inSection: 2)
            self.tableView?.selectRowAtIndexPath(self.selected!, animated: false, scrollPosition: .Bottom)
            return
        }
        
        
        var currentOption : Int = 0
        
        switch(indexPath.section) {
        case 0:
            currentOption = indexPath.row
        case 1:
            currentOption = indexPath.row + 3
        case 2:
            currentOption = indexPath.row + 7
        default:
            print("")
        }

        self.selected = indexPath
        if currentOption >= 3 && currentOption <= 5{
           self.selected = NSIndexPath(forRow: 0, inSection: 2)
        }
        self.delegate.selectedDetail(currentOption)
    }
    
   

    override func signOut(sender: UIButton?) {
        self.delegate.selectedDetail(7)
        self.selected = NSIndexPath(forRow: 0, inSection: 2)
        super.signOut(nil)
    }

    override func editProfile(sender:UIButton) {
       self.delegate.selectedDetail(10)
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IPAMoreOptionsViewController.reloadProfile), name: "RELOAD_PROFILE", object: nil)

    }
    
    func reloadProfile() {
        self.reloadButtonSession()
    }
    
    override func openLoginOrProfile() {
        if UserCurrentSession.sharedInstance().userSigned == nil{
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_LOGIN.rawValue, label: "")
            let cont = LoginController.showLogin()
            cont!.successCallBack = {() in
                if cont.alertView != nil {
                    cont!.closeAlert(true, messageSucesss: true)
                }else {
                    cont!.closeModal()
                }
                self.reloadButtonSession()
                self.selected = NSIndexPath(forRow: 0, inSection: 2)
                self.tableView?.reloadData()
                let cell = self.tableView?.cellForRowAtIndexPath(self.selected!)
                cell?.selected = true
                self.delegate?.selectedDetail(7)
                //self.performSegueWithIdentifier("showProfile", sender: self)
                //TODO: Poner acciones, cambio boton y nombre
            }
            self.selected = NSIndexPath(forRow: 0, inSection: 2)
            self.delegate?.selectedDetail(7)
        }
        else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APP_SESSION_END.rawValue, label: "")
            self.signOut(nil)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if indexPath == self.selected! {
           cell.selected = true
        }
        
        return cell
    }
    
    override func reloadProfileData(){
        self.reloadButtonSession()
        self.selected = NSIndexPath(forRow: 0, inSection: 2)
        self.tableView?.reloadData()
        let cell = self.tableView?.cellForRowAtIndexPath(self.selected!)
        cell?.selected = true
        self.delegate?.selectedDetail(7)
    }
    
}