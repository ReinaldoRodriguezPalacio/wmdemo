//
//  AddProductTolistView.swift
//  WalMart
//
//  Created by Joel Juarez on 01/03/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

protocol AddProductTolistViewDelegate {
    func scanCode()
    func showCamera()
    func searchByText(text:String)
}

class AddProductTolistView: UIView,UITextFieldDelegate {

    var delegate : AddProductTolistViewDelegate?
    var scannerButton : UIButton!
    var camButtom :  UIButton!
    var textFindProduct : FormFieldSearch!
    var line: CALayer!
    var changeFrame =  false//detail_close
    var closeSearch : UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.setup()
    }
    
    
    func setup(){
        
        self.closeSearch = UIButton(type: .Custom)
        self.closeSearch!.setImage(UIImage(named: "delete_icon"), forState: .Normal)
        self.closeSearch!.addTarget(self, action: "closeSearchText", forControlEvents: .TouchUpInside)
        self.closeSearch!.hidden =  true
        self.addSubview(self.closeSearch!)
        
        
        self.textFindProduct = FormFieldSearch()
        self.textFindProduct!.backgroundColor = WMColor.light_gray
        self.textFindProduct!.layer.cornerRadius = 10.0
        self.textFindProduct!.font = WMFont.fontMyriadProLightOfSize(16)
        self.textFindProduct!.delegate =  self
        self.textFindProduct!.returnKeyType = .Search
        self.textFindProduct!.autocapitalizationType = .None
        self.textFindProduct!.autocorrectionType = .No
        self.textFindProduct!.placeholder = NSLocalizedString("Agrega Artículo", comment:"")
        self.addSubview(self.textFindProduct!)
        
        self.camButtom = UIButton(type: .Custom)
        self.camButtom!.setImage(UIImage(named: "cam_icon_addtolist"), forState: .Normal)
        self.camButtom!.addTarget(self, action: "showCamera", forControlEvents: .TouchUpInside)
        self.addSubview(self.camButtom!)
  
        self.scannerButton = UIButton(type: .Custom)
        self.scannerButton!.setImage(UIImage(named: "barcode_icon_addtolist"), forState: .Normal)
        self.scannerButton!.addTarget(self, action: "scanCode", forControlEvents: .TouchUpInside)
        self.addSubview(self.scannerButton!)
        
        
      
        line = CALayer()
        line.backgroundColor = WMColor.light_light_gray.CGColor
        self.layer.insertSublayer(line, atIndex: 0)
        
    }
    
    override func layoutSubviews() {
        if changeFrame {
            
            self.camButtom.hidden =  true
            self.scannerButton.hidden =  true
            self.closeSearch.hidden =  false
            self.closeSearch.frame  = CGRectMake(0.0,8.0,44, 44)
            self.textFindProduct.frame = CGRectMake(self.closeSearch.frame.maxX,12 ,self.frame.width - 60, 40.0)
        }else{
            self.closeSearch.hidden =  true
            self.textFindProduct.frame = CGRectMake(16.0,12 ,self.frame.width - 144, 40.0)
            self.camButtom.hidden =  false
            self.scannerButton.hidden =  false
        }
        
        self.camButtom.frame = CGRectMake(self.textFindProduct!.frame.maxX + 16, 12, 40, 40)
        self.scannerButton.frame = CGRectMake(self.camButtom.frame.maxX + 16 , 12, 40, 40)
        line.frame = CGRectMake(0,self.textFindProduct.frame.maxY + 11,self.frame.width, 1)
        
    }
    
    
    
    //MARK: Actios
    func showCamera(){
        self.delegate?.showCamera()
    }
    
    func scanCode (){
         self.delegate?.scanCode()
    }
    
    func closeSearchText(){
        changeFrame =  false
        self.layoutSubviews()
        self.textFindProduct.resignFirstResponder()
        self.textFindProduct.text! =  ""
    }
    
    
    //MARK: UITextFieldDelegate
    
    override func becomeFirstResponder() -> Bool {
        
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print(textField.text)
        changeFrame =  false
        self.delegate?.searchByText(textField.text!)
        textField.resignFirstResponder()
        textField.text! =  ""
        self.layoutSubviews()
        
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text!
        let keyword = strNSString.stringByReplacingCharactersInRange(range, withString: string)
        
        if keyword.characters.count > 0 {
            changeFrame =  true
            self.textFindProduct.frame = CGRectMake(self.closeSearch.frame.maxX + 16.0,12 ,self.frame.width - 32, 40.0)

        }else {
             changeFrame = false
            self.textFindProduct.frame = CGRectMake(16.0,12 ,self.frame.width - 144, 40.0)

        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

         print("textFieldShouldEndEditing")
        

    }
    
    

}
