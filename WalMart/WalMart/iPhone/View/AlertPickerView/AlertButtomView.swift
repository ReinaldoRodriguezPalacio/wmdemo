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
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRect(x: 0, y: 0, width: 286, height: 194))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.white
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: viewContent.frame.width, height: 46))
        headerView.backgroundColor = WMColor.light_light_gray
        viewContent.addSubview(headerView)
        
        let viewButton = UIButton(frame: CGRect(x: 10, y: 3, width: 40, height: 40))
        viewButton.addTarget(self, action: Selector("closePicker"), for: UIControlEvents.touchUpInside)
        viewButton.setImage(UIImage(named: "detail_close"), for: UIControlState())
        self.headerView.addSubview(viewButton)
        
        titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        
        headerView.addSubview(titleLabel)
        
        viewContentOptions = UIView(frame: CGRect(x: 0, y: headerView.frame.height, width: viewContent.frame.width, height: viewContent.frame.height - headerView.frame.height))
     
       
        buttonGroceries = UIButton(frame: CGRect(x: 0, y: 0, width: 210, height: 34))
        buttonGroceries.backgroundColor = WMColor.green
        buttonGroceries.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonGroceries.layer.cornerRadius = 17
        buttonGroceries.center = CGPoint(x: self.viewContent.frame.width / 2, y: 34)
        buttonGroceries.addTarget(self, action: #selector(AlertButtomView.mailAction(_:)), for: UIControlEvents.touchUpInside)
        buttonGroceries.tag = 1
        
        
        buttonMG =  UIButton(frame: CGRect(x: 0, y: buttonGroceries.frame.maxY + 50, width: 210, height: 34))
        buttonMG.backgroundColor = WMColor.light_blue
        buttonMG.layer.cornerRadius = 17
        buttonMG.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonMG.center = CGPoint (x: self.viewContent.frame.width / 2, y: buttonGroceries.frame.maxY + 20 )
        buttonMG.addTarget(self, action: #selector(AlertButtomView.mailAction(_:)), for: UIControlEvents.touchUpInside)
        buttonMG.tag = 2
        
       
        self.viewContentOptions.addSubview(buttonMG)
        self.viewContentOptions.addSubview(buttonGroceries)
        
        self.viewContent.addSubview(self.viewContentOptions)
        
        self.addSubview(viewContent)

    }
    
    override func layoutSubviews() {
        viewContent.center = self.center
        buttonGroceries.frame =  CGRect(x: 38, y: 30, width: 210, height: 34)
         buttonMG.frame =  CGRect(x: 38, y: buttonGroceries.frame.maxY + 20, width: 210, height: 34)
        
    }
    
    
   override class func initPickerWithDefault() -> AlertButtomView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = AlertButtomView(frame:vc!.view.bounds)
        return newAlert
    }
    
    override func setValues(_ title:NSString,values:[String]) {
        
        self.titleLabel.text = title as String
        self.itemsToShow = values
    }
    
    override func startAnimating() {
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(from: self.superview!)
        let imgBackBlur = imgBack?.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
        
        
        bgView.alpha = 0
        viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
        
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransform.identity
            })
            
            }) { (complete:Bool) -> Void in
                
        }
        
    }
    
    func setNameBtn(_ titleBtnUp:NSString,titleBtnDown:NSString){
    
        self.buttonGroceries.setTitle(NSLocalizedString(titleBtnUp as String, comment: ""), for: UIControlState())
        self.buttonMG.setTitle(NSLocalizedString(titleBtnDown as String, comment: ""), for: UIControlState()) 
    
    }
    
    func mailAction(_ sender:UIButton){
            delegate?.buttomViewSelected(sender)
    }
    
    
    
    
    
    

}
