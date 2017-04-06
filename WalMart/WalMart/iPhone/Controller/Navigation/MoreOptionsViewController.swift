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
    
    case Promotions  = "Promotions"
    

    case Help = "Help"
    case Terms = "Terms"
    case Contact = "Contact"
    
    

}

class MoreOptionsViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource, CameraViewControllerDelegate {

    var options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.Promotions.rawValue,OptionsController.CamFind.rawValue,OptionsController.TicketList.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Invoice.rawValue,OptionsController.Notification.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
    
    @IBOutlet var profileView: UIImageView?
    @IBOutlet var tableView: UITableView?
    @IBOutlet var userName: UILabel?
    @IBOutlet var emailLabel: UILabel?
    @IBOutlet var passwordLabel: UILabel?
    
    var signInOrClose: WMRoundButton?
    var editProfileButton : UIButton!
    var showCamfind: Bool!
    var alertView: IPOWMAlertViewController?
    var showPromos: Bool = true
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MOREOPTIONS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName?.font = WMFont.fontMyriadProLightOfSize(25)
        userName?.textColor = UIColor.white
        
        emailLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        emailLabel?.textColor = UIColor.white
        
        let circleLetter: Character = "\u{25CF}"
        let finalPassword = "\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)\(circleLetter)"
        passwordLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        passwordLabel?.textColor = UIColor.white
        passwordLabel?.text = finalPassword
        
        
        self.signInOrClose = WMRoundButton()
        let sizeImage = CGSize(width: 90, height: 24)
        self.signInOrClose?.setFontTitle(WMFont.fontMyriadProRegularOfSize(12))
        self.signInOrClose?.setBackgroundColor(WMColor.blue, size: sizeImage, forUIControlState: UIControlState.selected)
        self.signInOrClose?.setTitle("cerrar sesión", for: UIControlState.selected)
        self.signInOrClose?.setBackgroundColor(WMColor.green, size: sizeImage, forUIControlState: UIControlState())
        self.signInOrClose?.setTitle("iniciar sesión", for: UIControlState())
        //self.signInOrClose?.setTitle(" ", forState: UIControlState.Highlighted)
        self.signInOrClose?.addTarget(self, action: #selector(MoreOptionsViewController.openLoginOrProfile), for: UIControlEvents.touchUpInside)
        self.view.addSubview(signInOrClose!)
       
        
        self.editProfileButton = UIButton()
        self.editProfileButton.addTarget(self, action: #selector(MoreOptionsViewController.editProfile(_:)), for: .touchUpInside)
        self.editProfileButton.setImage(UIImage(named: "editProfile"), for: UIControlState())
        self.editProfileButton.setImage(UIImage(named: "editProfile_active"), for: UIControlState.selected)
        self.editProfileButton.setImage(UIImage(named: "editProfile_active"), for: UIControlState.highlighted)
        self.editProfileButton.alpha = 0
        self.view.addSubview(editProfileButton)
        
        self.reloadButtonSession()
        
               tableView  = UITableView(frame: CGRect.zero)
        tableView!.register(MoreMenuViewCell.self, forCellReuseIdentifier: "Cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = UITableViewCellSeparatorStyle.none

        self.view.addSubview(tableView!)
        
        self.showCamfind = Bundle.main.object(forInfoDictionaryKey: "showCamFind") as! Bool
        
        if !self.showCamfind {
           options = [OptionsController.Address.rawValue,OptionsController.Recents.rawValue,OptionsController.Orders.rawValue,OptionsController.Promotions.rawValue,OptionsController.TicketList.rawValue,OptionsController.StoreLocator.rawValue,OptionsController.Invoice.rawValue,OptionsController.Notification.rawValue,OptionsController.Help.rawValue,OptionsController.Terms.rawValue,OptionsController.Contact.rawValue]
        }
            
       NotificationCenter.default.addObserver(self, selector: #selector(MoreOptionsViewController.reloadProfileData), name: NSNotification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(MoreOptionsViewController.reloadTable), name: .updateNotificationBadge, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadButtonSession()
        self.tableView?.reloadData()
        //TGM 360
        BaseController.setOpenScreenTagManager(titleScreen: "Más opciones", screenName: self.getScreenGAIName())
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds.size
        self.tableView!.frame = CGRect(x: 0.0, y: profileView!.frame.maxY, width: bounds.width, height: bounds.height - profileView!.frame.maxY)
        self.profileView?.backgroundColor = WMColor.light_blue
        self.editProfileButton!.frame = CGRect(x: bounds.width - 63, y: -13 , width: 63, height: 63 )
         signInOrClose?.frame = CGRect(x: (self.view.frame.width / 2) - 45, y: 109, width: 90, height: 24)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 3
            case 1:
                let rows = self.showCamfind! ? 6 : 5
                return rows
            case 2:
                return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MoreMenuViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MoreMenuViewCell
        
        
        var currentOption : Int = 0
        switch(indexPath.section) {
        case 0:
            currentOption = indexPath.row
        case 1:
            currentOption = indexPath.row + 3
        case 2:
            currentOption = indexPath.row + (self.showCamfind! ? 9 : 8)
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
        case.Promotions : image = "promotions_icon"
            
        default :
            print("option don't exist")
        }
         if UserCurrentSession.sharedInstance.userSigned == nil && (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 2 && self.showCamfind)) {
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
            
            if UserCurrentSession.sharedInstance.userSigned == nil && !self.showCamfind && indexPath.section == 1 && indexPath.row == 1   {
                image = "menu_scanTicket_disable"
                cell.setValues(srtOption, image: image, size:16, colorText: WMColor.gray, colorSeparate: WMColor.light_gray)
            }
        }
        


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if UserCurrentSession.sharedInstance.userSigned == nil && (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 2 && self.showCamfind)) {
            //CAMBIO
            self.openLoginOrProfile()
            return
        }
        else if UserCurrentSession.sharedInstance.userSigned == nil &&  !self.showCamfind && indexPath.section == 1 && indexPath.row == 1{
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
            currentOption = indexPath.row + (self.showCamfind! ? 9 : 8)
        default:
            print("")
        }
        
       
        NotificationCenter.default.post(name: .clearSearch, object: nil)
        let optionTxt = self.options[currentOption]

        switch (OptionsController(rawValue: optionTxt)!) {
        case .Help : self.performSegue(withIdentifier: "showHelp", sender: self)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_HOW_USE_APP.rawValue, label: "")
        case .Profile :
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label: "")
            let controller = EditProfileViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Terms: self.performSegue(withIdentifier: "termsHelp", sender: self)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_TERMS_AND_CONDITIONS.rawValue, label: "")
        case .Contact: self.performSegue(withIdentifier: "supportHelp", sender: self)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_SUPPORT.rawValue, label: "")
        case .StoreLocator: self.performSegue(withIdentifier: "storeLocator", sender: self)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_STORE_LOCATOR.rawValue, label: "")
        case .Notification: self.performSegue(withIdentifier: "notificationController", sender: self)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_NOTIFICATIONS.rawValue, label: "")
        case .Recents:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_MORE_ITEMES_PURCHASED.rawValue, label: "")
                let controller = RecentProductsViewController()
                self.navigationController!.pushViewController(controller, animated: true)
        case .Address:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ACCOUNT_ADDRES.rawValue, label: "")
            let controller = MyAddressViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case .Orders :
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_PREVIOUS_ORDERS.rawValue, label: "")
            let controller = OrderViewController()
            //controller.reloadPreviousOrders()
            self.navigationController!.pushViewController(controller, animated: true)
        case .CamFind:
            let cameraController = CameraViewController()
            cameraController.delegate = self
            self.present(cameraController, animated: true, completion: nil)
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
        case .Invoice:
            let webCtrl = IPOWebViewController()
            webCtrl.openURLFactura()
            self.present(webCtrl,animated:true,completion:nil)
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_ELECTRONIC_BILLING.rawValue, label: "")
        case .TicketList:
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BARCODE_SCANNED_TICKET.rawValue, label: "")
            scanTicket()
