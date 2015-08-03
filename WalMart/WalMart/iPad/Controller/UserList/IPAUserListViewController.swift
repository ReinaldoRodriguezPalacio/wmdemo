//
//  IPAUserListViewController.swift
//  WalMart
//
//  Created by neftali on 25/02/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

protocol IPAUserListDelegate {
    func viewForContainer() -> UIView
    func showListDetail(forId idList:String?, orEntity entity:List?, andName name:String?)
    func showListDetailAnimated(forId idList:String?, orEntity entity:List?, andName name:String?)
    func showLoadingView()
    func removeLoadingView()
    func showEmptyViewForLists()
    func removeEmptyViewForLists()
    func showPractilistViewController()
}

class IPAUserListViewController: UserListViewController {

    var delegate: IPAUserListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableuserlist!.registerClass(IPAListTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)

        self.showWishlistBtn?.removeFromSuperview()
        self.showWishlistBtn = nil
        
        self.isShowingWishList = false
        self.needsToShowWishList = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() 
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions

    override func showSearchField(aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?, animated:Bool) {
        self.isToggleBarEnabled = false
        self.searchContainer!.hidden = false
        //self.searchConstraint!.constant = self.SC_HEIGHT
        if animated {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.searchContainer!.frame = CGRectMake(0.0, self.header!.frame.height, self.view.frame.width, 56.0)
                    self.tableuserlist!.frame = CGRectMake(0.0, self.searchContainer!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + 56.0))
                    aditionalAnimations?()
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        action?()
                        self.isToggleBarEnabled = true
                    }
                }
            )
        } else {
            self.view.layoutIfNeeded()
            self.searchContainer!.frame = CGRectMake(0.0, self.header!.frame.height, self.view.frame.width, 56.0)
            self.tableuserlist!.frame = CGRectMake(0.0, self.searchContainer!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + 56.0))
            self.isToggleBarEnabled = true
        }
    }
    
    override func hideSearchField(aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?) {
        self.isToggleBarEnabled = false
        //self.searchConstraint!.constant = -5.0 //La seccion de busqueda es mas grande que el header
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.searchContainer!.frame = CGRectMake(0.0, -0.5, self.view.frame.width, 56.0)
                self.tableuserlist!.frame = CGRectMake(0.0, self.header!.frame.maxY, self.view.frame.width, self.view.frame.height - self.header!.frame.height)
                aditionalAnimations?()
            }, completion: { (finished:Bool) -> Void in
                if finished {
                    self.searchContainer!.hidden = true
                    action?()
                    self.isToggleBarEnabled = true
                }
            }
        )
    }

    //TODO:Delete wishlist help
    override func showHelpTicketView() {
        if self.helpView != nil {
            self.helpView!.removeFromSuperview()
            self.helpView = nil
        }
        
        var requiredHelp = true
        if let param = self.retrieveParam("ticketCamHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if requiredHelp && UserCurrentSession.sharedInstance().userSigned != nil {
            var view = self.view
            if self.delegate != nil {
                view = self.delegate!.viewForContainer()
            }

            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.height))
            self.helpView!.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.70)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeHelpTicketView"))
            view.addSubview(self.helpView!)
            
            var icon = UIImageView(image: UIImage(named: "list_scan_ticket_help"))
            icon.frame = CGRectMake(12.0, self.header!.frame.maxY + 16.0, 48.0, 48.0)
            self.helpView!.addSubview(icon)
            
            var arrow = UIImageView(image: UIImage(named: "list_arrow_help"))
            arrow.frame = CGRectMake(icon.frame.maxX - 10.0, icon.frame.maxY - 10.0, 80.0, 28.0)
            self.helpView!.addSubview(arrow)

            var message = UILabel(frame: CGRectMake(arrow.frame.maxX, self.header!.frame.maxY + 20.0, 350.0, 45.0))
            message.numberOfLines = 0
            message.textColor = UIColor.whiteColor()
            message.textAlignment = .Center
            message.font = WMFont.fontMyriadProRegularOfSize(20.0)
            message.text = NSLocalizedString("list.message.help", comment:"")
            self.helpView!.addSubview(message)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.helpView!.alpha = 1.0
            })
        }
    }

    //override func showWishlistHelpIfNeeded() { }
    
    override func showLoadingView() {
        self.delegate?.showLoadingView()
    }
    
    override func removeLoadingView() {
        self.delegate?.removeLoadingView()
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var wishList = false
        
        if indexPath.row == 0 && self.newListEnabled {
            return
        }
        
        var defaultList = false
        if indexPath.row == 0 && !self.newListEnabled && self.isShowingSuperlists {
            defaultList = true
        }
        if indexPath.row == 1 && self.newListEnabled && self.isShowingSuperlists {
            defaultList = true
        }
        
        if defaultList {
            delegate?.showPractilistViewController()
            return
        }
        
        var currentRow =   (self.isShowingSuperlists ? 1 : 0)
        currentRow =  currentRow + (self.newListEnabled ? 1 : 0)
        
        let idx =  indexPath.row - currentRow
        
        if let listItem = self.itemsUserList![idx] as? NSDictionary {
            if let listId = listItem["id"] as? String {
                self.selectedListId = listId
                self.selectedListName = listItem["name"] as? String
                
                //Event
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_LISTS.rawValue,
                        action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL.rawValue,
                        label: self.selectedListName ,
                        value: nil).build())
                }
                
                self.delegate?.showListDetailAnimated(forId: self.selectedListId, orEntity: nil, andName: self.selectedListName)
                
                
            }
        }
        else if let listEntity = self.itemsUserList![idx] as? List {
            self.selectedEntityList = listEntity
            self.selectedListName = listEntity.name
            //event
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_LISTS.rawValue,
                    action:WMGAIUtils.GR_EVENT_LISTS_SHOWLISTDETAIL.rawValue,
                    label: self.selectedListName ,
                    value: nil).build())
            }
            
            self.delegate?.showListDetailAnimated(forId: nil, orEntity: listEntity, andName: listEntity.name)
        }
        
        var idxPath = NSIndexPath(forRow: 0, inSection: 0)
        if let cell = self.tableuserlist!.cellForRowAtIndexPath(idxPath) as? NewListTableViewCell {
            if cell.inputNameList!.isFirstResponder() {
                cell.inputNameList!.resignFirstResponder()
            }
        }
    
        
    }

    //MARK: - Utils
    
    override func reloadList(#success:(()->Void)?, failure:((error:NSError)->Void)?){
        //Solo en caso de existir una sesion se consulta al backend por las listas del usuario
        if let user = UserCurrentSession.sharedInstance().userSigned {
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in
                    self.itemsUserList = result["responseArray"] as? NSArray
                    self.isShowingWishList = false
                    self.isShowingSuperlists = !self.isEditing
                    //println(self.itemsUserList)
                    self.tableuserlist!.reloadData()
                    if !self.newListEnabled && !self.isEditing {
                        self.showSearchField({ () -> Void in
                            }, atFinished: { () -> Void in
                            }, animated:false)
                    }
                    self.editBtn!.hidden = self.itemsUserList == nil || self.itemsUserList!.count == 0
                    if self.itemsUserList != nil && self.itemsUserList!.count > 0 {
                        self.delegate?.removeEmptyViewForLists()
                        var idxRow = 0
                        var selected = self.itemsUserList![0] as [String:AnyObject]
                        for var index = 0; index < self.itemsUserList!.count; index++ {
                            var item = self.itemsUserList![index] as [String:AnyObject]
                            if let countItem = item["countItem"] as? NSNumber {
                                if countItem.integerValue > 0 {
                                    idxRow = index
                                    selected = item
                                    break
                                }
                            }
                        }
                        
                        self.tableuserlist!.selectRowAtIndexPath(NSIndexPath(forRow: idxRow, inSection: 0), animated: true, scrollPosition: .Top)
                        self.selectedListId = selected["id"] as? String
                        self.selectedListName = selected["name"] as? String
                        self.delegate?.showListDetail(forId: self.selectedListId, orEntity: nil, andName: self.selectedListName)
                        
                    }
                    else {
                        self.delegate?.showEmptyViewForLists()
                    }
                    success?()
                    return
                },
                errorBlock: { (error:NSError) -> Void in
                    
                    self.editBtn!.hidden = true
                    failure?(error: error)
                    return
                }
            )
        }
        else {
            self.itemsUserList = self.retrieveNotSyncList()
            //println(self.itemsUserList)
            self.isShowingWishList = false
            self.isShowingSuperlists = !self.isEditing
            //println(self.itemsUserList)
            self.tableuserlist!.reloadData()
            if !self.newListEnabled && !self.isEditing {
                self.showSearchField({ () -> Void in
                    }, atFinished: { () -> Void in
                    }, animated:false)
            }
            //self.editBtn!.hidden = self.itemsUserList == nil || self.itemsUserList!.count == 0 //????? Deberia de incluirse para cuando no hay sesion
            if self.itemsUserList != nil && self.itemsUserList!.count > 0 {
                self.delegate?.removeEmptyViewForLists()
                var idxRow = 0
                var selected = self.itemsUserList![0] as List
                for var index = 0; index < self.itemsUserList!.count; index++ {
                    var item = self.itemsUserList![index] as List
                    if item.countItem.integerValue > 0 {
                        idxRow = index
                        selected = item
                        break
                    }
                }
                
                self.tableuserlist!.selectRowAtIndexPath(NSIndexPath(forRow: idxRow, inSection: 0), animated: true, scrollPosition: .Top)
                
                self.selectedEntityList = selected
                self.selectedListName = selected.name
                self.delegate?.showListDetail(forId: nil, orEntity: self.selectedEntityList, andName: self.selectedListName)
            }
            else {
                self.delegate?.showEmptyViewForLists()
            }
            success?()
        }
    }
    
    //MARK: - TabBar
    
    override func willShowTabbar() { }
    override func willHideTabbar() { }

    
    override func scanTicket() {
        let barCodeController = IPABarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.applyPadding = false
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    

    
}
