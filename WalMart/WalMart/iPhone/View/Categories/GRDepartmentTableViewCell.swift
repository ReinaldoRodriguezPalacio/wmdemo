//
//  GRDepartmentTableViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 17/06/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


class GRDepartmentTableViewCell : UITableViewCell {
    
    var imageBackground : UIImageView!
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    
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
        
        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.scaleAspectFill
        imageBackground.clipsToBounds = true
        
        imageIcon = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        
        
        self.addSubview(imageBackground)
        self.addSubview(imageIcon)
        self.addSubview(titleLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: 64,width: self.frame.width, height: 16)
        imageBackground.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - 4)
        imageIcon.frame = CGRect(x: (self.frame.width / 2) - 12, y: 23, width: 24, height: 24)
    }
    
    
    func setValues(_ title:String,imageBackgroundURL:String,imageIconURL:String) {
        
        let svcUrl = serviceUrl("WalmartMG.GRCategoryIcon")
        let imgURLName = "\(svcUrl)\(imageIconURL)"
        //self.imageIcon.setImageWithURL(NSURL(string: imgURLName), placeholderImage: UIImage(named: imageIconURL))
        var loadImageIcon =  true
        let imageIconDsk = self.loadImageFromDisk(imageIconURL, defaultStr: "categories_default") { (loadImage:Bool) -> Void in
            loadImageIcon = loadImage
        }
        let svcUrlCar = serviceUrl("WalmartMG.GRHeaderCategory")
        let imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"
        
        var loadHeader =  true
        let imageHeader = self.loadImageFromDisk(imageBackgroundURL, defaultStr: "header_default") { (loadHead:Bool) -> Void in
            loadHeader = loadHead
        }
        
        if loadHeader {
            self.imageBackground.setImageWith(URLRequest(url:URL(string: imgURLNamehead)!), placeholderImage:imageHeader, success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                self.imageBackground.image = image
                self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader!)
                }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                    
            }
        }else{
            self.imageBackground.image = imageHeader
        }
        
        if loadImageIcon {
            self.imageIcon.setImageWith(URLRequest(url:URL(string: imgURLName)!), placeholderImage:imageIconDsk, success: { (request:URLRequest, response:HTTPURLResponse?, image:UIImage) -> Void in
                self.imageIcon.image = image
                self.saveImageToDisk(imageIconURL, image: image,defaultImage:imageIconDsk!)
                }) { (request:URLRequest, response:HTTPURLResponse?, error:Error) -> Void in
                    
            }
        }else{
            self.imageIcon.image = imageIconDsk
        }
        
        self.titleLabel.text = title
        self.imageBackground.frame = self.bounds
        self.imageBackground.isHidden = false
        self.titleLabel.isHidden = false
        self.imageIcon.isHidden = false
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
    
    func loadImageFromDisk(_ fileName:String,defaultStr:String,succesBlock:((Bool) -> Void)) -> UIImage! {
        let getImagePath = self.getImagePath(fileName)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: getImagePath))
        {
            print("image \(fileName)")
            //UIImage(data: NSData(contentsOfFile: getImagePath), scale: 2)
            let imageis: UIImage = UIImage(data: try! Data(contentsOf: URL(fileURLWithPath: getImagePath)), scale: 2)! //UIImage(contentsOfFile: getImagePath)!
            succesBlock(false)
            return imageis
        }
        else
        {
            let imageDefault = UIImage(named: (fileName as NSString).deletingPathExtension)
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
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMURLServices") as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        return serviceURL
    }
    
    func saveImageToDisk(_ fileName:String,image:UIImage,defaultImage:UIImage) {
        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
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
}
