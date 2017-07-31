//
//  OrderSendigTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 07/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol OrderSendigTableViewCellDelegate : class {
    func didSelectOption(_ orderItem:[String:Any]?)
    func didShowDetail(_ orderItem:[String:Any]?)
}

class OrderSendigTableViewCell : UITableViewCell {
    
    var viewHeader : UIView!
    var notificationLabel : UILabel!
    var separatorView : UIView!
    
    var titleSending : UILabel!
    var txtSendig : String = ""
    
    var optionsBtn : UIButton!
    
    var statusTitle : UILabel!
    var nameTitle : UILabel!
    var sendingNormalTitle : UILabel!
    var paymentTypeTitle : UILabel!
    var addressTitle : UILabel!
    var providerTitle : UILabel!
    
    var showDetailBtn : UIButton!
    var orderItem: [String:Any]?
    
    var cellDelegate: OrderSendigTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.white
        
        self.viewHeader = UIView()
        self.viewHeader.backgroundColor = UIColor.white
        
        self.titleSending = UILabel()
        self.titleSending.font = WMFont.fontMyriadProRegularOfSize(14.0)
        self.titleSending.textColor = WMColor.regular_blue
        
        self.optionsBtn = UIButton()
        self.optionsBtn.setTitleColor(UIColor.white, for: .normal)
        self.optionsBtn.setTitle("opciones", for: .normal)
        self.optionsBtn.layer.cornerRadius = 11
        self.optionsBtn.backgroundColor = WMColor.light_blue
        self.optionsBtn.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.optionsBtn.addTarget(self, action: #selector(showOptionsView), for: .touchUpInside)
        
        self.statusTitle = self.labelContact()
        self.nameTitle = self.labelContact()
        self.sendingNormalTitle = self.labelContact()
        self.sendingNormalTitle.numberOfLines = 2
        self.paymentTypeTitle = self.labelContact()
        self.addressTitle = self.labelContact()
        self.addressTitle.numberOfLines = 3
        self.providerTitle = self.labelContact()
        
        self.showDetailBtn = UIButton()
        self.showDetailBtn.setTitleColor(UIColor.white, for: .normal)
        self.showDetailBtn.setTitle("Ver detalle", for: .normal)
        self.showDetailBtn.layer.cornerRadius = 11
        self.showDetailBtn.backgroundColor = WMColor.light_blue
        self.showDetailBtn.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.showDetailBtn.addTarget(self, action:#selector(OrderSendigTableViewCell.showDetail), for: .touchUpInside)

        self.addSubview(self.titleSending)
        self.addSubview(self.optionsBtn)
        
        self.addSubview(self.statusTitle)
        self.addSubview(self.nameTitle)
        self.addSubview(self.sendingNormalTitle)
        self.addSubview(self.paymentTypeTitle)
        self.addSubview(self.addressTitle)
        self.addSubview(self.providerTitle)
        self.addSubview(self.showDetailBtn)
        
        self.separatorView = UIView()
        self.separatorView.backgroundColor = WMColor.light_gray
        
        self.addSubview(self.separatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleSending.frame = CGRect(x: 16.0, y: 20.7, width: 100.0, height: 15.0)
        
        self.statusTitle.frame = CGRect(x: 16.0, y: 56.9, width: self.frame.width - 32.0, height: 15.0)
        self.nameTitle.frame = CGRect(x: 16.0, y: self.statusTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 15.0)
        //self.sendingNormalTitle.frame = CGRect(x: 16.0, y: self.nameTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 30.0)
        self.paymentTypeTitle.frame = CGRect(x: 16.0, y: self.nameTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 15.0)
        self.addressTitle.frame = CGRect(x: 16.0, y: self.paymentTypeTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 45.0)
        self.providerTitle.frame = CGRect(x: 16.0, y: self.addressTitle.frame.maxY + 10.0, width: self.frame.width - 38.0, height: 15.0)
        self.showDetailBtn.frame = CGRect(x: self.frame.width - 84, y: self.frame.height - 38, width: 68.0, height: 22)
        self.optionsBtn.frame = CGRect(x: showDetailBtn.frame.minX - 80, y: self.frame.height - 38, width: 68.0, height: 22)
        self.separatorView.frame = CGRect(x: 0.0, y: self.frame.height - 1.0, width: self.frame.width, height: 1.0)
    }
    
    
    func setValues(values:[String:Any]) {
        self.titleSending.text = txtSendig
        
        let statusAttrString = self.buildAttributtedString("Status", value: values["statusValue"] as! String)
        
        self.statusTitle.attributedText = statusAttrString
        
        let nameAttrString = self.buildAttributtedString("Nombre", value: values["nameValue"] as! String)
        self.nameTitle.attributedText = nameAttrString
        
        let paymentTypeAttrString = self.buildAttributtedString("Tipo de Pago", value: values["PaymentTypeValue"] as! String)
        self.paymentTypeTitle.attributedText = paymentTypeAttrString
        
        let addressAttrString = self.buildAttributtedString("Mi casa", value: values["addressValue"] as! String)
        //let rectSize = addressAttrString.boundingRect(with: CGSize(width: self.frame.width - 32, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        self.addressTitle.attributedText = addressAttrString
        
        let sellerName = values["ProviderValue"] as! String
        let providerAttrString = self.buildAttributtedString("Proveedor", value: sellerName)
        self.providerTitle.attributedText = providerAttrString
        self.providerTitle.isHidden = (sellerName == "")
        
        if let sendingNormalValues = values["sendingNormalValue"] as? String {
            let sendingNormaAttrString = self.buildAttributtedString("Envío normal", value: sendingNormalValues)
            self.sendingNormalTitle.attributedText = sendingNormaAttrString
            self.sendingNormalTitle.isHidden = false
        }else{
           self.sendingNormalTitle.isHidden = true
        }
        
        if let sellerId = values["sellerId"] as? String {
            self.optionsBtn.isHidden = (sellerId == "0")
        }
    }
    
    func buildAttributtedString(_ title:String, value:String ) -> NSAttributedString {
        let valuesDescItem = NSMutableAttributedString()
        if title != ""{
            let attrStringLab = NSAttributedString(string:"\(title) - ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(14.0),NSForegroundColorAttributeName:WMColor.dark_gray])
            valuesDescItem.append(attrStringLab)
        }
        let attrStringVal = NSAttributedString(string:"\(value)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(14.0),NSForegroundColorAttributeName:WMColor.dark_gray])
        valuesDescItem.append(attrStringVal)
        return valuesDescItem
    }
    
    func labelContact() -> UILabel {
        let labelTitleItem = UILabel(frame: CGRect.zero)
        labelTitleItem.textColor = WMColor.gray
        labelTitleItem.textAlignment = .left
        return labelTitleItem
    }
    
    func showOptionsView() {
        self.cellDelegate?.didSelectOption(self.orderItem)
    }
    
    func showDetail() {
        self.cellDelegate?.didShowDetail(self.orderItem)
    }
    
}
