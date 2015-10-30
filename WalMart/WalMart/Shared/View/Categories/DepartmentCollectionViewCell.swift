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
        imageBackground.contentMode = UIViewContentMode.Left
        imageBackground.clipsToBounds = true
        
        imageIcon = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(25)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        
        buttonClose = UIButton()
        buttonClose.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: "closeDepartment", forControlEvents: UIControlEvents.TouchUpInside)
        buttonClose.alpha = 0
        
        self.addSubview(imageBackground)
        self.addSubview(imageIcon)
        self.addSubview(titleLabel)
        self.addSubview(buttonClose)
        
    }
    
    
    func setValues(title:String,imageBackgroundURL:String,keyBgUrl:String,imageIconURL:String,keyIconUrl:String,hideImage:Bool) {
        
        let svcUrl = serviceUrl(keyIconUrl)
        let imgURLName = "\(svcUrl)\(imageIconURL)"
        
        let imageIcon = self.loadImageFromDisk(imageIconURL,defaultStr:"categories_default")
        self.imageIcon.setImageWithURL(NSURL(string: imgURLName), placeholderImage:imageIcon, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageIcon.image = image
            self.saveImageToDisk(imageIconURL, image: image,defaultImage:imageIcon)
            }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                
        }
        
        let svcUrlCar = serviceUrl(keyBgUrl)
        var imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"
        let strinname = imageBackgroundURL.stringByReplacingOccurrencesOfString(".png", withString: ".jpg")
        let scale = UIScreen.mainScreen().scale
        imgURLNamehead = imgURLNamehead.stringByReplacingOccurrencesOfString(".png", withString: "@\(Int(scale))x.jpg" )

        
        let imageHeader = self.loadImageFromDisk(strinname,defaultStr:strinname)
        self.imageBackground.setImageWithURL(NSURL(string: imgURLNamehead.stringByReplacingOccurrencesOfString("walmartmg", withString: "walmartgr")), placeholderImage:imageHeader, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageBackground.image = image
            self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader)
            }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                
        }
        
        self.titleLabel.text = title
        
        self.imageBackground.hidden = hideImage
        self.titleLabel.hidden = hideImage
        self.imageIcon.hidden = hideImage
        
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
    
    func setValuesFromCell(cell:DepartmentCollectionViewCell) {
        self.imageIcon.image = cell.imageIcon.image
        self.imageBackground.image = cell.imageBackground.image
        self.titleLabel.text = cell.titleLabel.text
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMURLServices") as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    func animateToOpenDepartment(widthEnd:CGFloat,endAnumating:(() -> Void)?) {
        self.startFrame = self.frame
        self.addGestureTiImage()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frame = CGRectMake(0, 0, widthEnd, self.frame.height)
                self.imageBackground.frame = self.bounds
                self.titleLabel.frame = CGRectMake((widthEnd / 2) - (self.titleLabel.frame.width / 2), self.titleLabel.frame.minY, self.titleLabel.frame.width, self.titleLabel.frame.height)
                self.imageIcon.frame = CGRectMake((widthEnd / 2) - 14,  self.imageIcon.frame.minY ,  self.imageIcon.frame.width,  self.imageIcon.frame.height)
                self.buttonClose.frame = CGRectMake(0, 0, 40, 40)
                self.buttonClose.alpha = 1
            }) { (complete:Bool) -> Void in
                if endAnumating != nil {
                    endAnumating!()
                }
        }
    }
  
    func addGestureTiImage(){
        let tapGesture = UITapGestureRecognizer(target: self, action: "closeDepartment")
        self.imageBackground.userInteractionEnabled = true
        self.imageBackground.addGestureRecognizer(tapGesture)
    }
    
    func closeDepartment() {
        if customCloseDep {
            if self.onclose != nil {
                self.onclose!()
            }
            return
        }
        if startFrame != nil {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frame = self.startFrame
                self.titleLabel.frame = CGRectMake((self.startFrame.width / 2) - (self.titleLabel.frame.width / 2), self.titleLabel.frame.minY, self.titleLabel.frame.width, self.titleLabel.frame.height)
                self.imageIcon.frame = CGRectMake((self.startFrame.width / 2) - 14,  self.imageIcon.frame.minY ,  self.imageIcon.frame.width,  self.imageIcon.frame.height)
                self.buttonClose.alpha = 0
                }) { (complete:Bool) -> Void in
                    self.removeFromSuperview()
                    if self.onclose != nil {
                        self.onclose!()
                    }
            }
        } else {
            self.removeFromSuperview()
            if self.onclose != nil {
                self.onclose!()
            }
        }
    }
    
    func loadImageFromDisk(fileName:String,defaultStr:String) -> UIImage! {
        let getImagePath = self.getImagePath(fileName)
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(getImagePath))
        {
            let imageis: UIImage = UIImage(data: NSData(contentsOfFile: getImagePath)!, scale: 2)!
            return imageis
        }
        else
        {
            let imageDefault = UIImage(named: (fileName as NSString).stringByDeletingPathExtension)
            if imageDefault != nil {
                print("default image \((fileName as NSString).stringByDeletingPathExtension)")
                return imageDefault
            }
            print("default walmart image \(fileName)")
            return UIImage(named:defaultStr )
        }
    }
    
    func saveImageToDisk(fileName:String,image:UIImage,defaultImage:UIImage) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let imageData : NSData = UIImagePNGRepresentation(image)!
            let imageDataLast : NSData = UIImagePNGRepresentation(defaultImage)!
            
            if imageData.MD5() != imageDataLast.MD5() {
                let getImagePath = self.getImagePath(fileName)
                //let fileManager = NSFileManager.defaultManager()
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
        var paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as NSString
        paths = paths.stringByAppendingPathComponent("catimg")
        var isDir : ObjCBool = true
        if fileManager.fileExistsAtPath(paths as String, isDirectory: &isDir) == false {
            let err: NSErrorPointer = nil
            do {
                try fileManager.createDirectoryAtPath(paths as String, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                err.memory = error
            }
        }
        let todeletecloud =  NSURL(fileURLWithPath: paths as String)

        do {
            try todeletecloud.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
        } catch let error1 as NSError {
             print(error1.description)
        }
        
        let getImagePath = paths.stringByAppendingPathComponent(fileName)
        return getImagePath
    }
    
    
    
}