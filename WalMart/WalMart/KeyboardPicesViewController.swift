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
    var priceProduct : NSNumber! = NSNumber(int: 0)
    var equivalence : NSNumber! = NSNumber(int: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        
        orderPiceButton.backgroundColor = WMColor.regular_blue
        orderPiceButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        orderPiceButton.layer.cornerRadius = 9
        orderPiceButton.addTarget(self, action: "gotograms", forControlEvents: UIControlEvents.TouchUpInside)
        
        addButton.backgroundColor = WMColor.green
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        keyboardView.generateButtons(WMColor.UIColorFromRGB(0xFFFFFF, alpha: 0.35), selected: WMColor.UIColorFromRGB(0xFFFFFF, alpha: 1.0))
        keyboardView.delegate = self
        
        
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) $0.00", forState: UIControlState.Normal)
        addButton.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        addButton.layer.cornerRadius = 18.0
        addButton.backgroundColor = WMColor.productAddToCartPriceSelect
        addButton.addTarget(self, action: "addtoshoppingcart:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        lblQuantity = UILabel(frame:CGRectMake(0, 0 ,viewContainerQ.frame.width, 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.whiteColor()
        lblQuantity.text = " \(Int(currentValGr)) pzas (5000g)"
        lblQuantity.textAlignment = NSTextAlignment.Center
        lblQuantity.minimumScaleFactor =  35 / 40
        lblQuantity.adjustsFontSizeToFitWidth = true
        
        viewContainerQ.addSubview(lblQuantity)
        
            self.updateShoppButton()
    }
    
    func userSelectValue(value:String!) {
        
    }
    
    func userSelectDelete() {
        
    }
    
    func gotograms() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func updateShoppButton(){
        let result = (priceProduct.doubleValue / 1000.0 ) * currentValGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)")
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
    }

    
}
