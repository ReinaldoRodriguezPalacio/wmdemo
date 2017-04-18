//
//  IPAGRCategoryCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/26/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

protocol IPAGRCategoryCollectionViewCellDelegate: class {
    func didTapProduct(_ upcProduct:String,descProduct:String,imageProduct :UIImageView)
    func didTapLine(_ name:String,department:String,family:String,line:String)
    func didTapMore(_ index:IndexPath)
}

class IPAGRCategoryCollectionViewCell : UICollectionViewCell {
    

    weak var delegate: IPAGRCategoryCollectionViewCellDelegate?
    var iconCategory : UIImageView!
    var imageBackground : UIImageView!
    var titleLabel:UILabel!
    var buttonDepartment : UIButton!
    var openLable : UILabel!
    var descLabel: UILabel?
    var moreButton: UIButton?
    var moreLabel: UILabel?
    var index: IndexPath?

    
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
        imageBackground.contentMode = .scaleAspectFill
        imageBackground.clipsToBounds = true
        
        iconCategory = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(24)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .left
        
        buttonDepartment = UIButton()
        buttonDepartment.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        buttonDepartment.setTitleColor(UIColor.white, for: UIControlState())
        buttonDepartment.layer.cornerRadius = 14
        buttonDepartment.setImage(UIImage(named:""), for: UIControlState())
        buttonDepartment.backgroundColor = WMColor.light_blue
        buttonDepartment.isEnabled = false
        buttonDepartment.titleEdgeInsets = UIEdgeInsetsMake(2.0, 1.0, 0.0, 0.0)
        
        //self.addSubview(buttonDepartment)
        
        self.descLabel = UILabel()
        self.descLabel?.text = "Lo más destacado"
        self.descLabel?.font = WMFont.fontMyriadProRegularOfSize(16)
        self.descLabel?.textColor = WMColor.light_blue
        
        self.moreLabel = UILabel()
        self.moreLabel?.text = "Ver todo"
        self.moreLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.moreLabel?.textColor = WMColor.light_blue
        self.moreLabel?.textAlignment = .center
        
