//
//  IPACategoriesResultViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

struct CategoryShouldShowFamily {
    static var shouldshowfamily : Bool = true
}

class IPACategoriesResultViewController : UIViewController,IPAFamilyViewControllerDelegate,IPASectionHeaderSearchReusableDelegate,IPACatHeaderSearchReusableDelegate,UIPopoverControllerDelegate {

    var viewImageBgCategory : UIImageView!
    var imgCategory : UIImage!

    var frameStart : CGRect!
    var frameEnd : CGRect!
    //var btnClose : UIButton!
    var btnOpenMenu : UIButton!
    var searchProduct : IPASearchCatProductViewController!
    var department : String!
    var family : String!
    var families : [[String:AnyObject]]!
    var line : String!
    var name : String!
    
    var imgIcon : UIImage!
    var titleStr : String!
    
    var popover : UIPopoverController?
    var familyController : IPAFamilyViewController!
    
    var viewImageContent : UIView!
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    
    var actionClose : (()->Void)?
    
    var searchContextType: SearchServiceContextType? = nil
    var closeAnimated : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.clearColor()
        
        viewImageBgCategory = UIImageView(frame: CGRectMake(-120, 0, 1024, frameStart.height))
        viewImageBgCategory.contentMode = UIViewContentMode.ScaleAspectFill
        viewImageBgCategory.image = imgCategory
        viewImageBgCategory.clipsToBounds = true
        
        imageIcon = UIImageView()
        imageIcon.frame = CGRectMake((self.frameStart.width / 2) - 24, 48, 48, 48)
        imageIcon.image = imgIcon

        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProLightOfSize(25)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.frame = CGRectMake((self.frameStart.width / 2) - 200, 112, 400, 50)
        titleLabel.text = titleStr
        
 
        
        viewImageContent = UIView(frame:frameStart)
        viewImageContent.addSubview(viewImageBgCategory)
        viewImageContent.addSubview(imageIcon)
        viewImageContent.addSubview(titleLabel)
        viewImageContent.clipsToBounds = true
        
      
        
       
        
        searchProduct = IPASearchCatProductViewController()
        searchProduct.searchContextType = self.searchContextType
        searchProduct.delegateImgHeader = self
        searchProduct.imageBgCategory = imgCategory
        searchProduct.imageIconCategory = imgIcon
        searchProduct.titleCategory = titleStr
        searchProduct.idFamily  = family
        searchProduct.idDepartment = department
        searchProduct.idLine = line
        searchProduct.titleHeader = name
        searchProduct.hiddenBack = true
        searchProduct.delegateHeader = self
        searchProduct.view.alpha = 0
        //searchProduct.showHeader = true
        self.view.addSubview(viewImageContent)
       
        searchProduct.view.frame = CGRectMake(0, 0,  self.frameEnd.width,  self.frameEnd.height)// self.viewContainer.bounds
        
