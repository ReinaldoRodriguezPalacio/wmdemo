//
//  IPAWMAlertViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 15/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPAWMAlertViewController: IPOWMAlertViewController {
   
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

}
