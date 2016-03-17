//
//  GRCheckOutPymentViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 17/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation



class GRCheckOutPymentViewController : NavigationViewController,UIWebViewDelegate {

    
    var cancelShop : UIButton?
    var continueShop : UIButton?
    var sectionTitleDiscount : UILabel!
    var contenPayments  : UIView!
    var tapPayments :  SegmentedView!
    
    let margin:  CGFloat = 15.0
    let fheight: CGFloat = 44.0
    let lheight: CGFloat = 25.0
    
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_CHECKOUT.rawValue
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = NSLocalizedString("Método de Pago", comment:"")

        self.cancelShop =  UIButton()
        cancelShop?.setTitle(NSLocalizedString("Cancelar", comment: ""), forState:.Normal)
        cancelShop?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelShop?.backgroundColor = WMColor.light_gray
        cancelShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        cancelShop?.layer.cornerRadius = 16
        cancelShop?.addTarget(self, action: "cancelPurche", forControlEvents: UIControlEvents.TouchUpInside)
        //self.view.addSubview(cancelShop!)
        
        self.continueShop =  UIButton()
        continueShop?.setTitle(NSLocalizedString("Continuar", comment: ""), forState:.Normal)
        continueShop?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        continueShop?.backgroundColor = WMColor.light_gray
        continueShop?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        continueShop?.layer.cornerRadius = 16
        continueShop?.addTarget(self, action: "continuePurche", forControlEvents: UIControlEvents.TouchUpInside)
        //self.view.addSubview(continueShop!)
        
        self.contenPayments =  UIView()
        self.contenPayments.backgroundColor = WMColor.light_gray
        self.contenPayments.layer.cornerRadius =  11.0
      
        self.view.addSubview(self.contenPayments)
        
        
        self.tapPayments =  SegmentedView(frame: CGRectMake(0,0 ,self.view.frame.width,40 ))
        self.contenPayments.addSubview(self.tapPayments)
      
        
        sectionTitleDiscount = self.buildSectionTitle(NSLocalizedString("checkout.title.discounts", comment:""), frame: CGRectMake(16, self.contenPayments!.frame.maxY + 20.0, self.view.frame.width, lheight))
        self.view.addSubview(self.sectionTitleDiscount)
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width - (2*margin)
        
        self.cancelShop?.frame = CGRectMake(10,10 ,100 ,40 )
        self.continueShop?.frame = CGRectMake(170,100 ,100 , 40)
        self.contenPayments.frame = CGRectMake(16, 60 ,self.view.frame.width - 32 , 300)
        self.tapPayments.frame = CGRectMake(0,0,self.tapPayments.frame.width,50)
        sectionTitleDiscount.frame = CGRectMake(16, self.contenPayments!.frame.maxY + 30.0, width, lheight)
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
    
    
    

}