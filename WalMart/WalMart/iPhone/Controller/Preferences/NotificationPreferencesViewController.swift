//
//  NotificationPreferencesViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class NotificationPreferencesViewController : NavigationViewController,UITableViewDataSource, UITableViewDelegate,PreferencesNotificationsCellDelegate {
    
    let titles =  ["Promociones por correo electrónico","Carrito abandonado","Promociones por SMS"]
    let descriptios = ["Deseo recibir información de walmart.com.mx en mi buzón de correo","Deseo recibir notificaciones de mi carrito abandonado de walmart.com.mx en mi correo electrónico","Deseo recibir informacion de vía SMS"]

    var userPreferences : NSMutableDictionary = [:]
    var tableview :  UITableView?
    var viewFooter : UIView?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREFERENCES_NOTIFICATION.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =  UIColor.whiteColor()
        self.titleLabel?.text =  "Alertas y Notificaciones"
        
        self.tableview =  UITableView()
        self.tableview!.registerClass(PreferencesNotificationsCell.self, forCellReuseIdentifier: "PreferencesNotificationsCell")
        self.tableview!.delegate = self
        self.tableview?.dataSource = self
        self.tableview!.separatorStyle = .None
        self.view.addSubview(self.tableview!)
        
        
        
        self.viewFooter =  UIView()
        self.viewFooter?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewFooter!)
        
        layerLine =  CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        viewFooter!.layer.insertSublayer(layerLine, atIndex: 1000)
        layerLine.frame = CGRectMake(0, 0, self.viewFooter!.frame.width, 2)

        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NotificationPreferencesViewController.cancel), forControlEvents: UIControlEvents.TouchUpInside)
        self.viewFooter!.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("Guardar", comment:""), forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(NotificationPreferencesViewController.save), forControlEvents: UIControlEvents.TouchUpInside)
        self.viewFooter!.addSubview(saveButton!)
        
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148, 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 ,16, 140, 34)
        
        self.invokePreferenceService()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableview?.frame =  CGRectMake(0,self.header!.frame.maxY,self.view.frame.width ,self.view.frame.height - (self.headerHeight + 64))
       
        
        self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY - 46, width:self.view.bounds.width , height: 64 )
        self.layerLine.frame = CGRectMake(0, 0,  self.view.frame.width, 1)

        if TabBarHidden.isTabBarHidden {
            self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY , width:self.view.bounds.width , height: 64 )
        }

      
    }
    
    
    func cancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func save(){
        print("invoke service set preferences")
        let peferencesService =  SetPreferencesService()
        
        let  params = peferencesService.buildParams(self.userPreferences["userPreferences"] as! NSArray, onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as! String, abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.userPreferences["receivePromoEmail"] as! String, forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: true, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
        peferencesService.jsonFromObject(params)
        peferencesService.callService(requestParams:params , successBlock: { (result:NSDictionary) in
            print("Preferencias Guardadas")
            self.invokePreferenceService()
            
            }, errorBlock: { (error:NSError) in
                print("Hubo un error al guardar las Preferencias")
                
        })
    }
    
    
    //MARK: Services
    
    func invokePreferenceService(){
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:NSDictionary) in
            self.userPreferences.addEntriesFromDictionary(result as [NSObject : AnyObject])
            print("Termina servicio de preferencias ")
            }, errorBlock: { (error:NSError) in
                print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    //MARK: PreferencesNotificationsCellDelegate
    func changeStatus(row: Int, value: Bool) {
        
        if row == 0 {//coore
            self.userPreferences.setObject(value, forKey:"receiveInfoEmail")
        }else if row == 1{//carrito
             self.userPreferences.setObject(value, forKey:"abandonCartAlert")
            
        }else{ //sms
              self.userPreferences.setObject(value, forKey:"telephonicSmsAlert")
        }
        
    }
    
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return indexPath.row == 2 ? 170 : 120
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var onSwich =  false
        
        if indexPath.row == 0 {//coore
        onSwich = userPreferences["receiveInfoEmail"] as! Bool
        }else if  indexPath.row == 1{//carrito
            onSwich = self.userPreferences["abandonCartAlert"] as! Bool
        }else{ //sms
            onSwich = self.userPreferences["telephonicSmsAlert"] as! Bool
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PreferencesNotificationsCell") as! PreferencesNotificationsCell!
        cell.setValues(self.titles[indexPath.row], description: self.descriptios[indexPath.row], isOn: onSwich,contenField: indexPath.row == self.titles.count - 1,position: indexPath.row,phone: self.userPreferences["mobileNumber"] as! String)
        cell.selectionStyle =  .None
        cell.delegate = self
        
        return cell
   
    }
    
    
    
    
    override func willHideTabbar() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY , width:self.view.bounds.width , height: 64 )
        })

    }
    
    override func willShowTabbar() {
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY - 46, width:self.view.bounds.width , height: 64 )

        })

    }
    
    
}