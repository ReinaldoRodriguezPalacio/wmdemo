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
    func searchByText(_ text:String)
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
        
        self.closeSearch = UIButton(type: .custom)
        self.closeSearch!.setImage(UIImage(named: "delete_icon"), for: UIControlState())
        self.closeSearch!.addTarget(self, action: #selector(AddProductTolistView.closeSearchText), for: .touchUpInside)
        self.closeSearch!.isHidden =  true
        self.addSubview(self.closeSearch!)
        
        
        self.textFindProduct = FormFieldSearch()
        self.textFindProduct!.backgroundColor = WMColor.light_gray
        self.textFindProduct!.layer.cornerRadius = 10.0
        self.textFindProduct!.font = WMFont.fontMyriadProLightOfSize(16)
        self.textFindProduct!.delegate =  self
        self.textFindProduct!.returnKeyType = .search
        self.textFindProduct!.autocapitalizationType = .none
        self.textFindProduct!.autocorrectionType = .no
        self.textFindProduct!.placeholder = NSLocalizedString("list.message.add.item.in.list", comment:"")
        self.addSubview(self.textFindProduct!)
        
        self.camButtom = UIButton(type: .custom)
        self.camButtom!.setImage(UIImage(named: "cam_icon_addtolist"), for: UIControlState())
        self.camButtom!.addTarget(self, action: #selector(AddProductTolistView.showCamera), for: .touchUpInside)
        self.addSubview(self.camButtom!)
  
        self.scannerButton = UIButton(type: .custom)
        self.scannerButton!.setImage(UIImage(named: "barcode_icon_addtolist"), for: UIControlState())
        self.scannerButton!.addTarget(self, action: #selector(AddProductTolistView.scanCode), for: .touchUpInside)
        self.addSubview(self.scannerButton!)
        
        
      
        line = CALayer()
        line.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(line, at: 0)
        
    }
    
    override func layoutSubviews() {
        let showCamfind = Bundle.main.object(forInfoDictionaryKey: "showCamFind") as! Bool
        
        if changeFrame {
            self.camButtom.isHidden =  true
            self.scannerButton.isHidden =  true
            self.closeSearch.isHidden =  false
            self.closeSearch.frame  = CGRect(x: 0.0,y: 8.0,width: 44, height: 44)
            self.textFindProduct.frame = CGRect(x: self.closeSearch.frame.maxX,y: 12 ,width: self.frame.width - 60, height: 40.0)
        }else{
            let textFindProductWidth = showCamfind ? (self.frame.width - 144) : (self.frame.width - 88)
            self.closeSearch.isHidden =  true
            self.textFindProduct.frame = CGRect(x: 16.0,y: 12 ,width: textFindProductWidth, height: 40.0)
            self.camButtom.isHidden = !showCamfind
            self.scannerButton.isHidden =  false
        }
        
        if showCamfind {
            self.camButtom.frame = CGRect(x: self.textFindProduct!.frame.maxX + 16, y: 12, width: 40, height: 40)
            self.scannerButton.frame = CGRect(x: self.camButtom.frame.maxX + 16 , y: 12, width: 40, height: 40)
        }else{
            self.scannerButton.frame = CGRect(x: self.textFindProduct!.frame.maxX + 16 , y: 12, width: 40, height: 40)
        }
        line.frame = CGRect(x: 0,y: self.textFindProduct.frame.maxY + 11,width: self.frame.width, height: 1)
        
    }
    
    
    
    //MARK: Actios
    /**
    Call open Camera controller delegate
     */
    func showCamera(){
        self.delegate?.showCamera()
    }
    
    /**
     Call open scan Camera controller delegate
     */
    func scanCode (){
         self.delegate?.scanCode()
    }
    
    /**
     Disable edit search text in list Detail
     */
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.text)
        changeFrame =  false
        self.delegate?.searchByText(textField.text!)
        textField.resignFirstResponder()
        textField.text! =  ""
        self.layoutSubviews()
        
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strNSString : NSString = textField.text! as NSString
        let keyword = strNSString.replacingCharacters(in: range, with: string)
        
        if keyword.characters.count > 0 {
            changeFrame =  true
            self.textFindProduct.frame = CGRect(x: self.closeSearch.frame.maxX + 16.0,y: 12 ,width: self.frame.width - 32, height: 40.0)

        }else {
             changeFrame = false
            self.textFindProduct.frame = CGRect(x: 16.0,y: 12 ,width: self.frame.width - 144, height: 40.0)

        }
        
        return true
    }

}