        self.addChildViewController(searchProduct)
        self.view.addSubview(searchProduct.view)
    }
  
    
    func setValues(department:String,family:String,line:String, name:String ) {
        self.department = department
        self.family = family
        self.line = line
        self.name = name
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startAnimating()
    }
    
    func startAnimating() {
         if CategoryShouldShowFamily.shouldshowfamily {
            CategoryShouldShowFamily.shouldshowfamily = false
            self.searchProduct.view.alpha = 0
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.frame = self.frameEnd
                self.viewImageContent.frame = CGRectMake(0, 0, self.frameEnd.width, self.viewImageBgCategory.frame.height)
                self.viewImageBgCategory.frame = CGRectMake(0, 0, self.frameEnd.width, self.viewImageBgCategory.frame.height)
                self.imageIcon.frame = CGRectMake((self.frameEnd.width / 2) - 24, 48, 48, 48)
                self.titleLabel.frame = CGRectMake((self.frameEnd.width / 2) - 200, 112, 400, 50)
                
                }) { (complete:Bool) -> Void in
                    //self.btnClose.frame  = CGRectMake(self.frameEnd.width - 100 ,3 ,100,100)
                    if self.searchProduct != nil {
                        self.searchProduct.view.frame = CGRectMake(0, 0,  self.frameEnd.width,  self.frameEnd.height)
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.searchProduct.view.alpha = 1
                            }) { (complete:Bool) -> Void in
                                if self.viewImageContent != nil {
                                    self.addPopover()
                                    self.viewImageContent.alpha = 0
                                    self.viewImageBgCategory.alpha = 0
                                }
                        }
                    }
                   
            }
        }
    }
    

    
    func addPopover(){
        familyController =  IPAFamilyViewController()
        
        familyController.departmentId = department
        familyController.families = families
        familyController.selectedFamily = nil
        familyController.delegate = self
       
        
        if #available(iOS 8.0, *) {
            familyController.modalPresentationStyle = .Popover
        } else {
            familyController.modalPresentationStyle = .FormSheet
        }
        familyController.preferredContentSize = CGSizeMake(320, 322)
        
        if popover ==  nil {
            popover = UIPopoverController(contentViewController: familyController)
        }
        popover!.delegate = self
        popover!.presentPopoverFromRect(CGRectMake(self.frameEnd.width / 2, frameStart.height + 40, 0, 0), inView: self.searchProduct.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        searchProduct.setSelectedHeaderCat()
        
        if familyController.familyTable != nil {
            familyController.familyTable.reloadData()
        }
        
    }
        
    func didSelectLine(department:String,family:String,line:String, name:String) {
        
        familyController.departmentId = line
        let pointPop =  searchProduct.viewHeader.convertPoint(CGPointMake(self.view.frame.width / 2,  frameStart.height - 40 ), toView:self.view)
        searchProduct.loading = WMLoadingView(frame: CGRectMake(0, pointPop.y, self.view.bounds.width, self.view.bounds.height - pointPop.y))
        
        searchProduct.mgResults!.resetResult()
        searchProduct.grResults!.resetResult()
        searchProduct.allProducts = []
        searchProduct.idFamily  = family
        searchProduct.idDepartment = department
        searchProduct.idLine = line
        searchProduct.titleHeader = name

        searchProduct.collection?.scrollRectToVisible(CGRectMake(0, 0, self.frameEnd.width, self.frameEnd.height), animated: false)
        searchProduct.showLoadingIfNeeded(false)
        searchProduct.brandText = ""
       
        searchProduct.getServiceProduct(resetTable: true)

        searchProduct.dismissCategory()
        popover!.dismissPopoverAnimated(false)
      
        
    }

 
    
    func closeCategory() {
        if closeAnimated {
            self.viewImageContent.alpha = 1
            self.viewImageBgCategory.alpha = 1
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.searchProduct.view.alpha = 0
                //self.btnClose.alpha = 0.0
                }) { (complete:Bool) -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.viewImageContent.frame = CGRectMake(self.frameStart.minX, 0, self.frameStart.width, self.frameStart.height)
                        self.viewImageBgCategory.frame = CGRectMake(-120, 0, 1024 , self.frameStart.height)
                        self.imageIcon.frame = CGRectMake((self.frameStart.width / 2) - 24, 48, 48, 48)
                        self.titleLabel.frame = CGRectMake((self.frameStart.width / 2) - 200, 112, 400, 50)
                        
                        }) { (complete:Bool) -> Void in
                            if complete {
                                self.actionClose?()
                                self.removeFromParentViewController()
                                self.view.removeFromSuperview()
                            }
                    }
            }
        } else {
            self.actionClose?()
        }
    }
    
    
    func showFamilyController() {
        //familyController.departmentId = department
        familyController.families = families
        //familyController.selectedFamily = nil
        familyController.delegate = self
        
        let pointPop =  searchProduct.viewHeader.convertPoint(CGPointMake(self.view.frame.width / 2,  frameStart.height + 40 ), toView:self.view)
        print(pointPop)
        if #available(iOS 8.0, *) {
            familyController.modalPresentationStyle = .Popover
        } else {
            familyController.modalPresentationStyle = .FormSheet
        }
        familyController.preferredContentSize = CGSizeMake(320, 322)
        
        popover = UIPopoverController(contentViewController: familyController)
        popover!.delegate = self
        popover!.presentPopoverFromRect(CGRectMake(self.frameEnd.width / 2, pointPop.y - 254 + 40 , 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        familyController.familyTable.reloadData()
    }
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        searchProduct.dismissCategory()
    }
    
    

    
    
}