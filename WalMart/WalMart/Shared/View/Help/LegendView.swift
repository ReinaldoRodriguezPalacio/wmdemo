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
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.isUserInteractionEnabled =  true
        
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
        legendForm!.backgroundColor = UIColor.white
        legendForm!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:#selector(LegendView.panViewGesture(_:)) ))
        legendForm!.layer.cornerRadius =  11
        legendForm!.clipsToBounds =  true
        self.addSubview(legendForm!)
        
        let headerView =  UIView(frame: CGRect(x: 0, y: 0, width:legendForm!.frame.width, height:46))
        headerView.backgroundColor = WMColor.light_light_gray
        legendForm!.addSubview(headerView)
        
        
        let buttonClose = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        buttonClose.setImage(UIImage(named:"detail_close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(HelpHomeView.closeView), for: UIControlEvents.touchUpInside)
        headerView.addSubview(buttonClose)
        
        let titleLegend =  UILabel(frame: CGRect(x: buttonClose.frame.maxX , y: 0,width: legendForm!.frame.width - (44 + 21 + 16), height: 46))
        titleLegend.text = NSLocalizedString("Leyendas", comment: "")
        titleLegend.textAlignment = .center
        titleLegend.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLegend.textColor =  WMColor.regular_blue
        titleLegend.textAlignment =  .center
        headerView.addSubview(titleLegend)
        
        let buttonMove = UIImageView(frame: CGRect(x: titleLegend.frame.maxX,y: (headerView.frame.height - 16) / 2 , width: 21, height: 16))
        buttonMove.image = UIImage(named: "icon_move_pop")
        headerView.addSubview(buttonMove)
        
        self.createIcons(headerView)
        
    }
    
    
    /**
     Create icons and labels in view
     
     - parameter headerView: header
     */
    func createIcons(_ headerView:UIView){
        
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
            
            let icon =  UILabel(frame: CGRect(x: 0, y: 0,width: viewIcon.frame.width, height: viewIcon.frame.height))
            icon.text = legendsIcon[index]
            icon.textAlignment = .center
            icon.font = WMFont.fontMyriadProRegularOfSize(9)
            icon.textColor = UIColor.white
            icon.textAlignment =  .center
            viewIcon.addSubview(icon)
            
            
            let iconDescription =  UILabel(frame: CGRect(x: viewIcon.frame.maxX + 4 ,y: headerView.frame.maxY + y,width: 79 ,height: 14))
            iconDescription.text = legends[index]
            iconDescription.textAlignment = .center
            iconDescription.font = WMFont.fontMyriadProRegularOfSize(9)
            iconDescription.textColor = WMColor.reg_gray
            iconDescription.textAlignment =  .left
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
    func panViewGesture(_ sender: UIPanGestureRecognizer) {
        let locationInView = sender.location(in: self)
        if sender.state == .changed {
            self.legendForm!.frame = CGRect(x: locationInView.x - (self.legendForm!.frame.width - 23),
                                                y: locationInView.y - 23 ,
                                                width: self.legendForm!.frame.width,
                                                height: self.legendForm!.frame.height )
        }
    }
    /**
     Close legend view
     */
    func closeView(){
        if onClose != nil {
            onClose!()
        }
    }

    /**
     show legend form
     
     - parameter viewPresent: view on present
     */
    func showLegend(_ viewPresent:UIView){
        if IS_IPAD {
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController {
                self.frame = CGRect(x: 0,y: 0 , width: customBar.view.bounds.width, height: customBar.view.frame.height)
                
                self.onClose  = {() in
                    self.removeLegend()
                }
                customBar.view.addSubview(self)
            }
    
        }else{
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? CustomBarViewController {
                self.frame = CGRect(x: 0,y: 0 , width: viewPresent.bounds.width, height: customBar.view.frame.height)
                
                self.onClose  = {() in
                    self.removeLegend()
                }
                customBar.view.addSubview(self)
            }
        }
    }
    
    /**
     Remove legend from superview
     */
    func removeLegend() {
        
        UIView.animate(withDuration: 0.5,
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
