//
//  ContactProviderViewController.swift
//  WalMart
//
//  Created by Daniel V on 07/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation
import MessageUI

class ContactProviderViewController: NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, MFMailComposeViewControllerDelegate{
  
  var scrollContact : TPKeyboardAvoidingScrollView!
  var viewGral : UIView!
  var notificationLabel : UILabel!
  var separatorView : UIView!
  
  var addressTitleLbl : UILabel!
  var addressDescrLbl : UILabel!
  var phoneTitleLbl : UILabel!
  var phoneDescrLbl : UILabel!
  var emailTitleLbl : UILabel!
  var emailDescrLbl : UILabel!
  var fiscalDataTitleLbl : UILabel!
  var fiscalDataDescrLbl : UILabel!
  
  var callBtn : UIButton!
  var emailBtn : UIButton!
  var callLbl : UILabel!
  var emailLbl : UILabel!
  
  var emailProvider : String!
  var numberPhoneProvider : String!
  
  override func getScreenGAIName() -> String {
    return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.white
    self.titleLabel!.text = "Contactar al Proveedor"//NSLocalizedString("profile.myOrders", comment: "")
    
    self.emailProvider = "contacto_acme@gmail.com"//cambiar a correo de proveedor
    self.numberPhoneProvider = "5523456789"
    
    
    self.viewGral = UIView(frame: CGRect(x: 0, y: 46, width: self.view.frame.width, height: 72))
    self.viewGral.backgroundColor = UIColor.white
    
    self.notificationLabel = UILabel()
    self.notificationLabel.font = WMFont.fontMyriadProRegularOfSize(14.0)
    self.notificationLabel.textColor = WMColor.gray
    self.notificationLabel.numberOfLines = 3
    self.notificationLabel.text = "Si tienes algún problema con tu orden o artículos (s) puedes contactar al vendedor para solicitarle mayor información."
    
    self.separatorView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    self.separatorView.backgroundColor = WMColor.light_light_gray
    
    self.addressTitleLbl = self.labelContact(true)
    self.addressTitleLbl.text = "Dirección"
    
    self.addressDescrLbl = self.labelContact(false)
    self.addressDescrLbl.text = "Av. San Francisco no. 1621, Del Valle, Benito Juárez, Ciudad de México. 03100"
    self.addressDescrLbl.numberOfLines = 4
    
    self.phoneTitleLbl = self.labelContact(true)
    self.phoneTitleLbl.text = "Teléfono"
    
    self.phoneDescrLbl = self.labelContact(false)
    self.phoneDescrLbl.text = self.numberPhoneProvider
    self.phoneDescrLbl.textColor = WMColor.light_blue
    
    self.emailTitleLbl = self.labelContact(true)
    self.emailTitleLbl.text = "Correo electrónico"
    
    self.emailDescrLbl = self.labelContact(false)
    self.emailDescrLbl.text = self.emailProvider
    self.emailDescrLbl.textColor = WMColor.light_blue
    
    self.fiscalDataTitleLbl = self.labelContact(true)
    self.fiscalDataTitleLbl.text = "Datos fiscales"
    
    self.fiscalDataDescrLbl = self.labelContact(false)
    self.fiscalDataDescrLbl.text = "RFCX0000009G9\nRazón social SA DE CV\nAv. San Francisco no. 1621, Del Valle, Benito Juárez,\nCiudad de México. 03100"
    self.fiscalDataDescrLbl.numberOfLines = 4
    
    
    self.callBtn = UIButton()
    self.emailBtn = UIButton()
    
    self.callBtn.setImage(UIImage(named:"call_provider"), for: UIControlState())
    self.callBtn.setImage(UIImage(named:"call_provider"), for: UIControlState.selected)
    self.callBtn.imageEdgeInsets = UIEdgeInsets(top: 7,left: 17,bottom: 6,right: 126)
    self.callBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0);
    self.callBtn.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
    self.callBtn.titleLabel?.textColor = UIColor.white
    self.callBtn.setTitle("Llámanos", for: UIControlState())
    self.callBtn.layer.cornerRadius = 15
    self.callBtn.addTarget(self , action: #selector(ContactProviderViewController.selectecButton(_:)), for:UIControlEvents.touchUpInside)
    self.callBtn.backgroundColor = WMColor.green
    
    self.emailBtn.setImage(UIImage(named:"message_provider"), for: UIControlState())
    self.emailBtn.setImage(UIImage(named:"message_provider"), for: UIControlState.selected)
    self.emailBtn.imageEdgeInsets = UIEdgeInsets(top: 7,left: 17,bottom: 6,right: 126)
    self.emailBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0);
    self.emailBtn.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
    self.emailBtn.titleLabel?.textColor = UIColor.white
    self.emailBtn.setTitle("Escríbenos", for: UIControlState())
    self.emailBtn.layer.cornerRadius = 15
    self.emailBtn.addTarget(self , action: #selector(ContactProviderViewController.sendEmailProvider), for:UIControlEvents.touchUpInside)
    self.emailBtn.backgroundColor = WMColor.green
    
    
    
    
    self.callLbl = UILabel()
    self.callLbl.font = WMFont.fontMyriadProRegularOfSize(12.0)
    self.callLbl.textColor = WMColor.gray
    self.callLbl.textAlignment = .center
    self.callLbl.text = self.numberPhoneProvider
    
    self.emailLbl = UILabel()
    self.emailLbl.font = WMFont.fontMyriadProRegularOfSize(12.0)
    self.emailLbl.textColor = WMColor.gray
    self.emailLbl.textAlignment = .center
    self.emailLbl.text = self.emailProvider
    
    
    self.viewGral.addSubview(self.notificationLabel)
    self.viewGral.addSubview(self.separatorView)
    self.viewGral.addSubview(self.addressTitleLbl)
    self.viewGral.addSubview(self.addressDescrLbl)
    
    self.viewGral.addSubview(self.phoneTitleLbl)
    self.viewGral.addSubview(self.phoneDescrLbl)
    self.viewGral.addSubview(self.emailTitleLbl)
    self.viewGral.addSubview(self.emailDescrLbl)
    self.viewGral.addSubview(self.fiscalDataTitleLbl)
    self.viewGral.addSubview(self.fiscalDataDescrLbl)
    
    self.viewGral.addSubview(self.callBtn)
    self.viewGral.addSubview(self.emailBtn)
    self.viewGral.addSubview(self.callLbl)
    self.viewGral.addSubview(self.emailLbl)
    
    
    scrollContact = TPKeyboardAvoidingScrollView()
    //self.scrollContact.backgroundColor = WMColor.light_red
    self.scrollContact.scrollDelegate = self
    scrollContact.contentSize = CGSize( width: self.view.bounds.width, height: 720)
    scrollContact.addSubview(viewGral)
    self.view.addSubview(scrollContact)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    self.notificationLabel.frame = CGRect(x: 16.0, y: 8.0, width: (self.view.frame.width - 32.0), height: 45.0)
    self.separatorView.frame = CGRect(x: 0.0, y: self.notificationLabel.frame.maxY + 8.0, width: self.view.frame.width, height: 1.0)
    self.addressTitleLbl.frame = CGRect(x: 16.0, y: self.separatorView.frame.maxY + 15.5, width: (self.view.frame.width - 32.0), height: 14.0)
    self.addressDescrLbl.frame = CGRect(x: 16.0, y: self.addressTitleLbl.frame.maxY + 4.5, width: (self.view.frame.width - 32.0), height: 32.0)
    
    self.phoneTitleLbl.frame = CGRect(x: 16.0, y: self.addressDescrLbl.frame.maxY + 16.0, width: (self.view.frame.width - 32.0), height: 14.0)
    self.phoneDescrLbl.frame = CGRect(x: 16.0, y: self.phoneTitleLbl.frame.maxY + 4.5, width: (self.view.frame.width - 32.0), height: 16.0)
    self.emailTitleLbl.frame = CGRect(x: 16.0, y: self.phoneDescrLbl.frame.maxY + 16.0, width: (self.view.frame.width - 32.0), height: 14.0)
    self.emailDescrLbl.frame = CGRect(x: 16.0, y: self.emailTitleLbl.frame.maxY + 4.5, width: (self.view.frame.width - 32.0), height: 16.0)
    self.fiscalDataTitleLbl.frame = CGRect(x: 16.0, y: self.emailDescrLbl.frame.maxY + 16.0, width: (self.view.frame.width - 32.0), height: 14.0)
    self.fiscalDataDescrLbl.frame = CGRect(x: 16.0, y: self.fiscalDataTitleLbl.frame.maxY + 4.5, width: (self.view.frame.width - 32.0), height: 64.0)
    
    if IS_IPHONE {
        self.callBtn.frame = CGRect(x: 16.0, y: self.fiscalDataDescrLbl.frame.maxY + 48.0, width: (self.view.frame.width / 2) - 24.0, height: 34.0)
        self.emailBtn.frame = CGRect(x: self.callBtn.frame.maxX + 8.0, y: self.callBtn.frame.minY, width: (self.view.frame.width / 2) - 24.0, height: 34.0)
        self.callLbl.frame = CGRect(x: 16.0, y: self.callBtn.frame.maxY + 8.0, width: self.callBtn.frame.width, height: 12.0)
        self.emailLbl.frame = CGRect(x: self.emailBtn.frame.minX, y: self.callLbl.frame.minY, width: self.callBtn.frame.width, height: 12.0)
    } else {
        
        self.callBtn.isHidden = true
        self.callLbl.isHidden = true
        let widthBtns = (self.view.frame.width / 2) - 32.0
        self.emailBtn.frame = CGRect(x: (self.view.frame.width - widthBtns - 16) / 2, y: self.fiscalDataDescrLbl.frame.maxY + 48.0, width: widthBtns, height: 34.0)
        self.emailLbl.frame = CGRect(x: self.emailBtn.frame.minX, y: self.emailBtn.frame.maxY + 8.0, width: widthBtns, height: 12.0)
    }
    
    self.viewGral.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.emailLbl.frame.maxY + 16.0)
    
