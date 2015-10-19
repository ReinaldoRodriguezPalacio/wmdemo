//
//  ProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 18/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class ProfileViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource  {
    var viewProfile : UIView!
    var imageBG : UIImageView!
    var imageProfile : UIImageView?
    var nameLabel : UILabel!
    var emailLabel : UILabel!
    var table: UITableView!
    var signOutButton: UIButton?
    var editProfileButton: UIButton?
    var backButton: UIButton!
    var hiddenBack = false
    var alertView: IPOWMAlertViewController?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

         NSNotificationCenter.defaultCenter().addObserver(self, selector: "setValues", name: ProfileNotification.updateProfile.rawValue, object: nil)
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_PROFILE.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }

        imageBG = UIImageView()
        imageBG!.image = UIImage(named: "profileBg")
        self.viewProfile = UIView()
        self.viewProfile.backgroundColor = UIColor.whiteColor()
        self.viewProfile.addSubview(imageBG!)
        self.view.addSubview(self.viewProfile!)
        
        imageProfile = UIImageView()
        imageProfile?.image = UIImage(named: "userProfile")
        self.viewProfile!.addSubview(self.imageProfile!)
        
        self.nameLabel = UILabel()
        self.nameLabel!.textColor = UIColor.whiteColor()
        self.nameLabel!.textAlignment = .Center
        self.nameLabel!.font = WMFont.fontMyriadProRegularOfSize(25)
        self.nameLabel!.numberOfLines = 2
        
        self.viewProfile!.addSubview(self.nameLabel!)
        
        emailLabel = UILabel()
        emailLabel!.textColor = UIColor.whiteColor()
        emailLabel!.textAlignment = .Center
        emailLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        
        signOutButton = UIButton()
        signOutButton!.setTitle(NSLocalizedString("profile.signOut", comment: ""), forState: UIControlState.Normal)
        signOutButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signOutButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        signOutButton!.backgroundColor = WMColor.loginSignOutButonBgColor
        signOutButton?.addTarget(self, action: "signOut:", forControlEvents: .TouchUpInside)
        signOutButton!.layer.cornerRadius = 14.0
        self.viewProfile!.addSubview(self.signOutButton!)

        self.editProfileButton = UIButton()
        self.editProfileButton?.addTarget(self, action: "editProfile:", forControlEvents: .TouchUpInside)
        self.editProfileButton!.setImage(UIImage(named: "editProfile"), forState: UIControlState.Normal)
        self.editProfileButton!.setImage(UIImage(named: "editProfile_active"), forState: UIControlState.Selected)
        self.editProfileButton!.setImage(UIImage(named: "editProfile_active"), forState: UIControlState.Highlighted)
        self.viewProfile!.addSubview(self.editProfileButton!)
        self.viewProfile!.addSubview(self.emailLabel!)
        
        if !hiddenBack{
            self.backButton = UIButton()
            self.backButton?.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
            self.backButton!.setImage(UIImage(named: "search_back"), forState: UIControlState.Normal)
            self.backButton!.setImage(UIImage(named: "search_back"), forState: UIControlState.Selected)
            self.backButton!.setImage(UIImage(named: "search_back"), forState: UIControlState.Highlighted)
            self.viewProfile!.addSubview(self.backButton!)
        }
        
        self.table = UITableView()
        self.table.registerClass(ProfileViewCell.self, forCellReuseIdentifier: "ProfileViewCell")
        self.table?.backgroundColor = UIColor.clearColor()
        self.table.separatorStyle = .None
        self.table.autoresizingMask = UIViewAutoresizing.None
        self.table.delegate = self
        self.table.dataSource = self
        self.viewProfile.addSubview(self.table!)
        //self.table.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if  UserCurrentSession.sharedInstance().userSigned == nil {
            if self.navigationController != nil {
                self.navigationController!.popToRootViewControllerAnimated(false)
            }
        }
        
        self.signOutButton?.enabled = true
        self.table.reloadData()
        self.setValues()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        self.viewProfile!.frame = CGRectMake(0,0,bounds.width, bounds.height )
        self.imageBG!.frame = CGRectMake(0,0,bounds.width, 210 )
        self.imageProfile!.frame = CGRectMake((bounds.width - 24 )/2 , 40 , 24, 24 )
        self.nameLabel!.frame = CGRectMake(15,self.imageProfile!.frame.maxY ,bounds.width - 30, 50)
        self.emailLabel!.frame = CGRectMake(0,self.nameLabel!.frame.maxY  , bounds.width, 16)
        self.editProfileButton!.frame = CGRectMake(bounds.width - 63, 0 , 63, 63 )
        if !hiddenBack{
            self.backButton.frame =  CGRectMake(0, 0 , 63, 63 )
        }
        self.signOutButton!.frame = CGRectMake((bounds.width - 86) / 2,self.emailLabel!.frame.maxY + 32 , 86, 28 )
        self.table!.frame = CGRectMake(0, 210, bounds.width, bounds.height -  210)
    }
    
    func setValues(){
        var user: User?
        if UserCurrentSession.hasLoggedUser() {
            user = UserCurrentSession.sharedInstance().userSigned!
            self.nameLabel!.text = (user!.profile.name as String) + " " + (user!.profile.lastName as String)
            self.emailLabel!.text = user!.email as String
        }//if UserCurrentSession.hasLoggedUser()
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height: CGFloat = 65
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileViewCell", forIndexPath: indexPath) as! ProfileViewCell
        
        //cell.selectionStyle = .None
        if indexPath.row == 0 {
            cell.setValues(NSLocalizedString("profile.misarticulos", comment: ""), image: "topSales" , size:16 ,  colorText: WMColor.loginProfileTextColor, colorSeparate:  WMColor.loginProfileLineColor )
        } else  if indexPath.row == 1 {
            cell.setValues(NSLocalizedString("profile.myAddress", comment: ""), image: "myAddresses" , size:16 ,  colorText: WMColor.loginProfileTextColor, colorSeparate:  WMColor.loginProfileLineColor )
        } else if indexPath.row == 2 {
            cell.setValues(NSLocalizedString("profile.myOrders", comment: ""), image: "myOrders" , size:16 ,  colorText: WMColor.loginProfileTextColor, colorSeparate:  WMColor.loginProfileLineColor )
        }
        
        if cell.selectedBackgroundView != nil {
            cell.selectedBackgroundView!.removeFromSuperview()
            cell.selectedBackgroundView = nil
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let controller = RecentProductsViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        }else if indexPath.row == 1 {
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue, action: WMGAIUtils.EVENT_PROFILE_MYADDRESSES.rawValue, label: "", value: nil).build() as [NSObject : AnyObject])
            }
        
            let controller = MyAddressViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        }else if indexPath.row == 2 {
            let controller = OrderViewController()
            controller.reloadPreviousOrders()
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func signOut(sender:UIButton?) {
        
        if sender == nil {
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        }else{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        }

        self.alertView!.setMessage(NSLocalizedString("profile.message.logout",comment:""))
        //Event close sesion
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_EDITPROFILE.rawValue,
                action:WMGAIUtils.EVENT_PROFILE_CLOSESESSION.rawValue,
                label: nil,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        signOutButton?.enabled = false
        let shoppingCartUpdateBg = ShoppingCartProductsService()
        shoppingCartUpdateBg.callService([:], successBlock: { (result:NSDictionary) -> Void in
            if  UserCurrentSession.hasLoggedUser() {
                UserCurrentSession.sharedInstance().userSigned = nil
                UserCurrentSession.sharedInstance().deleteAllUsers()
                self.signOutButton?.enabled = true
                let shoppingService = ShoppingCartProductsService()
                shoppingService.callCoreDataService([:], successBlock: { (result:NSDictionary) -> Void in
                    
                    self.alertView!.setMessage("Ok")
                    self.alertView!.showDoneIcon()
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                    
                    }
                    , errorBlock: { (error:NSError) -> Void in
                    print("")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    self.signOutButton?.enabled = true
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                })
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.signOutButton?.enabled = true
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
        })
    }

    

    
    func editProfile(sender:UIButton) {
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue,
                action:WMGAIUtils.EVENT_PROFILE_EDITPROFILE.rawValue,
                label: nil,
                value: nil).build() as [NSObject : AnyObject])
        }
        
        let controller = EditProfileViewController()
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func back() {
        if self.navigationController != nil {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
}
