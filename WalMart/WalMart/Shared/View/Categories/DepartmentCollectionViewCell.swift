//
//  CategoryCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/3/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class DepartmentCollectionViewCell : UICollectionViewCell {
    
    var buttonClose : UIButton!
    var imageBackground : UIImageView!
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    var isOpen : Bool = false
    var onclose : (() -> Void)? = nil
    var startFrame : CGRect!
    var customCloseDep = false
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        self.clipsToBounds = true
        
        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.left
        imageBackground.clipsToBounds = true
        
        imageIcon = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(25)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        
        buttonClose = UIButton()
        buttonClose.setImage(UIImage(named: "close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(DepartmentCollectionViewCell.closeDepartment), for: UIControlEvents.touchUpInside)
        buttonClose.alpha = 0
        
        self.addSubview(imageBackground)
        self.addSubview(imageIcon)
        self.addSubview(titleLabel)
        self.addSubview(buttonClose)
        
    }
    
    
    func setValues(_ title:String,imageBackgroundURL:String,keyBgUrl:String,imageIconURL:String,keyIconUrl:String,hideImage:Bool) {
        let scale = UIScreen.main.scale
        let svcUrl = serviceUrl(keyIconUrl)
        var imgURLName = "\(svcUrl)\(imageIconURL)"
        imgURLName = imgURLName.replacingOccurrences(of: ".png", with: "@\(Int(scale))x.png" )
        var loadImagefromUrl =  true
        
        let imageIcon = self.loadImageFromDisk(imageIconURL, defaultStr:"categories_default") { (loadImage:Bool) -> Void in
            loadImagefromUrl = loadImage
        }//self.loadImageFromDisk(imageIconURL,defaultStr:"categories_default")
        if loadImagefromUrl {
            self.imageIcon.setImageWith(URLRequest(url:URL(string: imgURLName)!), placeholderImage:imageIcon, success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                self.imageIcon.image = image
                self.saveImageToDisk(imageIconURL, image: image,defaultImage:imageIcon!)
                }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                    
            }
        }else{
            self.imageIcon.image = imageIcon
        }
        
        let svcUrlCar = serviceUrl(keyBgUrl)
        var imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"
        let strinname = imageBackgroundURL.replacingOccurrences(of: ".png", with: ".jpg")
        imgURLNamehead = imgURLNamehead.replacingOccurrences(of: ".jpg", with: "@\(Int(scale))x.jpg" )
        imgURLNamehead = imgURLNamehead.replacingOccurrences(of: ".png", with: "@\(Int(scale))x.jpg" )
        loadImagefromUrl =  true
        
        let imageHeader = self.loadImageFromDisk(strinname, defaultStr: "header_default") { (loadImage:Bool) -> Void in
            loadImagefromUrl = loadImage
        }//self.loadImageFromDisk(strinname,defaultStr:"header_default")
      
        if loadImagefromUrl {
            self.imageBackground.setImageWith(URLRequest(url:URL(string: imgURLNamehead)!), placeholderImage:imageHeader, success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                self.imageBackground.image = image
                self.saveImageToDisk(imageBackgroundURL.replacingOccurrences(of: ".png", with: ".jpg"), image: image,defaultImage:imageHeader!)
                }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                    
            }
        }else{
            self.imageBackground.image = imageHeader
        }
        
        self.titleLabel.text = title
        
        self.imageBackground.isHidden = hideImage
        self.titleLabel.isHidden = hideImage
        self.imageIcon.isHidden = hideImage
        
    }
    
    func setValuesLanding(_ imageBackgroundURL:String) {
        
        
        //println("Imagen del header en: \(imageBackgroundURL) ")
        self.imageBackground.setImageWith(URLRequest(url:URL(string: imageBackgroundURL)!), placeholderImage:nil, success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
            self.imageBackground.image = image
            //self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader)
            }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                print(error)
        }
        
        //self.titleLabel.text = title
        
        self.imageBackground.isHidden = false
        self.titleLabel.isHidden = true
        self.imageIcon.isHidden = true
        
    }
    
    func setValuesFromCell(_ cell:DepartmentCollectionViewCell) {
        self.imageIcon.image = cell.imageIcon.image
        self.imageBackground.image = cell.imageBackground.image
        self.titleLabel.text = cell.titleLabel.text
    }
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMURLServices") as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        return serviceURL
    }
    
    func animateToOpenDepartment(_ widthEnd:CGFloat,endAnumating:(() -> Void)?) {
        self.startFrame = self.frame
        self.addGestureTiImage()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.frame = CGRect(x: 0, y: 0, width: widthEnd, height: self.frame.height)
                self.imageBackground.frame = self.bounds
                self.titleLabel.frame = CGRect(x: (widthEnd / 2) - (self.titleLabel.frame.width / 2), y: self.titleLabel.frame.minY, width: self.titleLabel.frame.width, height: self.titleLabel.frame.height)
                self.imageIcon.frame = CGRect(x: (widthEnd / 2) - 14,  y: self.imageIcon.frame.minY ,  width: self.imageIcon.frame.width,  height: self.imageIcon.frame.height)
                self.buttonClose.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                self.buttonClose.alpha = 1
            }, completion: { (complete:Bool) -> Void in
                self.titleLabel.frame = CGRect(x: 0, y: self.titleLabel.frame.minY, width: widthEnd, height: self.titleLabel.frame.height)
                if endAnumating != nil {
                    endAnumating!()
                }
        }) 
    }
  
    func addGestureTiImage(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DepartmentCollectionViewCell.closeDepartment))
        self.imageBackground.isUserInteractionEnabled = true
        self.imageBackground.addGestureRecognizer(tapGesture)
        
       
        
    }
    
    func closeDepartment() {
        
        
        let label = self.titleLabel.text!
        let labelCategory = label.uppercased().replacingOccurrences(of: " ", with: "_")
        //BaseController.sendAnalytics("MG_\(labelCategory)_VIEW_AUTH", categoryNoAuth: "MG_\(labelCategory)_VIEW_NO_AUTH", action: WMGAIUtils.ACTION_CANCEL.rawValue, label: label)
        
        if customCloseDep {
            if self.onclose != nil {
                self.onclose!()
            }
            return
        }
        if startFrame != nil {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.frame = self.startFrame
                self.titleLabel.frame = CGRect(x: (self.startFrame.width / 2) - (self.titleLabel.frame.width / 2), y: self.titleLabel.frame.minY, width: self.titleLabel.frame.width, height: self.titleLabel.frame.height)
                self.imageIcon.frame = CGRect(x: (self.startFrame.width / 2) - 14,  y: self.imageIcon.frame.minY ,  width: self.imageIcon.frame.width,  height: self.imageIcon.frame.height)
                self.buttonClose.alpha = 0
                }, completion: { (complete:Bool) -> Void in
                    self.removeFromSuperview()
                    if self.onclose != nil {
                        self.onclose!()
                    }
            }) 
        } else {
            self.removeFromSuperview()
            if self.onclose != nil {
                self.onclose!()
            }
        }
    }
    
    func loadImageFromDisk(_ fileName:String,defaultStr:String,succesBlock:((Bool) -> Void)) -> UIImage! {
        let getImagePath = self.getImagePath(fileName)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: getImagePath))
        {
            let imageis: UIImage = UIImage(data: try! Data(contentsOf: URL(fileURLWithPath: getImagePath)), scale: 2)!
            succesBlock(false)
            return imageis
        }
        else
        {
            var imageDefault = UIImage(named: (fileName.replacingOccurrences(of: ".jpg", with:"") as NSString).deletingPathExtension)
            if imageDefault == nil {
                imageDefault = UIImage(named: (fileName as NSString).deletingPathExtension + ".jpg")
            }
            
            
            if imageDefault != nil {
                print("default image \((fileName as NSString).deletingPathExtension)")
                succesBlock(true)
                return imageDefault
            }
            print("default walmart image \(fileName)")
             succesBlock(true)
            return UIImage(named:defaultStr )
        }
    }
    
    func saveImageToDisk(_ fileName:String,image:UIImage,defaultImage:UIImage) {
        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
            let imageData : Data = UIImagePNGRepresentation(image)!
            let imageDataLast : Data = UIImagePNGRepresentation(defaultImage)!
            
            if imageData.MD5() != imageDataLast.MD5() {
                let getImagePath = self.getImagePath(fileName)
                //let fileManager = NSFileManager.defaultManager()
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
        var paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] as NSString
        paths = paths.appendingPathComponent("catimg") as NSString
        var isDir : ObjCBool = true
        if fileManager.fileExists(atPath: paths as String, isDirectory: &isDir) == false {
            let err: NSErrorPointer? = nil
            do {
                try fileManager.createDirectory(atPath: paths as String, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                err??.pointee = error
            }
        }
        let todeletecloud =  URL(fileURLWithPath: paths as String)

        do {
            try (todeletecloud as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch let error1 as NSError {
             print(error1.description)
        }
        
        let getImagePath = paths.appendingPathComponent(fileName)
        return getImagePath
    }
    
    
    
}
