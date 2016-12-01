//
//  ImageDisplayCollectionViewController.swift
//  WalMart
//
//  Created by neftali on 21/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
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


class ImageDisplayCollectionViewController: BaseController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let reuseIdentifier = "Cell"
    var collectionView: UICollectionView?
    var collectionFlowLayout: UICollectionViewFlowLayout?
    var close: UIButton?
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var pointButtons: [UIButton]? = nil
    var currentItem: Int? = nil
    var imagesToDisplay: [Any]?
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
        self.collectionFlowLayout!.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionFlowLayout!)
        self.collectionView!.backgroundColor = UIColor.white
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.showsVerticalScrollIndicator = false
        self.collectionView!.isPagingEnabled = true
        self.collectionView!.register(ImageDisplayCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        
        self.view.addSubview(self.collectionView!)
        
        self.pointSection = UIView()
        self.pointSection!.backgroundColor = UIColor.white
        self.view.addSubview(self.pointSection!)
        
        self.header = UIView()
        self.header?.backgroundColor = UIColor.white
        self.view.addSubview(self.header!)
        
        self.close = UIButton(type: .custom)
        self.close!.setImage(UIImage(named: "detail_close"), for: UIControlState())
        self.close!.addTarget(self, action: #selector(ImageDisplayCollectionViewController.closeModal), for: .touchUpInside)
        self.close!.backgroundColor = UIColor.white
        
        self.titleLabel = UILabel()
        self.titleLabel?.textColor =  WMColor.light_blue
        self.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.titleLabel!.numberOfLines = 2
        self.titleLabel?.text = name
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.header?.addSubview(self.titleLabel!)
        self.header?.addSubview(self.close!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.frame.size
        self.header!.frame = CGRect(x: 0, y: 0, width: self.view.bounds.maxX, height: 66)
        self.collectionView!.frame = CGRect(x: 0.0, y: self.header!.frame.maxY, width: bounds.width, height: bounds.height - self.header!.frame.maxY - self.pointSection!.frame.height)
        self.pointSection?.frame = CGRect(x: 0, y: bounds.height - 46 , width: bounds.width, height: 46)
        self.close!.frame = CGRect(x: 0.0, y: 20, width: 40.0, height: 40.0)
        self.titleLabel!.frame =  CGRect(x: 40.0 , y: 20, width: bounds.width - 40 , height: 46)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                let point = UIButton(type: .custom)
                point.frame = CGRect(x: x, y: 0, width: bsize, height: bsize)
                point.setImage(UIImage(named: "bannerContentOff"), for: UIControlState())
                point.setImage(UIImage(named: "bannerContentOn"), for: .selected)
                point.setImage(UIImage(named: "bannerContentOn"), for: .highlighted)
                point.addTarget(self, action: #selector(ImageDisplayCollectionViewController.pointSelected(_:)), for: .touchUpInside)
                point.isSelected = idx == self.currentItem!
                x = point.frame.maxX
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
            self.pointContainer!.frame = CGRect(x: (pbounds.size.width - x)/2,  y: (20.0 - bsize)/2, width: x, height: 20.0)
        }
      
        self.pointButtons = buttons
        //self.collectionView!.reloadData()
        
        if selectedButton == nil{
            selectedButton = self.pointButtons![0] as UIButton
        }
        
        pointSelected(selectedButton!)
    }
    
    func pointSelected(_ sender:UIButton) {
        for button: UIButton in self.pointButtons! {
            button.isSelected = button === sender
        }
        if let idx = (self.pointButtons!).index(of: sender) {
            self.collectionView!.scrollToItem(at: IndexPath(item: idx, section: 0),
                at: .centeredHorizontally, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = self.collectionView!.contentOffset.x / self.collectionView!.frame.size.width
        self.currentItem = Int(currentIndex)
        let array = self.pointButtons! as [Any]
        if let button = array[self.currentItem!] as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.isSelected = button === inner
            }
        }
    }
    
    // MARK: - Actionw
    func closeModal() {
        self.dismiss(animated: true, completion: nil)
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ZOOMPRODUCTDETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ZOOMPRODUCTDETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_BACK_PRODUCTDETAIL.rawValue, label: "")
    }
    

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var size = 0
        if let count = self.imagesToDisplay?.count {
            size = count
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageDisplayCollectionViewCell
        
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
