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
    //var ratingImage : UIImageView!
    var labelText : UILabel!
    var viewStarts: UIView!
    var isCustomAlert =  false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewBgImage.hidden =  true
        viewStarts = UIView()
        //ratingImage.image = UIImage(named: "ratingStars")
        
        labelText = UILabel()
        labelText.font = WMFont.fontMyriadProRegularOfSize(18)
        labelText.textColor = WMColor.light_gray
        labelText.textAlignment = .Center
        labelText.numberOfLines = 0
        labelText.text = NSLocalizedString("review.title.ok_rate", comment: "")
        
        self.view.addSubview(labelText)
        self.view.addSubview(viewStarts)
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        
        if !isCustomAlert {
            if IS_IPAD {
                viewStarts.frame = CGRectMake((bounds.width / 2) - 80 , 200, 160, 18)
                labelText.frame =  CGRectMake(16,  viewStarts.frame.maxY + 40, self.view.frame.width - 32, titleLabel!.frame.height)
                
                titleLabel.frame =  CGRectMake((bounds.width / 2) - 144,  labelText.frame.maxY + 29, 288, titleLabel!.frame.height)
                centerButton.frame = CGRectMake((bounds.width / 2) - 144 , self.titleLabel.frame.maxY + 29, centerButton.frame.width, 40)
            }else{
                
                viewStarts.frame = CGRectMake((bounds.width / 2) - 80 , 104, 160, 18)
                labelText.frame =  CGRectMake(16,  viewStarts.frame.maxY + 40, self.view.frame.width - 32, titleLabel!.frame.height)
                
                titleLabel.frame =  CGRectMake(16,  labelText.frame.maxY + 16, self.view.frame.width - 32, titleLabel!.frame.height)
                centerButton.frame = CGRectMake(16, self.titleLabel.frame.maxY + 29, centerButton.frame.width, 40)
            }
            
            leftButton.frame = CGRectMake(centerButton.frame.minX, self.centerButton.frame.maxY + 29, (centerButton.frame.width / 2) - 4, 40)
            rightButton.frame = CGRectMake(leftButton.frame.maxX + 8, self.centerButton.frame.maxY + 29, leftButton.frame.width, 40)
            
            createStartImage()
        }else{
            viewBgImage.hidden =  false
            titleLabel.frame = CGRectMake(titleLabel.frame.origin.x,  viewBgImage.frame.maxY + 24, titleLabel.frame.size.width, titleLabel.frame.size.height)
            if IS_IPAD {
                leftButton.frame = CGRectMake(self.view.frame.midX - 144, titleLabel.frame.maxY + 40, 140, 40)
                rightButton.frame = CGRectMake(leftButton.frame.maxX + 8, titleLabel.frame.maxY + 40, leftButton.frame.size.width, 40)
            }else{
                leftButton.frame = CGRectMake(16, titleLabel.frame.maxY + 40, 140, 40)
                rightButton.frame = CGRectMake(leftButton.frame.maxX + 8, titleLabel.frame.maxY + 40, leftButton.frame.size.width, 40)
            }
        }
    }
    
    
    /**
     Ceate custom buttons in alert
     
     - parameter leftText:     description button left
     - parameter leftAction:   block action left
     - parameter rightText:    description button right
     - parameter rightAction:  block action right
     - parameter centerText:   description button center
     - parameter centerAction: block action center
     */
    func addActionButtonsWithCustomTextRating(leftText:String,leftAction:(() -> Void),rightText:String,rightAction:(() -> Void),centerText:String,centerAction:(() -> Void)) {
    
        self.addActionButtonsWithCustomText(leftText, leftAction: leftAction, rightText: rightText, rightAction: rightAction, isNewFrame: false)
        
        
        centerButton = UIButton(frame:CGRectMake(16, self.titleLabel.frame.maxY + 29, 288,40))
        centerButton.layer.cornerRadius = 20
        centerButton.setTitle(centerText, forState: UIControlState.Normal)
        centerButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        centerButton.backgroundColor = WMColor.green
        centerButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        centerButton.addTarget(self, action: #selector(IPOWMAlertRatingViewController.centerTapInside), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.centerAction = centerAction
        
        self.view.addSubview(centerButton)
        

    }
    
    /**
     create stars image in alertview
     */
    func createStartImage(){
        var left :CGFloat = 0.0
        for _ in 0  ..< 5  {
         let start  =  UIImageView(image: UIImage(named: "ratingStars"))
            start.frame = CGRectMake(left ,0,16,16)
            self.viewStarts.addSubview(start)
            left = left + 36
        }
    }
    
    /**
     Action center button in this alert
     */
    func centerTapInside() {
        if self.centerAction != nil {
            self.centerAction!()
        }
    }
    
    /**
     Create alert in controler
     
     - parameter imageWaiting: image show
     - parameter imageDone:    image present when done
     - parameter imageError:   image present when error
     
     - returns: alert rating
     */
    class func showAlertRating(imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPOWMAlertRatingViewController? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            vc?.view.endEditing(true)
            return showAlert(vc!,imageWaiting:imageWaiting,imageDone:imageDone,imageError:imageError)
        }
        return nil
    }
    
    /**
     presenten alert
     
     - parameter controller: ciontroller to show alert
     - parameter imageWaiting: image show
     - parameter imageDone:    image present when done
     - parameter imageError:   image present when error
     
     - returns: alert rating
     */
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