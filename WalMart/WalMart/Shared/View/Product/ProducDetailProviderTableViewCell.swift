//
//  ProducDetailProviderTableViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 30/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol ProducDetailProviderTableViewCellDelegate: class {
    func selectOffer(offer: [String:Any])
}

class ProducDetailProviderTableViewCell : UITableViewCell {
    
    
//    var titleLabel = UILabel()
//    var switchBtn = UIButton()
    var segmentedControl = UISegmentedControl()
    var collection: UICollectionView!
    var border: CALayer!
    var providerNewItems: [[String:Any]]! = []
    var providerReconditionedItems: [[String:Any]]! = []
    var showNewItems = true
    var selectedOfferId: String = ""
    weak var delegate: ProducDetailProviderTableViewCellDelegate?
    
    var itemsProvider: [[String:Any]] = [] {
        didSet {
            self.grupProvidersByType()
            self.collection.reloadData()
            let cell = collection.cellForItem(at: IndexPath(row: 0, section: 0))
            cell?.isSelected = true
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.removeSubViews()
        
//        titleLabel.text = "Artículo nuevo vendido por" //NSLocalizedString("productdetail.related",comment:"")
//        titleLabel.font =  WMFont.fontMyriadProLightOfSize(14)
//        titleLabel.numberOfLines = 1
//        titleLabel.textAlignment = .left
//        titleLabel.textColor = WMColor.light_blue
//        self.addSubview(titleLabel)
//        
//        switchBtn.setTitle("reacondicionados", for: .normal)
//        switchBtn.titleLabel?.font =  WMFont.fontMyriadProLightOfSize(12)
//        switchBtn.setTitleColor(UIColor.white, for: .normal)
//        switchBtn.backgroundColor = WMColor.light_blue
//        switchBtn.layer.cornerRadius = 8.0
//        switchBtn.addTarget(self, action: #selector(switchProviders), for: .touchUpInside)
//        switchBtn.frame = CGRect(x: self.bounds.width - 120, y: 16, width: 104, height: 16.0)
//        self.bringSubview(toFront: switchBtn)
//        self.addSubview(switchBtn)
        
        let segmentedTitleAttributes = [NSFontAttributeName:WMFont.fontMyriadProLightOfSize(11),NSForegroundColorAttributeName:UIColor.white] as [String : Any]
        let segmentedTitleAttributesDis = [NSFontAttributeName:WMFont.fontMyriadProLightOfSize(11),NSForegroundColorAttributeName:WMColor.light_blue] as [String : Any]
        let segmentedTitleAttributesNormal = [NSFontAttributeName:WMFont.fontMyriadProLightOfSize(11),NSForegroundColorAttributeName:WMColor.light_blue] as [String : Any]
        
        segmentedControl = UISegmentedControl(items: ["Nuevos", "Reacondicionados"])
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.tintColor = WMColor.light_blue
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(switchProviders), for: .valueChanged)
        segmentedControl.layer.cornerRadius = 11
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.borderColor = WMColor.light_blue.cgColor
        segmentedControl.layer.masksToBounds = true
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributesNormal, for: UIControlState())
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributes, for: .highlighted)
        segmentedControl.setTitleTextAttributes(segmentedTitleAttributesDis, for: .disabled)
        self.addSubview(segmentedControl)
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collection = UICollectionView(frame: self.bounds, collectionViewLayout: collectionLayout)
        collection.register(ProviderViewCell.self, forCellWithReuseIdentifier: "providerViewCell")
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = false
        collection.backgroundColor = UIColor.white
        self.addSubview(collection)
        
        self.border = CALayer()
        self.border.backgroundColor = WMColor.light_light_gray.cgColor
        self.layer.insertSublayer(border, at: 99)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        titleLabel.frame = CGRect(x: 16, y: 16, width: self.bounds.width - 32, height: 16)
        segmentedControl.frame = CGRect(x: self.frame.width - 220, y: 16, width: 204, height: 22)
        collection.frame = CGRect(x: 16, y: 56.0, width: self.bounds.width - 32, height: 92)
        border.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.size.width, height: 1)
    }
    
