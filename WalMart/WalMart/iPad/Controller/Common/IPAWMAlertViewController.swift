//
//  IPAWMAlertViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 15/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAWMAlertViewControllerDelegate: class {
    
    func cancelButtonTapped()
}

class IPAWMAlertViewController: IPOWMAlertViewController {
    weak var delegate:IPAWMAlertViewControllerDelegate?
    var cancelButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     }
    
    override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
        
        let bounds = self.view.bounds
        
        titleLabel!.sizeToFit()
        
        if  self.isOtherFame {
            spinImage.frame = CGRect(x: (bounds.width - 84)  / 2, y: (bounds.height - 84 - 200)  / 2, width: 84, height: 84)
            viewBgImage.frame = CGRect(x: (bounds.width - 80)  / 2 , y: 192, width: 80, height: 80)
            
            if imageIcon != nil && imageIcon.image != nil {
                imageIcon.frame = CGRect( x: 0,y: 0,width: imageIcon.image!.size.width,height: imageIcon.image!.size.height)
                imageIcon.center = CGPoint(x: viewBgImage.frame.width / 2, y: viewBgImage.frame.width / 2)
            }
        }

        titleLabel.frame = self.isOtherFame ? CGRect(x: (self.view.bounds.width / 2) - (471 / 2),  y: viewBgImage.frame.maxY + 24, width: 471, height: 90) :
            CGRect(x: (bounds.width - 370) / 2,  y: viewBgImage.frame.maxY + 16, width: 370, height: titleLabel!.frame.height)
      
        if self.doneButton != nil {
            doneButton.frame = CGRect(x: (bounds.width - 160 ) / 2, y: titleLabel.frame.maxY + 16, width: 160 , height: 40)
        }
        
        
        if leftButton != nil {
            leftButton.frame =  self.isOtherFame ? CGRect(x: (self.view.bounds.width / 2) - (288 / 2),y: self.titleLabel.frame.maxY + 52 + 56, width: 288, height: 32) :
                CGRect(x: (self.view.bounds.width / 2) - 134, y: self.titleLabel.frame.maxY + 16, width: 128, height: 32)
        }
        
        
        if rightButton != nil {
            rightButton.frame =  self.isOtherFame ? CGRect(x: (self.view.bounds.width / 2) - (288 / 2), y: self.titleLabel.frame.maxY + 52, width: 288, height: 32) :
                CGRect(x: leftButton.frame.maxX + 11, y: self.titleLabel.frame.maxY + 16, width: leftButton.frame.width, height: leftButton.frame.height)
        }
        
    
    }
    
    override class func showAlert(_ imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPAWMAlertViewController? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        //var frame = vc!.view.bounds
        if vc != nil {
            vc?.view.endEditing(true)
            return showAlert(vc!,imageWaiting:imageWaiting,imageDone:imageDone,imageError:imageError)
        }
        return nil
    }

    override class func showAlert(_ controller:UIViewController,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPAWMAlertViewController? {
        let newAlert = IPAWMAlertViewController()
        newAlert.imageWaiting = imageWaiting
        newAlert.imageDone = imageDone
        newAlert.imageError = imageError
        controller.addChildViewController(newAlert)
        newAlert.view.frame = controller.view.bounds
        controller.view.addSubview(newAlert.view)
        newAlert.didMove(toParentViewController: controller)
        return newAlert
    }
    
    class func showAlertWithCancelButton(_ controller:UIViewController,delegate:IPAWMAlertViewControllerDelegate,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPAWMAlertViewController? {
       let newAlert = showAlert(controller, imageWaiting: imageWaiting, imageDone: imageDone, imageError: imageError)
        newAlert?.delegate = delegate
        newAlert!.showCancelButton("Cancelar", colorButton:WMColor.dark_blue)
        return newAlert
    }
    
     func showCancelButton(_ titleDone:String, colorButton: UIColor) {
        if  self.doneButton != nil{
            self.doneButton.removeFromSuperview()
        }
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle(titleDone, for: UIControlState())
        self.cancelButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.cancelButton!.backgroundColor = colorButton
        
        self.cancelButton!.addTarget(self, action: #selector(IPAWMAlertViewController.cancelBtn), for: .touchUpInside)
        self.cancelButton!.layer.cornerRadius = 20
        
        var bounds = self.view.bounds
        if self.view.superview != nil {
            bounds = self.view.superview!.bounds
        }
        
        self.cancelButton!.frame = CGRect(x: (bounds.width - 128 ) / 2, y: (bounds.height / 2) + 25, width: 128 , height: 40)
        self.view.addSubview(cancelButton!)
    }
    
    override func setMessage(_ message:String){
        titleLabel.frame.size = CGSize(width: 471, height: titleLabel!.frame.height)
        
        let size =  message.boundingRect(with: CGSize(width: titleLabel.frame.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil)
        titleLabel.frame = CGRect(x: titleLabel.frame.minX, y: titleLabel.frame.minY, width: 471, height: size.height)
        titleLabel.text = message
    }
    
    func cancelBtn(){
        self.close()
        delegate?.cancelButtonTapped()
    }


}
