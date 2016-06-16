//
//  IPOWMAlertRatingViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 15/06/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPOWMAlertRatingViewController : IPOWMAlertViewController  {

    
    var centerButton :UIButton!
    var centerAction : (() -> Void)? = nil
    var ratingImage : UIImageView!
    var labelText : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewBgImage.hidden =  true
        ratingImage = UIImageView()
        ratingImage.image = UIImage(named: "ratingStars")
        
        labelText = UILabel()
        labelText.font = WMFont.fontMyriadProRegularOfSize(18)
        labelText.textColor = WMColor.light_gray
        labelText.textAlignment = .Center
        labelText.numberOfLines = 0
        labelText.text =  "¡Nos da mucho gusto!"
        
        self.view.addSubview(labelText)
        self.view.addSubview(ratingImage)
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
         let bounds = self.view.bounds
        
        ratingImage.frame = CGRectMake((bounds.width / 2) - 100 , 200, 200, 18)
        
        labelText.frame =  CGRectMake(16,  ratingImage.frame.maxY + 24, self.view.frame.width - 32, titleLabel!.frame.height)
        
       
        if IS_IPAD {
            titleLabel.frame =  CGRectMake((bounds.width / 2) - 144,  labelText.frame.maxY + 16, 288, titleLabel!.frame.height)
            centerButton.frame = CGRectMake((bounds.width / 2) - 144 , self.titleLabel.frame.maxY + 16, centerButton.frame.width, centerButton.frame.height)
        }else{
             titleLabel.frame =  CGRectMake(16,  labelText.frame.maxY + 16, self.view.frame.width - 32, titleLabel!.frame.height)
            centerButton.frame = CGRectMake(16, self.titleLabel.frame.maxY + 16, centerButton.frame.width, centerButton.frame.height)
        }
        leftButton.frame = CGRectMake(centerButton.frame.minX, self.centerButton.frame.maxY + 16, (centerButton.frame.width / 2) - 4, leftButton.frame.height)
        rightButton.frame = CGRectMake(leftButton.frame.maxX + 8, self.centerButton.frame.maxY + 16, leftButton.frame.width, rightButton.frame.height)
        

    }
    
    
    
    func addActionButtonsWithCustomTextRating(leftText:String,leftAction:(() -> Void),rightText:String,rightAction:(() -> Void),centerText:String,centerAction:(() -> Void)) {
    
        self.addActionButtonsWithCustomText(leftText, leftAction: leftAction, rightText: rightText, rightAction: rightAction, isNewFrame: false)
        
        
        centerButton = UIButton(frame:CGRectMake(16, self.titleLabel.frame.maxY + 29, 288,32))
        centerButton.layer.cornerRadius = 16
        centerButton.setTitle(centerText, forState: UIControlState.Normal)
        centerButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        centerButton.backgroundColor = WMColor.green
        centerButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        centerButton.addTarget(self, action: #selector(IPOWMAlertRatingViewController.centerTapInside), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.centerAction = centerAction
        
        self.view.addSubview(centerButton)
        

    }
    
    
    func centerTapInside() {
        if self.centerAction != nil {
            self.centerAction!()
        }
    }
    
    class func showAlertRating(imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPOWMAlertRatingViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            vc?.view.endEditing(true)
            return showAlert(vc!,imageWaiting:imageWaiting,imageDone:imageDone,imageError:imageError)
        }
        return nil
    }
    
    override class func showAlert(controller:UIViewController,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPOWMAlertRatingViewController? {
        let newAlert = IPOWMAlertRatingViewController()
        newAlert.imageWaiting = imageWaiting
        newAlert.imageDone = imageDone
        newAlert.imageError = imageError
        controller.addChildViewController(newAlert)
        controller.view.addSubview(newAlert.view)
        newAlert.view.frame = controller.view.bounds
        return newAlert
    }
    
    
    
}