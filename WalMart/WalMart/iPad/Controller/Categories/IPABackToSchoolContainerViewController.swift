//
//  IPABackToSchoolContainerViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 27/05/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class IPABackToSchoolContainerViewController: UIViewController, IPABackToSchoolViewControllerDelegate {
    
    var urlTicer: String?
    var departmentId: String?
    var navigation : UINavigationController!
    var navController = UIViewController()
    var separatorLayer: CALayer?
    var btsController: IPABackToSchoolViewController?
    var detailController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = WMColor.light_light_gray
        
        self.separatorLayer = CALayer()
        self.separatorLayer!.backgroundColor = WMColor.light_light_gray.cgColor
        
        self.btsController = IPABackToSchoolViewController()
        self.btsController!.urlTicer = self.urlTicer
        self.btsController!.departmentId = self.departmentId
        self.btsController!.btsDelegate = self
        self.addChildViewController(btsController!)
        self.view.addSubview(btsController!.view)
        btsController!.didMove(toParentViewController: self)
        btsController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 341, height: 658.0)
        self.btsController!.view.layer.insertSublayer(self.separatorLayer!, at: 1000)
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        self.separatorLayer!.frame = CGRect(x: 341, y: 0.0, width: 1.0, height: bounds.height)
        self.btsController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 342, height: bounds.height)
    }
    
    //MARK: IPABackToSchoolViewControllerDelegate
    
    func schoolSelected(_ familyId: String, schoolName: String) {
        let gradesListController = GradesListViewController()
        gradesListController.departmentId = self.departmentId
        gradesListController.familyId = familyId
        gradesListController.schoolName = schoolName
        
        let navController = UINavigationController(rootViewController: gradesListController)
        navController.isNavigationBarHidden = true
        self.addChildViewController(navController)
        self.view.addSubview(navController.view)
        navController.didMove(toParentViewController: self)
        navController.view.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
        self.detailController = navController
    }
}
