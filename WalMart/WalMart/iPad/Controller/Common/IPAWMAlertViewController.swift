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
    var cancelButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     }
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
        
        let bounds = self.view.bounds
        
        titleLabel!.sizeToFit()
        
        if  self.isOtherFame {
            spinImage.frame = CGRectMake((bounds.width - 84)  / 2, (bounds.height - 84 - 200)  / 2, 84, 84)
            viewBgImage.frame = CGRectMake((bounds.width - 80)  / 2 , 192, 80, 80)
            
            if imageIcon != nil && imageIcon.image != nil {
                imageIcon.frame = CGRectMake( 0,0,imageIcon.image!.size.width,imageIcon.image!.size.height)
                imageIcon.center = CGPointMake(viewBgImage.frame.width / 2, viewBgImage.frame.width / 2)
            }
        }

        titleLabel.frame = self.isOtherFame ? CGRectMake((self.view.bounds.width / 2) - (321 / 2),  viewBgImage.frame.maxY + 24, 321, titleLabel!.frame.height) :
            CGRectMake((bounds.width - 370) / 2,  viewBgImage.frame.maxY + 16, 370, titleLabel!.frame.height)
      
        if self.doneButton != nil {
            doneButton.frame = CGRectMake((bounds.width - 160 ) / 2, titleLabel.frame.maxY + 16, 160 , 40)
        }
        
        
        if leftButton != nil {
            leftButton.frame =  self.isOtherFame ? CGRectMake((self.view.bounds.width / 2) - (288 / 2),self.titleLabel.frame.maxY + 52 + 56, 288, 32) :
                CGRectMake((self.view.bounds.width / 2) - 134, self.titleLabel.frame.maxY + 16, 128, 32)
        }
        
        
        if rightButton != nil {
            rightButton.frame =  self.isOtherFame ? CGRectMake((self.view.bounds.width / 2) - (288 / 2), self.titleLabel.frame.maxY + 52, 288, 32) :
                CGRectMake(leftButton.frame.maxX + 11, self.titleLabel.frame.maxY + 16, leftButton.frame.width, leftButton.frame.height)
        }
        
        
       

        

        
     
    
    }
    
    override class func showAlert(imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPAWMAlertViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            vc?.view.endEditing(true)
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
        newAlert!.showCancelButton("Cancelar", colorButton:WMColor.dark_blue)
        return newAlert
    }
    
     func showCancelButton(titleDone:String, colorButton: UIColor) {
        if  self.doneButton != nil{
            self.doneButton.removeFromSuperview()
        }
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(titleDone, forState: UIControlState.Normal)
        self.cancelButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.cancelButton!.backgroundColor = colorButton
        
        self.cancelButton!.addTarget(self, action: "cancelBtn", forControlEvents: .TouchUpInside)
        self.cancelButton!.layer.cornerRadius = 20
        
        var bounds = self.view.bounds
        if self.view.superview != nil {
            bounds = self.view.superview!.bounds
        }
        
        self.cancelButton!.frame = CGRectMake((bounds.width - 128 ) / 2, (bounds.height / 2) + 25, 128 , 40)
        self.view.addSubview(cancelButton!)
    }
    
    func cancelBtn(){
        self.close()
        delegate?.cancelButtonTapped()
    }


}
