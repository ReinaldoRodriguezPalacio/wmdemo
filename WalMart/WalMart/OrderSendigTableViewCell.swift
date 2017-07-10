//
//  OrderSendigTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 07/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol OrderSendigTableViewCellDelegate : class {
    func didSelectOption(_ text:String?)
    func didShowDetail(_ text:String?)
}

class OrderSendigTableViewCell : UITableViewCell {
    
    var viewHeader : UIView!
    var notificationLabel : UILabel!
    var separatorView : UIView!
    
    var titleSending : UILabel!
    var txtSendig : String = ""
    
    var optionsBtns : UIButton!
    
    var statusTitle : UILabel!
    var nameTitle : UILabel!
    var sendingNormalTitle : UILabel!
    var paymentTypeTitle : UILabel!
    var addressTitle : UILabel!
    var providerTitle : UILabel!
    
    var showDetailLbl : UILabel!
    var imageSeeMore : UIImageView!
    //see_more
    
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
        
        self.optionsBtns = UIButton()
        self.optionsBtns.setTitleColor(UIColor.white, for: .normal)
        self.optionsBtns.setTitle("opciones", for: .normal)
        self.optionsBtns.layer.cornerRadius = 11
        self.optionsBtns.backgroundColor = WMColor.light_blue
        self.optionsBtns.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.optionsBtns.addTarget(self, action: #selector(showOptionsView), for: .touchUpInside)
        
        
        self.statusTitle = self.labelContact()
        self.nameTitle = self.labelContact()
        self.sendingNormalTitle = self.labelContact()
        self.sendingNormalTitle.numberOfLines = 2
        self.paymentTypeTitle = self.labelContact()
        self.addressTitle = self.labelContact()
        self.addressTitle.numberOfLines = 3
        self.providerTitle = self.labelContact()
        
        let gestureShowDetail = UITapGestureRecognizer(target: self, action: #selector(OrderSendigTableViewCell.showDetail))
        
        self.showDetailLbl = UILabel()
        self.showDetailLbl.font = WMFont.fontMyriadProRegularOfSize(12.0)
        self.showDetailLbl.textColor = WMColor.regular_blue
        self.showDetailLbl.text = "Ver detalle"
        self.showDetailLbl.addGestureRecognizer(gestureShowDetail)
        self.showDetailLbl.isUserInteractionEnabled = true
        
        let gestureShowDetailImage = UITapGestureRecognizer(target: self, action: #selector(OrderSendigTableViewCell.showDetail))
        
        self.imageSeeMore = UIImageView()
        let image = UIImage(named: "see_more")
        self.imageSeeMore!.image = image
        self.imageSeeMore.addGestureRecognizer(gestureShowDetailImage)
        self.imageSeeMore.isUserInteractionEnabled = true
        self.addSubview(self.imageSeeMore!)
        
        
        self.addSubview(self.titleSending)
        self.addSubview(self.optionsBtns)
        
        self.addSubview(self.statusTitle)
        self.addSubview(self.nameTitle)
        self.addSubview(self.sendingNormalTitle)
        self.addSubview(self.paymentTypeTitle)
        self.addSubview(self.addressTitle)
        self.addSubview(self.providerTitle)
        
        self.addSubview(self.showDetailLbl)
        
        self.separatorView = UIView()
        self.separatorView.backgroundColor = WMColor.light_gray
        
        self.addSubview(self.separatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleSending.frame = CGRect(x: 16.0, y: 20.7, width: 100.0, height: 15.0)
        self.optionsBtns.frame = CGRect(x: self.frame.width - 68.0 - 16.0, y: 16.8, width: 68.0, height: 21.5)
        
        self.statusTitle.frame = CGRect(x: 16.0, y: 56.9, width: self.frame.width - 32.0, height: 15.0)
        self.nameTitle.frame = CGRect(x: 16.0, y: self.statusTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 15.0)
        self.sendingNormalTitle.frame = CGRect(x: 16.0, y: self.nameTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 30.0)
        self.paymentTypeTitle.frame = CGRect(x: 16.0, y: self.sendingNormalTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 15.0)
        self.addressTitle.frame = CGRect(x: 16.0, y: self.paymentTypeTitle.frame.maxY + 7.5, width: self.frame.width - 32.0, height: 45.0)
        self.providerTitle.frame = CGRect(x: 16.0, y: self.addressTitle.frame.maxY + 10.0, width: self.frame.width - 32.0, height: 15.0)
        
        self.showDetailLbl.frame = CGRect(x: self.frame.width - 56.0 - 41.0, y: self.providerTitle.frame.maxY + 7.5, width: 56.0, height: 12.0)
        self.imageSeeMore!.frame = CGRect(x: self.frame.width - 16.0 - 21.0, y: self.providerTitle.frame.maxY + 5.5, width: 16.0, height: 16.0)
        
        self.separatorView.frame = CGRect(x: 0.0, y: self.frame.height - 1.0, width: self.frame.width, height: 1.0)
    }
    
    
    func setValues(values:[String:Any]) {
        
        self.titleSending.text = txtSendig
        
        let statusAttrString = self.buildAttributtedString("Status", value: values["statusValue"] as! String)
        
        self.statusTitle.attributedText = statusAttrString
        
        let nameAttrString = self.buildAttributtedString("Nombre", value: values["nameValue"] as! String)
        self.nameTitle.attributedText = nameAttrString
        
        let sendingNormaAttrString = self.buildAttributtedString("Envío normal", value: values["sendingNormalValue"] as! String)
        self.sendingNormalTitle.attributedText = sendingNormaAttrString
        
        let paymentTypeAttrString = self.buildAttributtedString("Tipo de Pago", value: values["PaymentTypeValue"] as! String)
        self.paymentTypeTitle.attributedText = paymentTypeAttrString
        
        let addressAttrString = self.buildAttributtedString("Mi casa", value: values["addressValue"] as! String)
        //let rectSize = addressAttrString.boundingRect(with: CGSize(width: self.frame.width - 32, height: CGFloat.greatestFiniteMagnitude), options:NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        self.addressTitle.attributedText = addressAttrString
        
        let providerAttrString = self.buildAttributtedString("Proveedor", value: values["ProviderValue"] as! String)
        self.providerTitle.attributedText = providerAttrString
        
    }
    
    func buildAttributtedString(_ title:String, value:String ) -> NSAttributedString {
        let valuesDescItem = NSMutableAttributedString()
        if title != ""{
            let attrStringLab = NSAttributedString(string:"\(title): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(14.0),NSForegroundColorAttributeName:WMColor.dark_gray])
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
        self.cellDelegate?.didSelectOption("")
    }
    
    func showDetail() {
        self.cellDelegate?.didShowDetail("")
    }
    
}
