//
//  GRShoppingCartWeightSelectorView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/12/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation



class GRShoppingCartWeightSelectorView : GRShoppingCartQuantitySelectorView {
    
    var CONS_MINVAL = 50.0
    var CONS_MAXVAL = 20000.0
    
    var containerView : UIView!
    var containerWeightView : UIView!
    var containerNumericView : UIView!
    var btnChankePices : UIButton!
    var lblQuantityN : UILabel!
    var btnNoteN : UIButton!
    var btnNoteCompleteN : UIButton!
    var btnLess : UIButton!
    var btnMore : UIButton!
    var keyboard : WeightKeyboardView!
    var lblQuantityW : UILabel!
    
    var keyboardP : NumericKeyboardView!
    var lblQuantityP : UILabel!
    
    
    var quantityWAnimate : UIView!
    
    var currentValGr : Double! = 50.0
    var currentValPzs : Double! = 1.0
    var currentValCstmGr : Double! = 0.0
    var equivalenceByPiece : NSNumber! = NSNumber(int:0)
    
    var customValue  = false
    var gramsBase  = true
    var visibleLabel = false
    
    var btnOkAddN : UIButton!
    
    var buttonGramsKG : UIButton!
    var buttonKg : UIButton!
    
    var backAction : (() -> Void)!
    
    var keyboardN : NumericKeyboardView!
    
    
    var currentValKg : String? = nil
    
