//
//  IPOGRDepartmentSpecialTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/30/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol IPOGRDepartmentSpecialTableViewCellDelegate {
    func didTapProduct(upcProduct:String,descProduct:String)
    func didTapLine(name:String,department:String,family:String,line:String)
    func didTapMore(index: NSIndexPath)
}

class IPOGRDepartmentSpecialTableViewCell : UITableViewCell {
    
    var delegate: IPOGRDepartmentSpecialTableViewCellDelegate!
    var viewLoading : UIView?
    var descLabel: UILabel?
    var moreButton: UIButton?
    var moreLabel: UILabel?
    var index: NSIndexPath!
    
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
        self.descLabel?.textColor = WMColor.navigationFilterBGColor
        
        self.moreLabel = UILabel()
        self.moreLabel?.text = "Ver todo"
        self.moreLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        self.moreLabel?.textColor = WMColor.navigationFilterBGColor
        self.moreLabel?.textAlignment = .Center
        self.moreLabel!.hidden =  true
        
        self.moreButton = UIButton()
        self.moreButton?.setBackgroundImage(UIImage(named: "ver_todo"), forState: UIControlState.Normal)
        self.moreButton!.hidden =  true
        self.moreButton!.addTarget(self, action: "moreTap", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(self.descLabel!)
        self.addSubview(self.moreLabel!)
        self.addSubview(self.moreButton!)
    }
    
    override func layoutSubviews() {
        self.descLabel!.frame = CGRect(x: 8,y: 4,width: 90,height: 11)
    }

    
    func setLines(lines:[[String:AnyObject]],width:CGFloat, index: NSIndexPath) {
        self.index = index
        let jsonLines = JSON(lines)
        
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
        
        
        var currentX : CGFloat = 0.0
        for  lineToShow in jsonLines.arrayValue {
            let product = GRProductSpecialCollectionViewCell(frame: CGRectMake(currentX, 12, width, 111))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                                productShortDescription: descProd,
                                productPrice: "")
            self.contentView.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: "productTap:")
            product.addGestureRecognizer(tapOnProdut)
            
            currentX = currentX + width
        }
        
        self.moreButton?.frame = CGRect(x: currentX + 24, y: 43, width: 16, height: 16)
        self.moreButton!.hidden =  true
        self.moreLabel?.frame = CGRect(x: currentX, y: self.moreButton!.frame.maxY + 36, width: 64, height: 11)
        self.moreLabel!.hidden =  true
        self.descLabel!.hidden =  true
        
        let tapOnMore =  UITapGestureRecognizer(target: self, action: "moreTap")
        descLabel!.addGestureRecognizer(tapOnMore)
        
        let separator = UIView()
        separator.backgroundColor = WMColor.lineSaparatorColor
        let widthAndHeightSeparator = 1 / AppDelegate.scaleFactor()
        separator.frame = CGRectMake(0, self.frame.height - widthAndHeightSeparator, self.frame.width, widthAndHeightSeparator)
        
        self.contentView.addSubview(separator)
        
        self.viewLoadingProduct ()
        
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "removeViewLoading", userInfo: nil, repeats: false)
        
    }
    
    func removeViewLoading(){
        viewLoading!.hidden =  true
        moreButton!.hidden =  false
        moreLabel!.hidden =  false
        descLabel!.hidden =  false
    }
    
    func viewLoadingProduct(){
        viewLoading =  UIView()
        viewLoading!.frame = CGRectMake(0,0,self.frame.width,self.frame.height - 2)
        viewLoading!.backgroundColor =  UIColor.whiteColor()
        
        let imageIndicator =  UIImageView(frame: CGRectMake(self.frame.midX - 16, 20,32,32))
        imageIndicator.image =  UIImage(named:"home_super_spark")
        viewLoading!.addSubview(imageIndicator)
        
        let labelLoading =  UILabel(frame:CGRectMake(0, imageIndicator.frame.maxY + 10, self.frame.width, 30))
        labelLoading.text =  NSLocalizedString("gr.category.message.loading", comment:"")
        labelLoading.textAlignment =  .Center
        labelLoading.font =  WMFont.fontMyriadProRegularOfSize(14)
        labelLoading.textColor = WMColor.navigationFilterBGColor

        
        viewLoading!.addSubview(labelLoading)
        
        self.contentView.addSubview(viewLoading!)
    }
    
    
    func withOutProducts(){
        for sView in   self.contentView.subviews {
            sView.removeFromSuperview()
        }
    }
    
    func productTap(sender:UITapGestureRecognizer) {
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