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
    var backgroundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

         self.view.backgroundColor = WMColor.light_light_gray
        
        self.separatorView = UIView()
        self.separatorView!.backgroundColor = WMColor.light_light_gray
        self.separatorView!.layer.zPosition = 100
        self.view.addSubview(self.separatorView!)
        
        self.backgroundView = UIView()
        self.backgroundView?.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
        self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(IPAUserListViewContainerController.hideBackground))
        self.backgroundView?.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        self.separatorView!.frame = CGRect(x: 342, y: 0.0, width: 1.0, height: bounds.height)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listEmbedSegue" {
            self.listController = segue.destination as? IPAUserListViewController
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
        
        if self.detailController == nil {
            if idList != nil {
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.view.bringSubview(toFront: self.separatorView!)
            self.detailController!.view.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
            }
        }
        else {
            if idList != nil {
                let oldDetailContainer = self.detailController
                oldDetailContainer?.view.removeFromSuperview()
                self.createDetailInstance(idList: idList, listName: name, entity: entity)
                self.view.bringSubview(toFront: self.separatorView!)
                self.detailController!.view.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
            }
        }
    }
    
    func showPractilistViewController() {
        
       // if self.detailController is UINavigationController {
            //return
       // }
     
        let defaultListController = IPADefaultListViewController()
        defaultListController.delegate = self
        let navController = UINavigationController(rootViewController: defaultListController)
        navController.view.tag = 101
        navController.isNavigationBarHidden = true
        self.listController?.selectedItem = IndexPath(row: 0, section: 0)
      
        for view in self.view.subviews {
          if view.tag == 101 {
            view.removeFromSuperview()
          }
        }
      
        self.addChildViewController(navController)
      
        self.view.addSubview(navController.view)
        //self.view.bringSubview(toFront: self.separatorView!)
        navController.didMove(toParentViewController: self)
        self.currentListId = nil
        self.currentEntity = nil
        navController.view.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
        self.detailController = navController
    }
    
    func reloadViewList() {
        self.listController?.reloadListFormUpdate()
        self.showListDetail(forId: currentListId, orEntity: currentEntity, andName: currentName)
    }
    
    
    
    func showListDetailAnimated(forId idList:String?, orEntity entity:List?, andName name:String?) {
        //(self.currentListId != nil && self.currentListId == idList) ||
        if (self.currentEntity != nil && self.currentEntity == entity) {
            return
        }
        
        self.currentListId = idList
        self.currentEntity  = entity
        
        if self.detailController == nil {
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.view.bringSubview(toFront: self.separatorView!)
            self.detailController!.view.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
           
        }
        else {
            let oldDetailContainer = self.detailController
            self.createDetailInstance(idList: idList, listName: name, entity: entity)
            self.detailController!.view.frame = CGRect(x: 342.0, y: 0.0, width: 682.0, height: 658.0)
            self.view.bringSubview(toFront: self.separatorView!)
            oldDetailContainer?.view.removeFromSuperview()

        }

    }
    
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
        self.viewLoad!.layer.zPosition = 100
    }
    
    func removeLoadingView() {
        let param = CustomBarViewController.retrieveParam("listUpdated", forUser: UserCurrentSession.hasLoggedUser())
        if self.viewLoad != nil && param != nil && param!.value == "true" {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    func showBackground(_ show:Bool){
        if show {
            self.view.addSubview(self.backgroundView!)
        }else{
            self.backgroundView!.removeFromSuperview()
        }
    }
    
    func hideBackground() {
        if self.listController!.newListEnabled {
            self.listController!.showNewListField()
        }
        if self.listController!.isEditingUserList {
            self.listController!.showEditionMode()
        }

        self.showBackground(false)
    }
    
    func showEmptyViewForLists() {
        let bounds = self.view.frame
        let width = bounds.width - 342
        self.emptyView = UIView(frame: CGRect(x: 342, y: 46, width: width,  height: bounds.height-46))
        self.emptyView!.backgroundColor = UIColor.clear
        self.view.addSubview(self.emptyView!)
        
        let bg = UIImageView(image: UIImage(named: "empty_lists"))
        bg.frame = CGRect(x: 0.0, y: 0, width: width, height: bounds.height-46)
        self.emptyView!.addSubview(bg)
        
        let labelOne = UILabel(frame: CGRect(x: 0.0, y: 28.0, width: width, height: 20.0))
        labelOne.textAlignment = .center
        labelOne.textColor = WMColor.light_blue
        labelOne.font = WMFont.fontMyriadProLightOfSize(16.0)
        labelOne.text = NSLocalizedString("list.empty", comment:"")
        self.emptyView!.addSubview(labelOne)
        
    }
    
    func removeEmptyViewForLists() {
        if self.emptyView != nil {
            UIView.animate(withDuration: 0.5,
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
    
    func createDetailInstance(idList:String?, listName:String?, entity:List?) {
        if let vc = storyboard!.instantiateViewController(withIdentifier: "listDetailVC") as? IPAUserListDetailViewController {
            vc.delegate = self
            vc.listId = idList
            vc.listName = listName
            vc.listEntity = entity
            vc.itemsUserList = self.listController!.itemsUserList
            vc.detailDelegate = self.listController!

            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 1024.0, y: 0.0, width: 704.0, height: 658.0)
            vc.didMove(toParentViewController: self)
            self.detailController = vc
        }
    }
    
    //MARK: - IPAUserListDetailDelegate
    
    func showProductListDetail(fromProducts products:[Any], indexSelected index:Int,listName:String) {
        let controller = IPAProductDetailPageViewController()
        controller.ixSelected = index
        controller.itemsToShow = products
        controller.detailOf = listName
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func reloadTableListUser() {
        if (self.listController  != nil) {
            if self.listController!.newListEnabled {
               self.listController!.showNewListField()
            }
            if self.listController!.isEditingUserList {
               self.listController!.showEditionMode()
            }

            self.listController!.reloadListFormUpdate()
        }
    }
    
    func closeUserListDetail() {
    }
    
    func reloadTableListUserSelectedRow() {
        if let indexPath = self.listController?.selectedItem as IndexPath? {
            if self.listController?.itemsUserList != nil && self.listController!.itemsUserList!.count > 0 {
                let listEntity: List? = self.listController?.itemsUserList?[indexPath.row] as? List
        
                if listEntity != nil {
                    self.listController?.selectedEntityList = listEntity
                    self.listController?.selectedListName = listEntity!.name
                    self.listController?.selectedListId = listEntity!.idList
                    self.showListDetailAnimated(forId: listEntity!.idList, orEntity: listEntity!, andName: listEntity!.name)
                }
            }
        }
    }
    
    
   
}
