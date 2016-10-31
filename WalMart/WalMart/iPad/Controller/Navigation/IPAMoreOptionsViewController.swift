//
//  IPAMoreOptionsViewController.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 04/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAMoreOptionsViewControllerDelegate {
    func selectedDetail(_ row: Int)
}

class IPAMoreOptionsViewController: MoreOptionsViewController{

    var delegate:IPAMoreOptionsViewControllerDelegate!
    var selected: IndexPath?
    
    @IBOutlet var imgProfile: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailLabel?.textAlignment = .center
        
        options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.Preferences.rawValue,OptionsController.Promotions.rawValue,OptionsController.CamFind.rawValue,OptionsController.TicketList.rawValue,OptionsController.Invoice.rawValue,OptionsController.Notification.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
        
        if !self.showCamfind {
            options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.Preferences.rawValue,OptionsController.Promotions.rawValue,OptionsController.TicketList.rawValue,OptionsController.Invoice.rawValue,OptionsController.Notification.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
        }
       
        NotificationCenter.default.addObserver(self, selector: #selector(IPAMoreOptionsViewController.reloadMenu), name:NSNotification.Name(rawValue: "MORE_OPTIONS_RELOAD"), object: nil)
        print("Create MORE_OPTIONS_RELOAD")
        // Como usar el app
        self.selected = IndexPath(row: 0, section: 2)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()


        self.profileView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.userName?.frame = CGRect(x: 16 , y: 32, width: self.view.frame.width - 32, height: 25)
        self.emailLabel?.frame = CGRect(x: 16 , y: 60, width: self.view.frame.width - 32, height: 25)
        passwordLabel?.textAlignment =  .center
        self.passwordLabel?.frame = CGRect(x: 16 , y: self.emailLabel!.frame.maxY + 5, width: self.view.frame.width - 32, height: 25)
        self.signInOrClose?.frame = CGRect(x: (self.view.frame.width / 2) - 45 , y: self.passwordLabel!.frame.maxY + 5, width: 95, height: 24)
        self.tableView?.frame = CGRect(x: 0, y: self.profileView!.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.profileView!.frame.maxY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView?.selectRow(at: self.selected!, animated: false, scrollPosition: .none)
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RELOAD_PROFILE"), object: nil)
    }
  
    func reloadMenu(){
        self.reloadButtonSession()
        let cell = self.tableView?.cellForRow(at: self.selected!)
        cell?.isSelected = true
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ""), object: nil)
    }

    // MARK: - TableView
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 4
        case 1:
            let rows = self.showCamfind! ? 5 : 4
            return rows
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    override  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 36.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView?.cellForRow(at: self.selected!)
        cell?.isSelected = false
        if UserCurrentSession.sharedInstance().userSigned == nil && ((indexPath as NSIndexPath).section == 0 || ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 && self.showCamfind)) {
            self.openLoginOrProfile()
            self.selected = IndexPath(row: 0, section: 2)
            self.tableView?.selectRow(at: self.selected!, animated: false, scrollPosition: .bottom)
            return
        } else if UserCurrentSession.sharedInstance().userSigned == nil && (((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 && !self.showCamfind)) {
            self.openLoginOrProfile()
            self.selected = IndexPath(row: 0, section: 2)
            self.tableView?.selectRow(at: self.selected!, animated: false, scrollPosition: .bottom)
            return
        }
        
        
        var currentOption : Int = 0
        
        switch((indexPath as NSIndexPath).section) {
        case 0:
            currentOption = (indexPath as NSIndexPath).row
        case 1:
            currentOption = (indexPath as NSIndexPath).row + 4
        case 2:
            currentOption = (indexPath as NSIndexPath).row + (self.showCamfind! ? 9 : 8)
        default:
            print("")
        }

        self.selected = indexPath
        
        if !self.showCamfind! && currentOption > 4 {//2
            currentOption += 1
        }
        
        if currentOption >= 4 && currentOption <= 7{
           self.selected = IndexPath(row: 0, section: 2)
        }
    
        if currentOption == 8 {//6
            //Se elimina Badge de notificaciones
            UIApplication.shared.applicationIconBadgeNumber = 0
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateNotificationBadge.rawValue), object: nil)
        }
        
        self.delegate.selectedDetail(currentOption)
    }
    
   

    override func signOut(_ sender: UIButton?) {
        self.delegate.selectedDetail(8)
        self.selected = IndexPath(row: 0, section: 2)
        super.signOut(nil)
    }

    override func editProfile(_ sender:UIButton) {
       self.delegate.selectedDetail(11)
       NotificationCenter.default.addObserver(self, selector: #selector(IPAMoreOptionsViewController.reloadProfile), name: NSNotification.Name(rawValue: "RELOAD_PROFILE"), object: nil)

    }
    
    func reloadProfile() {
        self.reloadButtonSession()
    }
    
    override func openLoginOrProfile() {
        if UserCurrentSession.sharedInstance().userSigned == nil{
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_LOGIN.rawValue, label: "")
            let cont = LoginController.showLogin()
            cont!.successCallBack = {() in
                if cont?.alertView != nil {
                    cont!.closeAlert(true, messageSucesss: true)
                }else {
                    cont!.closeModal()
                }
                self.reloadButtonSession()
                self.selected = IndexPath(row: 0, section: 2)
                self.tableView?.reloadData()
                let cell = self.tableView?.cellForRow(at: self.selected!)
                cell?.isSelected = true
                self.delegate?.selectedDetail(8)// 7
                //self.performSegueWithIdentifier("showProfile", sender: self)
                //TODO: Poner acciones, cambio boton y nombre
            }
            self.selected = IndexPath(row: 0, section: 2)
            self.delegate?.selectedDetail(9)//7
        }
        else {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APP_SESSION_END.rawValue, label: "")
            self.signOut(nil)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath == self.selected! {
           cell.isSelected = true
        }
        
        return cell
    }
    
    override func reloadTable(){
        self.tableView?.reloadData()
        let cell = self.tableView?.cellForRow(at: self.selected!)
        cell?.isSelected = true
    }
    
    override func reloadProfileData(){
        self.reloadButtonSession()
        self.selected = IndexPath(row: 0, section: 2)
        self.tableView?.reloadData()
        let cell = self.tableView?.cellForRow(at: self.selected!)
        cell?.isSelected = true
        self.delegate?.selectedDetail(8)//7
    }
    
}
