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
    
    override func viewDidLoad() {
      self.view.backgroundColor =  UIColor.whiteColor()

        imageBackground = UIImageView()
        imageBackground.contentMode = UIViewContentMode.Left
        imageBackground.clipsToBounds = true
        
        self.imageBackground.setImageWithURL(NSURL(string: "http://\(urlTicer)"), placeholderImage:UIImage(named: "header_default"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageBackground.image = image
            }) { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
             print("Error al presentar imagen")
        }
    
        imageIcon = UIImageView()
        imageIcon.image = UIImage(named: "default")
        
        
        titleLabel = UILabel()
        titleLabel.font  = WMFont.fontMyriadProRegularOfSize(16)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.text = ""
        
        buttonClose = UIButton()
        buttonClose.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: "closeDepartment", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(imageBackground)
        self.view.addSubview(imageIcon)
        self.view.addSubview(titleLabel)
        self.view.addSubview(buttonClose)
        
        

        self.viewFamily = UIView()
        self.lineController = LineViewController()
        self.lineController.categoriesType = .CategoryForMG
        self.addChildViewController(self.lineController)
        self.viewFamily.addSubview(self.lineController.view)        
        self.invokeServiceLine()
    }
    
    
    override func viewWillLayoutSubviews() {
        viewFamily.frame = CGRectMake(0, CELL_HEIGHT, self.view.bounds.width, self.view.bounds.height - CELL_HEIGHT)
       // lineController.view.frame = viewFamily.frame
        
        self.imageBackground.frame = CGRectMake(0,0 ,self.view.frame.width , CELL_HEIGHT)
        titleLabel.frame = CGRectMake(0, 66, self.view.frame.width , 16)
        imageIcon.frame = CGRectMake((self.view.frame.width / 2) - 14, 22 , 28, 28)
        buttonClose.frame = CGRectMake(0, 0, 40, 40)
    }
    
    var linesCamp :[[String:AnyObject]]?
    
    func invokeServiceLine(){
        print("familyName :::\(familyName)")
        let service =  LineService()
        
        service.callService(requestParams: familyName, successBlock: { (response:NSDictionary) -> Void in
            let listLines  =  response["responseArray"] as! NSArray
            print(listLines)
            self.linesCamp = listLines as? [[String : AnyObject]]
            self.didSelectDeparmentAtIndex(NSIndexPath(index: 0))
           
            }, errorBlock: { (error:NSError) -> Void in
                print("Error")
        })
    
    }
    
    
    override func didSelectDeparmentAtIndex(indexPath: NSIndexPath){
        
        lineController.departmentId = "0"
        lineController.families = self.linesCamp!
        lineController.selectedFamily = nil
        lineController.familyTable.reloadData()
        self.viewFamily.alpha = 1
        self.view.addSubview(self.viewFamily)
       
        
    }
    override func closeDepartment() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
}
