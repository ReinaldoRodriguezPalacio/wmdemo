//
//  KeyboardPicesViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 08/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class KeyboardPicesViewController : UIViewController, KeyboardViewDelegate {

    @IBOutlet var backgroundView : UIView!
    @IBOutlet weak var keyboardView: NumericKeyboardView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var orderPiceButton: UIButton!
    @IBOutlet weak var viewContainerQ: UIView!
    
    
    var lblQuantity : UILabel!
    
    var currentValGr : Double! = 50.0
    var currentValCstmGr : Double! = 0.0
    var priceProduct : NSNumber! = NSNumber(value: 0 as Int32)
    var equivalence : NSNumber! = NSNumber(value: 0 as Int32)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = WMColor.light_blue
        
        orderPiceButton.backgroundColor = WMColor.blue
        orderPiceButton.setTitleColor(UIColor.white, for: UIControlState())
        orderPiceButton.layer.cornerRadius = 9
        orderPiceButton.addTarget(self, action: #selector(KeyboardPicesViewController.gotograms), for: UIControlEvents.touchUpInside)
        
        addButton.backgroundColor = WMColor.green
        addButton.setTitleColor(UIColor.white, for: UIControlState())
        
        keyboardView.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        keyboardView.delegate = self
        
        
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) $0.00", for: UIControlState())
        addButton.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        addButton.layer.cornerRadius = 18.0
        addButton.backgroundColor = WMColor.green
        addButton.addTarget(self, action: Selector("addtoshoppingcart:"), for: UIControlEvents.touchUpInside)
        
        
        lblQuantity = UILabel(frame:CGRect(x: 0, y: 0 ,width: viewContainerQ.frame.width, height: 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.white
        lblQuantity.text = " \(Int(currentValGr)) pzas (5000g)"
        lblQuantity.textAlignment = NSTextAlignment.center
        lblQuantity.minimumScaleFactor =  35 / 40
        lblQuantity.adjustsFontSizeToFitWidth = true
        
        viewContainerQ.addSubview(lblQuantity)
        
            self.updateShoppButton()
    }
    
    func userSelectValue(_ value:String!) {
        
    }
    
    func userSelectDelete() {
        
    }
    
    func gotograms() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func updateShoppButton(){
        let result = (priceProduct.doubleValue / 1000.0 ) * currentValGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)" as NSString)
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
    }

    
}
