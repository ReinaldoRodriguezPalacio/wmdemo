//
//  IPOLinesViewController.swift
//  WalMart
//
//  Created by Joel Juarez on 25/02/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPOLinesViewController : IPOCategoriesViewController {

    var lineController : LineViewController!
    var buttonClose : UIButton!
    var imageBackground : UIImageView!
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    var urlTicer : String!
    var familyName : String!
    var loading: WMLoadingView?
    var linesCamp :[[String:Any]]?

    override func viewDidLoad() {
      self.view.backgroundColor =  UIColor.white

        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.left
        imageBackground.clipsToBounds = true
        
        self.imageBackground.setImageWith(URL(string: "http://\(urlTicer)"), placeholderImage:UIImage(named: "header_default"), success: { (request:URLRequest?, response:HTTPURLResponse?, image:UIImage?) -> Void in
            self.imageBackground.image = image
            }) { (request:URLRequest?, response:HTTPURLResponse?, error:Error?) -> Void in
             print("Error al presentar imagen")
        }
    
        imageIcon = UIImageView()
        imageIcon.image = UIImage(named: "default")
        
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(16)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.text = ""
        
        buttonClose = UIButton()
        buttonClose.setImage(UIImage(named: "close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(BaseCategoryViewController.closeDepartment), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(imageBackground)
        self.view.addSubview(imageIcon)
        self.view.addSubview(titleLabel)
        self.view.addSubview(buttonClose)
        
        

        self.viewFamily = UIView()
        self.lineController = LineViewController()
        self.lineController.categoriesType = .categoryForMG
        self.addChildViewController(self.lineController)
        self.viewFamily.addSubview(self.lineController.view)        
        self.invokeServiceLine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.loading == nil {
            self.loading = WMLoadingView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 46))
            self.loading!.backgroundColor = UIColor.white
            self.view.addSubview(self.loading!)
            self.loading!.startAnnimating(self.isVisibleTab)
        }
    }


    override func viewWillLayoutSubviews() {
        viewFamily.frame = CGRect(x: 0, y: CELL_HEIGHT, width: self.view.bounds.width, height: self.view.bounds.height - CELL_HEIGHT)
       // lineController.view.frame = viewFamily.frame
        
        self.imageBackground.frame = CGRect(x: 0,y: 0 ,width: self.view.frame.width , height: CELL_HEIGHT)
        titleLabel.frame = CGRect(x: 0, y: 66, width: self.view.frame.width , height: 16)
        imageIcon.frame = CGRect(x: (self.view.frame.width / 2) - 14, y: 22 , width: 28, height: 28)
        buttonClose.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    }
    
    
    /**
     Call lines service
     */
    func invokeServiceLine(){
        print("familyName :::\(familyName)")
        let service =  LineService()
        
        service.callService(requestParams: familyName as AnyObject, successBlock: { (response:[String:Any]) -> Void in
            let listLines  =  response["subCategories"] as! [[String:Any]]
            print(listLines)
            self.linesCamp = listLines as? [[String : AnyObject]]
            self.didSelectDeparmentAtIndex(IndexPath(index: 0))
           
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
                self.navigationController?.popToRootViewController(animated: true)
                
        })
    
    }
    
    /**
     
     Load family select in this case is from banner tap
     - parameter indexPath: Department selected, in this case not use
     */
    override func didSelectDeparmentAtIndex(_ indexPath: IndexPath){
        lineController.departmentId = "0"
        lineController.families = self.linesCamp!
        lineController.selectedFamily = nil
        lineController.familyTable.reloadData()
        self.viewFamily.alpha = 1
        self.view.addSubview(self.viewFamily)
        self.loading!.stopAnnimating()
        
    }
    
    /**
     Return to home
     */
    override func closeDepartment() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}
