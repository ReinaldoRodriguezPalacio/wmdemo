//
//  NotificationViewController.swift
//  WalMart
//
//  Created by Alejandro Miranda on 09/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class NotificationViewController : NavigationViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var notification: UITableView!
    
    var allNotifications = []
    var selectable = true
    var emptyView : IPOEmptyNotificationView?
    
    
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
        
        
        let pushNotificationService = PushNotificationService()
        pushNotificationService.callService({ (dict) -> Void in
            self.allNotifications = self.getNotificationsForDevice(dict)
            if self.allNotifications.count == 0 {
                self.emptyView = IPOEmptyNotificationView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
                self.view.addSubview(self.emptyView!)
            } else {
                self.notification = UITableView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
                self.notification.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: "cellNot")
                self.notification.dataSource = self
                self.notification.delegate = self
                self.notification.reloadData()
                self.view.addSubview(self.notification)
            }

            }, errorBlock: {
                (error) -> Void in print("Error pushNotificationService")
                self.emptyView = IPOEmptyNotificationView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
                self.view.addSubview(self.emptyView!)
                })
        }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emptyView?.frame = CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
        notification?.frame = CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
        
         emptyView?.frame = CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
        
        notification?.frame = CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
        
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
    
}