        self.moreButton = UIButton()
        self.moreButton?.setBackgroundImage(UIImage(named: "ver_todo"), for: UIControlState())
        self.moreButton!.addTarget(self, action: #selector(IPAGRCategoryCollectionViewCell.moreTap), for: UIControlEvents.touchUpInside)
        
        self.addSubview(self.imageBackground!)
        self.addSubview(self.iconCategory!)
        self.addSubview(self.titleLabel!)
        self.addSubview(self.descLabel!)
        self.addSubview(self.moreLabel!)
        self.addSubview(self.moreButton!)

        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descLabel!.frame = CGRect(x: 8,y: 119,width: 300,height: 16)
        self.iconCategory.frame = CGRect(x: 16, y: 25, width: 48, height: 48)
        self.titleLabel.frame = CGRect(x: self.iconCategory.frame.maxX + 16, y: 40, width: 335, height: 24)
        self.imageBackground.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 103)
    }
    
    func setValues(_ categoryId:String,categoryTitle:String,products:[[String:Any]]) {
        let svcUrl = serviceUrl("WalmartMG.GRCategoryIconIpad")
        let imageIconURL = "i_\(categoryId.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).png"
        let imgURLName = "\(svcUrl)\(imageIconURL)"
        let imageIconDsk = self.loadImageFromDisk(imageIconURL,defaultStr:"categories_default")
        iconCategory.setImage(with: URL(string: imgURLName)!, and: imageIconDsk, success: { (image) in
            self.saveImageToDisk(imageIconURL, image: image, defaultImage: imageIconDsk!)
        }, failure: {})
        
        let svcUrlCar = serviceUrl("WalmartMG.GRHeaderCategoryIpad")
        let imageBackgroundURL = "\((categoryId as NSString).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).lowercased()).jpg"
        let imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"
        let imageHeader = self.loadImageFromDisk(imageBackgroundURL,defaultStr:"header_default")
        imageBackground.setImage(with: URL(string: imgURLNamehead)!, and: imageHeader, success: { (image) in
            self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader!)
        }, failure: {})
        
        self.titleLabel.text = categoryTitle
        let attrStringLab = NSAttributedString(string:categoryTitle, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.white])
        let size = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        var startx : CGFloat = 0.0
        let  sizeDep = size.width + 40
        startx = (self.frame.width / 2) - (sizeDep / 2)
        
        buttonDepartment.setTitle(categoryTitle, for: UIControlState())
        self.buttonDepartment.frame = CGRect(x: startx, y: 10, width: sizeDep, height: 28)
        
        setProducts(products, width: 125)
    }
    
    func setValues(_ categoryId:String,categoryTitle:String) {
//        iconCategory.image = UIImage(named: "b_i_\(categoryId)")
//        titleCategory.text = categoryTitle
//        openLable.text = NSLocalizedString("gr.category.open", comment: "")
        self.titleLabel.text = categoryTitle
        let attrStringLab = NSAttributedString(string:categoryTitle, attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(16),NSForegroundColorAttributeName:UIColor.white])
        let size = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        var startx : CGFloat = 0.0
        let  sizeDep = size.width + 40
        startx = (self.frame.width / 2) - (sizeDep / 2)
        
        buttonDepartment.setTitle(categoryTitle, for: UIControlState())
        self.buttonDepartment.frame = CGRect(x: startx, y: 10, width: sizeDep, height: 28)
        
        self.imageBackground.isHidden = false
        self.titleLabel.isHidden = false
        self.iconCategory.isHidden = false
       // setProducts(products, width: 162)
    }

    
    func setProducts(_ products:[[String:Any]],width:CGFloat) {
        
        for sView in   self.subviews {
            if let viewProduct = sView as? GRProductSpecialCollectionViewCell {
                viewProduct.removeFromSuperview()
            }
        }
        
        let jsonLines = JSON(products)
        var currentX : CGFloat = 0.0
        for  lineToShow in jsonLines.arrayValue {
            let product = GRProductSpecialCollectionViewCell(frame: CGRect(x:currentX, y:151, width:width, height:123))
            let imageProd =  lineToShow["imageUrl"].stringValue
            let descProd =  lineToShow["name"].stringValue
            product.jsonItemSelected = lineToShow
            product.setValues(imageProd,
                productShortDescription: descProd,
                productPrice: "")
            product.productImage!.frame = CGRect(x:16, y:0, width:106, height:110)
            product.productShortDescriptionLabel!.frame = CGRect(x:16, y:product.productImage!.frame.maxY + 14 , width:product.frame.width - 32, height:33)
            product.productShortDescriptionLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
            self.addSubview(product)
            
            let tapOnProdut =  UITapGestureRecognizer(target: self, action: #selector(IPAGRCategoryCollectionViewCell.productTap(_:)))
            product.addGestureRecognizer(tapOnProdut)
            
            currentX = currentX + width
            
        }
        self.moreButton?.frame = CGRect(x: currentX + 51, y: 195, width: 22, height: 22)
        self.moreLabel?.frame = CGRect(x: currentX + 25, y: self.moreButton!.frame.maxY + 66, width: 64, height: 14)
        
        let tapOnMore =  UITapGestureRecognizer(target: self, action: #selector(IPAGRCategoryCollectionViewCell.moreTap))
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

    
    func productTap(_ sender:UITapGestureRecognizer) {
        let viewC = sender.view as! GRProductSpecialCollectionViewCell
        

        delegate?.didTapLine(viewC.jsonItemSelected["name"].stringValue, department: viewC.jsonItemSelected["department"].stringValue, family:  viewC.jsonItemSelected["family"].stringValue, line:viewC.jsonItemSelected["line"].stringValue)
        //delegate.didTapLine(name: String, department: String, family: String, line: String)
        
        
        //delegate.didTapProduct(viewC.upcProduct!,descProduct:viewC.productShortDescriptionLabel!.text!,imageProduct: viewC.productImage!)
        //self.getControllerToShow(upc,descr:name,type:type,saving:saving)
       
    }
    
    func moreTap(){
        self.delegate?.didTapMore(self.index!)
    }
    
    //MARK: Image Functions
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMURLServices") as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        return serviceURL
    }
    
    func loadImageFromDisk(_ fileName:String,defaultStr:String) -> UIImage! {
        let getImagePath = self.getImagePath(fileName)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: getImagePath))
        {
            print("image \(fileName)")
            
            
            //UIImage(data: NSData(contentsOfFile: getImagePath), scale: 2)
            let imageis: UIImage = UIImage(data: try! Data(contentsOf: URL(fileURLWithPath: getImagePath)), scale: 2)! //UIImage(contentsOfFile: getImagePath)!
            
            return imageis
        }
        else
        {
            let imageDefault = UIImage(named: (fileName as NSString).deletingPathExtension)
            if imageDefault != nil {
                print("default image \((fileName as NSString).deletingPathExtension)")
                return imageDefault
            }
            print("default walmart image \(fileName)")
            return UIImage(named:defaultStr )
        }
    }
    
    func saveImageToDisk(_ fileName:String,image:UIImage,defaultImage:UIImage) {
       DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            let imageData : Data = UIImagePNGRepresentation(image)!
            let imageDataLast : Data = UIImagePNGRepresentation(defaultImage)!
            
            if imageData.MD5() != imageDataLast.MD5() {
                let getImagePath = self.getImagePath(fileName)
                _ = FileManager.default
                try? imageData.write(to: URL(fileURLWithPath: getImagePath), options: [.atomic])
                
                let todeletecloud =  URL(fileURLWithPath: getImagePath)
                do {
                    try (todeletecloud as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
                } catch let error1 as NSError {
                    print(error1.description)
                } catch {
                    fatalError()
                }
                
            }
        })
    }
    
    func getImagePath(_ fileName:String) -> String {
        let fileManager = FileManager.default
        var paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
        paths = (paths as NSString).appendingPathComponent("catimg")
        var isDir : ObjCBool = true
        if fileManager.fileExists(atPath: paths, isDirectory: &isDir) == false {
            let err: NSErrorPointer? = nil
            do {
                try fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                err??.pointee = error
            }
        }
        
        let todeletecloud =  URL(fileURLWithPath: paths)
        do {
            try (todeletecloud as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch let error1 as NSError {
            print(error1.description)
        }
        let getImagePath = (paths as NSString).appendingPathComponent(fileName)
        return getImagePath
    }
    
    func setValuesLanding(_ imageBackgroundURL:String) {
        self.imageBackground.setImageWith(URL(string: imageBackgroundURL)!, placeholderImage: nil)
        self.imageBackground.isHidden = false
        self.titleLabel.isHidden = true
        self.iconCategory.isHidden = true
        self.imageBackground.frame = self.bounds
    }
}
