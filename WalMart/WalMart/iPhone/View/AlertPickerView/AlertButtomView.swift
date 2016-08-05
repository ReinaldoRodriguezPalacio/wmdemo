//
//  AlertButtomView.swift
//  WalMart
//
//  Created by ISOL Ingenieria de Soluciones on 06/03/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class AlertButtomView : AlertPickerView {

    
    var buttonGroceries : UIButton!
    var buttonMG : UIButton!
    
    
    
    override  func setup() {
        self.backgroundColor = UIColor.clearColor()
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRectMake(0, 0, 286, 194))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.whiteColor()
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRectMake(0, 0, viewContent.frame.width, 46))
        headerView.backgroundColor = WMColor.light_light_gray
        viewContent.addSubview(headerView)
        
        let viewButton = UIButton(frame: CGRectMake(10, 3, 40, 40))
        viewButton.addTarget(self, action: Selector("closePicker"), forControlEvents: UIControlEvents.TouchUpInside)
        viewButton.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
        self.headerView.addSubview(viewButton)
        
        titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        
        headerView.addSubview(titleLabel)
        
        viewContentOptions = UIView(frame: CGRectMake(0, headerView.frame.height, viewContent.frame.width, viewContent.frame.height - headerView.frame.height))
     
       
        buttonGroceries = UIButton(frame: CGRectMake(0, 0, 210, 34))
        buttonGroceries.backgroundColor = WMColor.green
        buttonGroceries.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonGroceries.layer.cornerRadius = 17
        buttonGroceries.center = CGPointMake(self.viewContent.frame.width / 2, 34)
        buttonGroceries.addTarget(self, action: #selector(AlertButtomView.mailAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonGroceries.tag = 1
        
        
        buttonMG =  UIButton(frame: CGRectMake(0, buttonGroceries.frame.maxY + 50, 210, 34))
        buttonMG.backgroundColor = WMColor.light_blue
        buttonMG.layer.cornerRadius = 17
        buttonMG.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonMG.center = CGPointMake (self.viewContent.frame.width / 2, buttonGroceries.frame.maxY + 20 )
        buttonMG.addTarget(self, action: #selector(AlertButtomView.mailAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonMG.tag = 2
        
       
        self.viewContentOptions.addSubview(buttonMG)
        self.viewContentOptions.addSubview(buttonGroceries)
        
        self.viewContent.addSubview(self.viewContentOptions)
        
        self.addSubview(viewContent)

    }
    
    override func layoutSubviews() {
        viewContent.center = self.center
        buttonGroceries.frame =  CGRectMake(38, 30, 210, 34)
         buttonMG.frame =  CGRectMake(38, buttonGroceries.frame.maxY + 20, 210, 34)
        
    }
    
    
   override class func initPickerWithDefault() -> AlertButtomView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertButtomView(frame:vc!.view.bounds)
        return newAlert
    }
    
    override func setValues(title:NSString,values:[String]) {
        
        self.titleLabel.text = title as String
        self.itemsToShow = values
    }
    
    override func startAnimating() {
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(fromView: self.superview!)
        let imgBackBlur = imgBack.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
        
        
        bgView.alpha = 0
        viewContent.transform = CGAffineTransformMakeTranslation(0,500)
        
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransformIdentity
            })
            
            }) { (complete:Bool) -> Void in
                
        }
        
    }
    
    func setNameBtn(titleBtnUp:NSString,titleBtnDown:NSString){
    
        self.buttonGroceries.setTitle(NSLocalizedString(titleBtnUp as String, comment: ""), forState: UIControlState.Normal)
        self.buttonMG.setTitle(NSLocalizedString(titleBtnDown as String, comment: ""), forState: UIControlState.Normal) 
    
    }
    
    func mailAction(sender:UIButton){
            delegate?.buttomViewSelected(sender)
    }
    
    
    
    
    
    

}