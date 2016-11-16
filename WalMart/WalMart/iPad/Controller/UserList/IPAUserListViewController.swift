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
    func showBackground(_ show:Bool)
}

class IPAUserListViewController: UserListViewController {

    var selectedItem : IndexPath?
    var selectedId : String?
    var delegate: IPAUserListDelegate?
    var rowSelected : IndexPath?
    var isTableNewFrame  =  false
    var heightTable: CGFloat = 0.0
    var didShowBackground: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemsUserList = []
        
        tableuserlist?.isMultipleTouchEnabled = true
        
        self.tableuserlist!.register(IPAListTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        
        //self.showWishlistBtn?.removeFromSuperview()
        //self.showWishlistBtn = nil
        
        self.needsToShowWishList = false
        self.selectedItem = IndexPath(row: 0, section: 0)
        self.tableuserlist?.selectRow(at: self.selectedItem, animated: false, scrollPosition: .none)
        self.heightTable = self.view.frame.height - (self.header!.frame.height + 64.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.searchContainer!.frame = CGRect(x: 0.0, y: self.header!.frame.height, width: self.view.frame.width, height: 64.0)
        self.tableuserlist!.frame = CGRect(x: 0.0, y: isTableNewFrame ? self.header!.frame.height : self.searchContainer!.frame.maxY, width: self.view.frame.width,height: self.heightTable )
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.newListEnabled = false
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
    
    
   override func showFirstHelpView(){
        
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("controllerHelp") {
            requiredHelp = !(param.value == "false")
        }
        let  showhelpView = (requiredHelp && self.helpView == nil)
        if showhelpView {
            listHelView =  ListHelpView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height),context:ListHelpContextType.inControllerList )
            listHelView?.onClose  = {() in
                self.removeHelpView()
            }
            
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController  {
                listHelView?.frame = CGRect(x: 0,y: 0 , width: customBar.view.bounds.width, height: customBar.view.frame.height)
                customBar.view.addSubview(listHelView!)
                CustomBarViewController.addOrUpdateParam("controllerHelp", value: "false")
            }
        }
    }
    
    /**
     Show helview where is new list, only one time
     */
    override func showHelpView(){
        
        var requiredHelp = true
        if let param = CustomBarViewController.retrieveParam("detailHelp") {
            requiredHelp = !(param.value == "false")
        }
        let  showDetailHelp = (requiredHelp && self.helpView == nil)
        if showDetailHelp {
            listHelView =  ListHelpView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height),context:ListHelpContextType.inDetailList )
            listHelView?.onClose  = {() in
                self.removeHelpView()
            }
            