//    func switchProviders() {
//        if self.switchBtn.isSelected {
//            switchBtn.setTitle("reacondicionados", for: .normal)
//            titleLabel.text = "Artículo nuevo vendido por"
//            switchBtn.frame = CGRect(x: self.bounds.width - 120, y: 16, width: 104, height: 16.0)
//            showNewItems = true
//        }else{
//            switchBtn.setTitle("nuevos", for: .normal)
//            titleLabel.text = "Artículo reacondicionado vendido por"
//            switchBtn.frame = CGRect(x: self.bounds.width - 76, y: 16, width: 60, height: 16.0)
//            showNewItems = false
//        }
//        
//        self.collection.reloadData()
//        self.switchBtn.isSelected = !self.switchBtn.isSelected
//    }
    
    func switchProviders() {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            showNewItems = true
        case 1:
            showNewItems = false
        default:
            showNewItems = true
        }
        
        self.collection.reloadData()
    }
    
    func grupProvidersByType(){
        self.providerNewItems = []
        self.providerReconditionedItems = []
        
        for offer in itemsProvider {
            let condiiton = offer["condition"] as! String
            if condiiton == "1" {
                self.providerNewItems.append(offer)
            }else{
                self.providerReconditionedItems.append(offer)
            }
        }
        
        if providerReconditionedItems.count == 0 {
            segmentedControl.isHidden = false
            segmentedControl.setEnabled(false, forSegmentAt: 1)
            segmentedControl.setEnabled(true, forSegmentAt: 0)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.layer.borderWidth = 0
            segmentedControl.layer.borderColor = WMColor.empty_gray_btn.cgColor
            
            disableSegmented(index: 0)
            self.showNewItems = true
        }else if providerNewItems.count == 0 {
            segmentedControl.isHidden = false
            segmentedControl.setEnabled(false, forSegmentAt: 0)
            segmentedControl.setEnabled(true, forSegmentAt: 1)
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.layer.borderWidth = 0
            segmentedControl.layer.borderColor = WMColor.empty_gray_btn.cgColor
            
            disableSegmented(index: 1)
            self.showNewItems = false
        }
        
        self.segmentedControl.selectedSegmentIndex = self.showNewItems ? 0 : 1
    }
    
    func disableSegmented(index: Int) {
        let enabledIndex = index == 0 ? 0 : 1
        let disableIndex = enabledIndex == 1 ? 0: 1
        if segmentedControl.subviews[0].frame.origin.x == 0 {
            segmentedControl.subviews[disableIndex].tintColor = WMColor.empty_gray_btn
            segmentedControl.subviews[disableIndex].backgroundColor = WMColor.empty_gray_btn
            segmentedControl.subviews[enabledIndex].tintColor = WMColor.light_blue
            segmentedControl.subviews[enabledIndex].backgroundColor = WMColor.light_blue
        }else{
            segmentedControl.subviews[enabledIndex].tintColor = WMColor.empty_gray_btn
            segmentedControl.subviews[enabledIndex].backgroundColor = WMColor.empty_gray_btn
            segmentedControl.subviews[disableIndex].tintColor = WMColor.light_blue
            segmentedControl.subviews[disableIndex].backgroundColor = WMColor.light_blue
        }
    }
    
    func removeSubViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}


extension ProducDetailProviderTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showNewItems ? self.providerNewItems.count : self.providerReconditionedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "providerViewCell", for: indexPath) as! ProviderViewCell
        let provider = showNewItems ? self.providerNewItems[indexPath.row] : self.providerReconditionedItems[indexPath.row]
        cell.setValues(provider)
        if provider["offerId"] as! String == selectedOfferId {
            cell.isSelected = true
        }else{
            cell.isSelected = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        return CGSize(width: 136, height: 92)
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 8
    }
    
}

extension ProducDetailProviderTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let provider = showNewItems ? self.providerNewItems[indexPath.row] : self.providerReconditionedItems[indexPath.row]
        self.selectedOfferId = provider["offerId"] as! String
        collection.reloadData()
        delegate?.selectOffer(offer: provider)
    }
}

