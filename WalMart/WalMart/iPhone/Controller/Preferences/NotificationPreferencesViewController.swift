//
//  NotificationPreferencesViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 05/10/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class NotificationPreferencesViewController : NavigationViewController,UITableViewDataSource, UITableViewDelegate,PreferencesNotificationsCellDelegate,UIScrollViewDelegate {
    
    let titles =  ["Promociones por correo electrónico", "Carrito abandonado", "Promociones por SMS"]
    let descriptios = ["Deseo recibir información de walmart.com.mx en mi buzón de correo.", "Deseo recibir notificaciones de mi carrito abandonado de walmart.com.mx en mi correo electrónico.","Deseo recibir información vía SMS."]

    var userPreferences : NSMutableDictionary = [:]
    var tableview :  UITableView?
    var viewFooter : UIView?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var alertView: IPOWMAlertViewController?
    var cellPreferences : PreferencesNotificationsCell?
    var fieldValidate : FormFieldView?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREFERENCES_NOTIFICATION.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  UIColor.white
        self.titleLabel?.text =  "Alertas y Notificaciones"
        
        self.tableview =  UITableView()
        self.tableview!.register(PreferencesNotificationsCell.self, forCellReuseIdentifier: "PreferencesNotificationsCell")
        self.tableview!.delegate = self
        self.tableview?.dataSource = self
        self.tableview!.separatorStyle = .none
        self.view.addSubview(self.tableview!)
        
        self.viewFooter =  UIView()
        self.viewFooter?.backgroundColor = UIColor.white
        self.view.addSubview(viewFooter!)
        
        layerLine =  CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        viewFooter!.layer.insertSublayer(layerLine, at: 1000)
        layerLine.frame = CGRect(x: 0, y: 0, width: self.viewFooter!.frame.width, height: 2)

        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(NSLocalizedString("productdetail.cancel", comment:""), for:UIControlState())
        self.cancelButton!.titleLabel!.textColor = UIColor.white
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NotificationPreferencesViewController.cancel), for: UIControlEvents.touchUpInside)
        self.viewFooter!.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle(NSLocalizedString("Guardar", comment:""), for:UIControlState())
        self.saveButton!.titleLabel!.textColor = UIColor.white
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(NotificationPreferencesViewController.save), for: UIControlEvents.touchUpInside)
        self.viewFooter!.addSubview(saveButton!)
        
        self.invokePreferenceService()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableview?.frame =  CGRect(x: 0,y: self.header!.frame.maxY,width: self.view.frame.width ,height: IS_IPAD ? self.view.frame.height - 64 :self.view.frame.height - (self.headerHeight + 64))
       
        self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY - 46, width:self.view.bounds.width , height: 64 )
        self.layerLine.frame = CGRect(x: 0, y: 0,  width: self.view.frame.width, height: 1)

        if TabBarHidden.isTabBarHidden {
            self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY , width:self.view.bounds.width , height: 64 )
        }
        
        self.cancelButton!.frame = CGRect(x: (self.view.frame.width/2) - 148, y: 16, width: 140, height: 34)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) + 8 ,y: 16, width: 140, height: 34)

      
    }
    
    func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func save(){
        
        print("invoke service set preferences")
        

        if cellPreferences!.validate(self.tableview?.cellForRow(at: IndexPath(row: 2, section: 0)) as! PreferencesNotificationsCell) {
            
            let peferencesService =  SetPreferencesService()
            let  params = peferencesService.buildParams(self.userPreferences["userPreferences"] as! NSArray, onlyTelephonicAlert: self.userPreferences["onlyTelephonicAlert"] as! String, abandonCartAlert: self.userPreferences["abandonCartAlert"] as! Bool, telephonicSmsAlert: self.userPreferences["telephonicSmsAlert"] as! Bool, mobileNumber: self.userPreferences["mobileNumber"] as! String, receivePromoEmail: self.userPreferences["receivePromoEmail"] as! String, forOBIEE: self.userPreferences["forOBIEE"] as! Bool, acceptConsent: true, receiveInfoEmail: self.userPreferences["receiveInfoEmail"] as! Bool)
            peferencesService.jsonFromObject(params)
            
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"icon_alert_saving"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"alert_ups"))
            self.alertView!.setMessage(NSLocalizedString("preferences.message.saving", comment:""))
            
            peferencesService.callService(requestParams:params , successBlock: { (result:NSDictionary) in
                print("Preferencias Guardadas")
                self.alertView!.setMessage(NSLocalizedString("preferences.message.saved", comment:""))
                self.alertView!.showDoneIcon()
                self.invokePreferenceService()
                }, errorBlock: { (error:NSError) in
                    print("Hubo un error al guardar las Preferencias")
                    self.alertView!.setMessage(NSLocalizedString("preferences.message.errorSave", comment:""))
                    self.alertView!.showErrorIcon("Ok")
            })
        }

    }
    
    
    //MARK: Services
    
    func invokePreferenceService(){
        let peferences = GetPreferencesService()
        peferences.getLocalPreferences({ (result:NSDictionary) in
            self.userPreferences.addEntries(from: result as [AnyHashable: Any])
            self.tableview?.reloadData()
            print("Termina servicio de preferencias ")
            }, errorBlock: { (error:NSError) in
                print("Error invokePreferenceService \(error.localizedDescription)")
        })
        
    }
    
    //MARK: PreferencesNotificationsCellDelegate
    
    func changeStatus(_ row: Int, value: Bool) {
        
        if row == 0 {//coore
            self.userPreferences.setObject(value, forKey:"receiveInfoEmail" as NSCopying)
        }else if row == 1{//carrito
            self.userPreferences.setObject(value, forKey:"abandonCartAlert" as NSCopying)
            
        }else{ //sms
            self.userPreferences.setObject(value, forKey:"telephonicSmsAlert" as NSCopying)
            if !value {
                self.tableview?.setContentOffset(CGPoint.zero, animated:false)
                cellPreferences?.endEditing(true)
                cellPreferences?.phoneField?.isHidden = true
                self.userPreferences.setObject("", forKey:"mobileNumber" as NSCopying)
                cellPreferences?.errorView?.removeFromSuperview()
            }
        }
        
    }
    
    func editPhone(inEdition edition: Bool, field: FormFieldView) {
    
        if edition {
            self.tableview?.setContentOffset(CGPoint(x: 0, y:IS_IPAD ? self.view.frame.midY - 64  :self.view.frame.midY + (IS_IPHONE_4_OR_LESS ? 60: 20)), animated:false)
            self.userPreferences.setObject("", forKey:"mobileNumber" as NSCopying)
        }else{
            self.tableview?.setContentOffset(CGPoint.zero, animated:false)
             self.userPreferences.setObject(field.text!, forKey:"mobileNumber" as NSCopying)
            
        }
        self.fieldValidate = field
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = IS_IPAD ? 100 : 110
       
        if (indexPath as NSIndexPath).row == 1 {
            height = IS_IPAD ? 100 : 126
        }else if (indexPath as NSIndexPath).row == 2 {
            height = 170
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferencesNotificationsCell") as! PreferencesNotificationsCell!
        
        var onSwich =  false
        if userPreferences.count > 0 {
            
            if (indexPath as NSIndexPath).row == 0 {//coore
                onSwich = userPreferences["receiveInfoEmail"] as! Bool
            }else if  (indexPath as NSIndexPath).row == 1{//carrito
                onSwich = self.userPreferences["abandonCartAlert"] as! Bool
            }else{ //sms
                onSwich = self.userPreferences["telephonicSmsAlert"] as! Bool
            }
            
            cell?.setValues(self.titles[(indexPath as NSIndexPath).row], description: self.descriptios[(indexPath as NSIndexPath).row], isOn: onSwich,contenField: (indexPath as NSIndexPath).row == self.titles.count - 1,position: (indexPath as NSIndexPath).row,phone: self.userPreferences["mobileNumber"] as! String)
            cell?.selectionStyle =  .none
            cell?.delegate = self
            
            cellPreferences =  cell
        }
        
        return cell!
        
    }

    
    override func willHideTabbar() {
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY , width:self.view.bounds.width , height: 64 )
        })

    }
    
    override func willShowTabbar() {
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.viewFooter?.frame = CGRect(x:0 , y:self.tableview!.frame.maxY - 46, width:self.view.bounds.width , height: 64 )

        })

    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    
    
    
}
