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
    //case Refered = "ReferedList"
    
    case StoreLocator = "StoreLocator"
    case CamFind = "CamFind"
    case TicketList = "TicketList"
    case Invoice = "Invoice"
    case Notification  = "Notification"

    case Help = "Help"
    case Terms = "Terms"
    case Contact = "Contact"
    
    

}

class MoreOptionsViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource, CameraViewControllerDelegate {

    var options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.CamFind.rawValue,OptionsController.TicketList.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Invoice.rawValue,OptionsController.Notification.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
    
    @IBOutlet var profileView: UIImageView?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var userName: UILabel?
    @IBOutlet var emailLabel: UILabel?
    @IBOutlet var passwordLabel: UILabel?
    
    var signInOrClose: WMRoundButton?
    var editProfileButton : UIButton!
    
    var alertView: IPOWMAlertViewController?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MOREOPTIONS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName?.font = WMFont.fontMyriadProLightOfSize(25)
        userName?.textColor = UIColor.whiteColor()
        
        emailLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        emailLabel?.textColor = UIColor.whiteColor()
        
        let circleLetter: Character = "\u{25CF}"
        let finalPassword = "\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)"
        passwordLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        passwordLabel?.textColor = UIColor.whiteColor()
        passwordLabel?.text = finalPassword
        
        
        self.signInOrClose = WMRoundButton()
        let sizeImage = CGSizeMake(90, 24)
        self.signInOrClose?.setFontTitle(WMFont.fontMyriadProRegularOfSize(12))
        self.signInOrClose?.setBackgroundColor(WMColor.blue, size: sizeImage, forUIControlState: UIControlState.Selected)
        self.signInOrClose?.setTitle("cerrar sesión", forState: UIControlState.Selected)
        self.signInOrClose?.setBackgroundColor(WMColor.green, size: sizeImage, forUIControlState: UIControlState.Normal)
        self.signInOrClose?.setTitle("iniciar sesión", forState: UIControlState.Normal)
        //self.signInOrClose?.setTitle(" ", forState: UIControlState.Highlighted)
        self.signInOrClose?.addTarget(self, action: #selector(MoreOptionsViewController.openLoginOrProfile), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signInOrClose!)
       
        
        self.editProfileButton = UIButton()
        self.editProfileButton.addTarget(self, action: #selector(MoreOptionsViewController.editProfile(_:)), forControlEvents: .TouchUpInside)
        self.editProfileButton.setImage(UIImage(named: "editProfile"), forState: UIControlState.Normal)
        self.editProfileButton.setImage(UIImage(named: "editProfile_active"), forState: UIControlState.Selected)
        self.editProfileButton.setImage(UIImage(named: "editProfile_active"), forState: UIControlState.Highlighted)
        self.editProfileButton.alpha = 0
        self.view.addSubview(editProfileButton)
        
        self.reloadButtonSession()
        
               tableView  = UITableView(frame: CGRectZero)
        tableView!.registerClass(MoreMenuViewCell.self, forCellReuseIdentifier: "Cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = UITableViewCellSeparatorStyle.None

        self.view.addSubview(tableView!)
            
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreOptionsViewController.reloadProfileData), name: ProfileNotification.updateProfile.rawValue, object: nil)
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoreOptionsViewController.reloadTable), name: CustomBarNotification.UpdateNotificationBadge.rawValue, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadButtonSession()
        self.tableView?.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds.size
        self.tableView!.frame = CGRectMake(0.0, profileView!.frame.maxY, bounds.width, bounds.height - profileView!.frame.maxY)
        self.profileView?.backgroundColor = WMColor.light_blue
        self.editProfileButton!.frame = CGRectMake(bounds.width - 63, -13 , 63, 63 )
         signInOrClose?.frame = CGRectMake((self.view.frame.width / 2) - 45, 109, 90, 24)
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
                return 3
            case 1:
                return 5
            case 2:
                return 3
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: MoreMenuViewCell! = tableView.dequeueReusableCellWithIdentifier("Cell") as! MoreMenuViewCell
        
        
        var currentOption : Int = 0
        switch(indexPath.section) {
        case 0:
            currentOption = indexPath.row
        case 1:
            currentOption = indexPath.row + 3
        case 2:
            currentOption = indexPath.row + 8
        default:
            print("")
        }
        
        let srtOption = self.options[currentOption]
        
