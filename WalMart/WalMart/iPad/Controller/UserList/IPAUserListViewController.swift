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

    var selectedItem : NSIndexPath?
    var selectedId : String?
    var delegate: IPAUserListDelegate?
    var rowSelected : NSIndexPath?
    var isTableNewFrame  =  false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemsUserList = []
        
        tableuserlist?.multipleTouchEnabled = true
        
        self.tableuserlist!.registerClass(IPAListTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        
        self.showWishlistBtn?.removeFromSuperview()
        self.showWishlistBtn = nil
        
        self.isShowingWishList = false
        self.needsToShowWishList = false
        
        self.selectedItem = NSIndexPath(forRow: 0, inSection: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.searchContainer!.frame = CGRectMake(0.0, self.header!.frame.height, self.view.frame.width, 64.0)
        self.tableuserlist!.frame = CGRectMake(0.0, isTableNewFrame ? self.header!.frame.height : self.searchContainer!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + 64.0))
        
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
        self.searchConstraint?.constant = self.SC_HEIGHT
        if animated {
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.searchContainer!.frame = CGRectMake(0.0, self.header!.frame.height, self.view.frame.width, 64.0)
                    self.tableuserlist!.frame = CGRectMake(0.0, self.searchContainer!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + 64.0))
                    aditionalAnimations?()
                }, completion: { (finished:Bool) -> Void in
                    if finished {
                        action?()
                        self.isToggleBarEnabled = true
                    }
                }
            )
        } else {
            //self.view.layoutIfNeeded()
            self.searchContainer!.frame = CGRectMake(0.0, self.header!.frame.height, self.view.frame.width, 64.0)
            self.tableuserlist!.frame = CGRectMake(0.0, self.searchContainer!.frame.maxY, self.view.frame.width, self.view.frame.height - (self.header!.frame.height + 64.0))
            self.isToggleBarEnabled = true
        }
    }
    
    override func hideSearchField(aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?) {
        self.isToggleBarEnabled = false
        isTableNewFrame =  true
        //self.searchConstraint!.constant = -5.0 //La seccion de busqueda es mas grande que el header
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.searchContainer!.frame = CGRectMake(0.0, -0.5, self.view.frame.width, 64.0)
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
        
        if requiredHelp && UserCurrentSession.hasLoggedUser() {
            var view = self.view
            if self.delegate != nil {
                view = self.delegate!.viewForContainer()
            }

            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.height))
            self.helpView!.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeHelpTicketView"))
            view.addSubview(self.helpView!)
            
            let icon = UIImageView(image: UIImage(named: "list_scan_ticket_help"))
            icon.frame = CGRectMake(12.0, self.header!.frame.maxY + 16.0, 48.0, 48.0)
            self.helpView!.addSubview(icon)
            
            let arrow = UIImageView(image: UIImage(named: "list_arrow_help"))
            arrow.frame = CGRectMake(icon.frame.maxX - 10.0, icon.frame.maxY - 10.0, 80.0, 28.0)
            self.helpView!.addSubview(arrow)

            let message = UILabel(frame: CGRectMake(arrow.frame.maxX, self.header!.frame.maxY + 20.0, 350.0, 45.0))
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellTable = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        //cellTable.setSelected(selectedItem == indexPath, animated: true)
        return cellTable
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
         cell.setSelected(selectedItem == indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let lastSelected = self.rowSelected
        self.rowSelected = indexPath
        self.selectedIndex = indexPath
        if indexPath.section == 0 {
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
                self.selectedId  = nil
                selectedItem = indexPath
                delegate?.showPractilistViewController()
                if (lastSelected != nil){
                    self.tableuserlist?.reloadRowsAtIndexPaths([lastSelected!], withRowAnimation: UITableViewRowAnimation.None)
                }
                return
            }
        }
        
        selectedItem = indexPath
        if let listItem = self.itemsUserList![indexPath.row] as? NSDictionary {
            if let listId = listItem["id"] as? String {
                self.selectedListId = listId
                self.selectedListName = listItem["name"] as? String
                self.selectedId = listId
                self.delegate?.showListDetailAnimated(forId: self.selectedListId, orEntity: nil, andName: self.selectedListName)
                
                
            }
        }
        else if let listEntity = self.itemsUserList![indexPath.row] as? List {
            self.selectedEntityList = listEntity
            self.selectedListName = listEntity.name
            self.selectedListId = listEntity.idList
            self.delegate?.showListDetailAnimated(forId: listEntity.idList, orEntity: listEntity, andName: listEntity.name)
        }
        
        let idxPath = NSIndexPath(forRow: 0, inSection: 0)
        if let cell = self.tableuserlist!.cellForRowAtIndexPath(idxPath) as? NewListTableViewCell {
            if cell.inputNameList!.isFirstResponder() {
                cell.inputNameList!.resignFirstResponder()
            }
        }
        
        if (lastSelected != nil){
            self.tableuserlist?.reloadRowsAtIndexPaths([lastSelected!], withRowAnimation: UITableViewRowAnimation.None)
        }
   
    }

    //MARK: - Utils
    
    override func reloadList(success success:(()->Void)?, failure:((error:NSError)->Void)?){
        //Solo en caso de existir una sesion se consulta al backend por las listas del usuario
        if UserCurrentSession.hasLoggedUser() {
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in
                    self.itemsUserList = result["responseArray"] as? [AnyObject]
                    self.itemsUserList =  self.itemsUserList?.sort({ (first:AnyObject, second:AnyObject) -> Bool in
                        
                        let dicFirst = first as! NSDictionary
                        let dicSecond = second as! NSDictionary
                        let stringFirst  =  dicFirst["name"] as! String
                        let stringSecond  =  dicSecond["name"] as! String
                        
                        return stringFirst < stringSecond
                        
                    })
                    
                    self.isShowingWishList = false
                    self.isShowingSuperlists = !self.isEditingUserList
                    self.checkEditBtn()
                    self.tableuserlist!.reloadData()
                    if !self.newListEnabled && !self.isEditingUserList {
                        self.showSearchField({ () -> Void in
                            }, atFinished: { () -> Void in
                            }, animated:false)
                    }
                    if !self.isEditingUserList {
                        self.changeFrameEditBtn(true, side: "left")
                        if self.itemsUserList!.count == 0{
                            self.changeVisibilityBtn(self.editBtn!, visibility: 0)
                        }
                        else{
                            self.changeVisibilityBtn(self.editBtn!, visibility: 1)
                        }
                    }
                    
                    if self.itemsUserList != nil && self.itemsUserList!.count > 0 {
                        if !self.isEditingUserList {
                            if self.selectedItem != nil {
                                self.tableView(self.tableuserlist!, didSelectRowAtIndexPath: (self.rowSelected != nil ? self.rowSelected! : self.selectedItem!))

                            }
                        }
                        
                    }
                    else {
                        self.delegate?.showPractilistViewController()
                        self.selectedItem = NSIndexPath(forRow: 0, inSection: 0)
                    }
               
                    success?()
                    return
                },
                errorBlock: { (error:NSError) -> Void in
                    self.changeVisibilityBtn(self.editBtn!, visibility: 0)
                    self.changeFrameEditBtn(true, side: "left")
                    failure?(error: error)
                    return
                }
            )
        }
        else {
            
            let service = GRUserListService()
            self.itemsUserList = service.retrieveNotSyncList()
            self.itemsUserList =  self.itemsUserList?.sort({ (first:AnyObject, second:AnyObject) -> Bool in
                let firstString = first as! List
                let secondString = second as! List
                return firstString.name < secondString.name
                
            })
            //println(self.itemsUserList)
            self.isShowingWishList = false
            self.isShowingSuperlists = !self.isEditingUserList
            self.selectedItem = NSIndexPath(forRow: 0, inSection: 0)
            

            self.tableuserlist!.reloadData()
            self.checkEditBtn()
            /*self.tableuserlist?.selectRowAtIndexPath(self.selectedItem, animated: true, scrollPosition: UITableViewScrollPosition.Top)*/
            
            if !self.newListEnabled && !self.isEditingUserList {
                self.showSearchField({ () -> Void in
                    }, atFinished: { () -> Void in
                    }, animated:false)
            }
            
            if !self.isEditingUserList {
                self.changeFrameEditBtn(true, side: "left")
                if self.itemsUserList!.count == 0{
                    self.changeVisibilityBtn(self.editBtn!, visibility: 0)
                }
                else{
                    self.changeVisibilityBtn(self.editBtn!, visibility: 1)
                }
            }
            
            if self.itemsUserList != nil && self.itemsUserList!.count >= 0 {
                self.delegate?.showPractilistViewController()
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
        barCodeController.searchProduct = false
        barCodeController.useDelegate = true
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    

    override func selectRowIfNeeded() {
        self.tableuserlist?.selectRowAtIndexPath(self.selectedItem, animated: false, scrollPosition: UITableViewScrollPosition.None)
        if selectedItem! == NSIndexPath(forRow: 0, inSection: 0) {
            self.delegate?.showPractilistViewController()
        }
    }
    
    func indexPathForPreferredFocusedViewInTableView(tableView: UITableView) -> NSIndexPath? {
        return self.selectedItem
    }
    
    override func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0://Duplicate list
            if let cellList = cell as? ListTableViewCell {
                cellList.duplicate()
            }
        case 1://Delete list
            if let indexPath = self.tableuserlist!.indexPathForCell(cell) {
                if let listItem = self.itemsUserList![indexPath.row] as? NSDictionary {
                    if let listId = listItem["id"] as? String {
                        self.deleteListInDB(listId)
                        
                        self.invokeDeleteListService(listId)
                        self.selectedItem = NSIndexPath(forRow: 0, inSection: 0)
                        self.selectRowIfNeeded()
                    }
                }
                    //Si existe como entidad solo debe eliminarse de la BD
                else if let listEntity = self.itemsUserList![indexPath.row] as? List {
                    
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
                    self.alertView!.setMessage(NSLocalizedString("list.message.deletingList", comment:""))
                    
                    self.managedContext!.deleteObject(listEntity)
                    self.saveContext()
                    //No hay que generar acciones adicionales para este caso
                    //                    self.reloadList(success: nil, failure: nil)
                    self.reloadWithoutTableReload(success: nil, failure: nil)
                    self.tableuserlist!.beginUpdates()
                    self.tableuserlist!.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                    self.tableuserlist!.endUpdates()
                    
                    //EXTRA SI NO HAY MAS LISTAS
                    if self.itemsUserList!.count == 0 && self.isEditingUserList {
                        self.showEditionMode()
                    }
                    self.checkEditBtn()
                    self.reloadList(success: { () -> Void in
                        
                        }, failure: { (error) -> Void in
                            
                    })
                    
                }
            }
        default:
            print("other pressed")
        }
    }

    
}
