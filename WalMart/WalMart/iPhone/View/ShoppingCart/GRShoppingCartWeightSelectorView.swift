//
//  GRShoppingCartWeightSelectorView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/12/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class GRShoppingCartWeightSelectorView : GRShoppingCartQuantitySelectorView {
    
    var CONS_MINVAL = 0.0
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
    
    
    var originalValGr: Double! = 50.0
    var originalValPzs: Double! = 1.0
    
    var currentValGr : Double! = 50.0
    var currentValPzs : Double! = 1.0
    
    var currentValCstmGr : Double! = 0.0
    
    var customValue  = false
    var gramsBase  = true
    var visibleLabel = false
    var btnOkAddN : UIButton!
    var buttonGramsKG : UIButton!
    var buttonKg : UIButton!
    var buttonDelet : UIButton!
    var backAction : (() -> Void)!
    var keyboardN : NumericKeyboardView!
    var currentValKg : String? = nil
    var isSearchProductView = false
    
    init(frame: CGRect,priceProduct:NSNumber!,equivalenceByPiece:NSNumber,upcProduct:String,startY: CGFloat = 0, isSearchProductView: Bool) {
        super.init(frame: frame,equivalenceByPiece:equivalenceByPiece)
        self.isSearchProductView = isSearchProductView
        self.priceProduct = priceProduct
        self.equivalenceByPiece = equivalenceByPiece
        self.upcProduct = upcProduct
        self.originalValGr = currentValGr
        self.startY = startY
        self.orderByPiece =  false
        setup()
    }
    
    
    init(frame: CGRect,priceProduct:NSNumber!,quantity:Int!,equivalenceByPiece:NSNumber,upcProduct:String,startY: CGFloat = 0, isSearchProductView: Bool) {
        super.init(frame: frame,equivalenceByPiece:equivalenceByPiece)
        self.isSearchProductView = isSearchProductView
        self.priceProduct = priceProduct
        self.currentValGr = Double(quantity)
        self.equivalenceByPiece = equivalenceByPiece
        self.originalValGr = currentValGr
        self.upcProduct = upcProduct
        self.startY = startY
        setup()
        self.updateShoppButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func setup() {
        
        isFullView = (frame.height > 600) && !IS_IPAD
        
        containerView = UIView(frame: CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width * 2, height: self.bounds.height))
        containerWeightView = UIView(frame: self.bounds)
        containerNumericView = UIView(frame: CGRect(x: containerWeightView.frame.maxX, y: self.bounds.minY, width: self.bounds.width, height: self.bounds.height))
        
        let startH: CGFloat = startY
        
        self.backgroundColor = UIColor.clear
        
        self.backgroundView = UIView(frame:CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        self.backgroundView!.backgroundColor = WMColor.light_blue.withAlphaComponent(0.93)
        
        if equivalenceByPiece.intValue > 0 {
            btnChankePices = UIButton(frame:CGRect(x: (self.frame.width / 2) - 60, y: startH + (startH != 0 && isFullView ? 48 : 18), width: 120, height: 18))
            btnChankePices.titleLabel?.font = WMFont.fontMyriadProSemiboldSize(12)
            btnChankePices.setTitleColor(UIColor.white, for: UIControlState())
            btnChankePices.backgroundColor = WMColor.blue
            btnChankePices.layer.cornerRadius = 9
            btnChankePices.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.orderbypices), for: UIControlEvents.touchUpInside)
            btnChankePices.setTitle(NSLocalizedString("shoppingcart.selectpices",comment:""), for: UIControlState())
            btnChankePices.setTitle(NSLocalizedString("shoppingcart.selectgrkg",comment:""), for: UIControlState.selected)
            containerWeightView.addSubview(btnChankePices)
        } else {
            let lblTitle = UILabel(frame:CGRect(x: (self.frame.width / 2) - 115, y: startH + 18, width: 230, height: startH != 0 && isFullView ? 48 : 14))
            lblTitle.font = WMFont.fontMyriadProSemiboldSize(12)
            lblTitle.adjustsFontSizeToFitWidth = true
            lblTitle.textColor = UIColor.white
            lblTitle.text = NSLocalizedString("shoppingcart.addweighttitle",comment:"")
            lblTitle.textAlignment = NSTextAlignment.center
            containerWeightView.addSubview(lblTitle)
        }
        
        let xPosition = isFullView ? ((frame.width - 232) / 2) : ((frame.width - 222) / 2)
        let yPositionForTitles = isFullView && startH != 0 ? 112 : (startH + 51)
        let buttonSize: CGFloat = isFullView ? 40 : 32
        
        btnLess = UIButton(frame: CGRect(x: xPosition, y: yPositionForTitles, width: buttonSize, height: buttonSize))
        btnLess.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.btnLessAction), for: UIControlEvents.touchUpInside)
        btnLess.setImage(UIImage(named: "addProduct_Less"), for: UIControlState())
        
        lblQuantityW = UILabel(frame:CGRect(x: btnLess.frame.maxX + 4, y: yPositionForTitles, width: 152, height: 40))
        lblQuantityW.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantityW.textColor = UIColor.white
        lblQuantityW.text = " \(Int(currentValGr))g"
        lblQuantityW.textAlignment = NSTextAlignment.center
        lblQuantityW.minimumScaleFactor =  35 / 40
        lblQuantityW.adjustsFontSizeToFitWidth = true
        
        btnMore = UIButton(frame: CGRect(x: lblQuantityW.frame.maxX + 4,  y: yPositionForTitles, width: buttonSize, height: buttonSize))
        btnMore.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.btnMoreAction), for: UIControlEvents.touchUpInside)
        btnMore.setImage(UIImage(named: "addProduct_Add"), for: UIControlState())
        
        quantityWAnimate = UIView(frame: CGRect(x: lblQuantityW.bounds.maxX - 3, y: 0, width: 1, height: lblQuantityW.frame.height))
        quantityWAnimate.backgroundColor = UIColor.white
        quantityWAnimate.alpha = 0
        
        self.updateLabelW()
        
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(GRShoppingCartWeightSelectorView.updateAnimation), userInfo: nil, repeats: true)
        
        var closePossitionY : CGFloat = IS_IPAD ? startH - 3 :  startH - 26
        closePossitionY = closePossitionY <= 0 ? 0 : closePossitionY
        let closeButton = UIButton(frame: CGRect(x: 4, y: closePossitionY, width: 44, height: 44))
        closeButton.setImage(UIImage(named:"close"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.closeSelectQuantity), for: UIControlEvents.touchUpInside)
        
        let adjustWeightY: CGFloat = frame.height > 380 ? 14 : 0
        let separationWeightY: CGFloat = 12 + adjustWeightY
        let keyboardWeightHeight: CGFloat = isFullView ? 196 : 190
        let keyboardWeightYPosition: CGFloat = isFullView ? lblQuantityW.frame.maxY + 74 : lblQuantityW.frame.maxY + separationWeightY
        
        keyboard = WeightKeyboardView(frame: CGRect(x: (self.frame.width / 2) - (289/2), y: keyboardWeightYPosition, width: 289, height: keyboardWeightHeight))
        keyboard.delegate = self
        
        let botomWeightMargin: CGFloat = isFullView ? 74 : separationWeightY
        btnOkAdd = UIButton(frame: CGRect(x: (frame.width - 142) / 2, y: keyboard.frame.maxY + botomWeightMargin, width: 142, height: 36))
        btnOkAdd.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAdd.layer.cornerRadius = 18.0
        btnOkAdd.backgroundColor = WMColor.green
        btnOkAdd.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        

        if UserCurrentSession.sharedInstance.userHasUPCShoppingCart(self.upcProduct) {
            isUpcInShoppingCart = true
        } else {
            isUpcInShoppingCart = false
        }
        
        updateShoppButton()

        let gestureQuantity = UITapGestureRecognizer(target: self, action: #selector(GRShoppingCartWeightSelectorView.changetonumberpad(_:)))
        lblQuantityW.addGestureRecognizer(gestureQuantity)
        lblQuantityW.isUserInteractionEnabled = true
        
        btnNote = UIButton(frame:CGRect(x:0,y:btnOkAdd.frame.minY,width:btnOkAdd.frame.minX ,height:36))
        btnNote.setTitle(NSLocalizedString("shoppingcart.addnotebtn", comment: ""), for: .normal)
        btnNote.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        btnNote.alpha = 0
        btnNote.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.updateOrAddNote), for: .touchUpInside)
        self.addSubview(btnNote)
        
        btnNoteComplete = UIButton(frame: CGRect(x: 0, y: btnOkAdd.frame.maxY + 10, width: self.frame.width, height: 40))
        btnNoteComplete.setImage(UIImage(named: "notes_alert"), for: UIControlState())
        self.btnNoteComplete!.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 10.0)
        btnNoteComplete.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.updateOrAddNote), for: UIControlEvents.touchUpInside)
        btnNoteComplete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        btnNoteComplete.alpha = 0
        
        btnDelete = UIButton(frame:CGRect(x:btnOkAdd.frame.maxX,y:btnOkAdd.frame.minY,width:self.bounds.width - btnOkAdd.frame.maxX ,height:36))
        btnDelete.setTitle(NSLocalizedString("shoppingcart.delete", comment: ""), for: .normal)
        btnDelete.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        btnDelete.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deleteItems), for: .touchUpInside)

        self.addSubview(self.backgroundView!)
        containerWeightView.addSubview(btnLess)
        containerWeightView.addSubview(btnMore)
        containerWeightView.addSubview(lblQuantityW)
        containerWeightView.addSubview(keyboard)
        containerWeightView.addSubview(btnOkAdd)
        containerWeightView.addSubview(closeButton)
        containerWeightView.addSubview(btnNote)
        containerWeightView.addSubview(btnNoteComplete)
        containerWeightView.addSubview(btnDelete)
        
        let lblTitleNum = UILabel(frame:CGRect(x: (self.frame.width / 2.0) - 115.0, y: startH + 10, width: 230, height: 14))
        lblTitleNum.font = WMFont.fontMyriadProSemiboldSize(14)
        lblTitleNum.textColor = UIColor.white
        lblTitleNum.text = NSLocalizedString("shoppingcart.addquantitytitle",comment:"")
        lblTitleNum.textAlignment = NSTextAlignment.center

        buttonGramsKG = UIButton(frame: CGRect(x: (self.frame.width / 2.0) - 60, y: startH + 17, width: 120, height: 18))
        buttonGramsKG.setTitle("Ordenar por g", for: UIControlState())
        buttonGramsKG.setTitle("Ordenar por Kilos", for: UIControlState.selected)
        buttonGramsKG.setTitleColor(UIColor.white, for: UIControlState.selected)
        buttonGramsKG.setTitleColor(UIColor.white, for: UIControlState())
        buttonGramsKG.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonGramsKG.isSelected = true
        buttonGramsKG.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.changegrkg(_:)), for: UIControlEvents.touchUpInside)
        buttonGramsKG.backgroundColor = WMColor.blue
        buttonGramsKG.layer.cornerRadius = 9

        buttonKg = UIButton(frame: CGRect(x: (self.frame.width / 2.0) , y: startH + 17, width: 100, height: 14))
        buttonKg.setTitle("Kilos", for: UIControlState())
        buttonKg.setTitleColor(UIColor.white, for: UIControlState.selected)
        buttonKg.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: UIControlState())
        buttonKg.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonKg.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.changegrkg(_:)), for: UIControlEvents.touchUpInside)

        lblQuantityN = UILabel(frame:CGRect(x: (self.frame.width / 2) - (200 / 2), y: lblTitleNum.frame.maxY + 20 , width: 200, height: 40))
        lblQuantityN.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantityN.textColor = UIColor.white
        lblQuantityN.text = "\(Int(currentValCstmGr))g"
        lblQuantityN.textAlignment = NSTextAlignment.center
        
        //let gestureQuantityN = UITapGestureRecognizer(target: self, action: "changetonumberpad:")
        
        let yPosition = isSearchProductView ? closePossitionY : 0
        let closeButtonN = UIButton(frame: CGRect(x: self.frame.width - 44, y: yPosition, width: 44, height: 44))
        closeButtonN.setImage(UIImage(named:"close"), for: UIControlState())
        closeButtonN.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.closeSelectQuantity), for: UIControlEvents.touchUpInside)
        
        let backToW = UIButton(frame: CGRect(x: 0, y: yPosition, width: 44, height: 44))
        backToW.setImage(UIImage(named:"search_back"), for: UIControlState())
        backToW.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.backToWeight), for: UIControlEvents.touchUpInside)
        
        let adjustY: CGFloat = frame.height > 380 ? 14 : 0
        let separationY: CGFloat = 12 + adjustY
        let margin: CGFloat = isFullView ? ((self.frame.width - 220) / 2) : ((self.frame.width / 2) - 80)
        let keyboardHeight: CGFloat = isFullView ? 288 : 200
        let keyboardWidth: CGFloat = isFullView ? 220 : (frame.width - (margin * 2))
        let keyboardYPosition: CGFloat = isFullView ? lblQuantityN.frame.maxY + 28 : lblQuantityN.frame.maxY + separationY
        
        keyboardN = NumericKeyboardView(frame: CGRect (x: margin, y: keyboardYPosition, width: keyboardWidth, height: keyboardHeight), typeKeyboard: NumericKeyboardViewType.Integer)
        keyboardN.widthButton = isFullView ? 60 : 40
        keyboardN.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        keyboardN.delegate = self
        keyboardN.showDeleteBtn()
        
        let botomMargin: CGFloat = isFullView ? 28 : separationY
        btnOkAddN = UIButton(frame: CGRect(x: (frame.width - 142) / 2, y: keyboardN.frame.maxY + botomMargin, width: 142, height: 36))
        btnOkAddN.titleLabel?.font = WMFont.fontMyriadProSemiboldOfSize(16)
        btnOkAddN.layer.cornerRadius = 18.0
        btnOkAddN.backgroundColor = WMColor.green
        btnOkAddN.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        
        buttonDelet = UIButton(frame:CGRect(x:btnOkAdd.frame.maxX,y:btnOkAdd.frame.minY,width:self.bounds.width - btnOkAdd.frame.maxX ,height:36))
        buttonDelet.setTitle(NSLocalizedString("shoppingcart.delete", comment: ""), for: .normal)
        buttonDelet.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelet.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.userSelectDelete), for: .touchUpInside)
        buttonDelet.alpha = 1
        
        self.updateShoppButtonN()
        
        btnNoteN = UIButton(frame:CGRect(x:0,y:btnOkAdd.frame.minY,width:btnOkAdd.frame.minX ,height:36))
        btnNoteN.setTitle(NSLocalizedString("shoppingcart.addnotebtn", comment: ""), for: .normal)
        btnNoteN.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        btnNoteN.alpha = 0
        btnNoteN.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.updateOrAddNote), for: .touchUpInside)
        
        containerNumericView.addSubview(buttonGramsKG)
        containerNumericView.addSubview(lblQuantityN)
        containerNumericView.addSubview(keyboardN)
        containerNumericView.addSubview(btnOkAddN)
        containerNumericView.addSubview(closeButtonN)
        containerNumericView.addSubview(backToW)
        containerNumericView.addSubview(btnNoteN)
        containerNumericView.addSubview(buttonDelet)
        
        containerView.addSubview(containerWeightView)
        containerView.addSubview(containerNumericView)
        
        self.addSubview(containerView)
        
        if equivalenceByPiece.intValue > 0 {
            initViewForPices()
        }
        
        if isUpcInShoppingCart  {
            self.showNoteButton()

        }
        
    }
    
    override func addtoshoppingcart(_ sender:AnyObject) {
        
        orderByPiece = btnChankePices != nil ? btnChankePices.isSelected : false
        
        if self.customValue {
            if currentValCstmGr.truncatingRemainder(dividingBy: 50) != 0 || currentValCstmGr == 0 {
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
    
    override func deletefromshoppingcart(_ sender:AnyObject) {
        addToCartAction(ZERO_QUANTITY_STRING)
    }
    
    override func generateBlurImage(_ viewBg:UIView,frame:CGRect) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 1.0);
        viewBg.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        imageBlurView = UIImageView()
        imageBlurView.frame = frame
        imageBlurView.clipsToBounds = true
        imageBlurView.image = blurredImage
        
        self.addSubview(imageBlurView)
        self.sendSubview(toBack: imageBlurView)
    }
    
    override func closeSelectQuantity() {
        if closeAction != nil {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_CLOSE_KEYBOARD.rawValue, label:"" )
            closeAction()
        }
    }
    
    override func userSelectValue(_ value:String!) {
        
        if btnChankePices != nil && btnChankePices.isSelected {
            
            var tmpResult : Double = 0.0
            var resultText : NSString = ""
            
            if first {
                resultText  = "\(value!)" as NSString
                first = false
                tmpResult = resultText.doubleValue
            }else {
                resultText = "\(Int(currentValPzs))\(value!)" as NSString
                tmpResult = resultText.doubleValue
            }
            
            let equivalence : Int = self.equivalenceByPiece.intValue * Int(tmpResult)
            if Double(equivalence) <= CONS_MAXVAL {
                if  Double(equivalence) == 0 {
                  showError("Cantidad minima 1 pieza")
                } else {
                    currentValPzs = tmpResult
                    originalValPzs = currentValPzs
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
                resultText  = "\(value!)" as NSString
                first = false
            } else {
                resultText  = "\(Int(currentValCstmGr))\(value!)" as NSString
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
               
                currentValKg = "\(currentValKg!)\(value!)"
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
            self.orderByPiece =  false
            let resultText : NSString = "\(value!)" as NSString
            currentValGr = resultText.doubleValue
            originalValGr = currentValGr
            self.updateLabelW()
            self.updateShoppButton()
        }
        }
    }
    
    override func userSelectDelete() {
        
        if btnChankePices != nil && btnChankePices.isSelected {
            
            var resultText : NSString  = "\(Int(currentValPzs))" as NSString
            resultText = resultText.substring(to: resultText.length - 1) as NSString
            
            if resultText == "" {
                resultText = "0"
            }
            
            currentValPzs = resultText.doubleValue
            originalValPzs = currentValPzs
            
            self.updateLabelP()
            self.updateShoppButton()
            
        } else {
            if customValue {
                var resultText : NSString  = "\(Int(currentValCstmGr))" as NSString
                resultText = resultText.substring(to: resultText.length - 1) as NSString
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
                        let valKgTotal : NSString = valInKgString.substring(to: valInKgString.length - 1) as NSString
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
    
    override func showNoteButton() {
        self.btnNoteN.alpha = 1
        self.btnNote.alpha = 1
    }
    
    override func showNoteButtonComplete() {
        self.btnNoteComplete.alpha = 1
        self.btnNoteCompleteN.alpha = 1
    }
    
    override func setTitleCompleteButton(_ title:String) {
        self.btnNoteComplete.setTitle(title,for: UIControlState())
        self.btnNoteCompleteN.setTitle(title,for: UIControlState())
    }
    
    override func validateOrderByPiece(orderByPiece: Bool, quantity: Double, pieces: Int) {
        super.validateOrderByPiece(orderByPiece: orderByPiece, quantity: quantity, pieces: pieces)
        currentValGr = quantity
        if equivalenceByPiece.intValue > 0 && orderByPiece && pieces != 0{
            originalValPzs = Double(pieces)
            currentValPzs = Double(pieces)
            originalValGr = 100
            orderbypices()
        } else if equivalenceByPiece.intValue > 0 && orderByPiece && pieces == 0 {
            let piecesByEquivalence = Int(quantity) / equivalenceByPiece.intValue
            originalValPzs = Double(piecesByEquivalence)
            currentValPzs = Double(piecesByEquivalence)
            originalValGr = 100
            orderbypices()
        } else {
            first = true
            userSelectValue("\(quantity)")
        }
    }
    
    override func deleteItems() {
        self.lblQuantityW?.text = ZERO_QUANTITY_STRING
        self.lblQuantityN?.text = ZERO_QUANTITY_STRING
        if customValue {
            updateShoppButtonN()
        } else {
            updateShoppButton()
        }
    }
    
    func showError (_ message: String ){
        if !visibleLabel  {
            
            visibleLabel = true
            
            var  imageView : UIView? =  UIView(frame:CGRect(x: (self.frame.width/2) - 115 , y: self.lblQuantityN.frame.minY - 40, width: 230, height: 20))
            var  viewContent : UIView? = UIView(frame: imageView!.bounds)
            viewContent!.layer.cornerRadius = 4.0
            viewContent!.backgroundColor = UIColor.white
            imageView!.addSubview(viewContent!)
            self.addSubview(imageView!)
            
            var lblError : UILabel? =   UILabel(frame:CGRect (x: 0, y: 0 , width: viewContent!.frame.width, height: 20))
            lblError!.font = WMFont.fontMyriadProRegularOfSize(12)
            
            lblError!.textColor = WMColor.light_blue
            lblError!.backgroundColor = UIColor.clear
            lblError!.text = message
            lblError!.textAlignment = NSTextAlignment.center
            viewContent!.addSubview(lblError!)
            
            var imageIco : UIImageView? = UIImageView()
            imageIco!.image = UIImage(named:"tooltip_white")
            imageIco!.frame = CGRect( x: (self.frame.width - 3 ) / 2  , y: imageView!.frame.maxY,   width: 6, height: 4)
            self.addSubview(imageIco!)
            
            UIView.animate(withDuration: 3.5,
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
    
    func initViewForPices() {
        
        let valueItemPzs = NSMutableAttributedString()
        
        lblQuantityP = UILabel(frame:CGRect(x: 16, y: btnChankePices.frame.maxY + 17 , width: containerWeightView.frame.width - 32, height: 40))
        lblQuantityP.font = WMFont.fontMyriadProRegularOfSize(40)
        lblQuantityP.textColor = UIColor.white
        valueItemPzs.append(NSAttributedString(string: "\(Int(currentValPzs)) pzas", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(40),NSForegroundColorAttributeName:UIColor.white]))
        valueItemPzs.append(NSAttributedString(string: " (\(self.equivalenceByPiece.intValue)gr)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(20),NSForegroundColorAttributeName:UIColor.white]))
        lblQuantityP.attributedText = valueItemPzs
        lblQuantityP.textAlignment = NSTextAlignment.center
        lblQuantityP.minimumScaleFactor =  35 / 40
        lblQuantityP.adjustsFontSizeToFitWidth = true
        lblQuantityP.alpha = 0
        
        let adjustY: CGFloat = frame.height > 380 ? 16 : 0
        let separationY: CGFloat = 8 + adjustY
        let margin: CGFloat = isFullView ? ((self.frame.width - 220) / 2) : ((self.frame.width / 2) - 80)
        let keyboardHeight: CGFloat = isFullView ? 288 : 200
        let keyboardWidth: CGFloat = isFullView ? 220 : (frame.width - (margin * 2))
        let keyboardYPosition: CGFloat = isFullView ? lblQuantityP.frame.maxY + 28 : lblQuantityP.frame.maxY + separationY
        
        keyboardP = NumericKeyboardView(frame: CGRect(x: margin, y: keyboardYPosition, width: keyboardWidth, height: keyboardHeight), typeKeyboard: NumericKeyboardViewType.Integer)
        keyboardP.widthButton = isFullView ? 60 : 40
        keyboardP.generateButtons(UIColor.white.withAlphaComponent(0.35), selected: UIColor.white)
        keyboardP.delegate = self
        keyboardP.showDeleteBtn()
        keyboardP.alpha = 0
        
        containerWeightView.addSubview(lblQuantityP)
        containerWeightView.addSubview(keyboardP)
        
    }
    
    func btnMoreAction() {
        if (currentValGr + 50.0) <= CONS_MAXVAL {
              //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_ADD_GRAMS.rawValue , label:"" )
            
            if let weightBtn = keyboard.weightBtnSelected {
                keyboard.seleccionboton(weightBtn)
                keyboard.weightBtnSelected = nil
            }
            
            currentValGr = currentValGr + 50
            originalValGr = currentValGr
            updateShoppButton()
            updateLabelW()
            
            validateWeightSelectedBtn(gr: currentValGr)
        }
    }
    
    func btnLessAction() {
        if (currentValGr - 50.0) > CONS_MINVAL {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_DECREASE_GRAMS.rawValue , label:"" )
            
            if let weightBtn = keyboard.weightBtnSelected {
                keyboard.seleccionboton(weightBtn)
                keyboard.weightBtnSelected = nil
            }
            
            currentValGr = currentValGr - 50
            originalValGr = currentValGr
            updateShoppButton()
            updateLabelW()
            
            validateWeightSelectedBtn(gr: currentValGr)
        }
    }
    
    func validateWeightSelectedBtn(gr: Double) {
        if gr == 100.0 {
            keyboard.seleccionboton(keyboard.btngramos)
        } else if gr == 250.0 {
            keyboard.seleccionboton(keyboard.btncuarto)
        } else if gr == 500.0 {
            keyboard.seleccionboton(keyboard.btmediokilo)
        } else if gr == 750.0 {
            keyboard.seleccionboton(keyboard.bttrescuartos)
        } else if gr == 1000.0 {
            keyboard.seleccionboton(keyboard.btunkilo)
        }
    }
    
    func updateShoppButton() {
        
        let result = self.orderByPiece ? (priceProduct.doubleValue / 1000.0 ) * Double(self.equivalenceByPiece.intValue * Int(currentValPzs)) : (priceProduct.doubleValue / 1000.0 ) * currentValGr
        
        let strPrice = CurrencyCustomLabel.formatString("\(result)" as NSString)
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        
        var rectSize = CGRect.zero
        if isUpcInShoppingCart {
            btnOkAdd.setTitle("\(strUpdateToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
        } else {
            if result == 0.0 || result == 0 {
                return 
            }
            btnOkAdd.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        }
        
        if lblQuantityW?.text ?? "" == ZERO_QUANTITY_STRING {
            self.btnOkAdd.backgroundColor = WMColor.red
            if isFromList {
                self.btnOkAdd.setTitle(NSLocalizedString("shoppingcart.deleteoflist", comment: ""), for: .normal)
            } else {
                self.btnOkAdd.setTitle(NSLocalizedString("shoppingcart.deleteofcart", comment: ""), for: .normal)
            }
            self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAdd.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            
            if !isUpcInShoppingCart {
                if let weightBtn = keyboard.weightBtnSelected {
                    keyboard.seleccionboton(weightBtn)
                    keyboard.weightBtnSelected = nil
                }
                self.originalValGr = 0.0
                self.currentValGr = self.originalValGr
                self.currentValCstmGr = 0.0
                let tmpResult : NSString = "\(Int(currentValGr))g" as NSString
                lblQuantityW.text = tmpResult as String
                btnOkAdd.setTitle("\(strAdddToSC) \("0")", for: UIControlState())
                let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \("0")", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
                rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            }
        } else {
            self.btnOkAdd.backgroundColor = WMColor.green
            self.btnOkAdd.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAdd.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let botomMargin: CGFloat = self.isFullView ? 110 : 50
            self.btnOkAdd.frame = CGRect(x: (self.frame.width / 2) - ((rectSize.width + 32) / 2),y: self.btnOkAdd.frame.minY , width: rectSize.width + 32, height: 36)
        })
        
    }
    
    func updateShoppButtonN() {
        
        let result = self.orderByPiece ? (priceProduct.doubleValue / 1000.0 ) * Double(self.equivalenceByPiece.intValue * Int(currentValPzs)) : (priceProduct.doubleValue / 1000.0 ) * currentValCstmGr
        let strPrice = CurrencyCustomLabel.formatString("\(result)" as NSString)
        let strAdddToSC = NSLocalizedString("shoppingcart.addtoshoppingcart",comment:"")
        let strUpdateToSC = NSLocalizedString("shoppingcart.updatetoshoppingcart",comment:"")
        
        var rectSize = CGRect.zero
        if isUpcInShoppingCart {
            btnOkAddN.setTitle("\(strUpdateToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strUpdateToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        } else {
            btnOkAddN.setTitle("\(strAdddToSC) \(strPrice)", for: UIControlState())
            let attrStringLab = NSAttributedString(string:"\(strAdddToSC) \(strPrice)", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(16)])
            rectSize = attrStringLab.boundingRect(with: CGSize(width: self.frame.width, height: 36), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        }
        
        if lblQuantityN?.text ?? "" == ZERO_QUANTITY_STRING  {
            self.btnOkAddN.backgroundColor = WMColor.red
            if isFromList {
                self.btnOkAddN.setTitle(NSLocalizedString("shoppingcart.deleteoflist", comment: ""), for: .normal)
            } else {
                self.btnOkAddN.setTitle(NSLocalizedString("shoppingcart.deleteofcart", comment: ""), for: .normal)
            }
            self.btnOkAddN.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAddN.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
        } else {
            self.btnOkAddN.backgroundColor = WMColor.green
            self.btnOkAddN.removeTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.deletefromshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            self.btnOkAddN.addTarget(self, action: #selector(GRShoppingCartQuantitySelectorView.addtoshoppingcart(_:)), for: UIControlEvents.touchUpInside)
            
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.btnOkAddN.frame =  CGRect(x: (self.frame.width / 2) - ((rectSize.width + 32) / 2),y: self.btnOkAddN.frame.minY , width: rectSize.width + 32, height: 36)
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
            if (currentValGr.truncatingRemainder(dividingBy: 1000)) == 0 {
                formatedString = String(format:"%.f",valInKg)
            } else {
                formatedString = String(format:"%.2f",valInKg)
            }
            
            let tmpResult : NSString = "\(formatedString)kg" as NSString
            lblQuantityW.text = tmpResult as String
        }else {
            let tmpResult : NSString = "\(Int(currentValGr))g" as NSString
            lblQuantityW.text = tmpResult as String
        }
        let rectSize =  lblQuantityW.attributedText!.boundingRect(with: CGSize(width: lblQuantityW.frame.width, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        quantityWAnimate.frame = CGRect(x: (lblQuantityW.bounds.width / 2) + (rectSize.width / 2) + 3, y: 0, width: 1, height: lblQuantityW.frame.height)
        
    }
    
    func updateLabelN(_ value:String) {
        lblQuantityN.text = String(format:"%@Kg",value)
    }
    
    func updateLabelN() {
        if gramsBase {
            let tmpResult : NSString = "\(Int(currentValCstmGr))g" as NSString
            lblQuantityN.text = tmpResult as String
        } else {
            var formatedString = ""
            let valInKg = currentValGr / 1000
            if (currentValGr.truncatingRemainder(dividingBy: 1000)) == 0 {
                formatedString = String(format:"%.fKg",valInKg)
            } else {
                formatedString = String(format:"%.2fKg",valInKg)
            }
            lblQuantityN.text = formatedString
        }
    }
    
    func updateLabelP() {
        
        let equivalence : Int = self.equivalenceByPiece.intValue * Int(currentValPzs)
        currentValGr = self.orderByPiece ? currentValPzs : Double(equivalence)
        
        let valueItemPzs = NSMutableAttributedString()
        valueItemPzs.append(NSAttributedString(string: "\(Int(currentValPzs)) pzas", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(40),NSForegroundColorAttributeName:UIColor.white]))
        
        lblQuantityP.attributedText = valueItemPzs
        
    }
    
    func changetonumberpad(_ sender:AnyObject) {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_OPEN_KEYBOARD_KILO.rawValue, label:"" )
        customValue = true
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerView.frame = CGRect(x: -self.containerWeightView.frame.maxX, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height)
            }, completion: { (complete:Bool) -> Void in
            
        }) 
    }
    
    func backToWeight() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_KEYBOARD_GRAMS.rawValue, action:WMGAIUtils.ACTION_BACK_KEYBOARG_GRAMS.rawValue, label:"" )
        self.customValue = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerView.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height)
            }, completion: { (complete:Bool) -> Void in
                
        }) 
    }
    
    func updateAnimation() {
        if quantityWAnimate.alpha  == 0 {
            quantityWAnimate.alpha = 1
        }else {
            quantityWAnimate.alpha = 0
        }
    }
    
    func changegrkg(_ sender:UIButton) {
        if buttonGramsKG.isSelected {
            
            gramsBase = false
            buttonGramsKG.isSelected = false
            self.keyboardN.changeType(NumericKeyboardViewType.Decimal)
            
            var formatedString = ""
            let valInKg = currentValCstmGr / 1000.0
            
            if (currentValCstmGr.truncatingRemainder(dividingBy: 1000)) == 0 {
                formatedString = String(format:"%.f",valInKg)
            } else {
                formatedString = String(format:"%.2f",valInKg)
            }
            
            currentValKg = formatedString
            
            self.updateLabelN(currentValKg!)
            
        } else {
            gramsBase = true
            buttonGramsKG.isSelected = true
            self.keyboardN.changeType(NumericKeyboardViewType.Integer)
            self.updateLabelN()
        }
        keyboardN.showDeleteBtn()
    }
    
    func setBackActionShoppingCart(_ backAction:@escaping (() -> Void)) {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        backButton.setImage(UIImage(named: "search_back"), for: UIControlState())
        backButton.addTarget(self, action: #selector(GRShoppingCartWeightSelectorView.backActionUpInside), for: UIControlEvents.touchUpInside)
        self.addSubview(backButton)
        self.backAction = backAction
    }
    
    func backActionUpInside() {
        self.backAction()
    }
    
    func orderbypices() {
        
        btnChankePices.isEnabled = false
        
        if btnChankePices.isSelected {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.currentValGr = self.originalValGr
                self.updateLabelW()
                self.updateShoppButton()
                self.lblQuantityW.alpha = 1
                self.btnLess.alpha = 1
                self.btnMore.alpha = 1
                self.btnLess.alpha = 1
                self.keyboard.alpha = 1
                self.lblQuantityP.alpha = 0
                self.keyboardP.alpha = 0
            }, completion: { (Bool) -> Void in
                self.btnChankePices.isEnabled = true
                self.btnChankePices.isSelected = !self.btnChankePices.isSelected
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.orderByPiece = true
                self.btnChankePices.isSelected =  true
                self.currentValPzs = self.originalValPzs
                self.updateLabelP()
                self.updateShoppButton()
                self.lblQuantityW.alpha = 0
                self.btnLess.alpha = 0
                self.btnMore.alpha = 0
                self.btnLess.alpha = 0
                self.keyboard.alpha = 0
                self.lblQuantityP.alpha = 1
                self.keyboardP.alpha = 1
            }, completion: { (Bool) -> Void in
                self.btnChankePices.isEnabled = true
                self.btnChankePices.isSelected = true// !self.btnChankePices.isSelected
            })
        }

    }
    
}

