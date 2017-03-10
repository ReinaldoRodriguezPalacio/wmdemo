//
//  NotificationViewController.swift
//  WalMart
//
//  Created by Alejandro Miranda on 09/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class NotificationViewController : NavigationViewController, UITableViewDataSource, UITableViewDelegate, CMSwitchViewDelegate {
    
    var notification: UITableView!
    var allNotifications: [[String:Any]] = []
    var selectable = true
    var emptyView : IPOEmptyNotificationView?
    var receiveNotificationButton: CMSwitchView?
    var receiveNotificationLabel: UILabel?
    var layerLine: CALayer!
    var viewLoad: WMLoadingView?

    var headerNotification : UIView?    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_NOTIFICATION.rawValue
    }
    
    override func viewDidLoad() {
        if UIDevice.current.userInterfaceIdiom != .phone  {
            self.hiddenBack = true
            if  self.navigationController != nil {
                self.navigationController!.setNavigationBarHidden(true, animated: true)
            }
        }
        
        super.viewDidLoad()
        
        self.titleLabel?.text = NSLocalizedString("more.notification.title", comment: "")
        
        self.headerNotification = UIView()
        self.headerNotification!.backgroundColor =  UIColor.white
        self.view.addSubview(self.headerNotification!)
        
        self.receiveNotificationLabel = UILabel()
        self.receiveNotificationLabel?.textColor = WMColor.gray
        self.receiveNotificationLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.receiveNotificationLabel?.text = "Permitir Notificaciones"
        
        let showNotificationParam = CustomBarViewController.retrieveParam("showNotification", forUser: false)
        let showNotification = showNotificationParam == nil ? true : (showNotificationParam!.value == "true")
        
        self.receiveNotificationButton = CMSwitchView(frame: CGRect(x: 0.0, y: 0.0, width: 54, height: 34))
        self.receiveNotificationButton!.borderWidth = 1
        self.receiveNotificationButton!.borderColor =  showNotification ? WMColor.green : WMColor.gray
        self.receiveNotificationButton!.dotColor = UIColor.white
        self.receiveNotificationButton!.dotBorderColor = WMColor.light_gray
        self.receiveNotificationButton!.color = WMColor.gray
        self.receiveNotificationButton!.tintColor = WMColor.green
        self.receiveNotificationButton!.delegate =  self
        self.receiveNotificationButton!.dotWeight = 32.0
        self.receiveNotificationButton!.drawSelected(showNotification)
        
        self.headerNotification!.addSubview(self.receiveNotificationLabel!)
        self.headerNotification!.addSubview(self.receiveNotificationButton!)
        
        self.notification = UITableView(frame:CGRect(x: self.view.bounds.minX, y: self.header!.frame.maxY + 46,
            width: self.view.bounds.width, height: self.view.bounds.height - (self.header!.frame.maxY + self.headerNotification!.frame.height ) ) )
        self.notification.register(NotificationTableViewCell.self, forCellReuseIdentifier: "cellNot")
        self.notification.dataSource = self
        self.notification.delegate = self
        self.notification.separatorStyle = .none
        self.notification.backgroundColor =  UIColor.white
        self.view.addSubview(self.notification)
        
        self.layerLine = CALayer()
        self.layerLine!.backgroundColor = WMColor.light_light_gray.cgColor
        self.headerNotification!.layer.insertSublayer(layerLine!, at: 1000)
        self.showLoadingView()
        self.invokeNotificationService()
        BaseController.setOpenScreenTagManager(titleScreen: NSLocalizedString("more.notification.title", comment: ""), screenName: self.getScreenGAIName())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let receiveNotification = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let model = UIDevice.current.modelName
        
        self.headerNotification?.frame = CGRect(x: 0,y: self.header!.frame.maxY ,width: self.view.frame.width,  height: self.header!.frame.maxY)
        
        self.receiveNotificationLabel?.frame = CGRect(x: 16, y: 0,width: 200, height: 46)
        receiveNotificationButton?.frame = CGRect(x: self.view.bounds.width - 70, y: 6, width: 54, height: 34)
        self.layerLine?.frame = CGRect(x: 0, y: 45, width: self.view.frame.width, height: 1)
        
        var heightEmptyView = self.view.bounds.height
        if !model.contains("iPhone 5") && !model.contains("Plus") {
            heightEmptyView -= self.receiveNotificationLabel!.frame.maxY
        }
        
        if model.contains("4") {
            heightEmptyView -= 44
        }
    
        self.emptyView?.frame = CGRect(x: self.view.bounds.minX, y: self.headerNotification!.frame.maxY , width: self.view.bounds.width, height: heightEmptyView)
    
        notification?.frame = CGRect(x: self.view.bounds.minX,y: self.header!.frame.maxY + 46,
                                         width: self.view.bounds.width,
                                         height: self.view.bounds.height - (self.headerNotification!.frame.height))
    }
    
    
    func invokeNotificationService(){
        let model = UIDevice.current.modelName
        print(model)
        
        let pushNotificationService = PushNotificationService()
        pushNotificationService.callService({ (dict) -> Void in
            self.allNotifications = self.getNotificationsForDevice(dict)
            
            if self.allNotifications.count == 0 {
                var heightEmptyView = self.view.bounds.height
                
                if !model.contains("iPhone 5") && !model.contains("Plus") {
                    heightEmptyView -= self.receiveNotificationLabel!.frame.maxY
                }
//
                self.emptyView = IPOEmptyNotificationView(frame:CGRect(x: self.view.bounds.minX, y: self.header!.frame.maxY , width: self.view.bounds.width, height: heightEmptyView))
            
                if model.contains("iPhone 5") || model.contains("Plus") {
                    self.emptyView!.paddingBottomReturnButton += 87
                } else if model.contains("6"){
                    self.emptyView!.paddingBottomReturnButton += 44
                } else if model.contains("4") || model.contains("iPad") || IS_IPAD {
                    self.emptyView!.showReturnButton = false
                }
                self.emptyView!.returnAction = {() in
                    self.back()
                }
                self.view.addSubview(self.emptyView!)
            } else {
                self.notification.reloadData()
            }
            
            self.removeLoadingView()
        }, errorBlock: {
            (error) -> Void in print("Error pushNotificationService")
            self.removeLoadingView()
            self.emptyView = IPOEmptyNotificationView(frame:CGRect(x: self.view.bounds.minX, y: self.header!.frame.maxY , width: self.view.bounds.width, height: self.view.bounds.height - self.header!.frame.maxY))
            if model.contains("iPhone 5") || model.contains("Plus") {
                self.emptyView!.paddingBottomReturnButton += 87
            } else if model.contains("6"){
                self.emptyView!.paddingBottomReturnButton += 44
            }
            if model.contains("4") || model.contains("iPad") || IS_IPAD {
                self.emptyView!.showReturnButton = false
            }
            self.emptyView!.returnAction = {() in
                self.back()
            }
            self.view.addSubview(self.emptyView!)
        })
        
    }
    
    //MARK : TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNot") as! NotificationTableViewCell
        
        let notiicationInfo = allNotifications[indexPath.row] 
        let hour = notiicationInfo["hour"] as! String
        let date = notiicationInfo["date"] as! String
        let message = notiicationInfo["body"] as! String
        cell.descLabel?.text = message
        cell.dateLabel?.text = date
        cell.hourLabel?.text = hour
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectable  {
            selectable = false
            let notiicationInfo = allNotifications[indexPath.row] 
            let type = notiicationInfo["type"] as! String
            let name = ""
            let value = notiicationInfo["value"] as! String
            let business = (notiicationInfo["business"] as! String).lowercased()
            selectable = type == "URL"
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTIFICATION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_NOTIFICATION_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_OPEN_DETAIL_NOTIFICATION.rawValue , label:"\(type) \(value) \(business)")
            let window = UIApplication.shared.keyWindow
            
            if let customBar = window!.rootViewController  as? CustomBarViewController {
                
                let handled = customBar.handleNotification(type,name:name,value:value,bussines:business)
                if !handled {
                    selectable = true
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.selectable = true
    }
    
    //MARK: Actions
    
    /**
    notificatios group from servce, acording to device
     
     - parameter dict: all notifiction from service
     
     - returns: array notificatios acording to device
     */
    func getNotificationsForDevice(_ dict: [String:Any]) -> [[String:Any]]{
        var showNotifications: [[String:Any]] = []
        if let notifications = dict["notifications"] as? [[String:Any]]{
            for notif in notifications{
                let device = notif["device"] as! String
                if IS_IPHONE && device == "iphone" {
                    showNotifications.append(notif)
                }
                if IS_IPAD && device == "ipad" {
                    showNotifications.append(notif)
                }
                if device == "" {
                    showNotifications.append(notif)
                }
            }
        }
       return showNotifications
    }
    
    /**
     close notification controller
     */
    override func back() {
        super.back()
         //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTIFICATION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_NOTIFICATION_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label:"")
    }
    
    //MARK: CMSwitchViewDelegate
    
    func switchValueChanged(_ sender: Any!, andNewValue value: Bool) {
        self.receiveNotificationButton!.borderColor = value ? WMColor.green : WMColor.gray

        let idDevice = UIDevice.current.identifierForVendor!.uuidString
        let notService = NotificationService()
        if  UserCurrentSession.sharedInstance.deviceToken != "" {
            let params = notService.buildParams(UserCurrentSession.sharedInstance.deviceToken, identifierDevice: idDevice, enablePush: !value)
            notService.jsonFromObject(params as AnyObject!)
            notService.callPOSTService(params, successBlock: { (result:[String:Any]) -> Void in
                CustomBarViewController.addOrUpdateParam("showNotification", value: value ? "true" : "false",forUser: false)
            }) { (error:NSError) -> Void in
                print( "Error device token: \(error.localizedDescription)" )
                self.receiveNotificationButton!.borderColor = !value ? WMColor.green : WMColor.gray
                self.receiveNotificationButton!.drawSelected(!value)
                //TODO: quitar
               //CustomBarViewController.addOrUpdateParam("showNotification", value: value ? "true" : "false",forUser: false)
            }
        }
    }
    
    /**
     Present loader in screen list
     */
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: IS_IPAD ? 680 : self.view.bounds.width, height: self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    /**
     Remove loader from screen list
     */
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    override func swipeHandler(swipe: UISwipeGestureRecognizer) {
        self.back()
    }
    
}
