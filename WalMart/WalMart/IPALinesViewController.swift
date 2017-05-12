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
    var linesCamp :[[String:Any]]?
    var familyId : String!
    var loading: WMLoadingView?
    var timmer: Timer?
 

    override func viewDidLoad() {
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor.white
        //self.showLoadingView()
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
        
        
        self.invokeServiceLine { () -> Void in
            self.buttonClose?.isHidden = true
            let lineSelect  = self.linesCamp![0] as [String:Any]
            self.searchProduct = IPASearchCatProductViewController()
            self.searchProduct.searchContextType = self.searchContextType
            self.searchProduct.delegateImgHeader = self
            self.searchProduct.imageBgCategory =  UIImage(named: "header_default")
            self.imageBackground = UIImageView()
            self.imageBackground.setImage(with: URL(string: "http://\(self.urlTicer!)")!, and: UIImage(named:"header_default"), success: { (image) in
                self.searchProduct.imageBgCategory = image
            }, failure: {})
            self.searchProduct.imageIconCategory = UIImage(named: "default")
            self.searchProduct.titleCategory = ""
            self.searchProduct.idFamily  = "_"
            self.searchProduct.idDepartment = "_"
            self.searchProduct.idLine = lineSelect["id"] as? String
            self.searchProduct.titleHeader = lineSelect["name"] as? String
            self.searchProduct.hiddenBack = true
            self.searchProduct.delegateHeader = self
            self.view.addSubview(self.viewImageContent)
            
            self.searchProduct.view.frame = CGRect(x: 0, y: 0,  width: self.frameEnd.width,  height: self.frameEnd.height)
            self.addChildViewController(self.searchProduct)
            self.view.addSubview(self.searchProduct.view)
            self.addPopover()
            
        }
         //self.view.addSubview(viewImageContent)
        NotificationCenter.default.addObserver(self, selector: #selector(IPALinesViewController.finisSearch), name: NSNotification.Name(rawValue: "FINISH_SEARCH"), object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 11, y: 11, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(animated)
    }
    
    /**
     Removing animaion loading
     */
    func finisSearch(){
        self.loading!.stopAnnimating()
        print("::Termina carga de productos de linea::")
    }

    
    /**
     Call lines service
     
     - parameter succesBlock: if succes service, return block
     */
    func invokeServiceLine(_ succesBlock:@escaping (() -> Void)){
        print("familyId::::\(familyId)")
        let service =  LineService()
        service.callService(requestParams:familyId as AnyObject, successBlock: { (response:[String:Any]) -> Void in
            let listLines  =  response["responseArray"] as! [Any]
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
        lineController.modalPresentationStyle = .popover
        
        lineController.preferredContentSize = CGSize(width: 320, height: 322)
        
        if popover ==  nil {
            popover = UIPopoverController(contentViewController: lineController)
        }
        popover!.delegate = self
        timmer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(IPALinesViewController.openPopover), userInfo: nil, repeats: false)
        searchProduct.setSelectedHeaderCat()
        
        if lineController.familyTable != nil {
            lineController.familyTable.reloadData()
        }
       //self.buttonClose?.hidden = false
    }
    
    func openPopover() {
        self.popover!.present(from: CGRect(x: self.frameEnd.width / 2,y: 250, width: 0, height: 0), in: self.searchProduct.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        self.loading?.stopAnnimating()
    }
    
    /**
     Remove loading and popToRootViewController
     */
    override func closeCategory() {
        self.timmer?.invalidate()
        self.loading?.stopAnnimating()
        self.popover?.dismiss(animated: false)
        self.popover = nil
        let _ = self.navigationController?.popToRootViewController(animated: true)
        self.actionClose?()
        //self.removeFromParentViewController()
        //self.view.removeFromSuperview()
    }
    
    /**
     Open popover with lines lists
     */
    override func showFamilyController() {
        
        lineController.families = self.linesCamp!
        
        let pointPop =  searchProduct.viewHeader.convert(CGPoint(x: self.view.frame.width / 2, y: 245), to:self.view)
        print(pointPop)
        lineController.modalPresentationStyle = .popover
        
        //lineController.preferredContentSize = CGSizeMake(320, 322)
        
        popover = UIPopoverController(contentViewController: lineController)
        popover!.delegate = self
        popover!.present(from: CGRect(x: self.frameEnd.width / 2,y: 250, width: 0, height: 0), in: self.searchProduct.view, permittedArrowDirections: UIPopoverArrowDirection.up, animated: true)
        lineController.familyTable.reloadData()
        lineController.familyTable.contentSize =  CGSize(width: 320, height: CGFloat(((self.linesCamp?.count)!) * 46))
     
    }
    
    /**
     Select line in popover and send values to Cat Product View Controller
     
     - parameter department: departmen select
     - parameter family:     family select
     - parameter line:       line select
     - parameter name:       Title
     */
    func didSelectLineList(_ department:String,family:String,line:String, name:String) {
        lineController.departmentId = line
        let pointPop =  searchProduct.viewHeader.convert(CGPoint(x: self.view.frame.width / 2,  y: frameStart.height - 40 ), to:self.view)
        searchProduct.loading = WMLoadingView(frame: CGRect(x: 0, y: pointPop.y, width: self.view.bounds.width, height: self.view.bounds.height - pointPop.y))
        
        searchProduct.mgResults!.resetResult()
        searchProduct.grResults!.resetResult()
        searchProduct.allProducts = []
        searchProduct.idFamily  = family
        searchProduct.idDepartment = department
        searchProduct.idLine = line
        searchProduct.titleHeader = name
        
        searchProduct.collection?.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.frameEnd.width, height: self.frameEnd.height), animated: false)
        searchProduct.showLoadingIfNeeded(false)
        searchProduct.brandText = ""
        
        searchProduct.getServiceProduct(resetTable: true)
        
        searchProduct.dismissCategory()
        popover!.dismiss(animated: false)
    }

    

}
