//
//  MoreOptionsViewController.swift
//  WalMart
//
//  Created by neftali on 03/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

enum OptionsController : String {
    case Profile = "Profile"
    case Recents = "Recents"
    case Address = "Address"
    case Orders = "Orders"
    
    case StoreLocator = "StoreLocator"

    case Help = "Help"
    case Terms = "Terms"
    case Contact = "Contact"

}

class MoreOptionsViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource {

    let options = [OptionsController.Profile.rawValue,OptionsController.Recents.rawValue,OptionsController.Address.rawValue,OptionsController.Orders.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
    
    @IBOutlet var profileView: UIImageView?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var userName: UILabel?
    @IBOutlet var signInOrClose: UIButton?
    var editProfileButton : UIButton!
    
    var alertView: IPOWMAlertViewController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName?.font = WMFont.fontMyriadProLightOfSize(25)
        userName?.textColor = UIColor.whiteColor()
        
        signInOrClose?.layer.cornerRadius = 12.0
        signInOrClose?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        signInOrClose?.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0.0, 0, 0.0)
        signInOrClose?.addTarget(self, action: "openLoginOrProfile", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.editProfileButton = UIButton()
        self.editProfileButton.addTarget(self, action: "editProfile:", forControlEvents: .TouchUpInside)
        self.editProfileButton.setImage(UIImage(named: "editProfile"), forState: UIControlState.Normal)
        self.editProfileButton.setImage(UIImage(named: "editProfile_active"), forState: UIControlState.Selected)
        self.editProfileButton.setImage(UIImage(named: "editProfile_active"), forState: UIControlState.Highlighted)
        self.view.addSubview(editProfileButton)
        
        self.reloadButtonSession()
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_MORE.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        tableView  = UITableView(frame: CGRectZero)
        tableView!.registerClass(MoreMenuViewCell.self, forCellReuseIdentifier: "Cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = UITableViewCellSeparatorStyle.None

        self.view.addSubview(tableView!)
            
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadButtonSession()
    }
    
    override func viewWillLayoutSubviews() {
        var bounds = self.view.bounds.size
        self.tableView!.frame = CGRectMake(0.0, profileView!.frame.maxY, bounds.width, bounds.height - profileView!.frame.maxY)
        self.editProfileButton!.frame = CGRectMake(bounds.width - 63, 0 , 63, 63 )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    
    
    // MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 4
            case 1:
                return 1
            case 2:
                return 3
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: MoreMenuViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell") as MoreMenuViewCell
        
        
        var currentOption : Int = 0
        switch(indexPath.section) {
        case 0:
            currentOption = indexPath.row
        case 1:
            currentOption = indexPath.row + 4
        case 2:
            currentOption = indexPath.row + 5
        default:
            println("")
        }
        
        let srtOption = self.options[currentOption]
        
        var image: String?
        switch (OptionsController(rawValue: srtOption)!) {
        case .Profile : image = "Profile-icon"
        case .Recents : image = "Recents-icon"
        case .Address : image = "Address-icon"
        case .Orders : image = "Orders-icon"
        case .StoreLocator : image = "StoreLocator-icon"
        default :
            println("option don't exist")
        }      
        if UserCurrentSession.sharedInstance().userSigned != nil || indexPath.section != 0 {
            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.UIColorFromRGB(0x0E7DD3), colorSeparate: WMColor.UIColorFromRGB(0xDDDEE0))
        } else if UserCurrentSession.sharedInstance().userSigned == nil && indexPath.section == 0 {
            switch (OptionsController(rawValue: srtOption)!) {
            case .Profile : image = "Profile-disable-icon"
            case .Recents : image = "Recents-disable-icon"
            case .Address : image = "Address-disable-icon"
            case .Orders : image = "Orders-disable-icon"
            default :
                println("option don't exist")
            }
            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.regular_gray, colorSeparate: WMColor.UIColorFromRGB(0xDDDEE0))
        }
        


        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if UserCurrentSession.sharedInstance().userSigned == nil && indexPath.section == 0 {
            return
        }
        
