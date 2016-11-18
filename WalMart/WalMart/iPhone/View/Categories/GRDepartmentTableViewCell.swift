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
        imageBackground.contentMode = UIViewContentMode.ScaleAspectFill
        imageBackground.clipsToBounds = true
        
        imageIcon = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProLightOfSize(16)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        
        
        self.addSubview(imageBackground)
        self.addSubview(imageIcon)
        self.addSubview(titleLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRectMake(0, 64,self.frame.width, 16)
        imageBackground.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height - 4)
        imageIcon.frame = CGRectMake((self.frame.width / 2) - 12, 23, 24, 24)
    }
    
    
    func setValues(title:String,imageBackgroundURL:String,imageIconURL:String) {
        
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
            self.imageBackground.setImageWithURL(NSURL(string: imgURLNamehead), placeholderImage:imageHeader, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.imageBackground.image = image
                self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader)
                }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    
            }
        }else{
            self.imageBackground.image = imageHeader
        }
        
        if loadImageIcon {
            self.imageIcon.setImageWithURL(NSURL(string: imgURLName), placeholderImage:imageIconDsk, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.imageIcon.image = image
                self.saveImageToDisk(imageIconURL, image: image,defaultImage:imageIconDsk)
                }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    
            }
        }else{
            self.imageIcon.image = imageIconDsk
        }
        
        self.titleLabel.text = title
        self.imageBackground.frame = self.bounds
        self.imageBackground.hidden = false
        self.titleLabel.hidden = false
        self.imageIcon.hidden = false
    }
    
    func setValuesLanding(imageBackgroundURL:String) {
        //println("Imagen del header en: \(imageBackgroundURL) ")
        self.imageBackground.setImageWithURL(NSURL(string: imageBackgroundURL), placeholderImage:nil, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageBackground.image = image
            //self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader)
        }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
            print(error)
        }
        //self.titleLabel.text = title
        self.imageBackground.hidden = false
        self.titleLabel.hidden = true
        self.imageIcon.hidden = true
        
    }
    
    func loadImageFromDisk(fileName:String,defaultStr:String,succesBlock:((Bool) -> Void)) -> UIImage! {
        let getImagePath = self.getImagePath(fileName)
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(getImagePath))
        {
            print("image \(fileName)")
            //UIImage(data: NSData(contentsOfFile: getImagePath), scale: 2)
            let imageis: UIImage = UIImage(data: NSData(contentsOfFile: getImagePath)!, scale: 2)! //UIImage(contentsOfFile: getImagePath)!
            succesBlock(false)
            return imageis
        }
        else
        {
            let imageDefault = UIImage(named: (fileName as NSString).stringByDeletingPathExtension)
            if imageDefault != nil {
                print("default image \((fileName as NSString).stringByDeletingPathExtension)")
                succesBlock(true)
                return imageDefault
            }
            print("default walmart image \(fileName)")
            succesBlock(true)
            return UIImage(named:defaultStr )
        }
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMURLServices") as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    func saveImageToDisk(fileName:String,image:UIImage,defaultImage:UIImage) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let imageData : NSData = UIImagePNGRepresentation(image)!
            let imageDataLast : NSData = UIImagePNGRepresentation(defaultImage)!
            
            if imageData.MD5() != imageDataLast.MD5() {
                let getImagePath = self.getImagePath(fileName)
                _ = NSFileManager.defaultManager()
                imageData.writeToFile(getImagePath, atomically: true)
                
                let todeletecloud =  NSURL(fileURLWithPath: getImagePath)
                do {
                    try todeletecloud.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
                } catch let error1 as NSError {
                    print(error1.description)
                } catch {
                    fatalError()
                }
                
            }
        })
    }
    
    func getImagePath(fileName:String) -> String {
        let fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0]
        paths = (paths as NSString).stringByAppendingPathComponent("catimg")
        var isDir : ObjCBool = true
        if fileManager.fileExistsAtPath(paths, isDirectory: &isDir) == false {
            let err: NSErrorPointer = nil
            do {
                try fileManager.createDirectoryAtPath(paths, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                err.memory = error
            }
        }
        
        let todeletecloud =  NSURL(fileURLWithPath: paths)
        do {
            try todeletecloud.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
        } catch let error1 as NSError {
            print(error1.description)
        }
        let getImagePath = (paths as NSString).stringByAppendingPathComponent(fileName)
        return getImagePath
    }
}
