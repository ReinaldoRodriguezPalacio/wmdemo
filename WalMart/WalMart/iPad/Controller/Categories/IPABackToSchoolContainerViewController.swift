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
        self.separatorLayer!.backgroundColor = WMColor.light_light_gray.CGColor
        
        self.btsController = IPABackToSchoolViewController()
        self.btsController!.urlTicer = self.urlTicer
        self.btsController!.departmentId = self.departmentId
        self.btsController!.btsDelegate = self
        self.addChildViewController(btsController!)
        self.view.addSubview(btsController!.view)
        btsController!.didMoveToParentViewController(self)
        btsController!.view.frame = CGRectMake(0.0, 0.0, 341, 658.0)
        self.btsController!.view.layer.insertSublayer(self.separatorLayer!, atIndex: 1000)
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        self.separatorLayer!.frame = CGRectMake(341, 0.0, 1.0, bounds.height)
        self.btsController!.view.frame = CGRectMake(0.0, 0.0, 342, bounds.height)
    }
    
    //MARK: IPABackToSchoolViewControllerDelegate
    
    func schoolSelected(familyId: String, schoolName: String) {
        let gradesListController = GradesListViewController()
        gradesListController.departmentId = self.departmentId
        gradesListController.familyId = familyId
        gradesListController.schoolName = schoolName
        
        let navController = UINavigationController(rootViewController: gradesListController)
        navController.navigationBarHidden = true
        self.addChildViewController(navController)
        self.view.addSubview(navController.view)
        navController.didMoveToParentViewController(self)
        navController.view.frame = CGRectMake(342.0, 0.0, 682.0, 658.0)
        self.detailController = navController
    }
}