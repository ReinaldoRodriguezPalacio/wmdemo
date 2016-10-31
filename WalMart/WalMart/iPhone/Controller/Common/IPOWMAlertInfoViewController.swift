//
//  IPOWMAlertInfoViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 26/10/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPOWMAlertInfoViewController : IPOWMAlertViewController  {

    
    var messageLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageWaiting != nil {
            imageIcon.removeFromSuperview()
            imageIcon.isHidden = false
        }
    
        titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(24)
        
        messageLabel = UILabel()
        messageLabel.font = WMFont.fontMyriadProRegularOfSize(15)
        messageLabel.textColor = WMColor.light_gray
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        
        spinImage.isHidden = true
        spinImage.removeFromSuperview()
        
        viewBgImage.isHidden = true
        viewBgImage.removeFromSuperview()
        
        self.view.addSubview(messageLabel)

    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        
        self.imageblur?.isHidden = true
        self.bgView.frame = bounds

       
        
        messageLabel!.sizeToFit()
        //messageLabel.frame = CGRectMake((bounds.width - 232) / 2, 100, 232, messageLabel!.frame.height)
        
        titleLabel!.sizeToFit()
        titleLabel.frame = CGRect(x: (bounds.width - 232) / 2,  y: 60, width: 232, height: 40)
        
        if self.doneButton != nil {
            doneButton.frame = CGRect(x: (bounds.width - 160 ) / 2, y: messageLabel.frame.maxY + 80, width: 160 , height: 40)
        }
        
        if leftButton != nil {
            leftButton.frame = CGRect(x: (self.view.bounds.width / 2) - 134, y: self.messageLabel.frame.maxY + 28, width: 128, height: 32)
        }
        
        if rightButton != nil {
            rightButton.frame =  CGRect(x: leftButton.frame.maxX + 11, y: leftButton.frame.minY, width: leftButton.frame.width, height: leftButton.frame.height)
        }
        
    }
    
    /**
    change frame to label mesage in alert info and set message
     
     - parameter message: message in alert info
     */
    func setAttributedMessage(_ message:NSMutableAttributedString){
        let size =  message.boundingRect(with: CGSize(width: self.view.bounds.width - 50, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        messageLabel.frame = CGRect(x: 24, y: 130, width: self.view.bounds.width - 50, height: size.height)
        messageLabel.attributedText = message
    }
    
    /**
     center message info
     
     - parameter labelWidth: Width message
     */
    func setMessageLabelToCenter(_ labelWidth: CGFloat){
        self.messageLabel.frame.size = CGSize(width: labelWidth, height: self.messageLabel.frame.height)
        let x = (self.view.frame.width - self.messageLabel.frame.width)/2
        let y = (self.view.frame.height - self.messageLabel.frame.height)/2
        messageLabel.frame.origin = CGPoint(x: x,y: y - 50)
    }
    
    /**
     Create alertViewcontroller.
     
     - parameter controller: controller where will present the alert
     - parameter title:      title alert
     - parameter message:    message alert
     
     - returns: alert view controller type info.
     */
    class func showAttributedAlert(_ controller:UIViewController, title: String, message:NSMutableAttributedString)  -> IPOWMAlertInfoViewController? {
        let newAlert = IPOWMAlertInfoViewController()
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        newAlert.titleLabel.text = title
        newAlert.setAttributedMessage(message)
        return newAlert

    }
    /**
     Create alertViewcontroller.
     
     - parameter controller: controller where will present the alert
     - parameter title:       title alert
     - parameter message:    message alert
     
     - returns: Alert view controller type info.
     */
     class func showAlert(_ controller:UIViewController, title: String, message:String)  -> IPOWMAlertInfoViewController? {
        let newAlert = IPOWMAlertInfoViewController()
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        newAlert.titleLabel.text = title
        newAlert.setMessage(message)
        return newAlert
        
    }
    
    /**
     call func to create alertView
     
     - parameter title:   Title alert
     - parameter message: Message in alert
     
     - returns: Alert view controller type info.
     */
    class func showAlert(_ title: String, message:String)  -> IPOWMAlertInfoViewController? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        if vc != nil {
            return showAlert(vc!,title:title,message:message)
        }
        return nil
    }

    /**
      call func to create alertView
     
     - parameter title:    Title alert
     - parameter message: Message in alert.
     
     - returns: Alert view controller type info.
     */
    class func showAttributedAlert(_ title: String, message:NSMutableAttributedString)  -> IPOWMAlertInfoViewController? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        if vc != nil {
            return showAttributedAlert(vc!,title:title,message:message)
        }
        return nil
    }

}
