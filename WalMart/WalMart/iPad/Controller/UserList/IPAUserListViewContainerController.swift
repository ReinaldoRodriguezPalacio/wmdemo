//
//  IPAUserListViewController.swift
//  WalMart
//
//  Created by neftali on 25/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class IPAUserListViewContainerController: UIViewController, IPAUserListDelegate, IPAUserListDetailDelegate, IPADefaultListDetailViewControllerDelegate {

    var listController: IPAUserListViewController?
    var detailController: UIViewController?
    var separatorView: UIView?
    var viewLoad: WMLoadingView?
    var emptyView: UIView?
    
    var currentListId: String?
    var currentEntity: List?
    var currentName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

         self.view.backgroundColor = WMColor.navigationHeaderBgColor
        
        self.separatorView = UIView()
        self.separatorView!.backgroundColor = WMColor.UIColorFromRGB(0xEEEEEE)
        self.view.addSubview(self.separatorView!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        var bounds = self.view.bounds
        self.separatorView!.frame = CGRectMake(342, 0.0, 1.0, bounds.height)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "listEmbedSegue" {
            self.listController = segue.destinationViewController as? IPAUserListViewController
            self.listController!.delegate = self
        }
    }
    
    //MARK: - Actions
    
    // MARK: - IPAUserListDelegate
    
    func viewForContainer() -> UIView {
        return self.view
    }

    func showListDetail(forId idList:String?, orEntity entity:List?, andName name:String?) {
        self.currentListId = idList
        self.currentEntity = entity
        var currentName = name
        
        if self.detailController == nil {
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.view.bringSubviewToFront(self.separatorView!)
            self.detailController!.view.frame = CGRectMake(342.0, 0.0, 682.0, 658.0)
        }
        else {
            var oldDetailContainer = self.detailController
            oldDetailContainer?.view.removeFromSuperview()
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.view.bringSubviewToFront(self.separatorView!)
            self.detailController!.view.frame = CGRectMake(342.0, 0.0, 682.0, 658.0)
        }
    }
    
    func showPractilistViewController() {
        let defaultListController = IPADefaultListViewController()
        defaultListController.delegate = self
        let navController = UINavigationController(rootViewController: defaultListController)
        navController.navigationBarHidden = true
        self.listController?.selectedItem = NSIndexPath(forRow: 0, inSection: 0)
        
        self.addChildViewController(navController)
        self.view.addSubview(navController.view)
        self.view.bringSubviewToFront(self.separatorView!)
        navController.didMoveToParentViewController(self)
        self.currentListId = nil
        self.currentEntity = nil
        navController.view.frame = CGRectMake(342.0, 0.0, 682.0, 658.0)
        self.detailController = navController
        
        
    }
    
    func reloadViewList() {
        self.listController?.reloadListFormUpdate()
        self.showListDetail(forId: currentListId, orEntity: currentEntity, andName: currentName)
    }
    
    
    
    func showListDetailAnimated(forId idList:String?, orEntity entity:List?, andName name:String?) {
        
        if (self.currentListId != nil && self.currentListId == idList) || (self.currentEntity != nil && self.currentEntity == entity) {
            return
        }
        
        self.currentListId = idList
        self.currentEntity = entity
        
        if self.detailController == nil {
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.view.bringSubviewToFront(self.separatorView!)
            self.detailController!.view.frame = CGRectMake(342.0, 0.0, 682.0, 658.0)
           
        }
        else {
            var oldDetailContainer = self.detailController
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.detailController!.view.frame = CGRectMake(342.0, 0.0, 682.0, 658.0)
            self.view.bringSubviewToFront(self.separatorView!)
            oldDetailContainer?.view.removeFromSuperview()
            
        }

    }
    
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(false)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
        }
         self.viewLoad = nil
    }
    
    func showEmptyViewForLists() {
        var bounds = self.view.frame
        var width = bounds.width - 342
        self.emptyView = UIView(frame: CGRectMake(342, 46, width,  bounds.height-46))
        self.emptyView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.emptyView!)
        
        var bg = UIImageView(image: UIImage(named: "empty_lists"))
        bg.frame = CGRectMake(0.0, 0, width, bounds.height-46)
        self.emptyView!.addSubview(bg)
        
        var labelOne = UILabel(frame: CGRectMake(0.0, 28.0, width, 20.0))
        labelOne.textAlignment = .Center
        labelOne.textColor = WMColor.UIColorFromRGB(0x2870c9)
        labelOne.font = WMFont.fontMyriadProLightOfSize(16.0)
        labelOne.text = NSLocalizedString("list.empty", comment:"")
        self.emptyView!.addSubview(labelOne)
        
    }
    
    func removeEmptyViewForLists() {
        if self.emptyView != nil {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.emptyView!.alpha = 0.0
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        self.emptyView!.removeFromSuperview()
                        self.emptyView = nil
                    }
                }
            )
        }
    }

    //MARK: -
    
    func createDetailInstance(#idList:String?, listName:String?, entity:List?) {
        if let vc = storyboard!.instantiateViewControllerWithIdentifier("listDetailVC") as? IPAUserListDetailViewController {
            vc.delegate = self
            vc.listId = idList
            vc.listName = listName
            vc.listEntity = entity

            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            vc.view.frame = CGRectMake(1024.0, 0.0, 704.0, 658.0)
            vc.didMoveToParentViewController(self)
            self.detailController = vc
        }
    }
    
    //MARK: - IPAUserListDetailDelegate
    
    func showProductListDetail(fromProducts products:[AnyObject], indexSelected index:Int) {
        var controller = IPAProductDetailPageViewController()
        controller.ixSelected = index
        controller.itemsToShow = products
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func reloadTableListUser() {
        if (self.listController  != nil) {
            self.listController!.reloadListFormUpdate()
        }
    }
    
    func closeUserListDetail() {
    }
    
    func reloadTableListUserSelectedRow() {
        self.listController?.selectedItem
        self.listController?.tableuserlist?.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
        self.listController?.tableuserlist?.selectRowAtIndexPath(self.listController?.selectedItem, animated: false, scrollPosition: UITableViewScrollPosition.None)
    }
    
    
   
}
