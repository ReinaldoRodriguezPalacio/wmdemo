//
//  ProductDetailPageViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 9/1/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class ProductDetailPageViewController : IPOBaseController,UIPageViewControllerDataSource,UIPageViewControllerDelegate {
 
    var pageController : UIPageViewController!
    var ixSelected : Int = 0
    var ixAfterSelected : Int = 0
    var itemsToShow : [AnyObject] = []
    var storyBoard : UIStoryboard? = nil
    var countAfterBefore : Int = 0
    var ctrlToShow : UIViewController!
    var isForSeach:Bool = false
    var idListSeleted : String? = ""
    var stringSearching = ""
    var itemSelectedSolar : String = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.pageController.view.frame = self.view.bounds
        
        let selected = itemsToShow[ixSelected] as! NSDictionary
        let upc = selected["upc"] as! String
        let name = selected["description"] as! String
        let type = selected["type"] as! String
        let saving = selected["saving"] as? String
        
        let ctrlToShow  = self.getControllerToShow(upc,descr:name,type:type,saving:saving)
        if ctrlToShow != nil {
            self.pageController.setViewControllers([ctrlToShow!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        self.addChildViewController(self.pageController)
        self.view.addSubview(self.pageController.view)
        self.pageController.didMoveToParentViewController(self)
      
    }
    
    override func viewWillLayoutSubviews() {

        self.pageController.view.frame = self.view.bounds
    }
    
    
    func getControllerToShow(upc:String,descr:String,type:String) -> UIViewController? {
       return self.getControllerToShow(upc, descr: descr, type: type, saving: "")
    }
    /**
     validate type product and present detail gr or mg, recived parameters necesary
     
     - parameter upc:    upc to search
     - parameter descr:  description product
     - parameter type:   typye product mg or gr
     - parameter saving: saving
     
     - returns: ProductDetailViewController mg or gr
     */
    func getControllerToShow(upc:String,descr:String,type:String,saving:String?) -> UIViewController? {
        storyBoard = loadStoryboardDefinition()
        switch(type) {
        case ResultObjectType.Mg.rawValue :
            if let vc = storyBoard!.instantiateViewControllerWithIdentifier("productDetailVC") as? ProductDetailViewController {
                vc.upc = upc
                vc.indexRowSelected = self.itemSelectedSolar
                vc.stringSearching = self.stringSearching
                vc.name = descr
                vc.fromSearch =  self.isForSeach
                vc.view.tag = ixSelected
                
                
                return vc
            }
        case ResultObjectType.Groceries.rawValue :
                if let vc = storyBoard!.instantiateViewControllerWithIdentifier("productDetailVC") as? ProductDetailViewController {
                    vc.upc = upc
                    vc.indexRowSelected = self.itemSelectedSolar
                    vc.stringSearching =  self.stringSearching
                    vc.fromSearch =  self.isForSeach
                    vc.name = descr
                    vc.saving = saving == nil ? "" : saving!
                    vc.view.tag = ixSelected
                    vc.idListFromlistFind = self.idListSeleted! // new
                   
                    return vc
            }
        default:
            return nil
        }
        return nil
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.HideBar.rawValue, object: nil)
        
    }
    
    //MARK: PageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        ixSelected =  viewController.view.tag
        if ixSelected > 0 {
            ixSelected = ixSelected - 1
            
            let selected = itemsToShow[ixSelected] as! NSDictionary
            let upc = selected["upc"] as! String
            let name = selected["description"] as! String
            let type = selected["type"] as! String
            //let saving = selected["saving"] as? String
            
            let controllerBefore = getControllerToShow(upc,descr:name,type:type)
            return controllerBefore
        }
        return nil
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        ixSelected =  viewController.view.tag
        if ixSelected + 1 < itemsToShow.count {
            ixSelected = ixSelected + 1
            
            let selected = itemsToShow[ixSelected] as! NSDictionary
            let upc = selected["upc"] as! String
            let name = selected["description"] as! String
            let type = selected["type"] as! String
            //let saving = selected["saving"] as? String
            
            let controllerBefore = getControllerToShow(upc,descr:name,type:type)

            return controllerBefore
        }
        return nil
    }
    
    
    
    /**
     enable or disable gesture
     
     - parameter enabled: active or no gesture true/false
     */
    func enabledGesture(enabled:  Bool ) {
        for recognizer in pageController.gestureRecognizers {
             let rec = recognizer
             rec.enabled = enabled;
        }
        
        for recognizer in pageController.view.subviews {
            if let view = recognizer as? UIScrollView {
                view.scrollEnabled = enabled;
            }
        }
        
    }
    
    
}