//
//  IPAProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 13/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAProfileViewControllerDelegate {
    func selectedDetail(row: Int)
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
        self.viewLine.backgroundColor = UIColor.whiteColor()
        self.viewProfile.addSubview(self.viewLine!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var bounds = self.view.bounds
        self.imageBG!.frame = CGRectMake(0,0,bounds.width, bounds.height )
        self.viewProfile!.frame = CGRectMake(0,0,bounds.width, bounds.height )
        self.imageProfile!.frame = CGRectMake((bounds.width - 24 )/2 , 45 , 24, 24 )
        self.nameLabel!.frame = CGRectMake(15,self.imageProfile!.frame.maxY + 5 ,bounds.width - 30, 55)
        self.emailLabel!.frame = CGRectMake(0,self.nameLabel!.frame.maxY + 5 , bounds.width, 16)
        self.editProfileButton!.frame = CGRectMake(bounds.width - 63, 0 , 63, 63 )
        self.signOutButton!.frame = CGRectMake((bounds.width - 86) / 2,self.emailLabel!.frame.maxY + 80 , 86, 28 )
        self.viewLine!.frame = CGRectMake(0, self.signOutButton!.frame.maxY + 15 , bounds.width, 1)
        self.table!.frame = CGRectMake(0, self.signOutButton!.frame.maxY + 16 , bounds.width, bounds.height - self.signOutButton!.frame.maxY )
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.setSelected(indexPath.row == selected, animated: false)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileViewCell", forIndexPath: indexPath) as! ProfileViewCell
        
        if indexPath.row == 0 {
            cell.setValues(NSLocalizedString("profile.misarticulos", comment: ""), image: "topSales", size:16 ,  colorText: UIColor.whiteColor(), colorSeparate: UIColor.whiteColor() )
        }else
        if indexPath.row == 1 {
            cell.setValues(NSLocalizedString("profile.myAddress", comment: ""), image: "myAddresses", size:16 ,  colorText: UIColor.whiteColor(), colorSeparate: UIColor.whiteColor() )
        }
        else{
            cell.setValues(NSLocalizedString("profile.myOrders", comment: ""), image: "myOrders" , size:16 ,  colorText: UIColor.whiteColor(), colorSeparate: UIColor.whiteColor() )
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       selected = indexPath.row
       self.delegate.selectedDetail(indexPath.row)
       self.table.reloadData()
    }
    
    override func editProfile(sender:UIButton) {
        if sender.selected{
            return
        }
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue,
                action:WMGAIUtils.EVENT_PROFILE_EDITPROFILE.rawValue,
                label: nil,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        sender.selected = !sender.selected
        self.delegate.selectedDetail(3)
    }

    func finishSave(){
        self.setValues()
    }

    override func signOut(sender:UIButton?) {
        super.signOut(nil)
        self.delegate.closeSession()
    }
    
}
