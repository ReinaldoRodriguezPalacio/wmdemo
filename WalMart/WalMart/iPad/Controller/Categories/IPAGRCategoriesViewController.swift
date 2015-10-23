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
    
    var pontInViewNuew = CGRectZero
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if UserCurrentSession.sharedInstance().userSigned != nil {
           self.setStoreName()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton?.hidden = true
        
        //SCREEN
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
        controllerAnimateView.imgCategory =  UIImage(named: idDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString)
        controllerAnimateView.frameStart = pontInView
        controllerAnimateView.frameEnd = self.view.bounds
        controllerAnimateView.imgIcon = UIImage(named: "i_\(idDepartment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))")
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
    
    func okAction() {
        self.setStoreName()
    }
}