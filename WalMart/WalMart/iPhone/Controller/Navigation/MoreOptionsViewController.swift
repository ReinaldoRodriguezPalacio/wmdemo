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
    case Factura = "Factura"
    case Notification  = "Notification"

    case StoreLocator = "StoreLocator"
    case CamFind = "CamFind"
    case TicketList = "TicketList"

    case Help = "Help"
    case Terms = "Terms"
    case Contact = "Contact"
    
    case Refered = "ReferedList"

}

class MoreOptionsViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource, CameraViewControllerDelegate,BarCodeViewControllerDelegate {

    var options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.CamFind.rawValue,OptionsController.TicketList.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Factura.rawValue,OptionsController.Notification.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
    
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
        self.signInOrClose?.setBackgroundColor(WMColor.regular_blue, size: sizeImage, forUIControlState: UIControlState.Selected)
        self.signInOrClose?.setTitle("cerrar sesión", forState: UIControlState.Selected)
        self.signInOrClose?.setBackgroundColor(WMColor.green, size: sizeImage, forUIControlState: UIControlState.Normal)
        self.signInOrClose?.setTitle("iniciar sesión", forState: UIControlState.Normal)
        //self.signInOrClose?.setTitle(" ", forState: UIControlState.Highlighted)
        self.signInOrClose?.addTarget(self, action: "openLoginOrProfile", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signInOrClose!)
       
        
        self.editProfileButton = UIButton()
        self.editProfileButton.addTarget(self, action: "editProfile:", forControlEvents: .TouchUpInside)
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
            
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadButtonSession()
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds.size
        self.tableView!.frame = CGRectMake(0.0, profileView!.frame.maxY, bounds.width, bounds.height - profileView!.frame.maxY)
        self.editProfileButton!.frame = CGRectMake(bounds.width - 63, 0 , 63, 63 )
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
                return 3//4
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
        case .Factura : image = "Factura-icon"
        case .Notification : image = "menu_icon_notification"
        case .CamFind : image = "Camfind-icon"
        case .TicketList : image = "menu_scanTicket"
        case .Refered : image = "referidos_on"
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
            case .Refered : image = "referidos_off"
            default :
                print("option don't exist")
            }
            cell.setValues(srtOption, image: image, size:16, colorText: WMColor.regular_gray, colorSeparate: WMColor.UIColorFromRGB(0xDDDEE0))
        } else  {
             cell.setValues(srtOption, image: image, size:16, colorText: WMColor.UIColorFromRGB(0x0E7DD3), colorSeparate: WMColor.UIColorFromRGB(0xDDDEE0))
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
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_HELP.rawValue, label: "")
        case .Profile :
            
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
                let controller = RecentProductsViewController()
                self.navigationController!.pushViewController(controller, animated: true)
        case .Address:
            
            let controller = MyAddressViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Orders :
            let controller = OrderViewController()
            //controller.reloadPreviousOrders()
            self.navigationController!.pushViewController(controller, animated: true)
        case .CamFind:
            let cameraController = CameraViewController()
            cameraController.delegate = self
            self.presentViewController(cameraController, animated: true, completion: nil)
        case .Factura:
            let invoiceController = InvoiceViewController()
            self.navigationController!.pushViewController(invoiceController, animated: true)
        case .TicketList:
            scanTicket()
        case .Refered:
            openRefered()
            default :
                print("option don't exist")
       
            
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
        if value != nil && value != "" {
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_HOME.rawValue, action: WMGAIUtils.EVENT_SEARCHACTION.rawValue, label: value, value: nil).build() as [NSObject : AnyObject])
            }
            
            let params = ["upcs": upcs!, "keyWord":value!]
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
                
        let controller = EditProfileViewController()
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    //Ticket
    
    func scanTicket() {
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.applyPadding = false
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    //MARK: - BarCodeViewControllerDelegate
    func barcodeCaptured(value:String?) {
        if value == nil {
            return
        }
        print("Code \(value)")
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.retrieveProductsFromTicket", comment:""))
        let service = GRProductByTicket()
        service.callService(service.buildParams(value!),
            successBlock: { (result: NSDictionary) -> Void in
                if let items = result["items"] as? [AnyObject] {
                    
                    if items.count == 0 {
                        self.alertView!.setMessage(NSLocalizedString("list.message.noProductsForTicket", comment:""))
                        self.alertView!.showErrorIcon("Ok")
                        return
                    }
                    
                    let saveService = GRSaveUserListService()
                    
                    self.alertView!.setMessage(NSLocalizedString("list.message.creatingListFromTicket", comment:""))
                    
                    var products:[AnyObject] = []
                    for var idx = 0; idx < items.count; idx++ {
                        var item = items[idx] as! [String:AnyObject]
                        let upc = item["upc"] as! String
                        let quantity = item["quantity"] as! NSNumber
                        let param = saveService.buildBaseProductObject(upc: upc, quantity: quantity.integerValue)
                        products.append(param)
                    }
                    
                    let fmt = NSDateFormatter()
                    fmt.dateFormat = "MMM d hh"
                    let name = fmt.stringFromDate(NSDate())
                    //var number = 0;
                    
                    
                    
                    
                    
                    saveService.callService(saveService.buildParams(name, items: products),
                        successBlock: { (result:NSDictionary) -> Void in
                            //TODO
                            self.alertView!.setMessage(NSLocalizedString("list.message.listDone", comment: ""))
                            self.alertView!.showDoneIcon()
                            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowGRLists.rawValue, object: nil)
                        },
                        errorBlock: { (error:NSError) -> Void in
                            self.alertView!.setMessage(error.localizedDescription)
                            self.alertView!.showErrorIcon("Ok")
                        }
                    )
                }
            }, errorBlock: { (error:NSError) -> Void in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
    }
    
    func openRefered (){
        let invoiceController = InvoiceViewController()
        self.navigationController!.pushViewController(invoiceController, animated: true)
    
    }
    
    
}
