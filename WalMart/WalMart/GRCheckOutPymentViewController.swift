//
//  GRCheckOutPymentViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class GRCheckOutPymentViewController : NavigationViewController,UIWebViewDelegate,TPKeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate,SegmentedViewDelegate {

    var content: TPKeyboardAvoidingScrollView!
    
    var cancelShop : UIButton?
    var continueShop : UIButton?
    var sectionTitleDiscount : UILabel!
    var contenPayments  : UIView!
    var tapPayments :  SegmentedView!
    var stepLabel: UILabel!
    var paymentLine : UIView?
    var paymentDelivery : UIView?
    
    let margin:  CGFloat = 15.0
    let fheight: CGFloat = 44.0
    let lheight: CGFloat = 25.0
    
    let itemsPayments = [NSLocalizedString("En linea", comment:""), NSLocalizedString("Contra entrega", comment:"")]
    
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =  UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("Método de Pago", comment:"")
        
        self.stepLabel = UILabel()
        self.stepLabel.textColor = WMColor.gray
        self.stepLabel.text = "3 de 3"
        self.stepLabel.font = WMFont.fontMyriadProRegularOfSize(12)
        self.header?.addSubview(self.stepLabel)
        
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content.frame = CGRectMake(0.0, 46, self.view.bounds.width, self.view.bounds.height - (46 + 120))
        self.content.delegate = self
        self.content.scrollDelegate = self
        self.content.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content)
        

        self.cancelShop =  UIButton()
        cancelShop?.setTitle(NSLocalizedString("Cancelar", comment: ""), forState:.Normal)
        cancelShop?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelShop?.backgroundColor = WMColor.empty_gray_btn
        cancelShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelShop?.layer.cornerRadius = 16
        cancelShop?.addTarget(self, action: "cancelPurche", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelShop!)
        
        self.continueShop =  UIButton()
        continueShop?.setTitle(NSLocalizedString("Continuar", comment: ""), forState:.Normal)
        continueShop?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        continueShop?.backgroundColor = WMColor.green
        continueShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        continueShop?.layer.cornerRadius = 16
        continueShop?.addTarget(self, action: "continuePurche", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(continueShop!)
        
        self.contenPayments =  UIView()
        self.contenPayments.backgroundColor = UIColor.whiteColor()
        self.contenPayments.layer.cornerRadius =  11.0
        self.contenPayments!.layer.borderWidth = 1.0
        self.contenPayments!.layer.borderColor = WMColor.light_gray.CGColor
        self.contenPayments!.clipsToBounds = true
        self.content.addSubview(self.contenPayments)
        
        
        self.tapPayments =  SegmentedView(frame:CGRectMake(0,0 ,self.view.frame.width,40) , items:self.itemsPayments)
        self.tapPayments.delegate =  self
        self.contenPayments.addSubview(self.tapPayments)
        
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRectMake(16, self.contenPayments!.frame.maxY + 20.0, self.view.frame.width, lheight))
        self.content.addSubview(self.sectionTitleDiscount)
        
        //views
        self.paymentLine =  UIView()
        self.paymentLine?.backgroundColor =  UIColor.redColor()
        self.contenPayments.addSubview(self.paymentLine!)
        
        self.paymentDelivery =  UIView()
        self.paymentDelivery?.backgroundColor =  UIColor.brownColor()
        self.paymentDelivery?.hidden =  true
        self.contenPayments.addSubview(self.paymentDelivery!)
        
        self.content.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.maxY + 20.0)
        
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width - (2 * margin)
        let bounds = self.view.frame.size
        let footerHeight:CGFloat = 60.0
        
        self.content!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - (self.header!.frame.height + footerHeight))
        
        self.stepLabel!.frame = CGRectMake(self.view.bounds.width - 51.0,8.0, self.titleLabel!.bounds.height, 35)

        self.cancelShop!.frame = CGRectMake((self.view.frame.width/2) - 148,self.view.bounds.height - 65 + 16, 140, 34)
        self.continueShop!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.view.bounds.height - 65 + 16, 140, 34)
        
        self.contenPayments.frame = CGRectMake(16, 16 ,self.view.frame.width - 32 , 300)
        self.tapPayments.frame = CGRectMake(0,0,self.contenPayments!.frame.width,40)
        sectionTitleDiscount.frame = CGRectMake(16, self.contenPayments!.frame.maxY + 28.0, width, lheight)
        
        //paymens taps
        self.paymentLine?.frame = CGRectMake(0 ,self.tapPayments.frame.maxY, self.tapPayments.frame.width, self.contenPayments.frame.height - 40)
        self.paymentDelivery?.frame = CGRectMake(0 ,self.tapPayments.frame.maxY, self.tapPayments.frame.width, self.contenPayments.frame.height - 40)
    }
    
    
    
    func buildSectionTitle(title: String, frame: CGRect) -> UILabel {
        let sectionTitle = UILabel(frame: frame)
        sectionTitle.textColor = WMColor.light_blue
        sectionTitle.font = WMFont.fontMyriadProLightOfSize(14)
        sectionTitle.text = title
        sectionTitle.backgroundColor = UIColor.whiteColor()
        return sectionTitle
    }
    
    
    
    func cancelPurche (){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func continuePurche (){
    
    }
    
    
    //MARK: SegmentedViewDelegate
    func tapSelected(index: Int) {
        if index ==  0{
            self.paymentDelivery?.hidden =  true
            self.paymentLine?.hidden = false
        }else{
            self.paymentDelivery?.hidden = false
            self.paymentLine?.hidden = true
        }
        
    }
    
    
    

}