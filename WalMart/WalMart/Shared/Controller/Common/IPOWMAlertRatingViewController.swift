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
        viewBgImage.isHidden =  true
        viewStarts = UIView()
        //ratingImage.image = UIImage(named: "ratingStars")
        
        labelText = UILabel()
        labelText.font = WMFont.fontMyriadProRegularOfSize(18)
        labelText.textColor = WMColor.light_gray
        labelText.textAlignment = .center
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
                viewStarts.frame = CGRect(x: (bounds.width / 2) - 80 , y: 200, width: 160, height: 18)
                labelText.frame =  CGRect(x: 16,  y: viewStarts.frame.maxY + 40, width: self.view.frame.width - 32, height: 20)
                
                titleLabel.frame =  CGRect(x: (bounds.width / 2) - 144,  y: labelText.frame.maxY + 29, width: 288, height: titleLabel!.frame.height)
                centerButton.frame = CGRect(x: (bounds.width / 2) - 144 , y: self.titleLabel.frame.maxY + 29, width: centerButton.frame.width, height: 40)
            }else{
                
                viewStarts.frame = CGRect(x: (bounds.width / 2) - 80 , y: 104, width: 160, height: 18)
                labelText.frame =  CGRect(x: 16,  y: viewStarts.frame.maxY + 40, width: self.view.frame.width - 32, height: 20)
                
                titleLabel.frame =  CGRect(x: 16,  y: labelText.frame.maxY + 16, width: self.view.frame.width - 32, height: titleLabel!.frame.height)
                centerButton.frame = CGRect(x: 16, y: self.titleLabel.frame.maxY + 29, width: centerButton.frame.width, height: 40)
            }
            
            leftButton.frame = CGRect(x: centerButton.frame.minX, y: self.centerButton.frame.maxY + 29, width: (centerButton.frame.width / 2) - 4, height: 40)
            rightButton.frame = CGRect(x: leftButton.frame.maxX + 8, y: self.centerButton.frame.maxY + 29, width: leftButton.frame.width, height: 40)
            
            createStartImage()
        }else{
            viewBgImage.isHidden =  false
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x,  y: viewBgImage.frame.maxY + 24, width: titleLabel.frame.size.width, height: titleLabel.frame.size.height)
            
            if IS_IPAD {
                leftButton.frame = CGRect(x: self.view.frame.midX - 144, y: titleLabel.frame.maxY + 40, width: 140, height: 40)
                rightButton.frame = CGRect(x: leftButton.frame.maxX + 8, y: titleLabel.frame.maxY + 40, width: leftButton.frame.size.width, height: 40)
            }else{
                leftButton.frame = CGRect(x: 16, y: titleLabel.frame.maxY + 40, width: 140, height: 40)
                rightButton.frame = CGRect(x: leftButton.frame.maxX + 8, y: titleLabel.frame.maxY + 40, width: leftButton.frame.size.width, height: 40)
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
    func addActionButtonsWithCustomTextRating(_ leftText:String,leftAction:  @escaping((Void) -> Void),rightText:String,rightAction: @escaping((Void) -> Void),centerText:String,centerAction: @escaping (() -> Void)) {
    
        self.addActionButtonsWithCustomText(leftText, leftAction:leftAction, rightText: rightText, rightAction: rightAction, isNewFrame: false)
        
        
        centerButton = UIButton(frame:CGRect(x: 16, y: self.titleLabel.frame.maxY + 29, width: 288,height: 40))
        centerButton.layer.cornerRadius = 20
        centerButton.setTitle(centerText, for: UIControlState())
        centerButton.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        centerButton.backgroundColor = WMColor.green
        centerButton.setTitleColor(UIColor.white, for: UIControlState())
        centerButton.addTarget(self, action: #selector(IPOWMAlertRatingViewController.centerTapInside), for: UIControlEvents.touchUpInside)
        
        
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
            start.frame = CGRect(x: left ,y: 0,width: 16,height: 16)
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
    class func showAlertRating(_ imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?)  -> IPOWMAlertRatingViewController? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
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
    override class func showAlert(_ controller:UIViewController,imageWaiting:UIImage?,imageDone:UIImage?,imageError:UIImage?) -> IPOWMAlertRatingViewController? {
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