//        case .Refered:
//            ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_REFERED.rawValue, label: "")
//            openRefered()
        case .Promotions:
            self.openPromotios()
                print("Abrir promosiones")
            
        }
        
        let notificationOptions = (self.showCamfind! ? 8 : 7)
        if currentOption == notificationOptions {
            //Se elimina Badge de notificaciones
            UIApplication.shared.applicationIconBadgeNumber = 0
            NotificationCenter.default.post(name: .updateNotificationBadge, object: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        return 36.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        
        if UserCurrentSession.sharedInstance.userSigned == nil{
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_LOGIN.rawValue, label: "")
            let cont = LoginController.showLogin()
            cont!.successCallBack = {() in
                self.tableView?.reloadData()
                if cont?.alertView != nil {
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
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MORE_OPTIONS_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_APP_SESSION_END.rawValue, label: "")
            self.signOut(nil)
        }
    }
    
    func signOut(_ sender: UIButton?) {
        
        if IS_IPAD  {
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        } else {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.logout",comment:""))
        
        sender?.isEnabled = false
        
        func deleteData() {
            
            delay(0.3) {
                
                if UserCurrentSession.hasLoggedUser() {
                    
                    UserCurrentSession.sharedInstance.userSigned = nil
                    UserCurrentSession.sharedInstance.deleteAllUsers()
                    
                    let shoppingService = ShoppingCartProductsService()
                    shoppingService.callCoreDataService([:], successBlock: { (result: [String:Any]) -> Void in
                        
                        self.alertView!.setMessage("Ok")
                        self.alertView!.showDoneIcon()
                        sender?.isEnabled = true
                        NotificationCenter.default.post(name:.userLogOut, object: nil)
                        
                    }, errorBlock: { (error: NSError) -> Void in
                        
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        sender?.isEnabled = true
                        NotificationCenter.default.post(name:.userLogOut, object: nil)
                        
                    })
                }
            }
            
        }
        
        let logoutService = LogoutService()
        logoutService.callService(Dictionary<String, String>(), successBlock: { (response: [String:Any]) -> Void in
            
            let authorizationService = AuthorizationService()
            authorizationService.callGETService("", successBlock: { (response:[String:Any]) in
                deleteData()
            }, errorBlock:{ (error: NSError) in
                print(error.localizedDescription)
                deleteData()
            })
            
        }, errorBlock: { (error: NSError) -> Void in
            print("Call service LogoutService error \(error)")
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showErrorIcon("Ok")
            sender?.isEnabled = true
        })
        
    }
    
    

     
    
    //MARK CameraViewControllerDelegate
    func photoCaptured(_ value: String?,upcs:[String]?,done: (() -> Void))
    {
       if value != nil && value?.trim() != "" {
              //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_CAM_FIND_SEARCH_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_SEARCH_BY_TAKING_A_PHOTO.rawValue, label: "")
            var upcArray = upcs
            if upcArray == nil{
                upcArray = []
            }

            let params = ["upcs": upcArray!, "keyWord":value!] as [String : Any]
            NotificationCenter.default.post(name: .camFindSearch, object: params, userInfo: nil)
            done()
        }
    }
    
    /**
     change state butons in menu options, when user is login
     */
    func reloadButtonSession() {
        if UserCurrentSession.sharedInstance.userSigned == nil {
            self.editProfileButton.alpha = 0
            self.emailLabel?.alpha = 0
            self.passwordLabel?.alpha = 0
            userName?.text = "¡Hola!"
            
            signInOrClose?.isSelected = false
        } else {
            self.editProfileButton.alpha = 1
            self.emailLabel?.alpha = 1
            self.passwordLabel?.alpha = 1
            let userNameStr = UserCurrentSession.sharedInstance.userSigned?.profile.name as? String
            let userLastNameStr = UserCurrentSession.sharedInstance.userSigned?.profile.lastName as? String
            let emailStr = UserCurrentSession.sharedInstance.userSigned?.email as? String
            userName?.text = "\(userNameStr!) \(userLastNameStr!)"
            
            emailLabel?.text = emailStr
            
            signInOrClose?.isSelected = true
        }
        self.tableView?.reloadData()
    }
    
    /**
     Open for edit profile
     
     - parameter sender: button send action
     */
    func editProfile(_ sender:UIButton) {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_MORE_OPTIONS_AUTH.rawValue, action: WMGAIUtils.ACTION_OPEN_EDIT_PROFILE.rawValue, label: "")
        let controller = EditProfileViewController()
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    /**
     Open controller Sacan Barcode
     */
    func scanTicket() {
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.searchProduct = false
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    /**
     open controller Refered
     */
    func openRefered (){
        let referedController = ReferedViewController()
        self.navigationController!.pushViewController(referedController, animated: true)
    
    }
    
    /**
     Update menu Option
     */
    func reloadProfileData(){
        self.reloadButtonSession()
    }
    
    func reloadTable(){
        self.tableView?.reloadData()
    }
    
    /**
     Call service line promotions
     */
    func openPromotios(){
        if self.showPromos {
            self.showPromos = false
            NSLog("Inicia llamado de  Servicios:::::")
            self.loadGRServices { (bussines:String) in
                NSLog("termina llamado de Servicios:::")
                let window = UIApplication.shared.keyWindow
                if let customBar = window!.rootViewController as? CustomBarViewController {
                    let _ = customBar.handleNotification("LIN",name:"CP",value: bussines == "gr" ? "cat2320023" :"l-lp-app-promociones",bussines:bussines)
                    self.showPromos = true
                }
            }
        }
    }
    /**
     validate number items line contains
     
     - parameter successBlock: finish service an retun bussines
     */
    func loadGRServices(_ successBlock:((String) -> Void)?){
       
        let signalsDictionary : [String:Any] = ["signals" : GRBaseService.getUseSignalServices()]
        let service = GRProductBySearchService(dictionary: signalsDictionary)
        let params = service.buildParamsForSearch(text: "", family: "_", line: "cl-promociones-mobile", sort: "", departament: "_", start: 0, maxResult: 20,brand:"")
        service.callService(params!, successBlock: { (respose:[[String:Any]],resultDic:[String:Any]) in
            print("temina")
            if respose.count > 0 {
                successBlock!("gr")
            }else{
                successBlock!("mg")
            }
           
        }, errorBlock: { (error:NSError) in
            print(error.localizedDescription)
            successBlock!("mg")
            print("llama al mg")
        })
    }
    
    
    
}
