//
//  IPAGRCategoriesViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/26/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class IPAGRCategoriesViewController :  NavigationViewController, UICollectionViewDataSource, UICollectionViewDelegate,IPAGRCategoryCollectionViewCellDelegate, GRMyAddressViewControllerDelegate {
    
    var items : [AnyObject]? = []
    @IBOutlet var colCategories : UICollectionView!
    var canfigData : [String:AnyObject]! = [:]
    var animateView : UIView!
    var controllerAnimateView : IPACategoriesResultViewController!
    var itemsExclusive : [AnyObject]? = []
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_SUPER.rawValue
    }
    
    var pontInViewNuew = CGRectZero
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if UserCurrentSession.hasLoggedUser() {
           self.setStoreName()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton?.hidden = true
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        self.titleLabel?.text = "Súper"
        
        colCategories.backgroundColor = WMColor.navigationHeaderBgColor
        
        loadDepartments()
        
        let svcConfig = ConfigService()
        let svcExclusive = GRExclusiveItemsService()
        itemsExclusive = svcExclusive.getGrExclusiveContent()
        canfigData = svcConfig.getConfoigContent()
        
    }
    
    func loadDepartments() -> [AnyObject]? {
        let serviceCategory = GRCategoryService()
        self.items = serviceCategory.getCategoriesContent()
        colCategories.delegate = self
        colCategories.dataSource = self
        return self.items
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items!.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = colCategories.dequeueReusableCellWithReuseIdentifier("cellCategory", forIndexPath: indexPath) as! IPAGRCategoryCollectionViewCell
        cell.delegate =  self // new 
        
        let item = items![indexPath.row] as! [String:AnyObject]
        let descDepartment = item["description"] as! String
        var bgDepartment = item["idDepto"] as! String
        let families = JSON(item["family"] as! [[String:AnyObject]])
        
        bgDepartment = bgDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        
        if let resultProducts = fillConfigData(bgDepartment,families:families) {
            cell.setValues(bgDepartment, categoryTitle: descDepartment,products:resultProducts)
        }else {
            cell.setValues(bgDepartment, categoryTitle: descDepartment)
        }
        
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        let cellSelected = collectionView.cellForItemAtIndexPath(indexPath) as! IPAGRCategoryCollectionViewCell!
        let pontInView = cellSelected.superview!.convertRect(cellSelected!.frame, toView: self.view)
        pontInViewNuew = pontInView

        let item = self.items![indexPath.row] as! [String:AnyObject]
        let idDepartment = item["idDepto"] as! String
        let famArray : AnyObject = item["family"] as AnyObject!
        let itemsFam : [[String:AnyObject]] = famArray as! [[String:AnyObject]]
        let famSelected = itemsFam[0]
        let idFamDefault = famSelected["id"] as! String
        
        let lineArray : AnyObject = famSelected["line"] as AnyObject!
        let itemsLine : [[String:AnyObject]] = lineArray as! [[String:AnyObject]]
        let lineSelected = itemsLine[0]
        let idLineDefault = lineSelected["id"] as! String
        let nameLineDefault = lineSelected["name"] as! String
        
        CategoryShouldShowFamily.shouldshowfamily = true
        controllerAnimateView = IPACategoriesResultViewController()
        controllerAnimateView.setValues(idDepartment, family: idFamDefault, line: idLineDefault, name:nameLineDefault)
        
        NSLog("%@", (idDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString))
        
        let svcUrl = serviceUrl("WalmartMG.GRCategoryIconIpad")
        let imageIconURL = "i_\(idDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())).jpg"
        let imgURLName = "\(svcUrl)\(imageIconURL)"
        //self.imageIcon.setImageWithURL(NSURL(string: imgURLName), placeholderImage: UIImage(named: imageIconURL))
        controllerAnimateView.imageIcon = UIImageView()
        let imageIconDsk = self.loadImageFromDisk(imageIconURL,defaultStr:"categories_default")
        controllerAnimateView.imageIcon.setImageWithURL(NSURL(string: imgURLName), placeholderImage:imageIconDsk, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.controllerAnimateView.imageIcon.image = image
            self.saveImageToDisk(imageIconURL, image: image,defaultImage:imageIconDsk)
            }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                
        }
        
        let svcUrlCar = serviceUrl("WalmartMG.GRHeaderCategoryIpad")
        let imageBackgroundURL = "\(idDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString).jpg"
        let imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"

        let imageView = UIImageView()
        let imageHeader = self.loadImageFromDisk(imageBackgroundURL,defaultStr:"header_default")
        imageView.setImageWithURL(NSURL(string: imgURLNamehead), placeholderImage:imageHeader, success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.controllerAnimateView.imgCategory = image
            self.controllerAnimateView.searchProduct?.imageBgCategory = image
            imageView.image = image
            self.controllerAnimateView.searchProduct?.collection?.reloadData()
            self.saveImageToDisk(imageBackgroundURL, image: image,defaultImage:imageHeader)
            }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                
        }
        
        controllerAnimateView.frameStart = pontInView
        controllerAnimateView.frameEnd = self.view.bounds
        controllerAnimateView.titleStr = cellSelected.buttonDepartment.titleLabel!.text
        controllerAnimateView.families = itemsFam
        controllerAnimateView.name = nameLineDefault
        controllerAnimateView.searchContextType = SearchServiceContextType.WithCategoryForGR
        controllerAnimateView.closeAnimated = false
        
        controllerAnimateView.actionClose = {() in
            
//            self.categories.scrollEnabled = true
//            self.selectedLine = false
            
            //self.selectedIndex = nil
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.controllerAnimateView.view.alpha = 0
                }, completion: { (complete:Bool) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.animateView.frame =  pontInView
                        self.animateView.alpha = 0
                        
                        //self.categories.contentInset = UIEdgeInsetsZero
                        }, completion: { (complete:Bool) -> Void in
                            self.animateView.removeFromSuperview()
                            self.controllerAnimateView = nil
                            //self.categories.reloadData()
                    })
            })
            
            
        }
        
        self.addChildViewController(controllerAnimateView)
        self.view.addSubview(controllerAnimateView.view)
        
        animateView = UIView(frame: pontInView)
        animateView.backgroundColor = UIColor.whiteColor()
        animateView.alpha = 0
        controllerAnimateView.view.alpha = 0
        self.view.addSubview(animateView)
        self.animateView.addSubview(controllerAnimateView.view)
        self.controllerAnimateView.searchProduct.imageBgCategory = imageView.image
        self.controllerAnimateView.searchProduct.imageIconCategory = self.controllerAnimateView.imgIcon
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
             self.animateView.alpha = 1
            }) { (complete:Bool) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.animateView.frame = self.view.bounds
                    }, completion: { (complete:Bool) -> Void in
                        
                        if self.controllerAnimateView.searchProduct != nil {
                            self.controllerAnimateView.searchProduct.view.frame = CGRectMake(0, 0,  self.controllerAnimateView.frameEnd.width,  self.controllerAnimateView.frameEnd.height)
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.controllerAnimateView.searchProduct.view.alpha = 1
                                }) { (complete:Bool) -> Void in
                                    if self.controllerAnimateView.viewImageContent != nil {
                                        self.controllerAnimateView.addPopover()
                                    }
                            }
                        }

                        
                        
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.controllerAnimateView.view.alpha = 1
                    })
                })
            
        }
        
    }
 
    
    func didTapProduct(upcProduct: String, descProduct: String,imageProduct :UIImageView) {
        

        let controller = IPAProductDetailPageViewController()
        
        controller.itemsToShow = [["upc":upcProduct,"description":descProduct,"type":ResultObjectType.Groceries.rawValue]]
        controller.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
        controller.animationController.setImage(imageProduct.image!)
        pontInViewNuew = imageProduct.superview!.convertRect(imageProduct.frame, toView: self.view)
        
        controller.animationController.originPoint =  pontInViewNuew
        self.navigationController?.delegate = controller
        self.navigationController?.pushViewController(controller, animated: true)

    }
   
    
    func fillConfigData(depto:String,families:JSON) -> [[String:AnyObject]]? {
        var resultDict : [AnyObject] = []
        if Array(canfigData.keys.filter {$0 == depto }).count > 0 {
            let linesToShow = JSON(canfigData[depto] as! [[String:String]])
            for lineDest in linesToShow.arrayValue {
                for family in families.arrayValue {
                    for line in family["line"].arrayValue {
                        let lineOne = line["id"].stringValue
                        let lineTwo = lineDest["line"].stringValue
                        if lineOne.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                            == lineTwo.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                                let itemToShow = ["name": line["name"].stringValue,
                                    "imageUrl": lineDest["imageUrl"].stringValue,
                                    "line": lineTwo ,
                                    "family": family["id"].stringValue ,
                                    "department":depto]
                                resultDict.append(itemToShow)
                                
                        }
                    }
                }
            }
        }
        
        return resultDict as? [[String:AnyObject]]
    }
    
    func didTapLine(name:String,department:String,family:String,line:String) {
        let controller = IPASearchProductViewController()
        controller.searchContextType = SearchServiceContextType.WithCategoryForGR
        controller.idFamily  = family
        controller.idDepartment = department
        controller.idLine = line
        controller.titleHeader = name
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK changeStore
    func changeStore(){
        let myAddress = GRMyAddressViewController()
        myAddress.addCloseButton()
        myAddress.delegate = self
        myAddress.onClosePicker = { () in   self.navigationController?.dismissViewControllerAnimated(true, completion: nil)}
        let navController = UINavigationController(rootViewController: myAddress)
        navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        navController.navigationBarHidden = true
        navController.view.layer.cornerRadius = 8.0
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    func setStoreName(){
        if UserCurrentSession.sharedInstance().storeName != nil {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "arrow")
            let attachmentString = NSAttributedString(attachment: attachment)
            let myString = NSMutableAttributedString(string: "Tu tienda: ")
            let attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(16)]
            let boldString = NSMutableAttributedString(string:"Walmart \(UserCurrentSession.sharedInstance().storeName!.capitalizedString) ", attributes:attrs)
            myString.appendAttributedString(boldString)
            myString.appendAttributedString(attachmentString)
            self.titleLabel?.numberOfLines = 2;
            self.titleLabel?.attributedText = myString;
            self.titleLabel?.userInteractionEnabled = true;
            let tapGesture = UITapGestureRecognizer(target: self, action: "changeStore")
            self.titleLabel?.addGestureRecognizer(tapGesture)
        }

    }
    //MARK: Image Functions
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMURLServices") as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    func loadImageFromDisk(fileName:String,defaultStr:String) -> UIImage! {
        let getImagePath = self.getImagePath(fileName)
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(getImagePath))
        {
            print("image \(fileName)")
            
            
            //UIImage(data: NSData(contentsOfFile: getImagePath), scale: 2)
            let imageis: UIImage = UIImage(data: NSData(contentsOfFile: getImagePath)!, scale: 2)! //UIImage(contentsOfFile: getImagePath)!
            
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
    
    func okAction() {
        self.setStoreName()
    }
}