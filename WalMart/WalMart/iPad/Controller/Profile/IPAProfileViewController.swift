//
//  IPAProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 13/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAProfileViewControllerDelegate {
    func selectedDetail(_ row: Int)
    func closeSession()
}


class IPAProfileViewController:  ProfileViewController  , EditProfileViewControllerDelegate{
  
    var delegate:IPAProfileViewControllerDelegate!
    var viewLine : UIView!
    var selected : Int! = 0
    
    override func viewDidLoad() {
        self.hiddenBack = true
        super.viewDidLoad()
        self.viewLine = UIView()
        self.viewLine.backgroundColor = UIColor.white
        self.viewProfile.addSubview(self.viewLine!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds

        self.nameLabel!.frame = CGRect(x: 15,y: self.imageProfile!.frame.maxY + 5 ,width: bounds.width - 30, height: 55)
        self.emailLabel!.frame = CGRect(x: 0,y: self.nameLabel!.frame.maxY + 5 , width: bounds.width, height: 16)
        self.editProfileButton!.frame = CGRect(x: bounds.width - 63, y: 0 , width: 63, height: 63 )
        self.signOutButton!.frame = CGRect(x: (bounds.width - 86) / 2,y: self.emailLabel!.frame.maxY + 80 , width: 86, height: 28 )
        self.viewLine!.frame = CGRect(x: 0, y: self.signOutButton!.frame.maxY + 15 , width: bounds.width, height: 1)
        self.table!.frame = CGRect(x: 0, y: self.signOutButton!.frame.maxY + 16 , width: bounds.width, height: bounds.height - self.signOutButton!.frame.maxY )
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        cell.setSelected((indexPath as NSIndexPath).row == selected, animated: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileViewCell", for: indexPath) as! ProfileViewCell
        
        if (indexPath as NSIndexPath).row == 0 {
            cell.setValues(NSLocalizedString("profile.misarticulos", comment: ""), image: "topSales", size:16 ,  colorText: UIColor.white, colorSeparate: UIColor.white )
        }else
        if (indexPath as NSIndexPath).row == 1 {
            cell.setValues(NSLocalizedString("profile.myAddress", comment: ""), image: "myAddresses", size:16 ,  colorText: UIColor.white, colorSeparate: UIColor.white )
        }
        else{
            cell.setValues(NSLocalizedString("profile.myOrders", comment: ""), image: "myOrders" , size:16 ,  colorText: UIColor.white, colorSeparate: UIColor.white )
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       selected = (indexPath as NSIndexPath).row
       self.delegate.selectedDetail((indexPath as NSIndexPath).row)
       self.table.reloadData()
    }
    
    override func editProfile(_ sender:UIButton) {
        if sender.isSelected{
            return
        }
        
       
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_EDIT_PROFILE.rawValue, action: WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label: "")
        sender.isSelected = !sender.isSelected
        self.delegate.selectedDetail(3)
    }

    func finishSave(){
        self.setValues()
    }

    override func signOut(_ sender:UIButton?) {
        super.signOut(nil)
        self.delegate.closeSession()
    }
    
}