    scrollContact.contentSize = CGSize( width: self.view.bounds.width, height: self.viewGral.frame.height)
    scrollContact.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.frame.height - self.header!.frame.maxY - 44)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func back() {
    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_PREVIOUS_ORDERS.rawValue, action: WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label: "")
    super.back()
  }
  
  
  func labelContact(_ isTitle:Bool) -> UILabel {
    let labelTitleItem = UILabel(frame: CGRect.zero)
    labelTitleItem.font = isTitle ? WMFont.fontMyriadProSemiboldSize(16.0) : WMFont.fontMyriadProRegularOfSize(16.0)
    labelTitleItem.textColor = WMColor.gray
    labelTitleItem.textAlignment = .left
    return labelTitleItem
  }
  
  func selectecButton(_ sender:UIButton){
    if sender == self.callBtn{
      self.emailBtn.isSelected = false
      print("Selected call", terminator: "")
      if IS_IPHONE == true {
        let strTel = "telprompt://018009256278" //self.numberPhoneProvider
        if UIApplication.shared.canOpenURL(URL(string: strTel)!) {
          UIApplication.shared.openURL(URL(string: strTel)!)
        }
      }
      
    }
  }
  
  //MARK: - MFMailComposeViewControllerDelegate
  func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func sendEmailProvider(){
    
    print("email provider", terminator: "")
    
    let subject = "Titulo de Correo"
    
    if  MFMailComposeViewController.canSendMail(){
      let mc: MFMailComposeViewController = MFMailComposeViewController()
      mc.mailComposeDelegate = self
      mc.setSubject(subject)//Titulo de ,correo
      mc.setMessageBody("message Body", isHTML: false)
      mc.setToRecipients([self.emailProvider])
      
      self.present(mc, animated: true, completion: nil)
    }
    else{
      let alert = IPOWMAlertViewController.showAlert(UIImage(named:"alert_ups"),imageDone: UIImage(named:"alert_ups"), imageError: UIImage(named:"alert_ups"))
      alert!.setMessage("No se encontro una cuenta de correo configurada")
      alert!.showErrorIcon("Ok")
    }
  }
  
}
