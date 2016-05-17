//
//  IPALinesViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 25/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class IPALinesViewController : IPACategoriesResultViewController,IPALinesListViewControllerDelegate{
    
    var lineController : IPALinesListViewController!
    var buttonClose : UIButton!
    var imageBackground : UIImageView!
    var urlTicer : String!
    var linesCamp :[[String:AnyObject]]?
    var familyId : String!
    var loading: WMLoadingView?
 

    override func viewDidLoad() {
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.whiteColor()
        //self.showLoadingView()
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
        
        self.invokeServiceLine { () -> Void in
            
            let lineSelect  = self.linesCamp![0] as NSDictionary
            self.searchProduct = IPASearchCatProductViewController()
            self.searchProduct.searchContextType = self.searchContextType
            self.searchProduct.delegateImgHeader = self
            self.searchProduct.imageBgCategory =  UIImage(named: "header_default")
            self.imageBackground = UIImageView()
            self.imageBackground.setImageWithURL(NSURL(string: "http://\(self.urlTicer)"), placeholderImage:UIImage(named: "header_default"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                self.imageBackground.image = image
                self.searchProduct.imageBgCategory = image
                
                }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    print("Error al presentar imagen")
            }
            self.searchProduct.imageIconCategory = UIImage(named: "default")
            self.searchProduct.titleCategory = ""
            self.searchProduct.idFamily  = "_"
            self.searchProduct.idDepartment = "_"
            self.searchProduct.idLine = lineSelect["id"] as? String
            self.searchProduct.titleHeader = lineSelect["name"] as? String
            self.searchProduct.hiddenBack = true
            self.searchProduct.delegateHeader = self
            self.view.addSubview(self.viewImageContent)
            
            self.searchProduct.view.frame = CGRectMake(0, 0,  self.frameEnd.width,  self.frameEnd.height)
            self.addChildViewController(self.searchProduct)
            self.view.addSubview(self.searchProduct.view)
            self.addPopover()
            
        }
         //self.view.addSubview(viewImageContent)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IPALinesViewController.finisSearch), name: "FINISH_SEARCH", object: nil)

        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRectMake(11, 11, self.view.bounds.width, self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        //super.viewDidAppear(animated)
    }
    
    /**
     Removing animaion loading
     */
    func finisSearch(){
        self.loading!.stopAnnimating()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("::Termina carga de productos de linea::")
    }

    
    /**
     Call lines service
     
     - parameter succesBlock: if succes service, return block
     */
    func invokeServiceLine(succesBlock:(() -> Void)){
        print("familyId::::\(familyId)")
        let service =  LineService()
        service.callService(requestParams:familyId, successBlock: { (response:NSDictionary) -> Void in
            let listLines  =  response["responseArray"] as! NSArray
            print(listLines)
            self.linesCamp = listLines as? [[String : AnyObject]]
            //self.removeLoadingView()
            
           succesBlock()
            }, errorBlock: { (error:NSError) -> Void in
                self.closeCategory()
                print("Error")
        })
        
    }
    
    /**
     Show popover with  lines list
     */
   override func addPopover(){
        lineController =  IPALinesListViewController()
        lineController.departmentId = "0"
        lineController.families = self.linesCamp!
        lineController.selectedFamily = nil
        lineController.delegate = self
        
        
        if #available(iOS 8.0, *) {
            lineController.modalPresentationStyle = .Popover
        } else {
            lineController.modalPresentationStyle = .FormSheet
        }
        lineController.preferredContentSize = CGSizeMake(320, 322)
        
        if popover ==  nil {
            popover = UIPopoverController(contentViewController: lineController)
        }
        popover!.delegate = self
        popover!.presentPopoverFromRect(CGRectMake(self.frameEnd.width / 2,250, 0, 0), inView: self.searchProduct.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        searchProduct.setSelectedHeaderCat()
        
        if lineController.familyTable != nil {
            lineController.familyTable.reloadData()
        }
       self.loading?.stopAnnimating()
        
    }
    /**
     Remove loading and popToRootViewController
     */
    override func closeCategory() {
        self.loading?.stopAnnimating()
        self.navigationController?.popToRootViewControllerAnimated(true)
        self.actionClose?()
        //self.removeFromParentViewController()
        //self.view.removeFromSuperview()
    }
    
    /**
     Open popover with lines lists
     */
    override func showFamilyController() {
        
        lineController.families = self.linesCamp!
        
        let pointPop =  searchProduct.viewHeader.convertPoint(CGPointMake(self.view.frame.width / 2, 245), toView:self.view)
        print(pointPop)
        if #available(iOS 8.0, *) {
            lineController.modalPresentationStyle = .Popover
        } else {
            lineController.modalPresentationStyle = .FormSheet
        }
        lineController.preferredContentSize = CGSizeMake(320, 322)
        
        popover = UIPopoverController(contentViewController: lineController)
        popover!.delegate = self
        popover!.presentPopoverFromRect(CGRectMake(self.frameEnd.width / 2, pointPop.y - 254 + 40 , 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        lineController.familyTable.reloadData()
    }
    
    /**
     Select line in popover and send values to Cat Product View Controller
     
     - parameter department: departmen select
     - parameter family:     family select
     - parameter line:       line select
     - parameter name:       Title
     */
    func didSelectLineList(department:String,family:String,line:String, name:String) {
        
        lineController.departmentId = line
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

    

}