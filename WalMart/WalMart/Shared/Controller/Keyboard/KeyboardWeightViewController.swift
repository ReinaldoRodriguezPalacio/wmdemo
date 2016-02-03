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
    var priceProduct : NSNumber! = NSNumber(int: 0)
    var equivalenceProduct : NSNumber! = NSNumber(int: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = WMColor.light_blue

        orderPiceButton.backgroundColor = WMColor.blue
        orderPiceButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        orderPiceButton.layer.cornerRadius = 9
        orderPiceButton.addTarget(self, action: "gotopice", forControlEvents: UIControlEvents.TouchUpInside)
        
        addButton.backgroundColor = WMColor.green
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        keyboardView.delegate = self
        
        
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        addButton.setTitle("\(strAdddToSC) $0.00", forState: UIControlState.Normal)
        addButton.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        addButton.layer.cornerRadius = 18.0
        addButton.backgroundColor = WMColor.productAddToCartPriceSelect
        addButton.addTarget(self, action: "addtoshoppingcart:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let btnLess = UIButton(frame: CGRectMake(0, 0, 32, 32))
        btnLess.addTarget(self, action: "btnLessAction", forControlEvents: UIControlEvents.TouchUpInside)
        btnLess.setImage(UIImage(named: "addProduct_Less"), forState: UIControlState.Normal)
        
        let btnMore = UIButton(frame: CGRectMake(viewContainerQ.frame.width - 32, 0 , 32, 32))
        btnMore.addTarget(self, action: "btnMoreAction", forControlEvents: UIControlEvents.TouchUpInside)
        btnMore.setImage(UIImage(named: "addProduct_Add"), forState: UIControlState.Normal)
        
        lblQuantity = UILabel(frame:CGRectMake(btnLess.frame.maxX + 2, 0 , btnMore.frame.minX - btnLess.frame.maxX - 4, 40))
        lblQuantity.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantity.textColor = UIColor.whiteColor()
        lblQuantity.text = " \(Int(currentValGr))g"
        lblQuantity.textAlignment = NSTextAlignment.Center
        lblQuantity.minimumScaleFactor =  35 / 40
        lblQuantity.adjustsFontSizeToFitWidth = true
        let gestureQuantity = UITapGestureRecognizer(target: self, action: "changetonumberpad:")
        lblQuantity.addGestureRecognizer(gestureQuantity)
        lblQuantity.userInteractionEnabled = true
        
        quantityWAnimate = UIView(frame: CGRectMake(lblQuantity.bounds.maxX - 3, 0, 1, lblQuantity.frame.height))
        quantityWAnimate.backgroundColor = UIColor.whiteColor()
        quantityWAnimate.alpha = 0
        lblQuantity.addSubview(quantityWAnimate)
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateAnimation", userInfo: nil, repeats: true)
        
        viewContainerQ.addSubview(lblQuantity)
        viewContainerQ.addSubview(btnLess)
        viewContainerQ.addSubview(btnMore)
        
        btnNote.setImage(UIImage(named:"notes_keyboard"), forState: UIControlState.Normal)
        btnNote.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNote.alpha =  0

        self.updateLabelW()
        self.updateShoppButton()
        
    }
    
    
    func userSelectValue(value:String!) {
        let resultText : NSString = "\(value)"
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
            if (currentValGr % 1000) == 0 {
                formatedString = String(format:"%.f",valInKg)
            } else {
                formatedString = String(format:"%.2f",valInKg)
            }
            
            let tmpResult : NSString = "\(formatedString)kg"
            lblQuantity.text = tmpResult as String
        }else {
            let tmpResult : NSString = "\(Int(currentValGr))g"
            lblQuantity.text = tmpResult as String
        }
        let rectSize =  lblQuantity.attributedText!.boundingRectWithSize(CGSizeMake(lblQuantity.frame.width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        quantityWAnimate.frame = CGRectMake((lblQuantity.bounds.width / 2) + (rectSize.width / 2) + 3, 0, 1, lblQuantity.frame.height)
        
        
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
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_ADD_GRAMS.rawValue , label:"")
        if (currentValGr + 50.0) < CONS_MAXVAL {
            currentValGr = currentValGr + 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
    func btnLessAction() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_WEIGHABLE.rawValue, action:WMGAIUtils.ACTION_DECREASE_GRAMS.rawValue , label:"")
        if (currentValGr) > CONS_MINVAL {
            currentValGr = currentValGr - 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
    func updateAnimation() {
        if quantityWAnimate.alpha  == 0 {
            quantityWAnimate.alpha = 1
        }else {
            quantityWAnimate.alpha = 0
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pices" {
            if let keyboard = segue.destinationViewController as? KeyboardPicesViewController {
                keyboard.priceProduct = priceProduct
            }
        }
    }
    
    
    func changetonumberpad(sender:AnyObject) {
        self.performSegueWithIdentifier("kggrams", sender: nil)
    }

    
}