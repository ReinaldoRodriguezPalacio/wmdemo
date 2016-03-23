//
//  GRCheckOutCommentsViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
import Tune

class GRCheckOutCommentsViewController : NavigationViewController, TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate,UITextViewDelegate {

    let secSep: CGFloat = 30.0
    let titleSep: CGFloat = 15.0
    let fieldSep: CGFloat = 10.0
    let headerHeight: CGFloat = 46
    var content: TPKeyboardAvoidingScrollView!
    var viewLoad : WMLoadingView!
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var stepLabel: UILabel!
    var comments: UITextView?
    var phoneField: FormFieldView?
    var confirmCallButton: UIButton?
    var notConfirmCallButton: UIButton?
    var confirmCallOptionButton: UIButton?
    var paramsToOrder : NSMutableDictionary?
    var confirmSelected: Int! = 3
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel?.text = "Instrucciones especiales"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, headerHeight, self.view.bounds.width, self.view.bounds.height - (headerHeight + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        
        let margin: CGFloat = 16.0
        let width = self.view.frame.width - (2*margin)
        let fheight: CGFloat = 44.0
        let lheight: CGFloat = 15.0
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "2 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        let sectionTitle = self.buildSectionTitle("Si alguno de los articulos no esta disponible", frame: CGRectMake(margin, margin, width, lheight))
        self.content.addSubview(sectionTitle)
        
        self.confirmCallButton = UIButton(frame: CGRectMake(margin,sectionTitle.frame.maxY + margin,width,20))
        self.confirmCallButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.confirmCallButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.confirmCallButton!.addTarget(self, action: "confirmCallSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        self.confirmCallButton!.setTitle(NSLocalizedString("gr.confirmacall", comment: ""), forState: .Normal)
        self.confirmCallButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.confirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.confirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.confirmCallButton!.selected = true
        self.confirmCallButton!.tag = 3
        self.content.addSubview(self.confirmCallButton!)

        
        self.phoneField = FormFieldView(frame: CGRectMake(margin, confirmCallButton!.frame.maxY + 8.0, width, fheight))
        self.phoneField!.setCustomPlaceholder("Telefono: 5529000117")
        self.phoneField!.isRequired = false
        self.phoneField!.typeField = TypeField.Phone
        self.phoneField!.nameField = "phone"
        self.phoneField!.maxLength = 10
        self.phoneField!.minLength = 10
        self.phoneField!.text = (UserCurrentSession.sharedInstance().userSigned?.profile.phoneHomeNumber as? String)
        self.content.addSubview(self.phoneField!)
        
        self.confirmCallOptionButton = UIButton(frame: CGRectMake(margin,phoneField!.frame.maxY + margin,width,30))
        self.confirmCallOptionButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.confirmCallOptionButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.confirmCallOptionButton!.addTarget(self, action: "confirmCallSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        self.confirmCallOptionButton!.setTitle(NSLocalizedString("gr.not.confirmacall.option.detail", comment: ""), forState: .Normal)
        self.confirmCallOptionButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.confirmCallOptionButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.confirmCallOptionButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.confirmCallOptionButton!.titleLabel?.numberOfLines = 2
        self.confirmCallOptionButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.confirmCallOptionButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 14, right:0 )
        self.confirmCallOptionButton!.tag = 1
        self.content.addSubview(self.confirmCallOptionButton!)
        
        self.notConfirmCallButton = UIButton(frame: CGRectMake(margin,confirmCallOptionButton!.frame.maxY + margin,width,30))
        self.notConfirmCallButton!.setImage(UIImage(named:"checkTermOff"), forState: UIControlState.Normal)
        self.notConfirmCallButton!.setImage(UIImage(named:"checkAddressOn"), forState: UIControlState.Selected)
        self.notConfirmCallButton!.addTarget(self, action: "confirmCallSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        self.notConfirmCallButton!.setTitle(NSLocalizedString("gr.not.confirmacall.detal", comment: ""), forState: .Normal)
        self.notConfirmCallButton!.setTitleColor(WMColor.dark_gray, forState: .Normal)
        self.notConfirmCallButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.notConfirmCallButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.notConfirmCallButton!.titleLabel?.numberOfLines = 2
        self.notConfirmCallButton!.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.notConfirmCallButton!.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 14, right:0 )
        self.notConfirmCallButton!.tag = 2
        self.content.addSubview(self.notConfirmCallButton!)
        
        let sectionTitleComments = self.buildSectionTitle("¿Alguna intruccióno nota adicional?", frame: CGRectMake(margin, notConfirmCallButton!.frame.maxY + 28.0, width, lheight))
        self.content.addSubview(sectionTitleComments)
        
        self.comments = UITextView(frame:CGRectMake(margin,sectionTitleComments.frame.maxY + margin,width,70))
        self.comments!.layer.cornerRadius = 5.0
        self.comments!.returnKeyType = .Default
        self.comments!.autocapitalizationType = .None
        self.comments!.autocorrectionType = .No
        self.comments!.enablesReturnKeyAutomatically = true
        self.comments!.font = WMFont.fontMyriadProItOfSize(12)
        self.comments!.text = NSLocalizedString("checkout.field.comments", comment:"")
        self.comments!.textColor = UIColor.grayColor()
        self.comments!.backgroundColor = WMColor.light_light_gray
        self.comments!.delegate = self
        self.content.addSubview(self.comments!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Continuar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.light_blue
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - 65)
        self.layerLine.frame = CGRectMake(0, self.view.bounds.height - 65,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
    }
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    func next(){
        self.paramsToOrder!["comments"] = self.comments!.text
        self.paramsToOrder!["pickingInstruction"] = self.confirmSelected
        let nextController = GRCheckOutPymentViewController()
        nextController.paramsToOrder = self.paramsToOrder
        //nextController.paramsFromOrder("3", year: "2016", day: "20", comments: "Comentarios para envio de pedido", addressID: "c96-cef3-485a-b340-54e5e62673f1", deliveryType: "3", hour: "Martes - (14:00 - 15:00)", pickingInstruction: "3", deliveryTypeString: "Entrega Programada - $44", slotId: 1,shipmentAmount: 12.9)
        self.navigationController?.pushViewController(nextController, animated: true)
    }

    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            viewLoad.startAnnimating(true)
            self.view.addSubview(viewLoad)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func confirmCallSelected(button:UIButton){
        self.confirmCallButton?.selected = (self.confirmCallButton == button)
        self.notConfirmCallButton?.selected = (self.notConfirmCallButton == button)
        self.confirmCallOptionButton?.selected = (self.confirmCallOptionButton == button)
        self.confirmSelected = button.tag
    }
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.view.frame.width, self.content.contentSize.height)
    }
    
    //MARK: -TextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if NSString(string:textView.text).length + (NSString(string:text).length - range.length) ==  0{
            textView.text =  NSLocalizedString("checkout.field.comments", comment:"")
            textView.resignFirstResponder()
            textView.textColor = UIColor.grayColor()
        }
        return NSString(string:textView.text).length + (NSString(string:text).length - range.length) <= 200
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text ==  NSLocalizedString("checkout.field.comments", comment:"") {
            textView.text = ""
            textView.textColor = WMColor.dark_gray
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.content!.contentOffset = CGPointMake(0, 100)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text =  NSLocalizedString("checkout.field.comments", comment:"")
            textView.textColor = UIColor.grayColor()
        }
        self.content!.contentOffset = CGPointZero
    }

}