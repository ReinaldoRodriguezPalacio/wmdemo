//
//  IPOGRDepartmentSpecialTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPOGRDepartmentSpecialTableViewCellDelegate: class {
    func didTapProduct(_ upcProduct:String,descProduct:String)
    func didTapLine(_ name:String,department:String,family:String,line:String)
    func didTapMore(_ index: IndexPath)
}

class IPOGRDepartmentSpecialTableViewCell : UITableViewCell {
    
    weak var delegate: IPOGRDepartmentSpecialTableViewCellDelegate?
    var viewLoading : UIView?
    var descLabel: UILabel?
    var moreButton: UIButton?
    var moreLabel: UILabel?
    var index: IndexPath!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        
        self.clipsToBounds = true
        
        self.descLabel = UILabel()
        self.descLabel?.text = "Lo más destacado"
        self.descLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.descLabel?.textColor = WMColor.light_blue
        
        self.moreLabel = UILabel()
        self.moreLabel?.text = "Ver todo"
        self.moreLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.moreLabel?.textColor = WMColor.light_blue
        self.moreLabel?.textAlignment = .center
        self.moreLabel!.isHidden =  true
        
        self.moreButton = UIButton()
        self.moreButton?.setBackgroundImage(UIImage(named: "ver_todo"), for: UIControlState())
        self.moreButton!.isHidden =  true
        self.moreButton!.addTarget(self, action: #selector(IPOGRDepartmentSpecialTableViewCell.moreTap), for: UIControlEvents.touchUpInside)
        
        self.addSubview(self.descLabel!)
        self.addSubview(self.moreLabel!)
        self.addSubview(self.moreButton!)
    }
    
    override func layoutSubviews() {
        self.descLabel!.frame = CGRect(x: 8,y: 4,width: 250,height: 11)
    }

    
    func setLines(_ lines:[[String:Any]],width:CGFloat, index: IndexPath) {
        self.index = index
        let jsonLines = JSON(lines)
        
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
        
        var currentX : CGFloat = 0.0
        for  lineToShow in jsonLines.arrayValue {
            let product = GRProductSpecialCollectionViewCell(frame: CGRect(x:currentX,y: 12, width:width, height:111))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                                productShortDescription: descProd,
                                productPrice: "")
            self.contentView.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: #selector(IPOGRDepartmentSpecialTableViewCell.productTap(_:)))
            product.addGestureRecognizer(tapOnProdut)
            
            currentX = currentX + width
        }
        let midXMoreButton = Int((width / 2) + currentX)
        let widthMoreButton = 16
        let widthMoreLabel = 64
        
        self.moreButton?.frame = CGRect(x: Int(midXMoreButton - (widthMoreButton / 2)) , y: 43, width: widthMoreButton, height: 16)
        self.moreButton!.isHidden =  false
        self.moreLabel?.frame = CGRect(x: Int(midXMoreButton - (widthMoreLabel / 2)), y: Int(self.moreButton!.frame.maxY + 36), width: widthMoreLabel, height: 11)
        self.moreLabel!.isHidden =  false
        self.descLabel!.isHidden =  false
        
        let tapOnMore =  UITapGestureRecognizer(target: self, action: #selector(IPOGRDepartmentSpecialTableViewCell.moreTap))
        descLabel!.addGestureRecognizer(tapOnMore)
    }
    
    func withOutProducts(){
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
    }
    
    func productTap(_ sender:UITapGestureRecognizer) {
        //let viewC = sender.view as! GRProductSpecialCollectionViewCell
//        
//        delegate.didTapProduct(viewC.upcProduct!,descProduct:viewC.productShortDescriptionLabel!.text!)
        let viewC = sender.view as! GRProductSpecialCollectionViewCell
        delegate?.didTapLine(viewC.jsonItemSelected["name"].stringValue, department: viewC.jsonItemSelected["department"].stringValue, family:  viewC.jsonItemSelected["family"].stringValue, line:viewC.jsonItemSelected["line"].stringValue)
    }
    
    func moreTap(){
        delegate?.didTapMore(self.index)
    }
    
    
}
