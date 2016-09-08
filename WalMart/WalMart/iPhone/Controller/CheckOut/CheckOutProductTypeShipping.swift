//
//  CheckOutProductTypeShipping.swift
//  WalMart
//
//  Created by Joel Juarez on 07/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class CheckOutProductTypeShipping: NavigationViewController {
    
    var deliveryButton : UIButton?
    var collectButton : UIButton?
    var titleDelivery : UILabel?
    
    var delivaryCost : CurrencyCustomLabel?
    var collectCost : CurrencyCustomLabel?
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = "Envio 2 de 2"
        
        self.titleDelivery = UILabel()
        self.titleDelivery!.textColor = WMColor.light_blue
        self.titleDelivery!.font = WMFont.fontMyriadProLightOfSize(14)
        self.titleDelivery!.text = "Selecciona el tipo de envío"
        self.titleDelivery!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(titleDelivery!)


        self.deliveryButton = UIButton()
        self.deliveryButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.deliveryButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.deliveryButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.deliveryButton!.setTitle("Envio a domicilio", forState: .Normal)
        self.deliveryButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:25 )
        self.deliveryButton!.backgroundColor =  UIColor.greenColor()
        self.deliveryButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.view.addSubview(deliveryButton!)
        
        delivaryCost = CurrencyCustomLabel(frame: CGRectMake(self.deliveryButton!.frame.maxX + 3, deliveryButton!.frame.minY, 50, 18))
        delivaryCost!.textAlignment = .Right
        self.view.addSubview(delivaryCost!)
        
        self.collectButton = UIButton()
        self.collectButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.collectButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.collectButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.collectButton!.setTitle("Recoger en Tienda", forState: .Normal)
        self.collectButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.collectButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:25 )
        self.view.addSubview(collectButton!)
        
        collectCost = CurrencyCustomLabel(frame: CGRectMake(self.collectButton!.frame.maxX + 3, collectButton!.frame.minY, 50, 18))
        collectCost!.textAlignment = .Right
        self.view.addSubview(collectCost!)
        
        setvalues()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.titleDelivery?.frame =  CGRectMake(16,headerHeight + 16 ,self.view.frame.width - 32 ,46)
        
        self.deliveryButton?.frame =  CGRectMake(16,self.titleDelivery!.frame.maxY + 16 ,self.view.frame.midX - 16 ,17)
        delivaryCost?.frame = CGRectMake(self.deliveryButton!.frame.maxX + 3, deliveryButton!.frame.minY, 50, 12)
        
        self.collectButton?.frame =  CGRectMake(16,self.deliveryButton!.frame.maxY + 16 ,self.view.frame.midX - 16 ,17)
        collectCost?.frame = CGRectMake(self.collectButton!.frame.maxX + 3, collectButton!.frame.minY, 50, 12)


    
    }
    
    
    func setvalues(){
        
        delivaryCost!.updateMount( CurrencyCustomLabel.formatString(String("120.50")), font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.orange, interLine: false)
        
        collectCost!.updateMount( CurrencyCustomLabel.formatString(String("10.50")), font: WMFont.fontMyriadProRegularOfSize(18), color: WMColor.orange, interLine: false)
    
    }
    
    
    
    
    
    
    
    
    

}