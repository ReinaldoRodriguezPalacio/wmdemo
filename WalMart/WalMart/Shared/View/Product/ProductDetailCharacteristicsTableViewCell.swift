//
//  ProductDetailDescriptionCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol ProductDetailCharacteristicsTableViewCellDelegate {
    func showShippingDetail(shippingDetail: NSDictionary)
}

class ProductDetailCharacteristicsTableViewCell :UITableViewCell {
    var headerView = UIView()
    var titleShipping = UILabel()
    var showDetailButton: UIButton?
    var itemShipping = [:]
    
    var detailView = UIView()
    var nameLabel = UILabel()
    var deliveryTypeLabel = UILabel()
    var deliveryAddressLabel = UILabel()
    var paymentTypeLabel = UILabel()
    
    var delegateDetail : ProductDetailCharacteristicsTableViewCellDelegate!
    
    var descLabel = UIView()
    var downBorder = UIView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        let labelDesc = UILabel()
        labelDesc.numberOfLines = 0
        self.addSubview(labelDesc)
        
        self.headerView = UIView(frame:CGRectMake(0, 0, self.frame.width, 40))
        self.headerView.backgroundColor = WMColor.light_light_gray
        
        self.titleShipping = UILabel(frame:CGRectMake(16, 0, self.frame.width / 2, 40))
        self.titleShipping.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleShipping.textColor = WMColor.dark_gray
        self.headerView.addSubview(self.titleShipping)
        
        self.showDetailButton = UIButton(frame: CGRectMake(self.frame.width - 84.0, 9.0, 68.0, 22.0))
        self.showDetailButton!.backgroundColor = WMColor.light_blue
        self.showDetailButton!.layer.cornerRadius = 10.0
        self.showDetailButton!.setTitle(NSLocalizedString("previousorder.showDetail", comment: ""), forState: .Normal)
        self.showDetailButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(12)
        self.showDetailButton!.titleLabel?.textColor = UIColor.whiteColor()
        self.showDetailButton!.addTarget(self, action: #selector(ProductDetailCharacteristicsTableViewCell.showDetail(_:)), forControlEvents: .TouchUpInside)
        self.headerView.addSubview(self.showDetailButton!)
        
        self.detailView = UIView(frame:CGRectMake(0, 40, self.frame.width, self.frame.height - 40))
        self.detailView.backgroundColor = UIColor.whiteColor()
        
        self.nameLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.nameLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.nameLabel.textColor = WMColor.gray
        self.detailView.addSubview(self.nameLabel)
        
        self.deliveryTypeLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.deliveryTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryTypeLabel.textColor = WMColor.gray
        self.deliveryTypeLabel.numberOfLines = 2
        self.detailView.addSubview(self.deliveryTypeLabel)
        
        self.deliveryAddressLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.deliveryAddressLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.deliveryAddressLabel.textColor = WMColor.gray
        self.deliveryAddressLabel.numberOfLines = 4
        self.detailView.addSubview(self.deliveryAddressLabel)
        
        self.paymentTypeLabel = UILabel(frame:CGRectMake(16, 16, self.frame.width - 16.0, 16.0))
        self.paymentTypeLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.paymentTypeLabel.textColor = WMColor.gray
        self.detailView.addSubview(self.paymentTypeLabel)
        
        self.addSubview(self.headerView)
        self.addSubview(self.detailView)
        
        /*
        descLabel = UIView()
        
        downBorder = UIView(frame: CGRectZero)
        downBorder.backgroundColor = WMColor.light_light_gray
        //self.addSubview(downBorder)
        //self.addSubview(descLabel)
        */
    }
    
    func showDetail(sender:UIButton){
        //Pasar array o NSDictionary seleccionado
        self.delegateDetail.showShippingDetail(self.itemShipping as NSDictionary)
    }
    
