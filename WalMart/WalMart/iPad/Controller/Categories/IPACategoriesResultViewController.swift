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
    var families : [[String:Any]]!
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
    var filterMedida: Bool! = false
    var medidaToSearch:String! = ""
    
    var searchContextType: SearchServiceContextType? = nil
    var closeAnimated : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        
        viewImageBgCategory = UIImageView(frame: CGRect(x: -120, y: 0, width: 1024, height: frameStart.height))
        viewImageBgCategory.contentMode = UIViewContentMode.scaleAspectFill
        viewImageBgCategory.image = imgCategory
        viewImageBgCategory.clipsToBounds = true
        
        imageIcon = UIImageView()
        imageIcon.frame = CGRect(x: (self.frameStart.width / 2) - 24, y: 48, width: 48, height: 48)
        imageIcon.image = imgIcon

        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProLightOfSize(25)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: (self.frameStart.width / 2) - 200, y: 112, width: 400, height: 50)
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
       
        searchProduct.view.frame = CGRect(x: 0, y: 0,  width: self.frameEnd.width,  height: self.frameEnd.height)// self.viewContainer.bounds
        
        self.addChildViewController(searchProduct)
        self.view.addSubview(searchProduct.view)
    }
  
    
    func setValues(_ department:String,family:String,line:String, name:String ) {
        self.department = department
        self.family = family
        self.line = line
        self.name = name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimating()
    }
    
    func startAnimating() {
         if CategoryShouldShowFamily.shouldshowfamily {
            CategoryShouldShowFamily.shouldshowfamily = false
            self.searchProduct.view.alpha = 0
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.frame = self.frameEnd
                self.viewImageContent.frame = CGRect(x: 0, y: 0, width: self.frameEnd.width, height: self.viewImageBgCategory.frame.height)
                self.viewImageBgCategory.frame = CGRect(x: 0, y: 0, width: self.frameEnd.width, height: self.viewImageBgCategory.frame.height)
                self.imageIcon.frame = CGRect(x: (self.frameEnd.width / 2) - 24, y: 48, width: 48, height: 48)
                self.titleLabel.frame = CGRect(x: (self.frameEnd.width / 2) - 200, y: 112, width: 400, height: 50)
                
                }, completion: { (complete:Bool) -> Void in
                    //self.btnClose.frame  = CGRectMake(self.frameEnd.width - 100 ,3 ,100,100)
                    if self.searchProduct != nil {
                        self.searchProduct.view.frame = CGRect(x: 0, y: 0,  width: self.frameEnd.width,  height: self.frameEnd.height)
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.searchProduct.view.alpha = 1
                            }, completion: { (complete:Bool) -> Void in
                                if self.viewImageContent != nil {
                                    self.addPopover()
                                    self.viewImageContent.alpha = 0
                                    self.viewImageBgCategory.alpha = 0
                                }
                        }) 
                    }
                   
            }) 
        }
    }
    

    
    func addPopover(){
        familyController =  IPAFamilyViewController()
        
        familyController.departmentId = department
        familyController.families = families
        familyController.selectedFamily = nil
        familyController.delegate = self
       
        familyController.modalPresentationStyle = .popover
        
        familyController.preferredContentSize = CGSize(width: 320, height: 322)
        
        if popover ==  nil {
            popover = UIPopoverController(contentViewController: familyController)
        }
        popover!.delegate = self
        popover!.present(from: CGRect(x: self.frameEnd.width / 2, y: frameStart.height + 40, width: 0, height: 0), in: self.searchProduct.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        searchProduct.setSelectedHeaderCat()
        
        if familyController.familyTable != nil {
            familyController.familyTable.reloadData()
        }
        
    }
    
    func didSelectLine(_ department:String,family:String,line:String, name:String) {
        
        familyController.departmentId = line
        let pointPop =  searchProduct.viewHeader.convert(CGPoint(x: self.view.frame.width / 2,  y: frameStart.height - 40 ), to:self.view)
        searchProduct.loading = WMLoadingView(frame: CGRect(x: 0, y: pointPop.y, width: self.view.bounds.width, height: self.view.bounds.height - pointPop.y))
        
        searchProduct.mgResults!.resetResult()
        searchProduct.grResults!.resetResult()
        searchProduct.allProducts = []
        searchProduct.idFamily  = family
        searchProduct.idDepartment = department
        searchProduct.idLine = line
        searchProduct.titleHeader = name
        if self.filterMedida{
        searchProduct.textToSearch = medidaToSearch
        searchProduct.filterMedida = true
        }else{
        searchProduct.textToSearch = ""
        searchProduct.filterMedida = false
        }

        searchProduct.collection?.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.frameEnd.width, height: self.frameEnd.height), animated: false)
        searchProduct.showLoadingIfNeeded(false)
        searchProduct.brandText = ""
       
        searchProduct.getServiceProduct(resetTable: true)

        searchProduct.dismissCategory()
        popover!.dismiss(animated: false)
      
        
    }

 
    
    func closeCategory() {
        if closeAnimated {
            self.viewImageContent.alpha = 1
            self.viewImageBgCategory.alpha = 1
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.searchProduct.view.alpha = 0
                //self.btnClose.alpha = 0.0
                }, completion: { (complete:Bool) -> Void in
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.viewImageContent.frame = CGRect(x: self.frameStart.minX, y: 0, width: self.frameStart.width, height: self.frameStart.height)
                        self.viewImageBgCategory.frame = CGRect(x: -120, y: 0, width: 1024 , height: self.frameStart.height)
                        self.imageIcon.frame = CGRect(x: (self.frameStart.width / 2) - 24, y: 48, width: 48, height: 48)
                        self.titleLabel.frame = CGRect(x: (self.frameStart.width / 2) - 200, y: 112, width: 400, height: 50)
                        
                        }, completion: { (complete:Bool) -> Void in
                            if complete {
                                self.actionClose?()
                                self.removeFromParentViewController()
                                self.view.removeFromSuperview()
                            }
                    }) 
            }) 
        } else {
            self.actionClose?()
        }
    }
    
    
    func showFamilyController() {
        //familyController.departmentId = department
        familyController.families = families
        //familyController.selectedFamily = nil
        familyController.delegate = self
        
        let pointPop =  searchProduct.viewHeader.convert(CGPoint(x: self.view.frame.width / 2,  y: frameStart.height + 40 ), to:self.view)
        print(pointPop)
        familyController.modalPresentationStyle = .popover
        familyController.preferredContentSize = CGSize(width: 320, height: 322)
        
        popover = UIPopoverController(contentViewController: familyController)
        popover!.delegate = self
        popover!.present(from: CGRect(x: self.frameEnd.width / 2, y: pointPop.y - 254 + 40 , width: 0, height: 0), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        familyController.familyTable.reloadData()
    }
    
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        searchProduct.dismissCategory()
    }
    
    

    
    
}
