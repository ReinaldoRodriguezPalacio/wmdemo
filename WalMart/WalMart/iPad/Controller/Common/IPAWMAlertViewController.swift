//
//  IPAWMAlertViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 15/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAWMAlertViewControllerDelegate {
    
    func cancelButtonTapped()
}

class IPAWMAlertViewController: IPOWMAlertViewController {
   var delegate:IPAWMAlertViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewBgImage.backgroundColor = WMColor.UIColorFromRGB(0x2870c9, alpha: 0.5)
     }
    
    override class func showAlert(imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPAWMAlertViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        var frame = vc!.view.bounds
        if vc != nil {
            return showAlert(vc!,imageWaiting:imageWaiting,imageDone:imageDone,imageError:imageError)
        }
        return nil
    }

    override class func showAlert(controller:UIViewController,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPAWMAlertViewController? {
        let newAlert = IPAWMAlertViewController()
        newAlert.imageWaiting = imageWaiting
        newAlert.imageDone = imageDone
        newAlert.imageError = imageError
        controller.addChildViewController(newAlert)
        newAlert.view.frame = controller.view.bounds
        controller.view.addSubview(newAlert.view)
        newAlert.didMoveToParentViewController(controller)
        return newAlert
    }
    
    class func showAlertWithCancelButton(controller:UIViewController,delegate:IPAWMAlertViewControllerDelegate,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPAWMAlertViewController? {
       let newAlert = showAlert(controller, imageWaiting: imageWaiting, imageDone: imageDone, imageError: imageError)
        newAlert?.delegate = delegate
        newAlert!.showOkButton("Cancelar", colorButton:WMColor.loginSignOutButonBgColor)
        return newAlert
    }
    
    override func showOkButton(titleDone:String, colorButton: UIColor) {
        if  self.doneButton != nil{
            self.doneButton.removeFromSuperview()
        }
        
        self.doneButton = UIButton()
        self.doneButton.setTitle(titleDone, forState: UIControlState.Normal)
        self.doneButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.doneButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.doneButton.backgroundColor = colorButton
        
        self.doneButton.addTarget(self, action: "cancelBtn", forControlEvents: .TouchUpInside)
        self.doneButton.layer.cornerRadius = 16
        
        var bounds = self.view.bounds
        if self.view.superview != nil {
            bounds = self.view.superview!.bounds
        }
        
        self.doneButton.frame = CGRectMake(0, 0, 160 , 32)
        self.view.addSubview(doneButton)
    }
    
    func cancelBtn(){
        self.close()
        delegate?.cancelButtonTapped()
    }


}