    func setValuesDetail(values:NSDictionary){
        
        self.itemShipping = values
        self.titleShipping.text = values["order"] as? String
        
        self.nameLabel.text = values["name"] as? String
        self.deliveryTypeLabel.text = values["deliveryType"] as? String
        //"Envio estandar - Hasta 5 días \n(Fecha estimada de entrega: 08/03/2016)"
        
        //let address = values["deliveryAddress"] as? String
        let address = "Casa\nAv San Francisco no. 1621, Del valee,\nBenito Juarez, Ciudad de Mexico, 03100\nTel 5521365678"
        let rectSize = size(forText: address, withFont: deliveryAddressLabel.font, andSize: CGSizeMake(self.frame.width - 16.0, CGFloat.max))
        self.deliveryAddressLabel.text = address
        self.paymentTypeLabel.text = values["paymentType"] as? String//"Pago en línea"
        
        self.deliveryTypeLabel.frame = CGRectMake(16, self.nameLabel.frame.maxY + 8.0, self.frame.width - 16.0, 16.0)
        self.deliveryAddressLabel.frame = CGRectMake(16, self.deliveryTypeLabel.frame.maxY + 8.0, self.frame.width - 16.0, rectSize.height)
        self.paymentTypeLabel.frame = CGRectMake(16, self.deliveryAddressLabel.frame.maxY + 8.0, self.frame.width - 16.0, 40.0)
    }
    
    func setValues(values:NSArray){
        var currentY = 0.0 as CGFloat
        var index = 0
        self.clearView(descLabel)
        for dicValue in values {
            //var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? NSDictionary {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
               
                let attrString =  ProductDetailCharacteristicsCollectionViewCell.buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.gray, colorValue:WMColor.dark_gray, size: 14)
                let rectSize = attrString.boundingRectWithSize(CGSizeMake(self.frame.width - 32, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                let bgView = UIView(frame: CGRectMake(0, currentY, self.frame.width, rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()))
                let labelCharacteristic = WMTCopyLable(frame: CGRectMake(16, 5, self.frame.width-32, rectSize.height))
                labelCharacteristic.attributedText = attrString
                labelCharacteristic.stringCopy = strValue
                
                
                labelCharacteristic.numberOfLines = 0
                index += 1
                if index % 2 == 0 {
                    bgView.backgroundColor = UIColor.whiteColor()
                }else{
                    bgView.backgroundColor = WMColor.light_light_gray
                }
                bgView.userInteractionEnabled = true
                descLabel.userInteractionEnabled = true
                self.superview?.userInteractionEnabled = true
                bgView.addSubview(labelCharacteristic)
                descLabel.addSubview(bgView)
                currentY += rectSize.height + ProductDetailCharacteristicsCollectionViewCell.heightCharacteristic()
            }
        }
        
        descLabel.frame = CGRectMake(0, 0,  self.frame.width, currentY)
        downBorder.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, AppDelegate.separatorHeigth())

    }
    
    func clearView(view: UIView){
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
    }
    
    func size(forText text:NSString, withFont font:UIFont, andSize size:CGSize) -> CGSize {
        let computedRect: CGRect = text.boundingRectWithSize(size,
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName:font],
            context: nil)
        
        return CGSizeMake(computedRect.size.width, computedRect.size.height)
    }
    
    class func sizeForCell(width:CGFloat,values:NSArray) -> CGFloat {
        var heigth = 0.0 as CGFloat
        //var valuesDict = NSMutableArray()
       
        for dicValue in values {
            //var valuesValues = NSMutableDictionary()
            if let dicVal = dicValue as? NSDictionary {
                let strLabel = dicVal["label"] as! String
                let strValue = dicVal["value"] as! String
                let attrString =  buildAttributtedString(strLabel, value: strValue, colorKey:WMColor.gray, colorValue:WMColor.dark_gray, size:14)
                let rectSize = attrString.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
                heigth += rectSize.height + heightCharacteristic()

            }
        }
        return heigth
    }
    
    class func buildAttributtedString(key:String, value:String,  colorKey:UIColor,  colorValue:UIColor , size:CGFloat ) -> NSAttributedString {
        //var valueItem = NSMutableAttributedString()
                let valuesDescItem = NSMutableAttributedString()
        if key != ""{
            let attrStringLab = NSAttributedString(string:"\(key): ", attributes: [NSFontAttributeName : WMFont.fontMyriadProSemiboldOfSize(size),NSForegroundColorAttributeName:colorKey])
             valuesDescItem.appendAttributedString(attrStringLab)
        }
        let attrStringVal = NSAttributedString(string:"\(value)", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(size),NSForegroundColorAttributeName:colorValue])
        valuesDescItem.appendAttributedString(attrStringVal)
        return valuesDescItem
    }
    
    class func heightCharacteristic() -> CGFloat {
        return 10.0
    }
    
}