        var image: String?
        switch (OptionsController(rawValue: srtOption)!) {
        case .Profile : image = "Profile-icon"
        case .Recents : image = "Recents-icon"
        case .Address : image = "Address-icon"
        case .Orders : image = "Orders-icon"
        case .StoreLocator : image = "StoreLocator-icon"
        case .Invoice : image = "Factura-icon"
        case .Notification : image = "menu_icon_notification"
        case .CamFind : image = "Camfind-icon"
        case .TicketList : image = "menu_scanTicket"
        //case .Refered : image = "referidos_on"
        default :
            print("option don't exist")
        }
         if UserCurrentSession.sharedInstance().userSigned == nil && (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 1)) {
            switch (OptionsController(rawValue: srtOption)!) {
            case .Profile : image = "Profile-disable-icon"
            case .Recents : image = "Recents-disable-icon"
            case .Address : image = "Address-disable-icon"
            case .Orders : image = "Orders-disable-icon"
            case .TicketList : image = "menu_scanTicket_disable"
            case .Notification : image = "menu_icon_notification"
            //case .Refered : image = "referidos_off"
            default :
                print("option don't exist")
            }
            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.gray, colorSeparate: WMColor.light_gray)
        } else  {
             cell.setValues(srtOption, image: image, size:16, colorText: WMColor.light_blue, colorSeparate: WMColor.light_gray)
        }
        


        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if UserCurrentSession.sharedInstance().userSigned == nil && (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 1)) {
            //CAMBIO
            self.openLoginOrProfile()
            return
        }
        
        var currentOption : Int = 0
        switch(indexPath.section) {
        case 0:
            currentOption = indexPath.row
        case 1:
            currentOption = indexPath.row + 3
        case 2:
            currentOption = indexPath.row + 8
        default:
            print("")
        }
        
       
        
        let optionTxt = self.options[currentOption]

        switch (OptionsController(rawValue: optionTxt)!) {
        case .Help : self.performSegueWithIdentifier("showHelp", sender: self)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_HOW_USE_APP.rawValue, label: "")
        case .Profile :
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label: "")
            let controller = EditProfileViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Terms: self.performSegueWithIdentifier("termsHelp", sender: self)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_TERMS_AND_CONDITIONS.rawValue, label: "")
        case .Contact: self.performSegueWithIdentifier("supportHelp", sender: self)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_SUPPORT.rawValue, label: "")
        case .StoreLocator: self.performSegueWithIdentifier("storeLocator", sender: self)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_STORE_LOCATOR.rawValue, label: "")
        case .Notification: self.performSegueWithIdentifier("notificationController", sender: self)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_NOTIFICATIONS.rawValue, label: "")
        case .Recents:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_MORE_ITEMES_PURCHASED.rawValue, label: "")
                let controller = RecentProductsViewController()
                self.navigationController!.pushViewController(controller, animated: true)
        case .Address:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ACCOUNT_ADDRES.rawValue, label: "")
            let controller = MyAddressViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Orders :
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PREVIOUS_ORDERS.rawValue, label: "")
            let controller = OrderViewController()
            //controller.reloadPreviousOrders()
            self.navigationController!.pushViewController(controller, animated: true)
        case .CamFind:
            let cameraController = CameraViewController()
            cameraController.delegate = self
            self.presentViewController(cameraController, animated: true, completion: nil)
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
        case .Invoice:
            let webCtrl = IPOWebViewController()
            webCtrl.openURLFactura()
            self.presentViewController(webCtrl,animated:true,completion:nil)
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ELECTRONIC_BILLING.rawValue, label: "")
        case .TicketList:
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BARCODE_SCANNED_TICKET.rawValue, label: "")
            scanTicket()
//        case .Refered:
//            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_REFERED.rawValue, label: "")
//            openRefered()
        }
        
        if currentOption == 6 {
            //Se elimina Badge de notificaciones
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateNotificationBadge.rawValue, object: nil)
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
        //var title = ""
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_LOGIN.rawValue, label: "")
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
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APP_SESSION_END.rawValue, label: "")
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
                        print("")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
                })
            }
            }, errorBlock: { (error:NSError) -> Void in
                print("")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UserLogOut.rawValue, object: nil)
        })
    }
    
    //MARK CameraViewControllerDelegate
    func photoCaptured(value: String?,upcs:[String]?,done: (() -> Void))
    {
       if value != nil && value?.trim() != "" {
              BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }

            let params = ["upcs": upcArray!, "keyWord":value!]
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.CamFindSearch.rawValue, object: params, userInfo: nil)
            done()
        }
    }
    
    
    func reloadButtonSession() {
        if UserCurrentSession.sharedInstance().userSigned == nil {
            self.editProfileButton.alpha = 0
            self.emailLabel?.alpha = 0
            self.passwordLabel?.alpha = 0
            userName?.text = "¡Hola!"
            
            signInOrClose?.selected = false
        } else {
            self.editProfileButton.alpha = 1
            self.emailLabel?.alpha = 1
            self.passwordLabel?.alpha = 1
            let userNameStr = UserCurrentSession.sharedInstance().userSigned?.profile.name as? String
            let userLastNameStr = UserCurrentSession.sharedInstance().userSigned?.profile.lastName as? String
            let emailStr = UserCurrentSession.sharedInstance().userSigned?.email as? String
            userName?.text = "\(userNameStr!) \(userLastNameStr!)"
            
            emailLabel?.text = emailStr
            
            signInOrClose?.selected = true
        }
        self.tableView?.reloadData()
    }
    
    func editProfile(sender:UIButton) {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label: "")
        let controller = EditProfileViewController()
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    //Ticket
    
    func scanTicket() {
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.searchProduct = false
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    func openRefered (){
        let referedController = ReferedViewController()
        self.navigationController!.pushViewController(referedController, animated: true)
    
    }
    
    
    func reloadProfileData(){
        self.reloadButtonSession()
    }
    
    func reloadTable(){
        self.tableView?.reloadData()
    }
}
