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
    var buttonDepartment : UIButton!
    var openLable : UILabel!
    var buttonCategory : UIButton!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        
        iconCategory = UIImageView(frame: CGRectZero)
        
        buttonDepartment = UIButton()
        buttonDepartment.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        buttonDepartment.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonDepartment.layer.cornerRadius = 14
        buttonDepartment.setImage(UIImage(named:""), forState: UIControlState.Normal)
        buttonDepartment.backgroundColor = WMColor.light_blue
        buttonDepartment.enabled = false
        buttonDepartment.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, 0.0, 0.0)
        
//        titleCategory = UILabel(frame: CGRectZero)
//        titleCategory.font = WMFont.fontMyriadProLightOfSize(16)
//        titleCategory.textColor = WMColor.familyTextColor
        
        
        
//        buttonCategory = UIButton(frame: CGRectZero)
//        buttonCategory.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
//
//        openLable = UILabel(frame: CGRectZero)
//        openLable.font = WMFont.fontMyriadProRegularOfSize(11)
//        openLable.textColor = WMColor.familyTextColor
//        openLable.textAlignment = .Right
        
        //self.addSubview(iconCategory)
        self.addSubview(buttonDepartment)
        //self.addSubview(buttonCategory)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //iconCategory.frame = CGRectMake(0, 0, 40, 40)
        //buttonDepartment.frame = CGRectMake(iconCategory.frame.maxX, 14, self.frame.width - 140, 16)
        //openLable.frame = CGRectMake(self.frame.width - 100, 16, 84, 11)
    }
    
    func setValues(categoryId:String,categoryTitle:String,products:[[String:AnyObject]]) {
        //iconCategory.image = UIImage(named: "b_i_\(categoryId)")
        //buttonDepartment.setTitle(categoryTitle, forState: UIControlState.Normal)
        //openLable.text = NSLocalizedString("gr.category.open", comment: "")
        
        let attrStringLab = NSAttributedString(string:categoryTitle, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.whiteColor()])
        let size = attrStringLab.boundingRectWithSize(CGSizeMake(CGFloat.max,CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        var startx : CGFloat = 0.0
        let  sizeDep = size.width + 40
        startx = (self.frame.width / 2) - (sizeDep / 2)
        
        buttonDepartment.setTitle(categoryTitle, forState: UIControlState.Normal)
        self.buttonDepartment.frame = CGRectMake(startx, 10, sizeDep, 28)
        
        setProducts(products, width: 162)
    }
    
    func setValues(categoryId:String,categoryTitle:String) {
//        iconCategory.image = UIImage(named: "b_i_\(categoryId)")
//        titleCategory.text = categoryTitle
//        openLable.text = NSLocalizedString("gr.category.open", comment: "")
        
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
            let product = GRProductSpecialCollectionViewCell(frame: CGRectMake(currentX, 40, width, 150))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                productShortDescription: descProd,
                productPrice: "")
            self.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: "productTap:")
            product.addGestureRecognizer(tapOnProdut)
            
            currentX = currentX + width
            
        }
        
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
        //delegate.didTapLine(<#name: String#>, department: <#String#>, family: <#String#>, line: <#String#>)
        
        
        //delegate.didTapProduct(viewC.upcProduct!,descProduct:viewC.productShortDescriptionLabel!.text!,imageProduct: viewC.productImage!)
        //self.getControllerToShow(upc,descr:name,type:type,saving:saving)
       
    }
    
    
    
}