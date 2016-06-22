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
    
    var allNotifications = []
    var selectable = true
    var emptyView : IPOEmptyNotificationView?
    var receiveNotificationButton: CMSwitchView?
    var receiveNotificationLabel: UILabel?
    var layerLine: CALayer!
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_NOTIFICATION.rawValue
    }
    
    override func viewDidLoad() {
        if UIDevice.currentDevice().userInterfaceIdiom != .Phone  {
            self.hiddenBack = true
            if  self.navigationController != nil {
                self.navigationController!.setNavigationBarHidden(true, animated: true)
            }
        }
        
        super.viewDidLoad()
        
        self.titleLabel?.text = NSLocalizedString("more.notification.title", comment: "")
        
        self.receiveNotificationLabel = UILabel()
        self.receiveNotificationLabel?.textColor = WMColor.gray
        self.receiveNotificationLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.receiveNotificationLabel?.text = "Permitir Notificaciones"
        
        let showNotificationParam = CustomBarViewController.retrieveParam("showNotification", forUser: false)
        let showNotification = showNotificationParam == nil ? true : (showNotificationParam!.value == "true")
        
        self.receiveNotificationButton = CMSwitchView(frame: CGRectMake(0.0, 0.0, 54, 34))
        self.receiveNotificationButton!.borderWidth = 1
        self.receiveNotificationButton!.borderColor =  showNotification ? WMColor.green : WMColor.gray
        self.receiveNotificationButton!.dotColor = UIColor.whiteColor()
        self.receiveNotificationButton!.dotBorderColor = WMColor.light_gray
        self.receiveNotificationButton!.color = WMColor.gray
        self.receiveNotificationButton!.tintColor = WMColor.green
        self.receiveNotificationButton!.delegate =  self
        self.receiveNotificationButton!.dotWeight = 32.0
        self.receiveNotificationButton!.drawSelected(showNotification)
        
        self.layerLine = CALayer()
        self.layerLine!.backgroundColor = WMColor.light_light_gray.CGColor
        self.view!.layer.insertSublayer(layerLine!, atIndex: 1000)
        
        self.view.addSubview(self.receiveNotificationLabel!)
        self.view.addSubview(self.receiveNotificationButton!)
        
        let pushNotificationService = PushNotificationService()
        pushNotificationService.callService({ (dict) -> Void in
            self.allNotifications = self.getNotificationsForDevice(dict)
            if self.allNotifications.count == 0 {
                self.emptyView = IPOEmptyNotificationView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY + 46, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
                self.view.addSubview(self.emptyView!)
            } else {
                self.notification = UITableView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY + 46, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
                self.notification.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: "cellNot")
                self.notification.dataSource = self
                self.notification.delegate = self
                self.notification.reloadData()
                self.notification.separatorStyle = .None
                self.view.addSubview(self.notification)
            }

            }, errorBlock: {
                (error) -> Void in print("Error pushNotificationService")
                self.emptyView = IPOEmptyNotificationView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
                self.view.addSubview(self.emptyView!)
                })
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //let receiveNotification = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.receiveNotificationLabel?.frame = CGRectMake(16, self.header!.frame.maxY, self.view.bounds.width - 32, 46)
        receiveNotificationButton?.frame = CGRectMake(self.view.bounds.width - 70, self.header!.frame.maxY + 6, 54, 34)
        layerLine?.frame = CGRectMake(0, self.receiveNotificationLabel!.frame.maxY, self.view.frame.width, 1)
        emptyView?.frame = CGRectMake(self.view.bounds.minX, self.receiveNotificationLabel!.frame.maxY + 1, self.view.bounds.width, self.view.bounds.height - self.receiveNotificationLabel!.frame.maxY)
        notification?.frame = CGRectMake(self.view.bounds.minX, self.receiveNotificationLabel!.frame.maxY + 1, self.view.bounds.width, self.view.bounds.height - self.receiveNotificationLabel!.frame.maxY)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellNot") as! NotificationTableViewCell
        
        let notiicationInfo = allNotifications[indexPath.row] as! NSDictionary
        let hour = notiicationInfo["hour"] as! String
        let date = notiicationInfo["date"] as! String
        let message = notiicationInfo["body"] as! String
        
        cell.descLabel?.text = message
        cell.dateLabel?.text = date
        cell.hourLabel?.text = hour
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 91
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectable  {
            selectable = false
            let notiicationInfo = allNotifications[indexPath.row] as! NSDictionary
            let type = notiicationInfo["type"] as! String
            let name = ""
            let value = notiicationInfo["value"] as! String
            let business = (notiicationInfo["business"] as! String).lowercaseString
            selectable = type == "URL"
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTIFICATION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_NOTIFICATION_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_OPEN_DETAIL_NOTIFICATION.rawValue , label:"\(type) \(value) \(business)")
            let window = UIApplication.sharedApplication().keyWindow
            
            if let customBar = window!.rootViewController  as? CustomBarViewController {
                
                let handled = customBar.handleNotification(type,name:name,value:value,bussines:business)
                if !handled {
                    selectable = true
                }
            }
        }
    }
    
    func getNotificationsForDevice(dict: NSDictionary) -> [AnyObject]{
        var showNotifications: [AnyObject] = []
        if let notifications = dict["notifications"] as? [AnyObject]{
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
    
    override func viewWillAppear(animated: Bool) {
        self.selectable = true
    }
    
    override func back() {
        super.back()
         BaseController.sendAnalytics(WMGAIUtils.CATEGORY_NOTIFICATION_AUTH.rawValue, categoryNoAuth:WMGAIUtils.CATEGORY_NOTIFICATION_NO_AUTH.rawValue , action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label:"")
    }
    
    //MARK: CMSwitchViewDelegate
    
    func switchValueChanged(sender: AnyObject!, andNewValue value: Bool) {
        self.receiveNotificationButton!.borderColor = value ? WMColor.green : WMColor.gray

        let idDevice = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let notService = NotificationService()
        if  UserCurrentSession.sharedInstance().deviceToken != "" {
            let params = notService.buildParams(UserCurrentSession.sharedInstance().deviceToken, identifierDevice: idDevice, enablePush: value)
            notService.jsonFromObject(params)
            notService.callPOSTService(params, successBlock: { (result:NSDictionary) -> Void in
                CustomBarViewController.addOrUpdateParam("showNotification", value: value ? "true" : "false",forUser: false)
            }) { (error:NSError) -> Void in
                print( "Error device token: \(error.localizedDescription)" )
                self.receiveNotificationButton!.borderColor = !value ? WMColor.green : WMColor.gray
                self.receiveNotificationButton!.drawSelected(!value)
                //TODO: quitar
                 // CustomBarViewController.addOrUpdateParam("showNotification", value: value ? "true" : "false",forUser: false)
            }
        }
    }
    
}