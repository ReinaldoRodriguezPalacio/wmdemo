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
            imageIcon.hidden = false
        }
    
        titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(24)
        
        messageLabel = UILabel()
        messageLabel.font = WMFont.fontMyriadProRegularOfSize(15)
        messageLabel.textColor = WMColor.productAddToCartTitle
        messageLabel.textAlignment = .Left
        messageLabel.numberOfLines = 0
        
        spinImage.hidden = true
        spinImage.removeFromSuperview()
        
        viewBgImage.hidden = true
        viewBgImage.removeFromSuperview()
        
        self.view.addSubview(messageLabel)

    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        
        self.imageblur?.hidden = true
        self.bgView.frame = bounds

       
        
        messageLabel!.sizeToFit()
        //messageLabel.frame = CGRectMake((bounds.width - 232) / 2, 100, 232, messageLabel!.frame.height)
        
        titleLabel!.sizeToFit()
        titleLabel.frame = CGRectMake((bounds.width - 232) / 2,  60, 232, 40)
        
        if self.doneButton != nil {
            doneButton.frame = CGRectMake((bounds.width - 160 ) / 2, messageLabel.frame.maxY + 80, 160 , 40)
        }
        
        if leftButton != nil {
            leftButton.frame = CGRectMake((self.view.bounds.width / 2) - 134, self.messageLabel.frame.maxY + 16, 128, 32)
        }
        
        if rightButton != nil {
            rightButton.frame =  CGRectMake(leftButton.frame.maxX + 11, leftButton.frame.minY, leftButton.frame.width, leftButton.frame.height)
        }
        
    }
    
    func setAttributedMessage(message:NSMutableAttributedString){
        let size =  message.boundingRectWithSize(CGSizeMake(self.view.bounds.width - 50, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        messageLabel.frame = CGRectMake(24, 130, self.view.bounds.width - 50, size.height)
        messageLabel.attributedText = message
    }
    
    func setMessageLabelToCenter(){
        messageLabel.frame.origin = CGPoint(x: 24,y: (self.view.frame.height/2) - (self.messageLabel.frame.height/2))
    }
    
    
    class func showAttributedAlert(controller:UIViewController, title: String, message:NSMutableAttributedString)  -> IPOWMAlertInfoViewController? {
        let newAlert = IPOWMAlertInfoViewController()
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        newAlert.titleLabel.text = title
        newAlert.setAttributedMessage(message)
        return newAlert

    }
    
     class func showAlert(controller:UIViewController, title: String, message:String)  -> IPOWMAlertInfoViewController? {
        let newAlert = IPOWMAlertInfoViewController()
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        newAlert.titleLabel.text = title
        newAlert.setMessage(message)
        return newAlert
        
    }
    
    class func showAlert(title: String, message:String)  -> IPOWMAlertInfoViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            return showAlert(vc!,title:title,message:message)
        }
        return nil
    }

    
    class func showAttributedAlert(title: String, message:NSMutableAttributedString)  -> IPOWMAlertInfoViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            return showAttributedAlert(vc!,title:title,message:message)
        }
        return nil
    }

}
