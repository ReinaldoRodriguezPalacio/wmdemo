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
    var priceProduct : NSNumber! = NSNumber(value: 0 as Int32)
    var equivalenceProduct : NSNumber! = NSNumber(value: 0 as Int32)
    var first = true
    var currentValKg : String? = nil
    var gramsBase  = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = WMColor.light_blue
        
        orderPiceButton.backgroundColor = WMColor.blue
        orderPiceButton.setTitleColor(UIColor.white, for: UIControlState())
        orderPiceButton.layer.cornerRadius = 9
        //orderPiceButton.addTarget(self, action: "gotopice", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        lblQuantity.text = " \(Int(currentValGr))g"
        lblQuantity.textAlignment = NSTextAlignment.center
        lblQuantity.minimumScaleFactor =  35 / 40
        lblQuantity.adjustsFontSizeToFitWidth = true
        
     
        
        viewContainerQ.addSubview(lblQuantity)
        
        btnNote.setImage(UIImage(named:"notes_keyboard"), for: UIControlState())
        btnNote.addTarget(self, action: Selector("updateOrAddNote"), for: UIControlEvents.touchUpInside)
        btnNote.alpha =  0
        
        self.updateLabelW()
        self.updateShoppButton()
        
        closeButton.addTarget(self, action: #selector(KeyboardGramsKgViewController.back), for: UIControlEvents.touchUpInside)
        
    }
    
    
    func userSelectValue(_ value:String!) {
        var resultText : NSString = ""
        if first {
            resultText  = "\(value)" as NSString
            first = false
        } else {
            resultText  = "\(Int(currentValCstmGr))\(value)" as NSString
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
            
            let fullArray = currentVal.components(separatedBy: ".")
            
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
    
    func updateLabelN(_ value:String) {
        lblQuantity.text = String(format:"%@Kg",value)
    }
    
    func updateLabelW() {
        if gramsBase {
            let tmpResult : NSString = "\(Int(currentValCstmGr))g" as NSString
            lblQuantity.text = tmpResult as String
        } else {
            var formatedString = ""
            let valInKg = currentValGr / 1000
            if (currentValGr.truncatingRemainder(dividingBy: 1000)) == 0 {
                formatedString = String(format:"%.fKg",valInKg)
            } else {
                formatedString = String(format:"%.2fKg",valInKg)
            }
            lblQuantity.text = formatedString
        }
    }
    
    func updateShoppButton(){
        let result = (priceProduct.doubleValue / 1000.0 ) * currentValGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)" as NSString)
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
    }
    
    func gotopice() {
        self.performSegue(withIdentifier: "pices", sender: nil)
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
    
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pices" {
            if let keyboard = segue.destination as? KeyboardPicesViewController {
                keyboard.priceProduct = priceProduct
            }
        }
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
}
