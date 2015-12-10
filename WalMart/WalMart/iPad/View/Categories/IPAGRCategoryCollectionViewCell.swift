//
//  IPAGRCategoryCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/26/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol IPAGRCategoryCollectionViewCellDelegate {
    func didTapProduct(upcProduct:String,descProduct:String,imageProduct :UIImageView)
    func didTapLine(name:String,department:String,family:String,line:String)
}

class IPAGRCategoryCollectionViewCell : UICollectionViewCell {
    

    var delegate: IPAGRCategoryCollectionViewCellDelegate!
    var iconCategory : UIImageView!
    var imageBackground : UIImageView!
    var titleLabel:UILabel!
    var buttonDepartment : UIButton!
    var openLable : UILabel!
    var descLabel: UILabel?
    var moreButton: UIButton?
    var moreLabel: UILabel?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        
        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.Left
        imageBackground.clipsToBounds = true
        
        iconCategory = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(24)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Left
        
        buttonDepartment = UIButton()
        buttonDepartment.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        buttonDepartment.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonDepartment.layer.cornerRadius = 14
        buttonDepartment.setImage(UIImage(named:""), forState: UIControlState.Normal)
        buttonDepartment.backgroundColor = WMColor.light_blue
        buttonDepartment.enabled = false
        buttonDepartment.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, 0.0, 0.0)
        
        //self.addSubview(buttonDepartment)
        
        self.descLabel = UILabel()
        self.descLabel?.text = "Lo más destacado"
        self.descLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        self.descLabel?.textColor = WMColor.navigationFilterBGColor
        
        self.moreLabel = UILabel()
        self.moreLabel?.text = "Ver todo"
        self.moreLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.moreLabel?.textColor = WMColor.navigationFilterBGColor
        self.moreLabel?.textAlignment = .Center
        
        self.moreButton = UIButton()
        self.moreButton?.setBackgroundImage(UIImage(named: "ver_todo"), forState: UIControlState.Normal)
        self.moreButton!.addTarget(self, action: "moreTap", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(self.imageBackground!)
        self.addSubview(self.iconCategory!)
        self.addSubview(self.titleLabel!)
        self.addSubview(self.descLabel!)
        self.addSubview(self.moreLabel!)
        self.addSubview(self.moreButton!)

        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel!.frame = CGRect(x: 8,y: 119,width: 130,height: 16)
        self.iconCategory.frame = CGRectMake(16, 25, 48, 48)
        self.titleLabel.frame = CGRectMake(self.iconCategory.frame.maxX + 16, 40, 335, 24)
        self.imageBackground.frame = CGRectMake(0, 0, self.frame.width, 103)
    }
    
    func setValues(categoryId:String,categoryTitle:String,products:[[String:AnyObject]]) {
        iconCategory.image = UIImage(named: "i_\(categoryId)")
        imageBackground.image = UIImage(named: "\(categoryId)")
        //buttonDepartment.setTitle(categoryTitle, forState: UIControlState.Normal)
        //openLable.text = NSLocalizedString("gr.category.open", comment: "")
        self.titleLabel.text = categoryTitle
        let attrStringLab = NSAttributedString(string:categoryTitle, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.whiteColor()])
        let size = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var startx : CGFloat = 0.0
        let  sizeDep = size.width + 40
        startx = (self.frame.width / 2) - (sizeDep / 2)
        
        buttonDepartment.setTitle(categoryTitle, forState: UIControlState.Normal)
        self.buttonDepartment.frame = CGRectMake(startx, 10, sizeDep, 28)
        
        setProducts(products, width: 125)
    }
    
    func setValues(categoryId:String,categoryTitle:String) {
//        iconCategory.image = UIImage(named: "b_i_\(categoryId)")
//        titleCategory.text = categoryTitle
//        openLable.text = NSLocalizedString("gr.category.open", comment: "")
        self.titleLabel.text = categoryTitle
        let attrStringLab = NSAttributedString(string:categoryTitle, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.whiteColor()])
        let size = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var startx : CGFloat = 0.0
        let  sizeDep = size.width + 40
        startx = (self.frame.width / 2) - (sizeDep / 2)
        
        buttonDepartment.setTitle(categoryTitle, forState: UIControlState.Normal)
        self.buttonDepartment.frame = CGRectMake(startx, 10, sizeDep, 28)
        
       // setProducts(products, width: 162)
    }

    
    func setProducts(products:[[String:AnyObject]],width:CGFloat) {
        
        for sView in   self.subviews {
            if let viewProduct = sView as? GRProductSpecialCollectionViewCell {
                viewProduct.removeFromSuperview()
            }
        }
        
        let jsonLines = JSON(products)
        var currentX : CGFloat = 0.0
        for  lineToShow in jsonLines.arrayValue {
            let product = GRProductSpecialCollectionViewCell(frame: CGRectMake(currentX, 151, width, 123))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                productShortDescription: descProd,
                productPrice: "")
            product.productImage!.frame = CGRectMake(16, 0, 106, 110)
            product.productShortDescriptionLabel!.frame = CGRectMake(16,  product.productImage!.frame.maxY + 14 , product.frame.width - 32, 33)
            product.productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: "productTap:")
            product.addGestureRecognizer(tapOnProdut)
            
            currentX = currentX + width
            
        }
        self.moreButton?.frame = CGRect(x: currentX + 51, y: 195, width: 22, height: 22)
        self.moreLabel?.frame = CGRect(x: currentX + 25, y: self.moreButton!.frame.maxY + 66, width: 64, height: 14)
        
        let tapOnMore =  UITapGestureRecognizer(target: self, action: "moreTap")
        descLabel!.addGestureRecognizer(tapOnMore)
//        var currentX : CGFloat = 0.0
//        for  prod in products {
//            let product = GRProductSpecialCollectionViewCell(frame: CGRectMake(currentX, 40, width, 176))
//            let imageProd =  prod["imageUrl"] as! String
//            let descProd =  prod["description"] as! String
//            let priceProd =  prod["price"] as! NSNumber
//            let upcProd =  prod["upc"] as! String
//            
//            product.upcProduct = upcProd
//            product.setValues(imageProd, productShortDescription: descProd, productPrice: priceProd.stringValue)
//            self.addSubview(product)
//            
//            let tapOnProdut =  UITapGestureRecognizer(target: self, action: "productTap:")
//            product.addGestureRecognizer(tapOnProdut)
//            
//            currentX = currentX + width
//            
//        }
        
    }

    
    func productTap(sender:UITapGestureRecognizer) {
        let viewC = sender.view as! GRProductSpecialCollectionViewCell
        

        delegate.didTapLine(viewC.jsonItemSelected["name"].stringValue, department: viewC.jsonItemSelected["department"].stringValue, family:  viewC.jsonItemSelected["family"].stringValue, line:viewC.jsonItemSelected["line"].stringValue)
        //delegate.didTapLine(name: String, department: String, family: String, line: String)
        
        
        //delegate.didTapProduct(viewC.upcProduct!,descProduct:viewC.productShortDescriptionLabel!.text!,imageProduct: viewC.productImage!)
        //self.getControllerToShow(upc,descr:name,type:type,saving:saving)
       
    }
    
    
    
}