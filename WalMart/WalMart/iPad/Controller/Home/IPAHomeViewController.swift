//
//  IPAHomeViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 10/13/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class IPAHomeViewController : HomeViewController {
    
    var currentCellSelected : IndexPath!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.register(IPABannerCollectionViewCell.self, forCellWithReuseIdentifier: "iPABannerHome")
        collection.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "iPACategoryHome")
        collection.register(IPAProductHomeCollectionViewCell.self, forCellWithReuseIdentifier: "iPAProductHome")
        
        NotificationCenter.default.post(name: .showHomeSelected, object: nil)
    }
    
    override func showPleca(){
        print("::::showPleca:::")
        if plecaItems !=  nil  && plecaItems!.count > 0{
            if alertBank ==  nil {
                alertBank = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
                alertBank!.backgroundColor = WMColor.dark_blue.withAlphaComponent(0.9)
                self.view.addSubview(alertBank!)
            }
            let maxStrCat =  plecaItems?["terms"] as? String
            let size = maxStrCat!.size(attributes: [NSFontAttributeName:WMFont.fontMyriadProRegularOfSize(12)])
            
            if titleView ==  nil {
                titleView =  UILabel(frame: CGRect(x: (self.view.frame.width/2) - (size.width / 2), y: 0, width: size.width, height: alertBank!.frame.height))
            }
            titleView!.font = WMFont.fontMyriadProRegularOfSize(12)
            titleView!.textColor = UIColor.white
            titleView!.text = plecaItems?["terms"] as? String
            titleView!.textAlignment = .left
            titleView?.alpha = 0
            self.alertBank!.addSubview(titleView!)
            if detailsButton ==  nil{
                detailsButton = UIButton(frame: CGRect(x: titleView!.frame.maxX + 5, y: 12, width: 55, height: 22))
            }
            detailsButton.backgroundColor = WMColor.green
            detailsButton!.layer.cornerRadius = 11.0
            detailsButton!.setTitle("Detalles", for:UIControlState())
            detailsButton!.addTarget(self, action: #selector(HomeViewController.openDetailPleca), for: .touchUpInside)
            detailsButton!.setTitleColor(WMColor.light_light_gray, for: UIControlState())
            detailsButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
            detailsButton.alpha = 0
            self.alertBank!.addSubview(detailsButton!)
            if imageNotification ==  nil {
                self.imageNotification = UIImageView(frame:CGRect(x: self.titleView!.frame.minX - 17 ,y: alertBank!.frame.midY-6,width: 12,height: 12))
            }
            self.imageNotification?.image = UIImage(named: "notification_icon")
            imageNotification?.alpha =  0
            self.alertBank!.addSubview(imageNotification!)
            
     
            
    
            
            UIView.animate(withDuration: 0.2, animations: {
                self.alertBank?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46)
                self.titleView!.frame = CGRect(x: (self.view.frame.width/2) - (size.width / 2), y: 0,width: size.width, height: self.alertBank!.frame.height)
                self.detailsButton.frame = CGRect(x: self.titleView!.frame.maxX + 5, y: 12, width: 55, height: 22)
                self.imageNotification?.frame = CGRect(x: self.titleView!.frame.minX - 17 ,y: self.alertBank!.frame.midY-6,width: 12,height: 12)

                }, completion: {(bool : Bool) in
                        self.alertBank?.alpha = 1
                        self.titleView?.alpha = 1
                        self.detailsButton?.alpha = 1
                        self.imageNotification?.alpha = 1
                        self.startTimmerPleca()
                    
                    
            })
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            return CGSize(width: 1024, height: 274)
        case (0,1):
            return CGSize(width: 1024, height: 46)
        default:
            return CGSize(width: self.view.frame.width / 4, height: 192)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            let catNameFilter = self.categories[selectedIndexCategory]
            let arrayItems : AnyObject = self.recommendCategoryItems[catNameFilter]! as AnyObject
            let arrayItemsResult =  arrayItems as! [[String:Any]]
          
            let paginatedProductDetail = IPAProductDetailPageViewController()
            paginatedProductDetail.ixSelected = indexPath.row
            paginatedProductDetail.itemsToShow = []
            paginatedProductDetail.detailOf = "Especiales \(catNameFilter)"
            for productRecomm  in arrayItemsResult {
                let upc = productRecomm["upc"] as! String
                var desc = ""
                if let  descs = productRecomm["description"] as? String{
                   desc =  descs
                }
                
                let type = self.categoryType[catNameFilter]! == "gr" ? "groceries" : "mg"

                paginatedProductDetail.itemsToShow.append(["upc":upc,"description":desc,"type":type])
                
            }
            
            let currentCell = collectionView.cellForItem(at: indexPath) as! IPAProductHomeCollectionViewCell!
            currentCellSelected = indexPath
//            let pontInView = currentCell?.convert(currentCell!.productImage!.frame, to:  self.view)
//            paginatedProductDetail.animationController = ProductDetailNavigatinAnimationController(nav:self.navigationController!)
//            paginatedProductDetail.animationController.originPoint =  pontInView
//            paginatedProductDetail.animationController.setImage(currentCell!.productImage!.image!)
            currentCell?.hideImageView()
            
            
           
            self.navigationController?.delegate = paginatedProductDetail
            self.navigationController?.pushViewController(paginatedProductDetail, animated: true)
           
        }
    }
    
    override func openLandinCampaign(_ urlTicer:String,idFamily:String){
        
        let controller = IPALinesViewController()
        controller.urlTicer = urlTicer
        controller.familyId = idFamily
        controller.searchContextType =  .withCategoryForMG
        controller.frameStart =  CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        controller.frameEnd =  CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func showFindUpc(_ upcs:[Any],type:String){
        let controller = IPASearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .withCategoryForMG
        }else {
            controller.searchContextType = .withCategoryForGR
        }
        controller.findUpcsMg = upcs as? [String] as [Any]?
        controller.titleHeader = "Recomendados"
        self.navigationController!.pushViewController(controller, animated: true)
        
        
    }
    
    func reloadSelectedCell() {
        if currentCellSelected != nil {
            if let currentCell = collection.cellForItem(at: currentCellSelected) as? IPAProductHomeCollectionViewCell {
                currentCell.showImageView()
            }
        }
        
    }
    
    override func bannerCellIdentifier() -> String {
        return "iPABannerHome"
    }
    
    override func productCellIdentifier() -> String {
        return "iPAProductHome"
    }
    
    override func showProductDetail(_ upcProduct:String,type:String){
        let controller = IPAProductDetailPageViewController()
        controller.itemsToShow = [["upc":upcProduct,"description":"","type":type]]
        
        //TODO: Delete
        //willHideTabbar()
        //NotificationCenter.default.post(name: .hideBar, object: nil)
        
        self.navigationController!.delegate = nil
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func showProducts(forDepartmentId depto: String?, andFamilyId family: String?, andLineId line: String?,type:String, bannerName: String){
        let controller = IPASearchProductViewController()
        if type == "mg" {
            controller.searchContextType = .withCategoryForMG
        }else {
            controller.searchContextType = .withCategoryForGR
        }
        controller.idFamily  = family == nil ? "_" :  family
        controller.idDepartment = depto == nil ? "_" :  depto
        controller.idLine = line
        controller.titleHeader = "Recomendados"
        controller.eventCode = bannerName
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Open BackToSchoolCategory
     */
   override func openBackToSchoolCategory(_ urlTicer:String,idFamily:String){
        let controller = IPABackToSchoolContainerViewController()
        controller.urlTicer = urlTicer
        controller.departmentId = idFamily
        self.navigationController!.pushViewController(controller, animated: true)
    }

}
