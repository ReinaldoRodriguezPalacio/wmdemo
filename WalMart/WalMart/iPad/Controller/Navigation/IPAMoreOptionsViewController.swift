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

    
    @IBOutlet var imgProfile: UIImageView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.CamFind.rawValue,OptionsController.TicketList.rawValue,OptionsController.Factura.rawValue,OptionsController.Notification.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
       
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        

        self.profileView?.frame = CGRectMake(0, 0, self.view.frame.width, 160)
        self.imgProfile?.frame = CGRectMake((self.view.frame.width / 2) - 12 , 32,24, 24)
        self.userName?.frame = CGRectMake(16 , 71, self.view.frame.width - 32, 25)
        self.signInOrClose?.frame = CGRectMake((self.view.frame.width / 2) - 45 , 110, 90, 24)
        self.tableView?.frame = CGRectMake(0, self.profileView!.frame.maxY, self.view.frame.width, self.view.frame.height - self.profileView!.frame.maxY)
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
//        if UserCurrentSession.sharedInstance().userSigned != nil || indexPath.section != 0 {
//            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.UIColorFromRGB(0x0E7DD3), colorSeparate: WMColor.UIColorFromRGB(0xDDDEE0))
//        } else if UserCurrentSession.sharedInstance().userSigned == nil && indexPath.section == 0 {
//            switch (OptionsController(rawValue: srtOption)!) {
//            case .Profile : image = "Profile-disable-icon"
//            case .Recents : image = "Recents-disable-icon"
//            case .Address : image = "Address-disable-icon"
//            case .Orders : image = "Orders-disable-icon"
//            default :
//                println("option don't exist")
//            }
//            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.regular_gray, colorSeparate: WMColor.UIColorFromRGB(0xDDDEE0))
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
            println("")
        }

        
        
        self.delegate.selectedDetail(currentOption)
    }
    
   

    override func signOut(sender: UIButton?) {
        self.delegate.selectedDetail(7)
        super.signOut(nil)
    }

    override func editProfile(sender:UIButton) {
       self.delegate.selectedDetail(10)
    }

    
    
}