            let window = UIApplication.shared.keyWindow
            if let customBar = window!.rootViewController as? IPACustomBarViewController {
                listHelView?.frame = CGRect(x: 0,y: 0 , width: customBar.view.bounds.width, height: customBar.view.frame.height)
                customBar.view.addSubview(listHelView!)
                CustomBarViewController.addOrUpdateParam("detailHelp", value: "false")
            }
             self.view.endEditing(true)
        }
        
    }
    
    override func showSearchField(_ aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?, animated:Bool) {
        self.isToggleBarEnabled = false
        self.searchContainer!.isHidden = false
        self.searchConstraint?.constant = self.SC_HEIGHT
        self.isTableNewFrame =  false
        self.heightTable = self.view.frame.height - (self.header!.frame.height + 64.0)
        self.didShowBackground = false
        if animated {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.searchContainer!.frame = CGRect(x: 0.0, y: self.header!.frame.height, width: self.view.frame.width, height: 64.0)
                    self.tableuserlist!.frame = CGRect(x: 0.0, y: self.isTableNewFrame ? self.header!.frame.height : self.searchContainer!.frame.maxY, width: self.view.frame.width,height: self.heightTable )
                    self.delegate?.showBackground(false)
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
            self.searchContainer!.frame = CGRect(x: 0.0, y: self.header!.frame.height, width: self.view.frame.width, height: 64.0)
            self.tableuserlist!.frame = CGRect(x: 0.0, y: self.isTableNewFrame ? self.header!.frame.height : self.searchContainer!.frame.maxY, width: self.view.frame.width,height: self.heightTable )
            self.isToggleBarEnabled = true
            self.delegate?.showBackground(false)
        }
    }
    
    override func hideSearchField(_ aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?) {
        self.isToggleBarEnabled = false
        self.isTableNewFrame =  true
        self.heightTable = self.view.frame.height
        self.didShowBackground = true
        //self.searchConstraint!.constant = -5.0 //La seccion de busqueda es mas grande que el header
        UIView.animate(withDuration: 0.5,
            animations: { () -> Void in
                self.searchContainer!.frame = CGRect(x: 0.0, y: -0.5, width: self.view.frame.width, height: 64.0)
                self.tableuserlist!.frame = CGRect(x: 0.0, y: self.isTableNewFrame ? self.header!.frame.height : self.searchContainer!.frame.maxY, width: self.view.frame.width,height: self.heightTable )
                aditionalAnimations?()
            }, completion: { (finished:Bool) -> Void in
                self.delegate?.showBackground(true)
                if finished {
                    self.searchContainer!.isHidden = true
                    action?()
                    self.isToggleBarEnabled = true
                }
            }
        )
    }

    
    override func hiddenSearchField(){
        self.isToggleBarEnabled = false
        self.isTableNewFrame =  true
        self.heightTable = self.view.frame.height
        self.didShowBackground = true
        self.searchContainer!.frame = CGRect(x: 0.0, y: -0.5, width: self.view.frame.width, height: 64.0)
        self.tableuserlist!.frame = CGRect(x: 0.0, y: self.isTableNewFrame ? self.header!.frame.height : self.searchContainer!.frame.maxY, width: self.view.frame.width,height: self.heightTable )
        self.searchContainer!.isHidden = true
        
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

            self.helpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: (view?.bounds.size.width)!, height: (view?.bounds.height)!))
            self.helpView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(UserListViewController.removeHelpTicketView)))
            view?.addSubview(self.helpView!)
            
            let icon = UIImageView(image: UIImage(named: "list_scan_ticket_help"))
            icon.frame = CGRect(x: 12.0, y: self.header!.frame.maxY + 16.0, width: 48.0, height: 48.0)
            self.helpView!.addSubview(icon)
            
            let arrow = UIImageView(image: UIImage(named: "list_arrow_help"))
            arrow.frame = CGRect(x: icon.frame.maxX - 10.0, y: icon.frame.maxY - 10.0, width: 80.0, height: 28.0)
            self.helpView!.addSubview(arrow)

            let message = UILabel(frame: CGRect(x: arrow.frame.maxX, y: self.header!.frame.maxY + 20.0, width: 350.0, height: 45.0))
            message.numberOfLines = 0
            message.textColor = UIColor.white
            message.textAlignment = .center
            message.font = WMFont.fontMyriadProRegularOfSize(20.0)
            message.text = NSLocalizedString("list.message.help", comment:"")
            self.helpView!.addSubview(message)
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.helpView!.alpha = 1.0
            })
        }
    }

    
    override func showLoadingView() {
        self.delegate?.showLoadingView()
    }
    
    override func removeLoadingView() {
        self.delegate?.removeLoadingView()
    }

    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTable = super.tableView(tableView, cellForRowAt: indexPath)
        //cellTable.setSelected(selectedItem == indexPath, animated: true)
        return cellTable
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         cell.setSelected(selectedItem == indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectedItem == indexPath &&  indexPath != IndexPath(row: 0, section: 0) {
            return
        }
        
        
        
//        if self.didShowBackground {
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//            cell?.selected = false
//            return
//        }
        
        self.rowSelected = self.rowSelected ?? IndexPath(row: 0, section: 0)
        let cell = self.tableuserlist?.cellForRow(at: self.rowSelected!)
        cell?.isSelected = false
        let lastSelected = self.rowSelected
        self.rowSelected = indexPath
        self.selectedIndex = indexPath
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 && self.newListEnabled {
                return
            }
            
            var defaultList = false
            if (indexPath as NSIndexPath).row == 0 && !self.newListEnabled && self.isShowingSuperlists {
                defaultList = true
            }
            if (indexPath as NSIndexPath).row == 1 && self.newListEnabled && self.isShowingSuperlists {
                defaultList = true
            }
            
            if defaultList {
                self.selectedId  = nil
                selectedItem = indexPath
                delegate?.showPractilistViewController()
                if (lastSelected != nil){
                    self.tableuserlist?.reloadRows(at: [lastSelected!], with: UITableViewRowAnimation.none)
                }
                return
            }
        }
        
        selectedItem = indexPath
        if let listItem = self.itemsUserList![(indexPath as NSIndexPath).row] as? [String:Any] {
            if let listId = listItem["repositoryId"] as? String {
                self.selectedListId = listId
                self.selectedListName = listItem["name"] as? String
                self.selectedId = listId
                self.delegate?.showListDetailAnimated(forId: self.selectedListId, orEntity: nil, andName: self.selectedListName)
                
                
            }
        }
        else if let listEntity = self.itemsUserList![(indexPath as NSIndexPath).row] as? List {
            self.selectedEntityList = listEntity
            self.selectedListName = listEntity.name
            self.selectedListId = listEntity.idList
            self.delegate?.showListDetailAnimated(forId: listEntity.idList, orEntity: listEntity, andName: listEntity.name)
        }
        
        let idxPath = IndexPath(row: 0, section: 0)
        if let cell = self.tableuserlist!.cellForRow(at: idxPath) as? NewListTableViewCell {
            if cell.inputNameList!.isFirstResponder {
                cell.inputNameList!.resignFirstResponder()
            }
        }
        
        if (lastSelected != nil){
            self.tableuserlist?.reloadRows(at: [lastSelected!], with: UITableViewRowAnimation.none)
        }
   
    }

    //MARK: - Utils
    
    override func reloadList(success:(()->Void)?, failure:((_ error:NSError)->Void)?){
        //Solo en caso de existir una sesion se consulta al backend por las listas del usuario
        if UserCurrentSession.hasLoggedUser() {
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:[String:Any]) -> Void in
                    self.itemsUserList = result["responseArray"] as! [[String : Any]]?
                    self.itemsUserList =  self.itemsUserList?.sorted(by: { (first:AnyObject, second:AnyObject) -> Bool in
                        
                        let dicFirst = first as! [String:Any]
                        let dicSecond = second as! [String:Any]
                        let stringFirst  =  dicFirst["name"] as! String
                        let stringSecond  =  dicSecond["name"] as! String
                        
                        return stringFirst < stringSecond
                        
                    } as! (Any, Any) -> Bool)
                    
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
                                self.tableView(self.tableuserlist!, didSelectRowAt: (self.rowSelected != nil ? self.rowSelected! : self.selectedItem!))
                            }
                        }
                        
                        
                    }
                    else {
                        self.delegate?.showPractilistViewController()
                        self.selectedItem = IndexPath(row: 0, section: 0)
                    }
                    if self.itemsUserList!.count == 0 {
                        self.hiddenSearchField()
                    }
               
                    success?()
                    return
                },
                errorBlock: { (error:NSError) -> Void in
                    self.changeVisibilityBtn(self.editBtn!, visibility: 0)
                    self.changeFrameEditBtn(true, side: "left")
                    failure?(error)
                    return
                }
            )
        }
        else {
            
            let service = GRUserListService()
            self.itemsUserList = service.retrieveNotSyncList() as! [[String : Any]]?
            self.itemsUserList =  self.itemsUserList?.sorted(by: { (first:AnyObject, second:AnyObject) -> Bool in
                let firstString = first as! List
                let secondString = second as! List
                return firstString.name < secondString.name
                
            } as! (Any, Any) -> Bool)
            //println(self.itemsUserList)
            self.isShowingSuperlists = !self.isEditingUserList

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
            
            if self.itemsUserList != nil && self.itemsUserList!.count > 0 {
                if !self.isEditingUserList {
                    if self.selectedItem != nil {
                        self.tableView(self.tableuserlist!, didSelectRowAt: (self.rowSelected != nil ? self.rowSelected! : self.selectedItem!))
                    }
                }
                
            }
            else {
                self.delegate?.showPractilistViewController()
                self.selectedItem = IndexPath(row: 0, section: 0)
            }
            
            if self.itemsUserList!.count == 0 {
                self.hiddenSearchField()
            }
            success?()
        }
    }
    
    /**
     Call Service to add new list, and reload user list
     
     - parameter value: name new list
     */
    override func createNewList(_ value:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.creatingList", comment:""))
        let svcList = GRSaveUserListService()
        svcList.callService(svcList.buildParams(value),
                            successBlock: { (result:[String:Any]) -> Void in
                                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_CREATE_NEW_LIST.rawValue, label: value)
                                
                                self.checkEditBtn()
                                self.newListEnabled = false
                                self.isShowingSuperlists = true
                                
                                self.newListBtn!.isSelected = false
                                self.newListBtn!.backgroundColor = WMColor.green
                                self.reloadList(
                                    success: { () -> Void in
                                        self.alertView!.setMessage(NSLocalizedString("list.message.listDone", comment:""))
                                        self.alertView!.showDoneIcon()
                                        var count = 0
                                        for itemList in self.itemsUserList! {
                                            if UserCurrentSession.hasLoggedUser() {
                                                if (itemList["name"] as! String) == value {
                                                    self.tableView(self.tableuserlist!, didSelectRowAt: IndexPath(row:count,section:1))
                                                    let cell = self.tableuserlist!.cellForRow(at: IndexPath(row:count,section:1))
                                                    cell?.isSelected = true
                                                    return
                                                }
                                            }
                                            count += 1
                                        }
                                },
                                    failure: { (error) -> Void in
                                        self.alertView!.setMessage(error.localizedDescription)
                                        self.alertView!.showErrorIcon("Ok")
                                    }
                                )
            },
                            errorBlock: { (error:NSError) -> Void in
                                self.alertView!.setMessage(error.localizedDescription)
                                self.alertView!.showErrorIcon("Ok")
            }
        )
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
        barCodeController.onlyCreateList = true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    

    override func selectRowIfNeeded() {
        self.tableuserlist?.selectRow(at: self.selectedItem, animated: false, scrollPosition: UITableViewScrollPosition.none)
        if selectedItem! == IndexPath(row: 0, section: 0) {
            self.delegate?.showPractilistViewController()
        }
    }
    
    func indexPathForPreferredFocusedViewInTableView(_ tableView: UITableView) -> IndexPath? {
        return self.selectedItem
    }
    
    override func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0://Duplicate list
            if let cellList = cell as? ListTableViewCell {
                cellList.duplicate()
            }
        case 1://Delete list
            if let indexPath = self.tableuserlist!.indexPath(for: cell) {
                if let listItem = self.itemsUserList![(indexPath as NSIndexPath).row] as? [String:Any] {
                    if let listId = listItem["repositoryId"] as? String {
                        self.deleteListInDB(listId)
                        
                        self.invokeDeleteListService(listId)
                        self.selectedItem = IndexPath(row: 0, section: 0)
                        self.rowSelected = IndexPath(row: 0, section: 0)
                        self.selectRowIfNeeded()
                    }
                }
                    //Si existe como entidad solo debe eliminarse de la BD
                else if let listEntity = self.itemsUserList![(indexPath as NSIndexPath).row] as? List {
                    self.rowSelected = IndexPath(row: 0, section: 0)
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
                    self.alertView!.setMessage(NSLocalizedString("list.message.deletingList", comment:""))
                    self.managedContext!.delete(listEntity)
                    self.saveContext()
                    //                        let delay = 15.7 * Double(NSEC_PER_SEC)
                    //                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    //No hay que generar acciones adicionales para este caso
                    //                    self.reloadList(success: nil, failure: nil)
                    self.reloadWithoutTableReload(success: nil, failure: nil)
                    self.tableuserlist!.beginUpdates()
                    self.tableuserlist!.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.tableuserlist!.endUpdates()
                    
                    //EXTRA SI NO HAY MAS LISTAS
                    if self.itemsUserList!.count == 0 && self.isEditingUserList {
                        self.showEditionMode()
                    }
                    self.checkEditBtn()
                    self.reloadList(success: { () -> Void in
                        let delaySec:Double = 2.0
                        let delayTime = DispatchTime.now() + Double(Int64(delaySec * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                            self.alertView?.close()
                        })
                        }, failure: { (error) -> Void in
                            
                    })
                }
            }
            

            
        default:
            print("other pressed")
        }
    }
    
}
