//
//  BannerCollectionViewCell.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol BannerCollectionViewCellDelegate: class {
    func bannerDidSelect(_ queryBanner:String,type:String,urlTteaser:String?, bannerName: String)
    func termsSelect(_ url:String)
}

class BannerCollectionViewCell : UICollectionViewCell, UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    
    var currentInterval: TimeInterval = 4.0
    weak var delegate: BannerCollectionViewCellDelegate?
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = 0
    var visibleItem: Int? = 0
    var timmerBanner : Timer!
    var buttonTerms : UIButton!
    var viewTerms : BannerTermsView!
    var banners: [Banner]?
    var loaded = false
    //ale
    var plecaEnd : (() -> Void)? = nil

    var pageViewController : UIPageViewController!
    var nextController : HomeBannerImageViewController! = HomeBannerImageViewController()
    var backController : HomeBannerImageViewController!  = HomeBannerImageViewController()
    var dataSource : [[String:String]]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup() {
        
        if !loaded {
            
            loaded = banners?.count > 0 ? true : false
            self.pointSection = UIView()
            self.pointSection?.frame = CGRect(x: 0, y: self.frame.height - 20 , width: self.frame.width, height: 20)
            self.pointSection?.backgroundColor = UIColor.clear
            buildButtonSection()
            
            pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
            pageViewController.dataSource = self
            pageViewController.delegate = self
            pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            pageViewController.view.backgroundColor = WMColor.light_light_gray
            
            buttonTerms = UIButton(frame: CGRect(x: self.frame.width - 128, y: self.frame.height - 18, width: 120, height: 16))
            buttonTerms.setTitle(NSLocalizedString("home.banner.termsandconditions",comment:""), for: UIControlState())
            buttonTerms.setTitleColor(UIColor.white, for: UIControlState())
            buttonTerms.addTarget(self, action: #selector(BannerCollectionViewCell.termsclick), for: UIControlEvents.touchUpInside)
            buttonTerms.backgroundColor = WMColor.blue
            buttonTerms.layer.cornerRadius = 8
            buttonTerms.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(10)
            buttonTerms.alpha = 0
            
            let currrentController = getCurrentController()
            pageViewController.setViewControllers([currrentController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
            
            self.addSubview(pageViewController.view)
            self.addSubview(self.pointSection!)
            startTimmer()
            
            self.addSubview(buttonTerms)
            self.reloadTermsAndPages()
            
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.currentItem =  viewController.view.tag
        if self.currentItem > 0 {
            self.currentItem = self.currentItem! - 1
        }else {
            self.currentItem = dataSource!.count - 1
            
        }
        return getCurrentController()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) ->
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
            imageController.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BannerCollectionViewCell.tapOnItembanner(_:))))
            
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
        let size = dataSource?.count
        if size > 0 {
            let bsize: CGFloat = 8.0
            var x: CGFloat = 0.0
            let sep: CGFloat = 5.0
            for idx in 0 ..< size! {
                let point = UIButton(type: .custom)
                point.frame = CGRect(x: x, y: 0, width: bsize, height: bsize)
                point.setImage(UIImage(named: "bannerContentOff"), for: UIControlState())
                point.setImage(UIImage(named: "bannerContentOn"), for: .selected)
                point.setImage(UIImage(named: "bannerContentOn"), for: .highlighted)
                point.addTarget(self, action: #selector(BannerCollectionViewCell.pointSelected(_:)), for: .touchUpInside)
                point.isSelected = idx == self.currentItem!
                point.tag = idx
                x = point.frame.maxX
                if idx < size {
                    x += sep
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            let pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRect(x: (pbounds.size.width - x)/2,  y: (20.0 - bsize)/2, width: x, height: 20.0)
        }
        self.pointButtons = buttons
    }
    
    func startTimmer() {
        if dataSource!.count >= 2 {
            if timmerBanner != nil {
                timmerBanner.invalidate()
            }
            timmerBanner = Timer.scheduledTimer(timeInterval: currentInterval, target: self, selector: #selector(BannerCollectionViewCell.changebanner), userInfo: nil, repeats: true)
        }
        
    }

    func stopTimmer() {
        if timmerBanner != nil {
            timmerBanner.invalidate()
        }
    }
    
    func changebanner() {
        self.currentItem = self.visibleItem
        currentItem = currentItem! + 1
        
        if currentItem!  == dataSource?.count {
            currentItem = 0
        }
        
        self.visibleItem = currentItem!
        self.pageViewController.setViewControllers([self.getCurrentController()], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        self.reloadTermsAndPages()
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        stopTimmer()
        if plecaEnd != nil {
            plecaEnd!()
        }

        self.visibleItem = pendingViewControllers[0].view!.tag
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.buttonTerms.alpha =  0
        })
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        startTimmer()
        let currentController = previousViewControllers.last!
            if !completed {
                self.visibleItem = currentController.view.tag
            }else {
                self.visibleItem = pageViewController.viewControllers!.first!.view!.tag
            }
        reloadTermsAndPages()
    }
    
    func reloadTermsAndPages() {
        let array = self.pointButtons! as [Any]
        if array.count > 0 {
            if self.pointButtons!.count != self.visibleItem! {
                if !(self.visibleItem! >= array.count) {
                    if let button = array[self.visibleItem!] as? UIButton {
                        for inner: UIButton in self.pointButtons! {
                            inner.isSelected = button === inner
                        }
                    }
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.buttonTerms.alpha =  self.getCurrentTerms() == "" ? 0 : 1
                    }, completion: { (complete:Bool) -> Void in
                    })
                }
                
            }
            
        }
    }
    
    func tapOnItembanner(_ sender:UITapGestureRecognizer) {
        
        let selectedItem = sender.view!.tag
        let values = self.dataSource![selectedItem]
        if self.banners?.count > 0 {
          if let banner = self.banners?[selectedItem] {
              BaseController.sendAnalyticsClickBanner(banner)
          }
        }
        
        let type = values["type"]
        let queryBanner = values["eventUrl"]
        let teaserUrlPhone = values["teaserUrlPhone"]
        let bannerUrlTablet = values["teaserUrlIpad"]
        
        delegate?.bannerDidSelect(queryBanner!, type: type!,urlTteaser: IS_IPAD ? bannerUrlTablet : teaserUrlPhone, bannerName: values["eventCode"] != nil ? values["eventCode"]! : "")
    }
    
    func isUrl(_ temrs:String)-> Bool{
        var isUrl =  false
        if let url = URL(string: temrs) {
          isUrl =  UIApplication.shared.canOpenURL(url)
        }
        return isUrl
    }
    
    func termsclick() {
        if buttonTerms.isSelected {
            //Close details
            startTimmer()
            
        } else {
            //Open detail
            stopTimmer()
            //getCurrentTerms()
            

                viewTerms = BannerTermsView(frame:self.bounds)
                viewTerms.setup(getCurrentTerms())
                viewTerms.generateBlurImage(self, frame: self.bounds)
                self.addSubview(viewTerms)
                viewTerms.startAnimating()
                viewTerms.openURL = {(urlStr) in
                    if self.isUrl(urlStr){
                        self.delegate?.termsSelect(urlStr)
                    }
                }
                
                viewTerms.onClose = {() in
                    self.termsclick()
                }            
            
        }
        buttonTerms.isSelected  = !buttonTerms.isSelected
    }
    
    func pointSelected(_ sender:UIButton) {
        currentItem = sender.tag == dataSource?.count ? dataSource?.count : (sender.tag - 1)
        changebanner()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        }

}
