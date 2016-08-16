//
//  PickInStoreViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 15/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class PickInStoreViewController: NavigationViewController,TPKeyboardAvoidingScrollViewDelegate, UIScrollViewDelegate {
    
    var zipCodeLabel:UILabel?
    var countyLabel:UILabel?
    var storeLabel:UILabel?
    var zipCodeField: FormFieldView?
    var countyField: FormFieldView?
    var storeField:FormFieldView?
    var saveButton: UIButton?
    var cancelButton: UIButton?
    var layerLine: CALayer!
    var content:TPKeyboardAvoidingScrollView?
    var errorView : FormFieldErrorView? = nil
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REMINDER.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel?.text = "Recoger en tienda"
        
        self.content = TPKeyboardAvoidingScrollView()
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height - (46))
        self.content!.delegate = self
        self.content!.scrollDelegate = self
        self.content!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.content!)
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 1000)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.zipCodeLabel = UILabel()
        self.zipCodeLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.zipCodeLabel?.textColor = WMColor.light_blue
        self.zipCodeLabel?.textAlignment = .Left
        self.zipCodeLabel?.text = "C.P."
        self.content!.addSubview(self.zipCodeLabel!)
        
        self.zipCodeField = FormFieldView(frame: CGRectMake(16, 16,  self.view.frame.width - 32, 40))
        self.zipCodeField!.isRequired = true
        self.zipCodeField!.setCustomPlaceholder("Codigo postal")
        self.zipCodeField!.typeField = TypeField.Number
        self.zipCodeField!.setImageTypeField()
        self.zipCodeField!.nameField = "Codigo postal"
        self.zipCodeField!.minLength = 3
        self.zipCodeField!.maxLength = 5
        self.content!.addSubview(self.zipCodeField!)
        
        self.countyLabel = UILabel()
        self.countyLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.countyLabel?.textColor = WMColor.light_blue
        self.countyLabel?.textAlignment = .Left
        self.countyLabel?.text = "Colonia"
        self.content!.addSubview(self.countyLabel!)
        
        self.countyField = FormFieldView(frame: CGRectMake(16, 16,  self.view.frame.width - 32, 40))
        self.countyField!.isRequired = true
        self.countyField!.setCustomPlaceholder("Codigo postal")
        self.countyField!.typeField = TypeField.List
        self.countyField!.setImageTypeField()
        self.countyField!.nameField = "Codigo postal"
        self.countyField!.minLength = 0
        self.countyField!.maxLength = 25
        self.content!.addSubview(self.countyField!)
        
        self.storeLabel = UILabel()
        self.storeLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        self.storeLabel?.textColor = WMColor.light_blue
        self.storeLabel?.textAlignment = .Left
        self.storeLabel?.text = "Tiendas donde puedes recoger este articulo"
        self.content!.addSubview(self.storeLabel!)
        
        self.storeField = FormFieldView(frame: CGRectMake(16, 16,  self.view.frame.width - 32, 40))
        self.storeField!.isRequired = true
        self.storeField!.setCustomPlaceholder("Tienda")
        self.storeField!.typeField = TypeField.List
        self.storeField!.setImageTypeField()
        self.storeField!.nameField = "Tienda"
        self.storeField!.minLength = 0
        self.storeField!.maxLength = 25
        self.content!.addSubview(self.storeField!)
        
        self.cancelButton = UIButton()
        self.cancelButton!.setTitle("Cancelar", forState:.Normal)
        self.cancelButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.cancelButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.cancelButton!.backgroundColor = WMColor.empty_gray_btn
        self.cancelButton!.layer.cornerRadius = 17
        self.cancelButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton!)
        
        self.saveButton = UIButton()
        self.saveButton!.setTitle("Guardar", forState:.Normal)
        self.saveButton!.titleLabel!.textColor = UIColor.whiteColor()
        self.saveButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor = WMColor.green
        self.saveButton!.layer.cornerRadius = 17
        self.saveButton!.addTarget(self, action: #selector(ReminderViewController.save), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(saveButton!)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let lineHeight: CGFloat = TabBarHidden.isTabBarHidden ? 67 : 113
        self.zipCodeLabel!.frame = CGRectMake(16, 16,  self.view.frame.width - 32, 20)
        self.zipCodeField!.frame = CGRectMake(16, self.zipCodeLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.countyLabel!.frame = CGRectMake(16, self.zipCodeField!.frame.maxY + 16,  self.view.frame.width - 32, 20)
        self.countyField!.frame = CGRectMake(16, self.countyLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.storeLabel!.frame = CGRectMake(16, self.countyField!.frame.maxY + 16,  self.view.frame.width - 32, 20)
        self.storeField!.frame = CGRectMake(16, self.storeLabel!.frame.maxY + 8,  self.view.frame.width - 32, 40)
        self.content!.frame = CGRectMake(0.0, 46.0, self.view.bounds.width, self.view.bounds.height)
        self.layerLine.frame = CGRectMake(0, self.view.frame.height - lineHeight,  self.view.frame.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 34)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 34)
    }
    
    
    //MARK: - TPKeyboardAvoidingScrollViewDelegate
    func contentSizeForScrollView(sender:AnyObject) -> CGSize {
        return CGSizeMake(self.view.frame.width, self.content!.contentSize.height)
    }
}
