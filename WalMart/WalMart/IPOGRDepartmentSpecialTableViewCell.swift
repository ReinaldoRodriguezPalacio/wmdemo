//
//  IPOGRDepartmentSpecialTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPOGRDepartmentSpecialTableViewCellDelegate {
    func didTapProduct(_ upcProduct:String,descProduct:String)
    func didTapLine(_ name:String,department:String,family:String,line:String)
    func didTapMore(_ index: IndexPath)
}

class IPOGRDepartmentSpecialTableViewCell : UITableViewCell {
    
    var delegate: IPOGRDepartmentSpecialTableViewCellDelegate!
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
        
        var currentX : CGFloat = (self.frame.width - ((width * 3) + 64)  ) / 5
        for  lineToShow in jsonLines.arrayValue {
            let product = GRProductSpecialCollectionViewCell(frame: CGRect(x: currentX, y: 12, width: width, height: 111))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                                productShortDescription: descProd,
                                productPrice: "")
            self.contentView.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: #selector(IPOGRDepartmentSpecialTableViewCell.productTap(_:)))
            product.addGestureRecognizer(tapOnProdut)
            print( product.frame.width )
            currentX = currentX + product.frame.width + ((self.frame.width - ((width * 3) + 64) ) / 5)
        }
        
        self.moreButton?.frame = CGRect(x: currentX + 24, y: 43, width: 16, height: 16)
        self.moreButton!.isHidden =  true
        self.moreLabel?.frame = CGRect(x: currentX, y: self.moreButton!.frame.maxY + 36, width: 64, height: 11)
        self.moreLabel!.isHidden =  true
        self.descLabel!.isHidden =  true
        
        let tapOnMore =  UITapGestureRecognizer(target: self, action: #selector(IPOGRDepartmentSpecialTableViewCell.moreTap))
        descLabel!.addGestureRecognizer(tapOnMore)
        self.viewLoadingProduct ()
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(IPOGRDepartmentSpecialTableViewCell.removeViewLoading), userInfo: nil, repeats: false)
    }
    
    func removeViewLoading(){
        viewLoading!.isHidden =  true
        moreButton!.isHidden =  false
        moreLabel!.isHidden =  false
        descLabel!.isHidden =  false
    }
    
    func viewLoadingProduct(){
        viewLoading =  UIView()
        viewLoading!.frame = CGRect(x: 0,y: 0,width: self.frame.width,height: 125)
        viewLoading!.backgroundColor =  UIColor.white
        
        let imageIndicator =  UIImageView(frame: CGRect(x: self.frame.midX - 16, y: 20,width: 32,height: 32))
        imageIndicator.image =  UIImage(named:"home_super_spark")
        viewLoading!.addSubview(imageIndicator)
        
        let labelLoading =  UILabel(frame:CGRect(x: 0, y: imageIndicator.frame.maxY + 10, width: self.frame.width, height: 30))
        labelLoading.text =  NSLocalizedString("gr.category.message.loading", comment:"")
        labelLoading.textAlignment =  .center
        labelLoading.font =  WMFont.fontMyriadProRegularOfSize(14)
        labelLoading.textColor = WMColor.light_blue
        viewLoading!.addSubview(labelLoading)
        self.contentView.addSubview(viewLoading!)
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
        delegate.didTapLine(viewC.jsonItemSelected["name"].stringValue, department: viewC.jsonItemSelected["department"].stringValue, family:  viewC.jsonItemSelected["family"].stringValue, line:viewC.jsonItemSelected["line"].stringValue)
    }
    
    func moreTap(){
        delegate?.didTapMore(self.index)
    }
    
    
}
