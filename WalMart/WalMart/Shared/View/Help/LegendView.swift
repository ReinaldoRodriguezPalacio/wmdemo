//
//  LegendView.swift
//  WalMart
//
//  Created by Joel Juarez on 15/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class LegendView: UIView,UIGestureRecognizerDelegate {
    
     var onClose: ((Void) -> Void)?
     var legendForm :UIView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    func setup() {
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        self.userInteractionEnabled =  true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LegendView.closeView))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        self.createFormview()
      
    }
    
    override func layoutSubviews() {
          legendForm?.frame =  CGRect(x:  IS_IPAD ? self.frame.midX - 121 : 39, y: self.frame.midY - 116  , width:242, height:232)
    }
    
    /**
     Create view when all promotios 
     */
    func createFormview()  {
    
        legendForm =  UIView(frame: CGRect(x: IS_IPAD ? self.frame.midX - 121 : 39, y: self.frame.midY - 116  , width:242, height:232))
        legendForm!.backgroundColor = UIColor.whiteColor()
        legendForm!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:#selector(LegendView.panViewGesture(_:)) ))
        legendForm!.layer.cornerRadius =  11
        legendForm!.clipsToBounds =  true
        self.addSubview(legendForm!)
        
        let headerView =  UIView(frame: CGRect(x: 0, y: 0, width:legendForm!.frame.width, height:46))
        headerView.backgroundColor = WMColor.light_light_gray
        legendForm!.addSubview(headerView)
        
        
        let buttonClose = UIButton(frame: CGRectMake(0, 0, 44, 44))
        buttonClose.setImage(UIImage(named:"detail_close"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: #selector(HelpHomeView.closeView), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(buttonClose)
        
        let titleLegend =  UILabel(frame: CGRectMake(buttonClose.frame.maxX , 0,legendForm!.frame.width - (44 + 21 + 16), 46))
        titleLegend.text = NSLocalizedString("Leyendas", comment: "")
        titleLegend.textAlignment = .Center
        titleLegend.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLegend.textColor =  WMColor.regular_blue
        titleLegend.textAlignment =  .Center
        headerView.addSubview(titleLegend)
        
        let buttonMove = UIImageView(frame: CGRectMake(titleLegend.frame.maxX,(headerView.frame.height - 16) / 2 , 21, 16))
        buttonMove.image = UIImage(named: "icon_move_pop")
        headerView.addSubview(buttonMove)
        
        self.createIcons(headerView)
        
    }
    
    
    /**
     Create icons and labels in view
     
     - parameter headerView: header
     */
    func createIcons(headerView:UIView){
        
        var y : CGFloat = 16.0
        var x :CGFloat = 16.0
        var legends = [NSLocalizedString("promotion.new", comment: ""),NSLocalizedString("promotion.on.request", comment: ""),NSLocalizedString("promotion.presale", comment: ""),NSLocalizedString("promotion.package", comment: ""),NSLocalizedString("promotion.free", comment: ""),NSLocalizedString("promotion.in.store", comment: ""),NSLocalizedString("promotion.settlement", comment: ""),NSLocalizedString("promotion.end.end", comment: ""),NSLocalizedString("promotion.reduction", comment: ""),NSLocalizedString("promotion.cyber", comment: ""),NSLocalizedString("promotion.hotSale", comment: ""),NSLocalizedString("promotion.more.save", comment: ""),NSLocalizedString("promotion.low.price", comment: ""),NSLocalizedString("promotion.last.pieces", comment: ""),NSLocalizedString("promotion.more.art", comment: ""),NSLocalizedString("promotion.msi", comment: "")]
        
        var legendsIcon = ["N","Sp","Pv","P","Eg","Rt","L","Bf","R","Cm","Hs","A+","-$","Up","+A-","MSI"]
        
        for index in 0 ..< 16 {
            let viewIcon =  UIView(frame: CGRect(x: x ,y : headerView.frame.maxY + y , width: 18, height:14))
            viewIcon.tag = index
            viewIcon.layer.cornerRadius = 2
            
           
            
            if index == 0{
                viewIcon.backgroundColor =  WMColor.green
            }else if index == 1 || index == 2{
                viewIcon.backgroundColor =  WMColor.light_light_light_blue
            }else if index > 2 && index < 6 {
                viewIcon.backgroundColor =  WMColor.light_blue
            }
            else if index > 5 && index < 14 {
                viewIcon.backgroundColor =  WMColor.red
            }
            else{
             viewIcon.backgroundColor =  WMColor.yellow
            }
            
            legendForm!.addSubview(viewIcon)
            
            let icon =  UILabel(frame: CGRectMake(0, 0,viewIcon.frame.width, viewIcon.frame.height))
            icon.text = legendsIcon[index]
            icon.textAlignment = .Center
            icon.font = WMFont.fontMyriadProRegularOfSize(9)
            icon.textColor = UIColor.whiteColor()
            icon.textAlignment =  .Center
            viewIcon.addSubview(icon)
            
            
            let iconDescription =  UILabel(frame: CGRectMake(viewIcon.frame.maxX + 4 ,headerView.frame.maxY + y,79 ,14))
            iconDescription.text = legends[index]
            iconDescription.textAlignment = .Center
            iconDescription.font = WMFont.fontMyriadProRegularOfSize(9)
            iconDescription.textColor = WMColor.gray
            iconDescription.textAlignment =  .Left
            legendForm!.addSubview(iconDescription)
            
            y = y + 20.0
            if index == 7{
                x = iconDescription.frame.maxX + 16
                y =  16.0
            }
        }
        
    
    }
    
    
    /**
     Add gesture pan to view
     
     - parameter sender: view Reconozer
     */
    func panViewGesture(sender: UIPanGestureRecognizer) {
        let locationInView = sender.locationInView(self)
        if sender.state == .Changed {
            self.legendForm!.frame = CGRectMake(locationInView.x - (self.legendForm!.frame.width - 23),
                                                locationInView.y - 23 ,
                                                self.legendForm!.frame.width,
                                                self.legendForm!.frame.height )
        }
    }
    /**
     Close legend view
     */
    func closeView(){
        print("closeView")
        if onClose != nil {
            onClose!()
        }
    }

    /**
     show legend form
     
     - parameter viewPresent: view on present
     */
    func showLegend(viewPresent:UIView){
        
        let window = UIApplication.sharedApplication().keyWindow
        if let customBar = window!.rootViewController as? CustomBarViewController {
           self.frame = CGRectMake(0,0 , viewPresent.bounds.width, customBar.view.frame.height)
            
            self.onClose  = {() in
                self.removeLegend()
            }
            customBar.view.addSubview(self)
        }
        
        
    }
    
    /**
     Remove legend from superview
     */
    func removeLegend() {
        
        UIView.animateWithDuration(0.5,
                                   animations: { () -> Void in
                                    self.alpha = 0.0
            },
                                   completion: { (finished:Bool) -> Void in
                                    if finished {
                                        self.removeFromSuperview()
                                    }
            }
        )
        
    }
    
    
  
}