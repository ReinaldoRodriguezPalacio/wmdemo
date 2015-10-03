//
//  KeyboardGramsKgViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 08/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class KeyboardGramsKgViewController : UIViewController, KeyboardViewDelegate  {
    
    var CONS_MINVAL = 50.0
    var CONS_MAXVAL = 20000.0
    
    @IBOutlet var backgroundView : UIView!
    @IBOutlet weak var keyboardView: NumericKeyboardView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var orderPiceButton: UIButton!
    @IBOutlet weak var viewContainerQ: UIView!
    @IBOutlet weak var btnNote: UIButton!
    
    var lblQuantity : UILabel!
    
    var currentValGr : Double! = 50.0
    var currentValCstmGr : Double! = 0.0
    var priceProduct : NSNumber! = NSNumber(int: 0)
    var equivalenceProduct : NSNumber! = NSNumber(int: 0)
    var first = true
    var currentValKg : String? = nil
    var gramsBase  = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        
        orderPiceButton.backgroundColor = WMColor.regular_blue
        orderPiceButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        orderPiceButton.layer.cornerRadius = 9
        //orderPiceButton.addTarget(self, action: "gotopice", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        lblQuantity.text = " \(Int(currentValGr))g"
        lblQuantity.textAlignment = NSTextAlignment.Center
        lblQuantity.minimumScaleFactor =  35 / 40
        lblQuantity.adjustsFontSizeToFitWidth = true
        
     
        
        viewContainerQ.addSubview(lblQuantity)
        
        btnNote.setImage(UIImage(named:"notes_keyboard"), forState: UIControlState.Normal)
        btnNote.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNote.alpha =  0
        
        self.updateLabelW()
        self.updateShoppButton()
        
        closeButton.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    
    func userSelectValue(value:String!) {
        var resultText : NSString = ""
        if first {
            resultText  = "\(value)"
            first = false
        } else {
            resultText  = "\(Int(currentValCstmGr))\(value)"
        }
        
        if keyboardView.typeKeyboard == NumericKeyboardViewType.Integer {
            if (resultText as String).characters.count > 5 {
                return
            }
            currentValCstmGr = resultText.doubleValue
            self.updateLabelW()
        }else {
            let valOrigin = currentValKg
            let valcurrentOrigin = currentValCstmGr
            if currentValKg == "0" {
                currentValKg = ""
            }
            if currentValKg == nil {
                currentValKg = "\(currentValGr / 1000.0)"
            }
            
            currentValKg = "\(currentValKg!)\(value)"
            let currentVal = currentValKg! as NSString
            
            let fullArray = currentVal.componentsSeparatedByString(".")
            
            if fullArray.count > 2 {
                currentValKg = valOrigin
                currentValCstmGr =  valcurrentOrigin
                return
            }
            
            let kg = fullArray[0] 
            if kg.characters.count > 2 {
                currentValKg = valOrigin
                currentValCstmGr =  valcurrentOrigin
                return
            }
            
            if fullArray.count > 1 {
                let gr = fullArray[1] 
                
                if gr.characters.count > 2 {
                    currentValKg = valOrigin
                    currentValCstmGr =  valcurrentOrigin
                    return
                }
                
            }
            
            currentValCstmGr = currentVal.doubleValue * 1000.0

            self.updateLabelN(currentValKg!)
        }
        updateShoppButton()
    }
    
    func userSelectDelete() {
    }
    
    func updateLabelN(value:String) {
        lblQuantity.text = String(format:"%@Kg",value)
    }
    
    func updateLabelW() {
        if gramsBase {
            let tmpResult : NSString = "\(Int(currentValCstmGr))g"
            lblQuantity.text = tmpResult as String
        } else {
            var formatedString = ""
            let valInKg = currentValGr / 1000
            if (currentValGr % 1000) == 0 {
                formatedString = String(format:"%.fKg",valInKg)
            } else {
                formatedString = String(format:"%.2fKg",valInKg)
            }
            lblQuantity.text = formatedString
        }
    }
    
    func updateShoppButton(){
        let result = (priceProduct.doubleValue / 1000.0 ) * currentValGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)")
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
    }
    
    func gotopice() {
        self.performSegueWithIdentifier("pices", sender: nil)
    }
    
    //More and less button actions
    func btnMoreAction() {
        if (currentValGr + 50.0) < CONS_MAXVAL {
            currentValGr = currentValGr + 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
    func btnLessAction() {
        if (currentValGr) > CONS_MINVAL {
            currentValGr = currentValGr - 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
  
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pices" {
            if let keyboard = segue.destinationViewController as? KeyboardPicesViewController {
                keyboard.priceProduct = priceProduct
            }
        }
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}