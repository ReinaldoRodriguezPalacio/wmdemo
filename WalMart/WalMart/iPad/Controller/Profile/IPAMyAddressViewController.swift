//
//  IPAMyAddressViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 14/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPAMyAddressViewController: MyAddressViewController {
    override func viewDidLoad() {
        self.hiddenBack = true
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addressController = IPAAddressViewController()
        super.tableView(tableView, didSelectRowAt:indexPath)
    }
    
    override func deleteAddress(_ idAddress:String, isFisicalAddress:Bool){
        self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        super.deleteAddress(idAddress, isFisicalAddress:isFisicalAddress)
    }
}
