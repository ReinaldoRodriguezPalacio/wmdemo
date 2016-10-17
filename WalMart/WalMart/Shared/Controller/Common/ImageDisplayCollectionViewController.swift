//
//  ImageDisplayCollectionViewController.swift
//  WalMart
//
//  Created by neftali on 21/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class ImageDisplayCollectionViewController: BaseController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let reuseIdentifier = "Cell"
    var collectionView: UICollectionView?
    var collectionFlowLayout: UICollectionViewFlowLayout?
    var close: UIButton?
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var imagesToDisplay: [AnyObject]?
    var index : Int = 0
    var header: UIView? = nil
    var titleLabel: UILabel? = nil
    var name: String? = nil
    var type: String! = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_ZOOMPRODUCTDETAIL.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.collectionFlowLayout =  UICollectionViewFlowLayout()
        self.collectionFlowLayout!.minimumInteritemSpacing = 0.0
        self.collectionFlowLayout!.minimumLineSpacing = 0.0
        self.collectionFlowLayout!.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.collectionFlowLayout!.scrollDirection = .Horizontal
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionFlowLayout!)
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.showsVerticalScrollIndicator = false
        self.collectionView!.pagingEnabled = true
        self.collectionView!.registerClass(ImageDisplayCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        
        self.view.addSubview(self.collectionView!)
        
        self.pointSection = UIView()
        self.pointSection!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.pointSection!)
        
        self.header = UIView()
        self.header?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.header!)
        
        self.close = UIButton(type: .Custom)
        self.close!.setImage(UIImage(named: "detail_close"), forState: .Normal)
        self.close!.addTarget(self, action: #selector(ImageDisplayCollectionViewController.closeModal), forControlEvents: .TouchUpInside)
        self.close!.backgroundColor = UIColor.whiteColor()
        
        self.titleLabel = UILabel()
        self.titleLabel?.textColor =  WMColor.light_blue
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel?.text = name
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.header?.addSubview(self.titleLabel!)
        self.header?.addSubview(self.close!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.frame.size
        self.header!.frame = CGRectMake(0, 0, self.view.bounds.maxX, 66)
        self.collectionView!.frame = CGRectMake(0.0, self.header!.frame.maxY, bounds.width, bounds.height - self.header!.frame.maxY - self.pointSection!.frame.height)
        self.pointSection?.frame = CGRectMake(0, bounds.height - 46 , bounds.width, 46)
        self.close!.frame = CGRectMake(0.0, 20, 40.0, 40.0)
        self.titleLabel!.frame =  CGRectMake(40.0 , 20, bounds.width - 40 , 46)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      
        self.buildButtonSection()
    }

    func buildButtonSection() {
        if let container = self.pointContainer {
            container.removeFromSuperview()
        }
        self.pointContainer = UIView()
        self.pointSection!.addSubview(self.pointContainer!)
        
        var selectedButton: UIButton? = nil
        var buttons = Array<UIButton>()
        let size = imagesToDisplay?.count
        if size > 0 {
            let bsize: CGFloat = 8.0
            var x: CGFloat = 0.0
            let sep: CGFloat = 5.0
            for idx in 0 ..< size! {
                let point = UIButton(type: .Custom)
                point.frame = CGRectMake(x, 0, bsize, bsize)
                point.setImage(UIImage(named: "bannerContentOff"), forState: .Normal)
                point.setImage(UIImage(named: "bannerContentOn"), forState: .Selected)
                point.setImage(UIImage(named: "bannerContentOn"), forState: .Highlighted)
                point.addTarget(self, action: #selector(ImageDisplayCollectionViewController.pointSelected(_:)), forControlEvents: .TouchUpInside)
                point.selected = idx == self.currentItem!
                x = CGRectGetMaxX(point.frame)
                if idx < size {
                    x += sep
                }
                
                if idx == self.currentItem{
                    selectedButton = point
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            let pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRectMake((pbounds.size.width - x)/2,  (20.0 - bsize)/2, x, 20.0)
        }
      
        self.pointButtons = buttons
        //self.collectionView!.reloadData()
        
        if selectedButton == nil{
            selectedButton = self.pointButtons![0] as UIButton
        }
        
        pointSelected(selectedButton!)
    }
    
    func pointSelected(sender:UIButton) {
        for button: UIButton in self.pointButtons! {
            button.selected = button === sender
        }
        if let idx = (self.pointButtons!).indexOf(sender) {
            self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: idx, inSection: 0),
                atScrollPosition: .CenteredHorizontally, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = self.collectionView!.contentOffset.x / self.collectionView!.frame.size.width
        self.currentItem = Int(currentIndex)
        let nsarray = self.pointButtons! as NSArray
        if let button = nsarray.objectAtIndex(self.currentItem!) as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.selected = button === inner
            }
        }
    }
    
    // MARK: - Actionw
    func closeModal() {
        self.dismissViewControllerAnimated(true, completion: nil)
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ZOOMPRODUCTDETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ZOOMPRODUCTDETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK_PRODUCTDETAIL.rawValue, label: "")
    }
    

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var size = 0
        if let count = self.imagesToDisplay?.count {
            size = count
        }
        return size
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageDisplayCollectionViewCell
        
        var indexView = indexPath.row
        
        if self.pointContainer == nil{
            indexView = self.currentItem!
        }
        
        if let image = self.imagesToDisplay![indexView] as? UIImage {
            cell.setImageToDisplay(image)
        }
        else if let url = self.imagesToDisplay![indexView] as? String {
            cell.setImageUrlToDisplay(url)
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.collectionView!.frame.size
    }
    
    func selectFirstPoint(){
        if self.pointButtons?.count > 0{
            pointSelected(self.pointButtons!.first! as UIButton)
            self.currentItem = 0
        }
    }
    
//    override func supportedInterfaceOrientations() -> Int {
//        let rotation = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? UIInterfaceOrientationMask.Portrait : UIInterfaceOrientationMask.Landscape
//        return Int(rotation.rawValue)
//        
//    }

}