        var currentOption : Int = 0
        switch(indexPath.section) {
        case 0:
            currentOption = indexPath.row
        case 1:
            currentOption = indexPath.row + 4
        case 2:
            currentOption = indexPath.row + 5
        default:
            println("")
        }
        
       
        
        var optionTxt = self.options[currentOption]

        switch (OptionsController(rawValue: optionTxt)!) {
            case .Help : self.performSegueWithIdentifier("showHelp", sender: self)
            case .Profile :
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue,
                        action:WMGAIUtils.EVENT_PROFILE_EDITPROFILE.rawValue,
                        label: nil,
                        value: nil).build())
                }
                
                let controller = EditProfileViewController()
                self.navigationController!.pushViewController(controller, animated: true)
            case .Terms: self.performSegueWithIdentifier("termsHelp", sender: self)
            case .Contact: self.performSegueWithIdentifier("supportHelp", sender: self)
            case .StoreLocator: self.performSegueWithIdentifier("storeLocator", sender: self)
        case .Recents:
                let controller = RecentProductsViewController()
                self.navigationController!.pushViewController(controller, animated: true)
        case .Address:
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue, action: WMGAIUtils.EVENT_PROFILE_MYADDRESSES.rawValue, label: "", value: nil).build())
            }
            
            let controller = MyAddressViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Orders :
            let controller = OrderViewController()
            controller.reloadPreviousOrders()
            self.navigationController!.pushViewController(controller, animated: true)

            default :
                println("option don't exist")
        }
        
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 46.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 36.0
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        var title = ""
        let viewReturn = MoreSectionView()
      
        switch(section) {
        case 1:
            viewReturn.setup("Herramientas")
        case 2:
            viewReturn.setup("Ayuda")
        default:
            viewReturn.setup("")
        }
        return viewReturn
        
    }
    
    //MARK: Other
    
    func openLoginOrProfile() {
        if UserCurrentSession.sharedInstance().userSigned == nil{
            let cont = LoginController.showLogin()
            cont!.successCallBack = {() in
                self.tableView?.reloadData()
                if cont.alertView != nil {
                    cont!.closeAlert(true, messageSucesss: true)
                }else {
                    cont!.closeModal()
                }
                self.reloadButtonSession()
                //self.performSegueWithIdentifier("showProfile", sender: self)
                //TODO: Poner acciones, cambio boton y nombre
            }
        }
        else {
            self.signOut(nil)
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
                value: nil).build())
        }
        
        let shoppingCartUpdateBg = ShoppingCartProductsService()
        shoppingCartUpdateBg.callService([:], successBlock: { (result:NSDictionary) -> Void in
            if  UserCurrentSession.sharedInstance().userSigned != nil {
                UserCurrentSession.sharedInstance().userSigned = nil
                UserCurrentSession.sharedInstance().deleteAllUsers()
                self.reloadButtonSession()
                let shoppingService = ShoppingCartProductsService()
                shoppingService.callCoreDataService([:], successBlock: { (result:NSDictionary) -> Void in
                    
                    self.alertView!.setMessage("Ok")
                    self.alertView!.showDoneIcon()
                    NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                    
                    }
                    , errorBlock: { (error:NSError) -> Void in
                        println("")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                })
            }
            }, errorBlock: { (error:NSError) -> Void in
                println("")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
        })
    }
    
    
    func reloadButtonSession() {
        if UserCurrentSession.sharedInstance().userSigned == nil {
            userName?.text = "¡Hola!"
            signInOrClose?.backgroundColor = WMColor.green
            signInOrClose?.setTitle("iniciar sesión", forState: UIControlState.Normal)
        } else {
            userName?.text = UserCurrentSession.sharedInstance().userSigned?.profile.name
            signInOrClose?.backgroundColor = WMColor.regular_blue
            signInOrClose?.setTitle("Cerrar sesión", forState: UIControlState.Normal)
        }
        self.tableView?.reloadData()
    }
    
    func editProfile(sender:UIButton) {
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_PROFILE.rawValue,
                action:WMGAIUtils.EVENT_PROFILE_EDITPROFILE.rawValue,
                label: nil,
                value: nil).build())
        }
        
        let controller = EditProfileViewController()
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    
    
}
