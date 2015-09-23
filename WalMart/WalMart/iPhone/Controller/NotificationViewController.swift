//
//  NotificationViewController.swift
//  WalMart
//
//  Created by Alejandro Miranda on 09/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class NotificationViewController : NavigationViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var notification: UITableView!
    
    var allNotifications = []
    var selectable = true
    var emptyView : IPOEmptyNotificationView?
    
    
    override func viewDidLoad() {
        
        
        if UIDevice.currentDevice().userInterfaceIdiom != .Phone  {
            self.hiddenBack = true
            if  self.navigationController != nil {
                self.navigationController!.setNavigationBarHidden(true, animated: true)
            }
        }
        
        super.viewDidLoad()
        
        self.titleLabel?.text = NSLocalizedString("more.notification.title", comment: "")
        
        
        let serviceSave = NotificationFileService()
        let dict = serviceSave.getAllNotifications()
        allNotifications = dict["items"] as! [AnyObject]
        
        if allNotifications.count == 0 {
            emptyView = IPOEmptyNotificationView(frame:CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
            self.view.addSubview(emptyView!)
        } else {
            notification.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: "cellNot")
            self.notification.dataSource = self
            self.notification.delegate = self
            self.notification.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
         emptyView?.frame = CGRectMake(self.view.bounds.minX, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellNot") as! NotificationTableViewCell
        
        let userInfo = allNotifications[indexPath.row] as! NSDictionary
        
        let notiicationInfo = userInfo["notification"] as! NSDictionary
        let notiicationAPS = userInfo["aps"] as! NSDictionary
        let hour = userInfo["hour"] as! String
        let date = userInfo["date"] as! String
        
       
        
        let type = notiicationInfo["type"] as! String
        let name = notiicationInfo["name"] as! String
        let value = notiicationInfo["value"] as! String
        let message = notiicationAPS["alert"] as! String
        
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
            let userInfo = allNotifications[indexPath.row] as! NSDictionary
            let notiicationInfo = userInfo["notification"] as! NSDictionary
            let type = notiicationInfo["type"] as! String
            let name = notiicationInfo["name"] as! String
            let value = notiicationInfo["value"] as! String
            let window = UIApplication.sharedApplication().keyWindow
            
            if let customBar = window!.rootViewController  as? CustomBarViewController {
                
                customBar.handleNotification(type,name:name,value:value)
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.selectable = true
    }
    
}