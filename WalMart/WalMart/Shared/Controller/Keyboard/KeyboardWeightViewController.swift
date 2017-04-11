//
//  KeyboardWeightViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 04/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class KeyboardWeightViewController : UIViewController, KeyboardViewDelegate {
    
    var CONS_MINVAL = 50.0
    var CONS_MAXVAL = 20000.0
    
    @IBOutlet var backgroundView : UIView!
    @IBOutlet weak var keyboardView: WeightKeyboardView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var orderPiceButton: UIButton!
    @IBOutlet weak var viewContainerQ: UIView!
    @IBOutlet weak var btnNote: UIButton!
    
    var lblQuantity : UILabel!
    var quantityWAnimate : UIView!
    
    var currentValGr : Double! = 50.0
    var currentValCstmGr : Double! = 0.0
    var priceProduct : NSNumber! = NSNumber(value: 0 as Int32)
    var equivalenceProduct : NSNumber! = NSNumber(value: 0 as Int32)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = WMColor.light_blue

        orderPiceButton.backgroundColor = WMColor.blue
        orderPiceButton.setTitleColor(UIColor.white, for: UIControlState())
        orderPiceButton.layer.cornerRadius = 9
        orderPiceButton.addTarget(self, action: #selector(KeyboardWeightViewController.gotopice), for: UIControlEvents.touchUpInside)
        
        addButton.backgroundColor = WMColor.green
        addButton.setTitleColor(UIColor.white, for: UIControlState())
        
        keyboardView.delegate = self
        
        
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) $0.00", for: UIControlState())
        addButton.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        addButton.layer.cornerRadius = 18.0
        addButton.backgroundColor = WMColor.green
        addButton.addTarget(self, action: Selector("addtoshoppingcart:"), for: UIControlEvents.touchUpInside)
        
        let btnLess = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        btnLess.addTarget(self, action: #selector(KeyboardWeightViewController.btnLessAction), for: UIControlEvents.touchUpInside)
        btnLess.setImage(UIImage(named: "addProduct_Less"), for: UIControlState())
        
        let btnMore = UIButton(frame: CGRect(x: viewContainerQ.frame.width - 32, y: 0 , width: 32, height: 32))
        btnMore.addTarget(self, action: #selector(KeyboardWeightViewController.btnMoreAction), for: UIControlEvents.touchUpInside)
        btnMore.setImage(UIImage(named: "addProduct_Add"), for: UIControlState())
        
        lblQuantity = UILabel(frame:CGRect(x: btnLess.frame.maxX + 2, y: 0 , width: btnMore.frame.minX - btnLess.frame.maxX - 4, height: 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.white
        lblQuantity.text = " \(Int(currentValGr))g"
        lblQuantity.textAlignment = NSTextAlignment.center
        lblQuantity.minimumScaleFactor =  35 / 40
        lblQuantity.adjustsFontSizeToFitWidth = true
        let gestureQuantity = UITapGestureRecognizer(target: self, action: #selector(KeyboardWeightViewController.changetonumberpad(_:)))
        lblQuantity.addGestureRecognizer(gestureQuantity)
        lblQuantity.isUserInteractionEnabled = true
        
        quantityWAnimate = UIView(frame: CGRect(x: lblQuantity.bounds.maxX - 3, y: 0, width: 1, height: lblQuantity.frame.height))
        quantityWAnimate.backgroundColor = UIColor.white
        quantityWAnimate.alpha = 0
        lblQuantity.addSubview(quantityWAnimate)
        
        viewContainerQ.addSubview(lblQuantity)
        viewContainerQ.addSubview(btnLess)
        viewContainerQ.addSubview(btnMore)
        
        btnNote.setImage(UIImage(named:"notes_keyboard"), for: UIControlState())
        btnNote.addTarget(self, action: Selector("updateOrAddNote"), for: UIControlEvents.touchUpInside)
        btnNote.alpha =  0

        self.updateLabelW()
        self.updateShoppButton()
        
    }
    
    
    func userSelectValue(_ value:String!) {
        let resultText : NSString = "\(value)" as NSString
        currentValGr = resultText.doubleValue
        self.updateLabelW()
        self.updateShoppButton()
    }
    
    func userSelectDelete() {
    }
    
    func updateLabelW() {
        if  currentValGr >= 1000 {
            let valInKg = currentValGr / 1000.0
            var formatedString = ""
            if (currentValGr.truncatingRemainder(dividingBy: 1000)) == 0 {
                formatedString = String(format:"%.f",valInKg)
            } else {
                formatedString = String(format:"%.2f",valInKg)
            }
            
            let tmpResult : NSString = "\(formatedString)kg" as NSString
            lblQuantity.text = tmpResult as String
        }else {
            let tmpResult : NSString = "\(Int(currentValGr))g" as NSString
            lblQuantity.text = tmpResult as String
        }
        let rectSize =  lblQuantity.attributedText!.boundingRect(with: CGSize(width: lblQuantity.frame.width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        quantityWAnimate.frame = CGRect(x: (lblQuantity.bounds.width / 2) + (rectSize.width / 2) + 3, y: 0, width: 1, height: lblQuantity.frame.height)
        
        
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
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_ADD_GRAMS.rawValue , label:"")
        if (currentValGr + 50.0) < CONS_MAXVAL {
            currentValGr = currentValGr + 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
    func btnLessAction() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_DECREASE_GRAMS.rawValue , label:"")
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
    
    
    func changetonumberpad(_ sender:AnyObject) {
        self.performSegue(withIdentifier: "kggrams", sender: nil)
    }

    
}
