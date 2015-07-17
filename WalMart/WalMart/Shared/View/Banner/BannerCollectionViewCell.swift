//
//  BannerCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

protocol BannerCollectionViewCellDelegate {
    func bannerDidSelect(queryBanner:String,type:String)
}

class BannerCollectionViewCell : UICollectionViewCell, UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    var currentInterval: NSTimeInterval = 4.0
    var delegate: BannerCollectionViewCellDelegate!
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var visibleItem: Int? = nil
    var timmerBanner : NSTimer!
    var buttonTerms : UIButton!
    
    var viewTerms : BannerTermsView!
    
    var pageViewController : UIPageViewController!
    var nextController : HomeBannerImageViewController! = HomeBannerImageViewController()
    var backController : HomeBannerImageViewController!  = HomeBannerImageViewController()
    
    
    var dataSource : [[String:String]]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup() {
        
        self.visibleItem = 0
        self.currentItem = 0
        self.pointSection = UIView()
        self.pointSection?.frame = CGRectMake(0, self.frame.height - 20 , self.frame.width, 20)
        self.pointSection?.backgroundColor = UIColor.clearColor()
        buildButtonSection()
        
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        pageViewController.view.backgroundColor = UIColor.whiteColor()
        
        
        buttonTerms = UIButton(frame: CGRectMake(self.frame.width - 128, self.frame.height - 18, 120, 16))
        buttonTerms.setTitle(NSLocalizedString("home.banner.termsandconditions",comment:""), forState: UIControlState.Normal)
        buttonTerms.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonTerms.addTarget(self, action: "termsclick", forControlEvents: UIControlEvents.TouchUpInside)
        buttonTerms.backgroundColor = WMColor.medium_blue
        buttonTerms.layer.cornerRadius = 8
        buttonTerms.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(10)
        buttonTerms.alpha = 0
        
        
        let currrentController = getCurrentController()
        pageViewController.setViewControllers([currrentController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.addSubview(pageViewController.view)
        self.addSubview(self.pointSection!)
        startTimmer()
        
        self.addSubview(buttonTerms)
       
        self.reloadTermsAndPages()
        
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        self.currentItem =  viewController.view.tag
        if self.currentItem > 0 {
            self.currentItem = self.currentItem! - 1
        }else {
            self.currentItem = dataSource!.count - 1
        }
        return getCurrentController()
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) ->
        UIViewController? {
            self.currentItem =  viewController.view.tag
            if self.currentItem! + 1 < dataSource!.count {
                self.currentItem = self.currentItem! + 1
            }else {
                self.currentItem = 0
            }
            
           return getCurrentController()
    }
    
    func getCurrentController() -> HomeBannerImageViewController {
        
        if dataSource?.count > 0 {
        
            var bannerUrl = ""
            let dictBanner = dataSource![self.currentItem!]
            if let strUrl = dictBanner["urlPhone"]  {
                bannerUrl = strUrl
            }
            if let strUrl = dictBanner["bannerUrlPhone"] {
                bannerUrl = strUrl
            }
            
            let imageController = HomeBannerImageViewController()
            imageController.view.frame = pageViewController.view.bounds
            imageController.setCurrentImage(bannerUrl)
            imageController.view.tag = self.currentItem!
            imageController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapOnItembanner:"))
            
            return imageController
        }
        return HomeBannerImageViewController()
    }
    
    func getCurrentTerms() -> String {
        var terms = ""
        let dictTerms = dataSource![self.visibleItem!]
        if let termsandcond = dictTerms["terms"] {
            terms = termsandcond
        }
        return terms
    }
    
    func buildButtonSection() {
        if let container = self.pointContainer {
            container.removeFromSuperview()
        }
        self.pointContainer = UIView()
        self.pointSection!.addSubview(self.pointContainer!)
        
        var buttons = Array<UIButton>()
        var size = dataSource?.count
        if size > 0 {
            var bsize: CGFloat = 8.0
            var x: CGFloat = 0.0
            var sep: CGFloat = 5.0
            for var idx = 0; idx < size; ++idx {
                var point = UIButton.buttonWithType(.Custom) as UIButton
                point.frame = CGRectMake(x, 0, bsize, bsize)
                point.setImage(UIImage(named: "bannerContentOff"), forState: .Normal)
                point.setImage(UIImage(named: "bannerContentOn"), forState: .Selected)
                point.setImage(UIImage(named: "bannerContentOn"), forState: .Highlighted)
                point.addTarget(self, action: "pointSelected:", forControlEvents: .TouchUpInside)
                point.selected = idx == self.currentItem!
                x = CGRectGetMaxX(point.frame)
                if idx < size {
                    x += sep
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            var pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRectMake((pbounds.size.width - x)/2,  (20.0 - bsize)/2, x, 20.0)
        }
        self.pointButtons = buttons
    }
    
       
    
    func startTimmer() {
        if dataSource!.count >= 2 {
            if timmerBanner != nil {
                timmerBanner.invalidate()
            }
            timmerBanner = NSTimer.scheduledTimerWithTimeInterval(currentInterval, target: self, selector: "changebanner", userInfo: nil, repeats: true)
        }
        
    }
    func stopTimmer() {
        if timmerBanner != nil {
            timmerBanner.invalidate()
        }
    }
    
    func changebanner() {
        var newItem = ++currentItem!
        if currentItem!  == dataSource?.count {
            currentItem = 0
            newItem = 0
        }
        self.visibleItem = currentItem!
        self.pageViewController.setViewControllers([self.getCurrentController()], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
      
       
        self.reloadTermsAndPages()
    }

    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]){
        stopTimmer()
        self.visibleItem = pendingViewControllers[0].view!!.tag
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.buttonTerms.alpha =  0
        })
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        startTimmer()
        if let currentController = previousViewControllers.last as? UIViewController {
            if !completed {
                self.visibleItem = currentController.view.tag
            }else {
                self.visibleItem = pageViewController.viewControllers.first!.view!!.tag
            }
        }
        reloadTermsAndPages()
    }
    
    func reloadTermsAndPages() {
        let nsarray = self.pointButtons! as NSArray
        if nsarray.count > 0 {
            if let button = nsarray.objectAtIndex(self.visibleItem!) as? UIButton {
                for inner: UIButton in self.pointButtons! {
                    inner.selected = button === inner
                }
            }
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.buttonTerms.alpha =  self.getCurrentTerms() == "" ? 0 : 1
                }) { (complete:Bool) -> Void in
            }
        }
    }
    
    
    func tapOnItembanner(sender:UITapGestureRecognizer) {
        
        let selectedItem = sender.view!.tag
        let values = self.dataSource![selectedItem]
        
        let type = values["type"]
        let queryBanner = values["eventUrl"]
        
        delegate.bannerDidSelect(queryBanner!, type: type!)
    }
    
    
    func termsclick() {
        if buttonTerms.selected {
            //Close details
            startTimmer()
            
        } else {
            //Open detail
            stopTimmer()
            
            
            viewTerms = BannerTermsView(frame:self.bounds)
            viewTerms.setup(getCurrentTerms())
            viewTerms.generateBlurImage(self, frame: self.bounds)
            self.addSubview(viewTerms)
            viewTerms.startAnimating()
            viewTerms.onClose = {() in
                self.termsclick()
            }
        }
        buttonTerms.selected  = !buttonTerms.selected
    }
    
    
    
}