    init(frame: CGRect,priceProduct:NSNumber!,equivalenceByPiece:NSNumber,upcProduct:String) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.equivalenceByPiece = equivalenceByPiece
        self.upcProduct = upcProduct
        setup()
    }
    
    init(frame: CGRect,priceProduct:NSNumber!,quantity:Int!,equivalenceByPiece:NSNumber,upcProduct:String) {
        super.init(frame: frame)
        self.priceProduct = priceProduct
        self.currentValGr = Double(quantity)
        self.equivalenceByPiece = equivalenceByPiece
        self.upcProduct = upcProduct
        setup()
        self.updateShoppButton()
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    override func setup() {
        
        
        containerView = UIView(frame: CGRectMake(self.bounds.minX, self.bounds.minY, self.bounds.width * 2, self.bounds.height))
        containerWeightView = UIView(frame: self.bounds)
        containerNumericView = UIView(frame: CGRectMake(containerWeightView.frame.maxX, self.bounds.minY, self.bounds.width, self.bounds.height))
        
        
        let startH : CGFloat = 0
        
        self.backgroundColor = UIColor.clearColor()
        
        
        self.backgroundView = UIView(frame:CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        self.backgroundView!.backgroundColor = WMColor.light_blue.colorWithAlphaComponent(0.9)
        
        if equivalenceByPiece.integerValue > 0 {
            btnChankePices = UIButton(frame:CGRectMake((self.frame.width / 2) - 60, startH + 17, 120, 18 ))
            btnChankePices.titleLabel?.font = WMFont.fontMyriadProSemiboldSize(12)
            btnChankePices.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btnChankePices.backgroundColor = WMColor.blue
            btnChankePices.layer.cornerRadius = 9
            btnChankePices.addTarget(self, action: "orderbypices", forControlEvents: UIControlEvents.TouchUpInside)
            btnChankePices.setTitle(NSLocalizedString("shoppingcart.selectpices",comment:""), forState: UIControlState.Normal)
            btnChankePices.setTitle(NSLocalizedString("shoppingcart.selectgrkg",comment:""), forState: UIControlState.Selected)
            containerWeightView.addSubview(btnChankePices)
            
            
        } else {
        
            let lblTitle = UILabel(frame:CGRectMake((self.frame.width / 2) - 115, startH + 17, 230, 14))
            lblTitle.font = WMFont.fontMyriadProSemiboldSize(12)
            lblTitle.adjustsFontSizeToFitWidth = true
            lblTitle.textColor = UIColor.whiteColor()
            lblTitle.text = NSLocalizedString("shoppingcart.addweighttitle",comment:"")
            lblTitle.textAlignment = NSTextAlignment.Center
            containerWeightView.addSubview(lblTitle)
        }
        btnLess = UIButton(frame: CGRectMake(64, startH + 51 , 32, 32))
        btnLess.addTarget(self, action: "btnLessAction", forControlEvents: UIControlEvents.TouchUpInside)
        btnLess.setImage(UIImage(named: "addProduct_Less"), forState: UIControlState.Normal)
        
        btnMore = UIButton(frame: CGRectMake(224,  startH + 51 , 32, 32))
        btnMore.addTarget(self, action: "btnMoreAction", forControlEvents: UIControlEvents.TouchUpInside)
        btnMore.setImage(UIImage(named: "addProduct_Add"), forState: UIControlState.Normal)
        
        lblQuantityW = UILabel(frame:CGRectMake(btnLess.frame.maxX + 2, startH + 52 , btnMore.frame.minX - btnLess.frame.maxX - 4, 40))
        lblQuantityW.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantityW.textColor = UIColor.whiteColor()
        lblQuantityW.text = " \(Int(currentValGr))g"
        lblQuantityW.textAlignment = NSTextAlignment.Center
        lblQuantityW.minimumScaleFactor =  35 / 40
        lblQuantityW.adjustsFontSizeToFitWidth = true
        
        
        quantityWAnimate = UIView(frame: CGRectMake(lblQuantityW.bounds.maxX - 3, 0, 1, lblQuantityW.frame.height))
        quantityWAnimate.backgroundColor = UIColor.whiteColor()
        quantityWAnimate.alpha = 0
        lblQuantityW.addSubview(quantityWAnimate)
        
        self.updateLabelW()
        
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateAnimation", userInfo: nil, repeats: true)
        
        let closeButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        closeButton.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "closeSelectQuantity", forControlEvents: UIControlEvents.TouchUpInside)
        
        keyboard = WeightKeyboardView(frame:CGRectMake((self.frame.width / 2) - (289/2), lblQuantityW.frame.maxY + 20, 289, 196))
        //keyboard.generateButtons(UIColor.whiteColor().colorWithAlphaComponent(0.35), selected: UIColor.whiteColor())
        keyboard.delegate = self

        btnOkAdd = UIButton(frame: CGRectMake((self.frame.width / 2) - 71, keyboard.frame.maxY  , 142, 36))
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: "addtoshoppingcart:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if UserCurrentSession.sharedInstance().userHasUPCShoppingCart(self.upcProduct) {
            isUpcInShoppingCart = true
        } else {
            isUpcInShoppingCart = false
        }
        
        updateShoppButton()

        let gestureQuantity = UITapGestureRecognizer(target: self, action: "changetonumberpad:")
        lblQuantityW.addGestureRecognizer(gestureQuantity)
        lblQuantityW.userInteractionEnabled = true
        
        btnNote = UIButton(frame: CGRectMake((self.frame.width) - 48, keyboard.frame.maxY  , 40, 40))
        btnNote.setImage(UIImage(named:"notes_keyboard"), forState: UIControlState.Normal)
        btnNote.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNote.alpha =  0
        self.addSubview(btnNote)
        
        btnNoteComplete = UIButton(frame: CGRectMake(0, btnOkAdd.frame.maxY + 10, self.frame.width, 40))
        btnNoteComplete.setImage(UIImage(named: "notes_alert"), forState: UIControlState.Normal)
        self.btnNoteComplete!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
        btnNoteComplete.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNoteComplete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNoteComplete.alpha = 0

        
        
        self.addSubview(self.backgroundView!)
        containerWeightView.addSubview(btnLess)
        containerWeightView.addSubview(btnMore)
        containerWeightView.addSubview(lblQuantityW)
        containerWeightView.addSubview(btnOkAdd)
        containerWeightView.addSubview(closeButton)
        containerWeightView.addSubview(keyboard)
        containerWeightView.addSubview(btnNote)
        containerWeightView.addSubview(btnNoteComplete)
        
    
        let lblTitleNum = UILabel(frame:CGRectMake((self.frame.width / 2.0) - 115.0, startH + 17, 230, 14))
        lblTitleNum.font = WMFont.fontMyriadProSemiboldSize(14)
        lblTitleNum.textColor = UIColor.whiteColor()
        lblTitleNum.text = NSLocalizedString("shoppingcart.addquantitytitle",comment:"")
        lblTitleNum.textAlignment = NSTextAlignment.Center

        buttonGramsKG = UIButton(frame: CGRectMake((self.frame.width / 2.0) - 60, startH + 17, 120, 18))
        buttonGramsKG.setTitle("Ordenar por g", forState: UIControlState.Normal)
        buttonGramsKG.setTitle("Ordenar por Kilos", forState: UIControlState.Selected)
        buttonGramsKG.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        buttonGramsKG.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonGramsKG.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonGramsKG.selected = true
        buttonGramsKG.addTarget(self, action: "changegrkg:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonGramsKG.backgroundColor = WMColor.blue
        buttonGramsKG.layer.cornerRadius = 9

        
        buttonKg = UIButton(frame: CGRectMake((self.frame.width / 2.0) , startH + 17, 100, 14))
        buttonKg.setTitle("Kilos", forState: UIControlState.Normal)
        buttonKg.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        buttonKg.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.6), forState: UIControlState.Normal)
        buttonKg.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonKg.addTarget(self, action: "changegrkg:", forControlEvents: UIControlEvents.TouchUpInside)

        lblQuantityN = UILabel(frame:CGRectMake((self.frame.width / 2) - (200 / 2), lblTitleNum.frame.maxY + 20 , 200, 40))
        lblQuantityN.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantityN.textColor = UIColor.whiteColor()
        lblQuantityN.text = "\(Int(currentValCstmGr))g"
        lblQuantityN.textAlignment = NSTextAlignment.Center
        
        //let gestureQuantityN = UITapGestureRecognizer(target: self, action: "changetonumberpad:")
        
        let closeButtonN = UIButton(frame: CGRectMake(self.frame.width - 44, 0, 44, 44))
        closeButtonN.setImage(UIImage(named:"close"), forState: UIControlState.Normal)
        closeButtonN.addTarget(self, action: "closeSelectQuantity", forControlEvents: UIControlEvents.TouchUpInside)
        
        let backToW = UIButton(frame: CGRectMake(0, 0, 44, 44))
        backToW.setImage(UIImage(named:"search_back"), forState: UIControlState.Normal)
        backToW.addTarget(self, action: "backToWeight", forControlEvents: UIControlEvents.TouchUpInside)
        
        keyboardN = NumericKeyboardView(frame:CGRectMake((self.frame.width / 2) - (160/2), lblQuantityN.frame.maxY + 10, 160, 196),typeKeyboard:NumericKeyboardViewType.Integer)
        keyboardN.generateButtons(UIColor.whiteColor().colorWithAlphaComponent(0.35), selected: UIColor.whiteColor())
        keyboardN.delegate = self
        
        btnOkAddN = UIButton(frame: CGRectMake((self.frame.width / 2) - 71, keyboard.frame.maxY + 15 , 142, 36))
        //btnOkAddN.setTitle("\(strAdddToSC) $0.00", forState: UIControlState.Normal)
        btnOkAddN.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAddN.layer.cornerRadius = 18.0
        btnOkAddN.backgroundColor = WMColor.green
        btnOkAddN.addTarget(self, action: "addtoshoppingcart:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.updateShoppButtonN()
        
        btnNoteN = UIButton(frame: CGRectMake((self.frame.width) - 48, keyboard.frame.maxY + 15  , 40, 40))
        btnNoteN.setImage(UIImage(named:"notes_keyboard"), forState: UIControlState.Normal)
        btnNoteN.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNoteN.alpha  = 0
        
        btnNoteCompleteN = UIButton(frame: CGRectMake(0, btnOkAdd.frame.maxY + 15, self.frame.width, 40))
        btnNoteCompleteN.setImage(UIImage(named: "notes_alert"), forState: UIControlState.Normal)
        self.btnNoteCompleteN!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
        btnNoteCompleteN.addTarget(self, action: "updateOrAddNote", forControlEvents: UIControlEvents.TouchUpInside)
        btnNoteCompleteN.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNoteCompleteN.alpha = 0
        
        containerNumericView.addSubview(buttonGramsKG)
        //containerNumericView.addSubview(buttonKg)
        containerNumericView.addSubview(lblQuantityN)
        containerNumericView.addSubview(btnOkAddN)
        containerNumericView.addSubview(closeButtonN)
        containerNumericView.addSubview(keyboardN)
        containerNumericView.addSubview(backToW)
        containerNumericView.addSubview(btnNoteN)
        containerNumericView.addSubview(btnNoteCompleteN)
        
        containerView.addSubview(containerWeightView)
        containerView.addSubview(containerNumericView)
        
        self.addSubview(containerView)
        
        if equivalenceByPiece.integerValue > 0 {
            initViewForPices()
        }
        
    }
    
    
    func initViewForPices() {
        
        let valueItemPzs = NSMutableAttributedString()
        
        lblQuantityP = UILabel(frame:CGRectMake(16, btnChankePices.frame.maxY + 17 , containerWeightView.frame.width - 32, 40))
        lblQuantityP.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantityP.textColor = UIColor.whiteColor()
        valueItemPzs.appendAttributedString(NSAttributedString(string: "\(Int(currentValPzs)) pzas", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(40),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        valueItemPzs.appendAttributedString(NSAttributedString(string: " (\(self.equivalenceByPiece.integerValue)gr)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(20),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        lblQuantityP.attributedText = valueItemPzs
        lblQuantityP.textAlignment = NSTextAlignment.Center
        lblQuantityP.minimumScaleFactor =  35 / 40
        lblQuantityP.adjustsFontSizeToFitWidth = true
        lblQuantityP.alpha = 0
        
        keyboardP = NumericKeyboardView(frame:CGRectMake((self.frame.width / 2) - (160/2), lblQuantityN.frame.maxY + 10, 160, 196),typeKeyboard:NumericKeyboardViewType.Integer)
        keyboardP.generateButtons(UIColor.whiteColor().colorWithAlphaComponent(0.35), selected: UIColor.whiteColor())
        keyboardP.delegate = self
        keyboardP.alpha = 0
        
        containerWeightView.addSubview(lblQuantityP)
        containerWeightView.addSubview(keyboardP)
        
    }
    
    
    override func addtoshoppingcart(sender:AnyObject) {
        if self.customValue {
            if currentValCstmGr % 50 != 0 || currentValCstmGr == 0{
                  showError(NSLocalizedString("shoppingcart.multiple.50",comment:""))
                 return
            }
            if currentValCstmGr > CONS_MAXVAL {
                showError("Cantidad Máxima 20 kg")
                //showError(NSLocalizedString("shoppingcart.multiple.50",comment:""))
                return
            }
            
            addToCartAction("\(Int(currentValCstmGr))")
        } else {
            if Int(currentValGr) == 0 {
                showError("Cantidad minima 1 pieza")
                return
            }
            addToCartAction("\(Int(currentValGr))")
        }
    }
    
    //metodo
    func showError (message: String ){
        if !visibleLabel  {

        visibleLabel = true
        
        var  imageView : UIView? =  UIView(frame:CGRectMake((self.frame.width/2) - 115 , self.lblQuantityN.frame.minY - 40, 230, 20))
        var  viewContent : UIView? = UIView(frame: imageView!.bounds)
        viewContent!.layer.cornerRadius = 4.0
        viewContent!.backgroundColor = UIColor.whiteColor()
        imageView!.addSubview(viewContent!)
        self.addSubview(imageView!)
        
        var lblError : UILabel? =   UILabel(frame:CGRectMake (0, 0 , viewContent!.frame.width, 20))
        lblError!.font = WMFont.fontMyriadProRegularOfSize(12)
        
        lblError!.textColor = WMColor.light_blue
        lblError!.backgroundColor = UIColor.clearColor()
        lblError!.text = message
        lblError!.textAlignment = NSTextAlignment.Center
        viewContent!.addSubview(lblError!)
        
        var imageIco : UIImageView? = UIImageView()
        imageIco!.image = UIImage(named:"tooltip_white")
        imageIco!.frame = CGRectMake( (self.frame.width - 3 ) / 2  , imageView!.frame.maxY,   6, 4)
        self.addSubview(imageIco!)
        
        UIView.animateWithDuration(3.5,
            animations: { () -> Void in
                viewContent!.alpha = 0.0
                imageView!.alpha = 0.0
                lblError!.alpha = 0.0
                imageIco!.alpha = 0.0
                
            }, completion: { (finished:Bool) -> Void in
                if finished {
                    viewContent!.removeFromSuperview()
                    imageView!.removeFromSuperview()
                    lblError!.removeFromSuperview()
                    imageIco!.removeFromSuperview()
                    viewContent = nil
                    imageView = nil
                    lblError = nil
                    imageIco = nil
                    self.visibleLabel = false
                }
            }
        )
        }
        
    }
    
    override func generateBlurImage(viewBg:UIView,frame:CGRect) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = blurredImage
        
        self.addSubview(imageBlurView)
        self.sendSubviewToBack(imageBlurView)
    }
    
    override func closeSelectQuantity() {
        if closeAction != nil {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_CLOSE_KEYBOARD.rawValue, label:"" )
            closeAction()
        }
    }
    
    override func userSelectValue(value:String!) {
        if btnChankePices != nil && btnChankePices.selected {
            var tmpResult : Double = 0.0
            var resultText : NSString = ""
            if first {
                resultText  = "\(value)"
                first = false
                tmpResult = resultText.doubleValue
            }else {
                resultText = "\(Int(currentValPzs))\(value)"
                tmpResult = resultText.doubleValue
            }
            
            let equivalence : Int = self.equivalenceByPiece.integerValue * Int(tmpResult)
            if Double(equivalence) <= CONS_MAXVAL {
                if  Double(equivalence) == 0
                {
                  showError("Cantidad minima 1 pieza")
                }else{
                currentValPzs = tmpResult
                self.updateLabelP()
                    self.updateShoppButton()
                }
            } else {
                let maxPices = Int(CONS_MAXVAL / self.equivalenceByPiece.doubleValue)
                showError("Cantidad Máxima \(maxPices) piezas")
            }
            
        } else {
        if customValue {
            var resultText : NSString = ""
            if first {
                resultText  = "\(value)"
                first = false
            } else {
                resultText  = "\(Int(currentValCstmGr))\(value)"
            }
            
            if keyboardN.typeKeyboard == NumericKeyboardViewType.Integer {
                if (resultText as String).characters.count > 5 {
                    return
                }
                currentValCstmGr = resultText.doubleValue
                self.updateLabelN()
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
                
               /* if countElements(currentValKg!) > 5 {
                    currentValKg = valOrigin
                    return
                }*/
                currentValCstmGr = currentVal.doubleValue * 1000.0

               /* var c:String = String(format:"%f", currentValCstmGr)
                if countElements("\(currentValCstmGr)") > 7 {
                    currentValKg = valOrigin
                    currentValCstmGr =  valcurrentOrigin
                    return
                }*/
                
                self.updateLabelN(currentValKg!)
            }
            updateShoppButtonN()
        } else {
            let resultText : NSString = "\(value)"
            currentValGr = resultText.doubleValue
            self.updateLabelW()
             self.updateShoppButton()
        }
        }
    }
    
    override func userSelectDelete() {
        if btnChankePices != nil && btnChankePices.selected {
            var resultText : NSString  = "\(Int(currentValPzs))"
            resultText = resultText.substringToIndex(resultText.length - 1)
            
            if resultText == "" {
                resultText = "0"
            }
            currentValPzs = resultText.doubleValue
            self.updateLabelP()
            self.updateShoppButton()
            
        } else {
            if customValue {
                var resultText : NSString  = "\(Int(currentValCstmGr))"
                resultText = resultText.substringToIndex(resultText.length - 1)
                if keyboardN.typeKeyboard == NumericKeyboardViewType.Integer {
                    if resultText == "" {
                        resultText = "0"
                    }
                    currentValCstmGr = resultText.doubleValue
                    self.updateLabelN()
                    self.updateShoppButtonN()
                } else {
                    let valInKgString = currentValKg! as NSString
                    if valInKgString.length > 0 {
                        let valKgTotal : NSString = valInKgString.substringToIndex(valInKgString.length - 1)
                        if valKgTotal.length > 0 {
                            currentValKg = valKgTotal as String
                        } else {
                            currentValKg = "0"
                        }
                        self.updateLabelN(currentValKg!)
                        
                    }
                }
            }
        }
    }
    
    
    
    func btnMoreAction() {
      
        if (currentValGr + 50.0) <= CONS_MAXVAL {
              BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_ADD_GRAMS.rawValue , label:"" )
            currentValGr = currentValGr + 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
    func btnLessAction() {
        
        
        if (currentValGr - 50.0) > CONS_MINVAL {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_DECREASE_GRAMS.rawValue , label:"" )
            currentValGr = currentValGr - 50
            self.updateShoppButton()
            self.updateLabelW()
        }
    }
    
    func updateShoppButton(){
        
        let result = (priceProduct.doubleValue / 1000.0 ) * currentValGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)")
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        
        var rectSize = CGRectZero
        if isUpcInShoppingCart {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            
        } else {
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.btnOkAdd.frame =  CGRectMake((self.frame.width / 2) - ((rectSize.width + 32) / 2),self.btnOkAdd.frame.minY , rectSize.width + 32, 36)
        })
        
        
//        var result = (priceProduct.doubleValue / 1000.0 ) * currentValGr
//        let strPrice = CurrencyCustomLabel.formatString("\(result)")
//        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
//        btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
    }
    
    func updateShoppButtonN(){
        
        let result = (priceProduct.doubleValue / 1000.0 ) * currentValCstmGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)")
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        
        var rectSize = CGRectZero
        if isUpcInShoppingCart {
            btnOkAddN.setTitle("\(strUpdateToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            
        } else {
            btnOkAddN.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRectWithSize(CGSizeMake(self.frame.width, 36), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.btnOkAddN.frame =  CGRectMake((self.frame.width / 2) - ((rectSize.width + 32) / 2),self.btnOkAddN.frame.minY , rectSize.width + 32, 36)
        })

        
//        var result = (priceProduct.doubleValue / 1000.0 ) * currentValCstmGr
//        let strPrice = CurrencyCustomLabel.formatString("\(result)")
//        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
//        btnOkAddN.setTitle("\(strAdddToSC) \(strPrice)", forState: UIControlState.Normal)
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
            lblQuantityW.text = tmpResult as String
        }else {
            let tmpResult : NSString = "\(Int(currentValGr))g"
            lblQuantityW.text = tmpResult as String
        }
        let rectSize =  lblQuantityW.attributedText!.boundingRectWithSize(CGSizeMake(lblQuantityW.frame.width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        quantityWAnimate.frame = CGRectMake((lblQuantityW.bounds.width / 2) + (rectSize.width / 2) + 3, 0, 1, lblQuantityW.frame.height)
        
    }
    
    func updateLabelN(value:String) {
        lblQuantityN.text = String(format:"%@Kg",value)
    }
    
    func updateLabelN() {
        if gramsBase {
            let tmpResult : NSString = "\(Int(currentValCstmGr))g"
            lblQuantityN.text = tmpResult as String
        } else {
            var formatedString = ""
            let valInKg = currentValGr / 1000
            if (currentValGr % 1000) == 0 {
                formatedString = String(format:"%.fKg",valInKg)
            } else {
                formatedString = String(format:"%.2fKg",valInKg)
            }
            lblQuantityN.text = formatedString
        }
    }
    
    func updateLabelP() {
        
        let equivalence : Int = self.equivalenceByPiece.integerValue * Int(currentValPzs)
        currentValGr = Double(equivalence)
        
        let valueItemPzs = NSMutableAttributedString()
        valueItemPzs.appendAttributedString(NSAttributedString(string: "\(Int(currentValPzs)) pzas", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(40),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        valueItemPzs.appendAttributedString(NSAttributedString(string: " (\(equivalence)gr)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(20),NSForegroundColorAttributeName:UIColor.whiteColor()]))
        
        lblQuantityP.attributedText = valueItemPzs
        
    }
    
    func changetonumberpad(sender:AnyObject) {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_OPEN_KEYBOARD_KILO.rawValue, label:"" )
        customValue = true
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.containerView.frame = CGRectMake(-self.containerWeightView.frame.maxX, 0, self.containerView.frame.width, self.containerView.frame.height)
            }) { (complete:Bool) -> Void in
            
        }
    }
    
    func backToWeight() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_BACK_KEYBOARG_GRAMS.rawValue, label:"" )
        self.customValue = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.containerView.frame = CGRectMake(0, 0, self.containerView.frame.width, self.containerView.frame.height)
            }) { (complete:Bool) -> Void in
                
        }
    }
    
    func updateAnimation() {
        if quantityWAnimate.alpha  == 0 {
            quantityWAnimate.alpha = 1
        }else {
            quantityWAnimate.alpha = 0
        }
    }
    
    func changegrkg(sender:UIButton) {
        if buttonGramsKG.selected {
            gramsBase = false
            buttonGramsKG.selected = false
            //self.currentValGr = self.currentValGr * 1000
            
            self.keyboardN.changeType(NumericKeyboardViewType.Decimal)
            
            
            var formatedString = ""
            let valInKg = currentValCstmGr / 1000.0
            if (currentValCstmGr % 1000) == 0 {
                formatedString = String(format:"%.f",valInKg)
            } else {
                formatedString = String(format:"%.2f",valInKg)
            }
            currentValKg = formatedString
            
            
            self.updateLabelN(currentValKg!)
        } else {
            gramsBase = true
            buttonGramsKG.selected = true
            //self.currentValGr = self.currentValGr / 1000
            
            self.keyboardN.changeType(NumericKeyboardViewType.Integer)
            self.updateLabelN()
        }
    }
    
    func setBackActionShoppingCart(backAction:(() -> Void)) {
        let backButton = UIButton(frame: CGRectMake(0, 0, 40, 40))
        backButton.setImage(UIImage(named: "search_back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backActionUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        self.backAction = backAction
    }
    
    func backActionUpInside() {
        self.backAction()
    }
    
    override func showNoteButton() {
        self.btnNoteN.alpha = 1
        self.btnNote.alpha = 1
    }
    
    override func showNoteButtonComplete() {
        self.btnNoteComplete.alpha = 1
        self.btnNoteCompleteN.alpha = 1
    }
    
    
    override func setTitleCompleteButton(title:String) {
        self.btnNoteComplete.setTitle(title,forState: UIControlState.Normal)
        self.btnNoteCompleteN.setTitle(title,forState: UIControlState.Normal)
    }
    
    func orderbypices() {
        btnChankePices.enabled = false
        
        if btnChankePices.selected {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.lblQuantityW.alpha = 1
                self.btnLess.alpha = 1
                self.btnMore.alpha = 1
                self.btnLess.alpha = 1
                self.keyboard.alpha = 1
                self.updateShoppButton()
                self.lblQuantityP.alpha = 0
                self.keyboardP.alpha = 0
            }, completion: { (Bool) -> Void in
                self.btnChankePices.enabled = true
                self.btnChankePices.selected = !self.btnChankePices.selected
            })
           
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.lblQuantityW.alpha = 0
            self.btnLess.alpha = 0
            self.btnMore.alpha = 0
            self.btnLess.alpha = 0
            self.keyboard.alpha = 0
            self.updateShoppButtonN()
            self.lblQuantityP.alpha = 1
            self.keyboardP.alpha = 1
                }, completion: { (Bool) -> Void in
                    self.btnChankePices.enabled = true
                    self.btnChankePices.selected = !self.btnChankePices.selected
            })
        }
        
    }
    
    
   
    
}