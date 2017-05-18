//
//  UserListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/13/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class UserListViewController : UserListNavigationBaseViewController, UITableViewDelegate, UITableViewDataSource, NewListTableViewCellDelegate, SWTableViewCellDelegate, UITextFieldDelegate, ListTableViewCellDelegate, BarCodeViewControllerDelegate, UserListDetailViewControllerDelegate,UIScrollViewDelegate {
    
    let CELL_ID = "listCell"
    let NEWCELL_ID = "newlistCell"
    
    let SC_HEIGHT:CGFloat = 46.0
    
    @IBOutlet var searchContainer: UIView?
    @IBOutlet var tableuserlist: UITableView?
    
    @IBOutlet var searchConstraint: NSLayoutConstraint?
    
    var viewLoad: WMLoadingView?
    var searchField: FormFieldView?

    var editBtn: UIButton?
    var newListBtn: UIButton?
    var showWishlistBtn: UIButton?
    var viewSeparator : UIView!
    
    var helpView: UIView?
    //var alertView: IPOWMAlertViewController?
    
    var newListEnabled = false
    var isEditingUserList  = false
    var isShowingWishList  = true
    var isShowingSuperlists = true
    var isShowingTabBar = true
    var isToggleBarEnabled = true
    var enabledHelpView = false
    var listToUpdate: [String:String]?
    
    var selectedEntityList: List?
    var selectedListId: String?
    var selectedListName: String?
    
    var viewTapHelp: UIView?
    var iconImageHelp : UIImageView!
    var arrowImageHelp : UIImageView!
    var helpLabel: UILabel? = nil
    
    var deleteListServiceInvoked = false
    var needsToShowWishList = true
    var cellEditing: SWTableViewCell? = nil
    var selectedIndex: IndexPath? = nil
    var changeNames =  true
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MYLIST.rawValue
    }
    
    var numberOfDefaultLists = 0
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(UserListViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = WMColor.yellow
        return refreshControl
    }()
    
    override func viewDidLoad() {
        self.hiddenBack = true
        super.viewDidLoad()
        
        tableuserlist?.isMultipleTouchEnabled = true

        self.titleLabel?.text = NSLocalizedString("list.title",comment:"")
        self.titleLabel?.textAlignment = .left
        self.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.newListBtn = UIButton(type: .custom)
        self.newListBtn!.setTitle(NSLocalizedString("list.new", comment:""), for: UIControlState())
        self.newListBtn!.setTitle(NSLocalizedString("list.endnew", comment:""), for: .selected)
        self.newListBtn!.setTitleColor(UIColor.white, for: UIControlState())
        self.newListBtn!.setTitleColor(WMColor.light_blue, for: .selected)
        self.newListBtn!.addTarget(self, action: #selector(UserListViewController.showNewListField), for: .touchUpInside)
        self.newListBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.newListBtn!.backgroundColor = WMColor.green
        self.newListBtn!.layer.cornerRadius = 11.0
        self.newListBtn!.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0, 1, 0.0)
        self.header!.addSubview(self.newListBtn!)
        
        self.editBtn = UIButton(type: .custom)
        self.editBtn!.setTitle(NSLocalizedString("list.edit", comment:""), for: UIControlState())
        self.editBtn!.setTitle(NSLocalizedString("list.endedit", comment:""), for: .selected)
        self.editBtn!.addTarget(self, action: #selector(UserListViewController.showEditionMode), for: .touchUpInside)
        self.editBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.editBtn!.backgroundColor = WMColor.light_blue
        self.editBtn!.layer.cornerRadius = 11.0
        self.editBtn!.titleEdgeInsets = UIEdgeInsetsMake(1.0, 0, 1, 0.0)
        self.header!.addSubview(self.editBtn!)

        
        self.searchContainer!.backgroundColor = UIColor.white
        
        self.searchField = FormFieldView()
        self.searchField!.maxLength = 100
        self.searchField!.delegate = self
        self.searchField!.setCustomPlaceholderRegular(NSLocalizedString("list.search.placeholder",comment:""))
        self.searchField!.typeField = .string
        self.searchField!.nameField = NSLocalizedString("list.search.placeholder",comment:"")
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.light_light_gray
        
        self.searchContainer!.addSubview(viewSeparator)
        self.searchContainer!.addSubview(searchField!)
        
        self.tableuserlist!.register(ListTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableuserlist!.register(NewListTableViewCell.self, forCellReuseIdentifier: self.NEWCELL_ID)
        
        self.updateNumberOfDefaultList()
        self.invokeDefaultUserListService()
        
        self.tableuserlist?.allowsMultipleSelection = false
        self.tableuserlist?.separatorStyle = .none
        BaseController.setOpenScreenTagManager(titleScreen: "Listas", screenName: self.getScreenGAIName())
        
        self.tableuserlist?.addSubview(self.refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserListViewController.reloadListFormUpdate), name: NSNotification.Name(rawValue: "ReloadListFormUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserListViewController.updateListTable), name: .userlistUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserListViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserListViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showLoadingView()
        self.reloadList(
            success:{() -> Void in
                self.removeLoadingView()
            },
            failure: {(error:NSError) -> Void in
                self.removeLoadingView()
            }
        )
        
        if stateEdit {
            self.cancelNewList()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.endEditing(true)
    }
    var stateEdit =  false
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.newListEnabled = false
        if self.isEditingUserList {
           self.showEditionMode()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.newListBtn!.frame.equalTo(CGRect.zero) {
            let headerBounds = self.header!.frame.size
            let buttonWidth: CGFloat = 56.0
            let buttonHeight: CGFloat = 22.0
            self.titleLabel!.frame = CGRect(x: 16.0, y: 0.0, width: (headerBounds.width/2) - 16.0, height: headerBounds.height)
            self.newListBtn!.frame = CGRect(x: headerBounds.width - (buttonWidth   + 16.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
            self.editBtn!.frame = CGRect(x: self.newListBtn!.frame.minX - (buttonWidth + 8.0), y: (headerBounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        }
        
        let bounds = self.view.frame.size
        self.searchField!.frame = CGRect(x: 16.0, y: 12.0, width: bounds.width - 32.0, height: 40.0)
        
        self.viewSeparator.frame = CGRect(x: 0, y: searchContainer!.frame.height  - AppDelegate.separatorHeigth() , width: searchContainer!.frame.width,   height: AppDelegate.separatorHeigth())
    }
    
    /**
     Reload list in Notifications
     */
    func reloadListFormUpdate (){
        print("Notificacion para actualizar lista")
        self.reloadList(success: nil, failure: nil)
        print("Lista actualizada correctamente")
    }
    
    /**
     change editing mode, the seccion list
     */
    func checkEditBtn(){
        if self.itemsUserList == nil || self.itemsUserList!.count == 0{
            if self.isEditingUserList {
                self.showEditionMode()
            }
            UIView.animate(withDuration: 0.4, animations: {
                self.editBtn!.isHidden = true
                self.editBtn?.isEnabled = false
            })
        }
        else{
            UIView.animate(withDuration: 0.4, animations: {
                self.editBtn!.isHidden = false
                self.editBtn?.isEnabled = true
            })
        }
    }
    
    
    
    //MARK: - List Utilities
    var listSelectedDuplicate : IndexPath?
    
    //MARK: UserListDetailService
    /**
        valid if the function duplicate list execute.
     */
    func duplicateListDelegate(){
        if self.listSelectedDuplicate == self.selectedIndex {
            return
        }
        self.listSelectedDuplicate = self.selectedIndex
        let indexpath = self.selectedIndex
        if indexpath != nil {
            let cell =  self.tableuserlist!.cellForRow(at: indexpath!) as? ListTableViewCell
            if cell != nil {
                self.duplicateList(cell!)
            }
        }
    }
    
    /**
     change visibility button
     
     - parameter button:     button change
     - parameter visibility: alpha visibility
     */
    func changeVisibilityBtn(_ button: UIButton, visibility: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            button.alpha = visibility
        })
    }
    
    /**
     Change frame button
     
     - parameter front: position to button
     - parameter side:  button position in frame
     */
    func changeFrameEditBtn(_ front: Bool, side: String) {
        if front == true {
            self.header!.bringSubview(toFront: self.editBtn!)
        }
        else{
            self.header!.bringSubview(toFront: self.newListBtn!)
        }
        UIView.animate(withDuration: 0.4, animations: {
            if side == "left" {
                self.editBtn!.frame = CGRect(x: self.newListBtn!.frame.minX - (self.newListBtn!.frame.width + 8.0), y: self.newListBtn!.frame.minY, width: self.newListBtn!.frame.width, height: self.newListBtn!.frame.height)
            }
            else if side == "right" {
                self.editBtn!.frame = self.newListBtn!.frame
            }
        })
    }
    
    /**
     call servie user list, in case necesary, update add, or remove
     
     - parameter success: succes block return
     - parameter failure: faild block return
     */
    func reloadList(success:(()->Void)?, failure:((_ error:NSError)->Void)?){
        if let _ = UserCurrentSession.sharedInstance.userSigned {
            let service = GRUserListService()
            self.itemsUserList = service.retrieveUserList()
            self.itemsUserList =  self.itemsUserList?.sorted(by: { (first:Any, second:Any) -> Bool in
                let firstString = first as! List
                let secondString = second as! List
                return firstString.name < secondString.name
                
            })
            
            self.invokeWishListService()
            
            self.tableuserlist?.reloadData()
            self.checkEditBtn()
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
            self.checkEditBtn()
            success?()
            return
            
        }else {
            self.isShowingWishList = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            let service = GRUserListService()
            self.itemsUserList = service.retrieveNotSyncList()
            CustomBarViewController.addOrUpdateParam("listUpdated", value: "true",forUser: false)
            self.itemsUserList =  self.itemsUserList?.sorted(by: { (first:Any, second:Any) -> Bool in
                let firstString = first as! List
                let secondString = second as! List
                return firstString.name < secondString.name
            
           })
            
            self.tableuserlist!.reloadData()
            self.tableuserlist!.selectRow(at: self.listSelectedDuplicate, animated: false, scrollPosition: .none)
            self.checkEditBtn()
            if !self.newListEnabled && !self.isEditingUserList {
                self.showSearchField({
                    }, atFinished: {
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
            self.checkEditBtn()
            success?()
        }
    }
    
    /**
     Call user list Service.
     
     - parameter success: succes block return
     - parameter failure: faild block return
     */
    func reloadWithoutTableReload(success:(()->Void)?, failure:((_ error:NSError)->Void)?){
        if let _ = UserCurrentSession.sharedInstance.userSigned {
            self.isShowingWishList = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            let service = GRUserListService()
            self.itemsUserList = service.retrieveNotSyncList()
            if !self.newListEnabled && !self.isEditingUserList {
                self.showSearchField({ () -> Void in
                }, atFinished: { () -> Void in
                }, animated:false)
            }
            //self.editBtn!.hidden = (self.itemsUserList == nil || self.itemsUserList!.count == 0)
            success?()
        }
        else {
            self.isShowingWishList = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            let service = GRUserListService()
            self.itemsUserList = service.retrieveNotSyncList()
            if !self.newListEnabled && !self.isEditingUserList {
                self.showSearchField({
                    }, atFinished: {
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
            
            success?()
        }
    }
    
    //MARK: - Edit
    
    /**
        show enable edit mode or disable edit mode.
     */
    func showEditionMode() {
        
        self.cellEditing = nil
        self.newListBtn?.isEnabled = false
        self.editBtn?.isEnabled = false
        
        if !self.isEditingUserList {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_EDIT_LIST.rawValue, label: "")
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.newListBtn?.alpha = 0
            })
            
            self.hideSearchField({
                self.changeFrameEditBtn(true, side: "right")
                },
                atFinished: { () -> Void in
                    self.isShowingWishList = false
                    self.isShowingSuperlists = false
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({ () -> Void in
                        let cells = self.tableuserlist!.visibleCells
                        for cellObj in cells {
                            if let cell = cellObj as? ListTableViewCell {
                                cell.enableEditing = true
                                cell.textField!.text = cell.listName!.text
                                cell.setEditing(true, animated: false)
                                cell.enableEditListAnimated(true)
                                cell.setSelected(false, animated: false)
                                cell.showLeftUtilityButtons(animated: false)
                            }
                        }
                        self.newListBtn?.isEnabled = true
                        self.editBtn?.isEnabled = true
                    })
                    self.tableuserlist!.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
                    CATransaction.commit()
                }
            )
        }
        else {
            //ale
            self.view.endEditing(true)
            self.showSearchField({
                self.changeFrameEditBtn(true, side: "left")
                }, atFinished: { () -> Void in
                    
                    if let _ = UserCurrentSession.sharedInstance.userSigned {
                        self.alertView = nil
                        if self.changeNames {
                            self.invokeUpdateListService()
                        }
                    }
                    else {
                        if self.changeNames {
                            self.changeEntityNames()
                        }
                    }
                    
                    self.isShowingWishList = true
                    self.isShowingSuperlists = true
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({ () -> Void in
                        var cells = self.tableuserlist!.visibleCells
                        for idx in 0 ..< cells.count {
                            if let cell = cells[idx] as? ListTableViewCell {
                                cell.listName!.text = cell.textField!.text
                                cell.hideUtilityButtons(animated: false)
                                cell.setEditing(false, animated: false)
                                cell.enableEditList(false)
                            }
                        }
                        
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.newListBtn?.alpha = 1
                        })
                        
                        self.newListBtn?.isEnabled = true
                        self.editBtn?.isEnabled = true
                    })
                    self.tableuserlist!.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
                    self.tableuserlist!.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
                    self.selectRowIfNeeded()
                    CATransaction.commit()
                    
                    
                }, animated:true)
        }
        
        self.isEditingUserList = !self.isEditingUserList
        self.editBtn!.isSelected = self.isEditingUserList
    }
    
    //MARK: - NewList
    
    func selectRowIfNeeded() {
    }
    
    /**
        Present field to add new list, valid if can add more
     */
    func showNewListField() {
        self.newListBtn!.isEnabled = false
        self.editBtn!.isEnabled = false
        
        for cell in self.tableuserlist!.visibleCells {
            if let swipeCell = cell as? SWTableViewCell {
                swipeCell.hideUtilityButtons(animated: true)
            }
        }
        
        if !self.newListEnabled {
            if self.itemsUserList!.count >= 12{
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
                self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
                self.alertView!.showErrorIcon("Ok")
                self.newListBtn!.isEnabled = true
                self.editBtn!.isEnabled = true
                return
            }
            self.stateEdit =  true
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_NEW_LIST.rawValue, label: "")
            self.isShowingWishList = false
            self.isShowingSuperlists = false
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tableuserlist!.setContentOffset(CGPoint.zero, animated:false)
                self.editBtn!.alpha = 0
                //self.tableuserlist!.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }, completion: { (complete:Bool) -> Void in
                    self.hideSearchField({
                        }, atFinished: { () -> Void in
                            self.newListBtn!.backgroundColor = WMColor.light_gray
                            CATransaction.begin()
                            CATransaction.setCompletionBlock({ () -> Void in
                                CATransaction.begin()
                                CATransaction.setCompletionBlock({ () -> Void in
                                    var cells = self.tableuserlist!.visibleCells
                                    for idx in 0 ..< cells.count {
                                            if let cell = cells[idx] as? ListTableViewCell {
                                                cell.enableDuplicateList(true)
                                                cell.canDelete = false
                                            }
                                        }
                                        self.newListBtn!.isEnabled = true
                                        self.editBtn!.isEnabled = true
                                    })
                                    CATransaction.commit()
                                    
                                    self.newListEnabled = !self.newListEnabled
                                    self.newListBtn!.isSelected = self.newListEnabled
                                    self.tableuserlist!.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.bottom)
                                })
                                self.tableuserlist!.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
                                CATransaction.commit()
                                
                                //                        self.enabledHelpView = true
                                //                        self.editBtn!.enabled = false
                        })
                })
                
            }
            else {
                stateEdit =  false
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_CANCEL_NEW_LIST.rawValue, label: "")
            
                self.showSearchField({
                    self.editBtn!.alpha = 1
                    
                    self.newListEnabled = !self.newListEnabled
                    self.newListBtn!.isSelected = self.newListEnabled
                    
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({ () -> Void in
                        CATransaction.begin()
                        CATransaction.setCompletionBlock({ () -> Void in
                            var cells = self.tableuserlist!.visibleCells
                            var initial = self.isShowingWishList && self.needsToShowWishList ? 1 : 0
                            initial = initial + (self.isShowingSuperlists ? 1 : 0)
                            for idx in initial ..< cells.count {
                                if let cell = cells[idx] as? ListTableViewCell {
                                    cell.enableDuplicateList(false)
                                    cell.canDelete = true
                                }
                            }
                            self.newListBtn!.isEnabled = true
                        })
                        self.isShowingWishList = !self.isEditingUserList
                        self.isShowingSuperlists = !self.isEditingUserList
                        self.tableuserlist!.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.bottom)
                        CATransaction.commit()
                    })
                    self.tableuserlist!.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.top)
                    CATransaction.commit()
                    
                    self.newListBtn!.backgroundColor = WMColor.green
                    }, atFinished: {
                        self.editBtn!.isEnabled = true
                        self.tableuserlist?.reloadData()
                    }, animated:true
                )
            }
    }
    
    //MARK: - NewListTableViewCellDelegate
    
    /**
        Remove field to add more list
     */
    func cancelNewList() {
        self.showNewListField()
    }
    
    /**
     Call Service to add new list, and reload user list
     
     - parameter value: name new list
     */
    func createNewList(_ value:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.creatingList", comment:""))
        
        let svcList = GRSaveUserListService()
        svcList.callService(svcList.buildParams(value),
            successBlock: { (result:[String:Any]) -> Void in
                
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_CREATE_NEW_LIST.rawValue, label: value)
                
                self.checkEditBtn()
                self.newListEnabled = false
                self.isShowingWishList  = true
                self.isShowingSuperlists = true
                
                self.newListBtn!.isSelected = false
                self.newListBtn!.backgroundColor = WMColor.green
                self.reloadList(
                    success: { () -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.listDone", comment:""))
                        self.alertView!.showDoneIcon()
                        var count = 0
                        
                        if UserCurrentSession.hasLoggedUser() {
                            self.newListEnabled = true
                            self.cancelNewList()

                            for itemList in self.itemsUserList! as! [List] {
                                if itemList.name == value {
                                    self.tableView(self.tableuserlist!, didSelectRowAt: IndexPath(row:count,section:1))
                                    return
                                }
                                count += 1
                            }
                        }
                        self.newListEnabled = true
                        self.cancelNewList()
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
    
    /**
     Present barcode controller, to scan ticket
     */
    func scanTicket() {
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.searchProduct = false
        barCodeController.useDelegate = true
        barCodeController.onlyCreateList = true
        self.present(barCodeController, animated: true, completion: nil)
    }
    
    //MARK: - ListTableViewCellDelegate
    /**
        Call service to doubles list from cell selected
     
     - parameter cell: cell or list doubles,
     */
    func duplicateList(_ cell:ListTableViewCell) {
      let service = GRUserListService()
      self.itemsUserList = service.retrieveUserList()
      self.itemsUserList =  self.itemsUserList?.sorted(by: { (first:Any, second:Any) -> Bool in
            let firstString = first as! List
            let secondString = second as! List
            return firstString.name < secondString.name
            
        })

      if let indexPath = self.tableuserlist!.indexPath(for: cell) {
        if self.itemsUserList!.count >= 12 {
          if self.alertView != nil{
            self.alertView!.close()
            self.alertView = nil
          }
          self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
          self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
          self.alertView!.showErrorIcon("Ok")
          return
        }
        else if let listItem = self.itemsUserList![indexPath.row] as? [String:Any] {
          let listId = listItem["id"] as! String
          let listName = listItem["name"] as! String
          
        

          self.invokeSaveListToDuplicateService(forListId: listId, andName: listName, successDuplicateList: { () -> Void in
            self.newListEnabled = false
            self.isShowingWishList  = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            self.newListBtn!.isSelected = false
            self.newListBtn!.backgroundColor = WMColor.green
            
            self.reloadList(
              success: { () -> Void in
                self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                self.alertView!.showDoneIcon()
                //---
                self.newListEnabled = true
                self.cancelNewList()
                self.listSelectedDuplicate = nil
                //---
            },
              failure: { (error) -> Void in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.listSelectedDuplicate = nil
            })
            
          })
        }else if let listItem = self.itemsUserList![indexPath.row] as? List {
         
          
          if UserCurrentSession.hasLoggedUser() {//Con session
           
            let copyName = self.buildDuplicateNameList(listItem.name, forListId: nil)

            self.invokeSaveListToDuplicateService(forListId: listItem.idList!, andName: copyName, successDuplicateList: { () -> Void in
              self.newListEnabled = false
              self.isShowingWishList  = !self.isEditingUserList
              self.isShowingSuperlists = !self.isEditingUserList
              self.newListBtn!.isSelected = false
              self.newListBtn!.backgroundColor = WMColor.green
              
              self.reloadList(
                success: { () -> Void in
                  self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                  self.alertView!.showDoneIcon()
                  //---
                  self.newListEnabled = true
                  self.cancelNewList()
                self.listSelectedDuplicate = nil
                  //---
              },
                failure: { (error) -> Void in
                  self.alertView!.setMessage(error.localizedDescription)
                  self.alertView!.showErrorIcon("Ok")
                self.listSelectedDuplicate = nil
              })
              
            })
            
          }else{//Sin sessión
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.creatingList", comment:""))
            
            let copyName = self.buildDuplicateNameList(listItem.name, forListId: nil)
            let clist = NSEntityDescription.insertNewObject(forEntityName: "List", into: self.managedContext!) as? List
            clist!.name = copyName
            clist!.registryDate = Date()
            clist!.countItem = NSNumber(value: 0 as Int)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "list == %@", listItem)
            var result: [Product]? = nil
            do{
              result = try self.managedContext!.fetch(fetchRequest) as? [Product]
            }catch{
              print("Error executeFetchRequest")
            }
            if result != nil && result!.count > 0 {
              clist!.countItem = NSNumber(value: result!.count as Int)
              for idx in 0 ..< result!.count {
                let item = result![idx]
                let detail = NSEntityDescription.insertNewObject(forEntityName: "Product", into: self.managedContext!) as? Product
                detail!.upc = item.upc
                detail!.type = item.type
                detail!.img = item.img
                detail!.desc = item.desc
                detail!.price = item.price
                detail!.quantity = item.quantity
                detail!.stock = item.stock
                detail!.promoDescription = item.promoDescription
                detail!.pieces = item.pieces
                detail!.orderByPiece = item.orderByPiece
                detail!.equivalenceByPiece = item.equivalenceByPiece
                detail!.list = clist!
                
                
                // 360 Event
                BaseController.sendAnalyticsProductToList(detail!.upc, desc: detail!.desc, price: detail!.price as String)
              }
            }
            
            self.saveContext()
            self.newListEnabled = false
            self.isShowingWishList  = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            
            self.newListBtn!.isSelected = false
            self.newListBtn!.backgroundColor = WMColor.green
            self.reloadList(
              success: { () -> Void in
                self.alertView?.setMessage(NSLocalizedString("list.message.listDuplicated", comment:""))
                self.alertView?.showDoneIcon()
                //---
                self.newListEnabled = true
                self.cancelNewList()
                self.listSelectedDuplicate = nil
                //---
            },
              failure: { (error) -> Void in
                self.alertView?.setMessage(error.localizedDescription)
                self.alertView?.showErrorIcon("Ok")
                self.listSelectedDuplicate = nil
            })
            
          }
          
        }
      }
    }
  
    /**
     change name to list
   
     - parameter cell: cell to edit
     - parameter text: name list
     */
    func didListChangeName(_ cell:ListTableViewCell, text:String?) {
        if let indexPath = self.tableuserlist!.indexPath(for: cell) {
            
            changeNames = true
            
            if self.listToUpdate == nil {
                self.listToUpdate = [:]
            }
          
            let idx = self.newListEnabled ? indexPath.row - 1 : indexPath.row
            
            if let listItem = self.itemsUserList![idx] as? [String:Any] {
                
                let listId = listItem["id"] as! String
                self.listToUpdate![listId] = text
                
            } else if let listEntity = self.itemsUserList![idx] as? List {
                
                var entityId = listEntity.objectID.uriRepresentation().absoluteString
                
                if UserCurrentSession.hasLoggedUser() {
                  entityId = listEntity.idList!
                }
              
                self.listToUpdate![entityId] = text
            }
            
        }
    }
    
    func didListChangeNameFailed(){
        changeNames =  false
    }
    
    func editCell(_ cell: SWTableViewCell) {
      self.cellEditing = cell
    }
    
    //MARK: - SWTableViewCellDelegate
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0://Duplicate list
            if let cellList = cell as? ListTableViewCell {
                cellList.duplicate()
            }
        case 1://Delete list
            if let indexPath = self.tableuserlist!.indexPath(for: cell) {
                if  UserCurrentSession.hasLoggedUser() {
                    if let listEntity = self.itemsUserList![indexPath.row] as? List {
                        let listId = listEntity.idList
                        self.invokeDeleteListService(listId!)
                    }
                }
                    //Si existe como entidad solo debe eliminarse de la BD
                else if let listEntity = self.itemsUserList![indexPath.row] as? List {
                    self.managedContext!.delete(listEntity)
                    self.saveContext()
                    //No hay que generar acciones adicionales para este caso
                    //                    self.reloadList(success: nil, failure: nil)
                    self.reloadWithoutTableReload(success: nil, failure: nil)
                    //self.tableuserlist!.beginUpdates()
                    //self.tableuserlist!.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    //self.tableuserlist!.endUpdates()
                    
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
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
        switch index {
        case 0:
            cell.showRightUtilityButtons(animated: true)
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, canSwipeTo state: SWCellState) -> Bool {
        switch state {
        case SWCellState.cellStateLeft:
            return self.isEditingUserList
        case SWCellState.cellStateRight:
            if self.isEditingUserList { return true }
            if let validateCanDelete = cell as? ListTableViewCell {
                return validateCanDelete.canDelete
            } else {
                return true
            }
        case SWCellState.cellStateCenter:
            return !self.isEditingUserList
        //default:
        //    return !self.isEditingUserList
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return !self.isEditingUserList
    }
    
    // MARK: - Actions
    
    /**
     Present view to search in to list
     
     - parameter aditionalAnimations: animation return
     - parameter action:                when finish animation return action
     - parameter animated:            if anitamete send true
     */
    func showSearchField(_ aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?,animated:Bool) {
        self.isToggleBarEnabled = false
        self.searchContainer!.isHidden = false
        self.searchConstraint!.constant = self.SC_HEIGHT
        if animated {
            
            UIView.animate(withDuration: 0.4,
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
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
            self.isToggleBarEnabled = true
        }
    }
    
    /**
     remove field search in list
     
     - parameter aditionalAnimations: block animation
     - parameter action:              when finish animation return action
     */
    func hideSearchField(_ aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?) {
        self.isToggleBarEnabled = false
        self.searchConstraint!.constant = -5.0 //La seccion de busqueda es mas grande que el header
        //        UIView.animateWithDuration(0.5,
        UIView.animate(withDuration: 0.2,
            animations: { () -> Void in
                self.view.layoutIfNeeded()
                aditionalAnimations?()
            }, completion: { (finished:Bool) -> Void in
                if finished {
                    self.searchContainer!.isHidden = true
                    action?()
                    self.isToggleBarEnabled = true
                }
            }
        )
    }
    
    func showHelpTicketView() {
        if self.helpView != nil {
            self.helpView!.removeFromSuperview()
            self.helpView = nil
        }
        
        var requiredHelp = true
        if let param = self.retrieveParam("ticketCamHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if requiredHelp && UserCurrentSession.sharedInstance.userSigned != nil {
            self.helpView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
            self.helpView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserListViewController.removeHelpTicketView)))
            self.view.addSubview(self.helpView!)
            
            let icon = UIImageView(image: UIImage(named: "list_scan_ticket_help"))
            icon.frame = CGRect(x: 12.0, y: self.header!.frame.maxY + 16.0, width: 48.0, height: 48.0)
            self.helpView!.addSubview(icon)
            
            let message = UILabel(frame: CGRect(x: icon.frame.maxX + 12.0, y: self.header!.frame.maxY + 20.0, width: self.view.bounds.width - 88.0, height: 40.0))
            message.numberOfLines = 0
            message.textColor = UIColor.white
            message.textAlignment = .center
            message.font = WMFont.fontMyriadProRegularOfSize(16.0)
            message.text = NSLocalizedString("list.message.help", comment:"")
            self.helpView!.addSubview(message)
            
            let arrow = UIImageView(image: UIImage(named: "list_arrow_help"))
            arrow.frame = CGRect(x: icon.frame.midX, y: message.frame.maxY - 5.0, width: 80.0, height: 28.0)
            self.helpView!.addSubview(arrow)
            
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.helpView!.alpha = 1.0
                }, completion: {(finished:Bool) -> Void in
                    if finished {
                        //let time = dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
                        //dispatch_after(time, dispatch_get_main_queue(), {
                        //  self.removeHelpTicketView()
                        //})
                    }
                }
            )
        }
        
    }
    
    func removeHelpTicketView() {
        if self.helpView != nil {
            UIView.animate(withDuration: 0.5,
                animations: { () -> Void in
                    self.helpView!.alpha = 0.0
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        self.enabledHelpView = false
                        self.helpView!.removeFromSuperview()
                        self.helpView = nil
                        self.addOrUpdateParam("ticketCamHelp", value: "false")
                        if let cell = self.tableuserlist!.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewListTableViewCell {
                            cell.inputNameList!.becomeFirstResponder()
                        }
                    }
                }
            )
        }
    }
    
    /**
     Open WishList and generate tag of Analytics
     */
    func showWishlist() {
        WishlistService.shouldupdate = true
        let vc = storyboard!.instantiateViewController(withIdentifier: "wishlitsItemVC")
        self.navigationController!.pushViewController(vc, animated: true)
        
        ////BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_TAPPED_VIEW_DETAILS_WISHLIST.rawValue, label: "")
        
    }
    
    /**
     Open super list controller and generate tag of Analytics
     */
    func showDefaultLists() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "defaultListVC")
        self.navigationController!.pushViewController(vc, animated: true)
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_TAPPED_VIEW_DETAILS_SUPERLIST.rawValue, label: "")
        
    }
    

    
    func removeWishlistHelp(_ recognizer:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5,
            animations: { () -> Void in
                self.viewTapHelp!.alpha = 0.0
            },
            completion: { (finished:Bool) -> Void in
                if finished {
                    self.viewTapHelp!.removeFromSuperview()
                    self.viewTapHelp = nil
                    self.addOrUpdateParam("wishlistHelp", value: "false")
                }
            }
        )
    }
    
    /**
     Present loader in screen list
     */
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    /**
     Remove loader from screen list
     */
    func removeLoadingView() {
        let param = CustomBarViewController.retrieveParam("listUpdated", forUser: UserCurrentSession.hasLoggedUser())
        if self.viewLoad != nil && param != nil && param!.value == "true" {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showListDetail" {
            if let controller = segue.destination as? UserListDetailViewController {
                controller.itemsUserList = self.itemsUserList
                controller.listId = self.selectedListId
                controller.listName = self.selectedListName
                controller.listEntity = self.selectedEntityList
                controller.detailDelegate = self
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.itemsUserList!.count
        }
        var size = (self.newListEnabled ? 1 : 0)
        size = size + (self.isShowingWishList && needsToShowWishList ? 1 : 0)
        size = size + (self.isShowingSuperlists ? 1 : 0)
        return size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //WishList
        if  indexPath.section == 0 {
            
            if indexPath.row == 0 && self.newListEnabled {
                let listCell = tableView.dequeueReusableCell(withIdentifier: self.NEWCELL_ID) as! NewListTableViewCell
                listCell.delegate = self
                listCell.accessoryView = nil
                let _ = searchField?.resignFirstResponder()
                Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(UserListViewController.become(timer:)), userInfo: listCell, repeats: false)
                
                return listCell
            }
            var currentRow = (self.newListEnabled ? 1 : 0)
            
            let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID) as! ListTableViewCell
            listCell.delegate = self
            listCell.listDelegate = self
            
            if (indexPath.row == 0 && self.isShowingWishList && self.needsToShowWishList)  {
                listCell.setValues(name: NSLocalizedString("wishlist.title", comment: ""), count: "\(UserCurrentSession.sharedInstance.userItemsInWishlist())", icon: UIImage(named: "wishlist")!,enableEditing: false)
                listCell.canDelete = false
                listCell.enableDuplicateList(self.newListEnabled)
                listCell.shouldChangeState = !self.isEditingUserList
                listCell.setEditing(self.isEditingUserList, animated: false)
                listCell.showLeftUtilityButtons(animated: false)
                listCell.enableEditList(self.isEditingUserList)
                listCell.accessoryView = nil
                listCell.selectionStyle = .none
                return listCell
            }
            
            currentRow = currentRow + (self.isShowingWishList ? 1 : 0)
            if (indexPath.row == 0 && self.isShowingSuperlists ) || (indexPath.row == 1 && self.isShowingSuperlists && self.needsToShowWishList) || (indexPath.row == 1 && self.isShowingSuperlists && self.newListEnabled && !self.needsToShowWishList) || (indexPath.row == 2 && self.isShowingSuperlists && self.newListEnabled)  {
                listCell.setValues(name: "Superlistas", count: "\(numberOfDefaultLists)", icon: UIImage(named: "superlist_list")!,enableEditing: false)
                listCell.articlesTitle!.text = String(format: "%@ listas", "\(numberOfDefaultLists)")
                listCell.canDelete = false
                listCell.enableDuplicateList(self.newListEnabled)
                listCell.shouldChangeState = !self.isEditingUserList
                listCell.setEditing(self.isEditingUserList, animated: false)
                listCell.showLeftUtilityButtons(animated: false)
                listCell.enableEditList(self.isEditingUserList)
                listCell.accessoryView = UIImageView(image:UIImage(named:"practilist_gooo"))
                
                return listCell
            }
        }
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID) as! ListTableViewCell
        listCell.delegate = self
        listCell.listDelegate = self
        
        if let listItem = self.itemsUserList![indexPath.row] as? [String:Any] {
            listCell.setValues(listObject:listItem)
        } else if let listEntity = self.itemsUserList![indexPath.row] as? List {
            listCell.setValues(listEntity: listEntity)
        }
        listCell.canDelete = true
        listCell.enableDuplicateList(self.newListEnabled)
        listCell.shouldChangeState = !self.isEditingUserList
        listCell.setEditing(self.isEditingUserList, animated: false)
        listCell.showLeftUtilityButtons(animated: false)
        listCell.enableEditList(self.isEditingUserList)
        if self.isEditingUserList {
            listCell.showLeftUtilityButtons(animated: false)
        }
        listCell.accessoryView = nil
        listCell.selectionStyle = .none
        return listCell
    }
    
    func become(timer:Timer){
      let cell =  timer.userInfo as? NewListTableViewCell
       if (cell?.inputNameList?.isFirstResponder)! {
            cell?.inputNameList?.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 && self.newListEnabled {
                return
            }
            if !self.newListEnabled {
                if indexPath.row == 0 && self.isShowingWishList && self.needsToShowWishList {
                    showWishlist()
                    return
                }
                else if indexPath.row == 1 && self.isShowingSuperlists {
                    showDefaultLists()
                    return
                }
            }
            return
        }
        if indexPath.section != 0  && !self.isShowingWishList {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            return
        }
        
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_TAPPED_VIEW_DETAILS_MYLIST.rawValue, label: "")
        
        if let listItem = self.itemsUserList![indexPath.row] as? [String:Any] {
            if let listId = listItem["id"] as? String {
                self.selectedListId = listId
                self.selectedListName = listItem["name"] as? String
                self.selectedIndex = indexPath

                self.performSegue(withIdentifier: "showListDetail", sender: self)
            }
        }
        else if let listEntity = self.itemsUserList![indexPath.row] as? List {
            self.selectedEntityList = listEntity
            self.selectedListId = listEntity.idList
            self.selectedListName = listEntity.name
            self.selectedIndex = indexPath
            
            self.performSegue(withIdentifier: "showListDetail", sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let newCell = cell as? NewListTableViewCell {
            newCell.inputNameList!.text = ""
            if self.enabledHelpView {
                self.showHelpTicketView()
            }
            if self.helpView == nil && !newCell.scanning {
                newCell.inputNameList!.becomeFirstResponder()
            }
        }
    }
    
    
    //MARK: - Utils
    /**
     Change name list and validete if name exist.
     */
    func changeEntityNames() {
        if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
            let array = Array(self.listToUpdate!.keys)
            for idx in 0 ..< array.count {
                let idList = array[idx]
                
                var list:List? = nil
                for idxl in 0 ..< self.itemsUserList!.count {
                    if let entity = self.itemsUserList![idxl] as? List {
                        if entity.objectID.uriRepresentation().absoluteString == idList {
                            list = entity
                            break
                        }
                    }
                }
                
                if list != nil {
                    
                    let name = self.listToUpdate![idList]!
                    if name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
                        self.alertView!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
                        self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                        return
                    }
                    
                    if !validateListName(idList, nameList: name) {
                        return
                    }
                    
                    list!.name = name
                }
            }
            self.saveContext()
        }
    }
    
    //MARK: - Services
    /**
     Invoke delete list service
     
     - parameter listId: id list to remove.
     */
    func invokeDeleteListService(_ listId:String) {
        if !self.deleteListServiceInvoked {
            self.deleteListServiceInvoked = true
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.deletingList", comment:""))
            
            let service = GRDeleteUserListService()
            service.buildParams(listId)
            service.callService(nil,
                successBlock:{ (result:[String:Any]) -> Void in
                    service.deleteListInDB(listId)
                    self.reloadList(
                        success: { () -> Void in
                            self.alertView!.setMessage(NSLocalizedString("list.message.deleteListDone", comment:""))
                            self.alertView!.showDoneIcon()
                            self.deleteListServiceInvoked = false
                            let reminderService = ReminderNotificationService(listId: listId, listName: "")
                            reminderService.removeNotificationsFromCurrentList()
                        },
                        failure: { (error) -> Void in
                            self.alertView!.setMessage(error.localizedDescription)
                            self.alertView!.showErrorIcon("Ok")
                            self.deleteListServiceInvoked = false
                    })
                },
                errorBlock:{ (error:NSError) -> Void in
                    print("Error at delete list \(listId)")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                    self.deleteListServiceInvoked = false
                }
            )
        }
    }
    
   
    /**
     validate name and call sevices update and get list detail
     */
    func invokeUpdateListService() {
        if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
            if  self.alertView == nil {
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            }
            self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNames", comment:""))
            
            let array = Array(self.listToUpdate!.keys)
            let firstKey = array.first
            let name = self.listToUpdate![firstKey!]
            
            if name == nil || name!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                self.alertView!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            
            if !validateListName(firstKey!, nameList: name!) {
                self.alertView!.setMessage(NSLocalizedString("gr.list.samename", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            
            let whitespaceset = CharacterSet.whitespaces
            
            let trimmedString = name!.trimmingCharacters(in: whitespaceset)
            let length = trimmedString.lengthOfBytes(using: String.Encoding.utf8)
            if length == 0 {
                self.alertView!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            if length < 2 {
                self.alertView!.setMessage(NSLocalizedString("list.new.validation.name.tiny", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            
            let alphanumericset = CharacterSet(charactersIn: "áéíóúÁÉÍÓÚabcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890 ").inverted
            let cleanedName = (trimmedString.components(separatedBy: alphanumericset) as NSArray).componentsJoined(by: "")
            if trimmedString != cleanedName {
                self.alertView!.setMessage(NSLocalizedString("list.new.validation.name.notvalid", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }

            self.view.endEditing(true)
            let detailService = GRUserListDetailService()
            detailService.buildParams(firstKey!)
            detailService.callService([:],
                successBlock: { (result:[String:Any]) -> Void in
                    let service = GRUpdateListService()
                    service.callService(name!,
                        successBlock: { (result:[String:Any]) -> Void in
                            service.updateListNameDB(firstKey!, listName: name!)
                            let reminderService = ReminderNotificationService()
                            reminderService.listId = firstKey!
                            reminderService.updateListName(name!)
                            self.listToUpdate!.removeValue(forKey: firstKey!)
                            if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
                              
                                self.invokeUpdateListService()
                            }
                            else {
                                self.reloadList(
                                    success:{() -> Void in
                                        self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNamesDone", comment:""))
                                        self.alertView!.showDoneIcon()
                                        
                                    },
                                    failure: {(error:NSError) -> Void in
                                        self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNamesDone", comment:""))
                                        self.alertView!.showDoneIcon()
                                      
                                    }
                                )
                            }
                        },
                        errorBlock: { (error:NSError) -> Void in
                            self.listToUpdate!.removeValue(forKey: firstKey!)
                            if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
                                self.invokeUpdateListService()
                            }
                            else {
                                self.alertView!.setMessage(error.localizedDescription)
                                self.alertView!.showErrorIcon("Ok")
                            }
                        }
                    )
                },
                errorBlock: { (error:NSError) -> Void in
                  print("Error \(error.localizedDescription)")
                  self.alertView?.setMessage(error.localizedDescription)
                  self.alertView?.showErrorIcon("Ok")
            
            })

        }
    }
    
    /**
     Validate if name list exist
     
     - parameter idLits:   id list change name
     - parameter nameList: name list
     
     - returns: exist or no list
     */
    func validateListName(_ idLits:String,nameList:String) -> Bool {
        //Validate list exist
        if let itemsList = self.itemsUserList {
            for itemInList in itemsList {
                if let itemInListVal = itemInList as? [String:Any] {
                    if let nameListSvc = itemInListVal["name"] as? String {
                        if let idListSvc = itemInListVal["id"]  as? String  {
                            if nameListSvc == nameList  && idListSvc != idLits {
                                return false
                            }
                        }
                    }
                }
                if let itemInListVal = itemInList as? List {
                    if itemInListVal.name == nameList  && itemInListVal.idList != idLits {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    //MARK: - BarCodeViewControllerDelegate
    func barcodeCaptured(_ value:String?) {
        if value == nil {
            return
        }
        print("Code \(value)")
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.retrieveProductsFromTicket", comment:""))
        let service = GRProductByTicket()
        service.callService(service.buildParams(value!),
            successBlock: { (result: [String:Any]) -> Void in
                if let items = result["items"] as? [Any] {
                    
                    if items.count == 0 {
                        self.alertView!.setMessage(NSLocalizedString("list.message.noProductsForTicket", comment:""))
                        self.alertView!.showErrorIcon("Ok")
                        return
                    }
                    
                    let saveService = GRSaveUserListService()
                    
                    self.alertView!.setMessage(NSLocalizedString("list.message.creatingListFromTicket", comment:""))
                    
                    var products:[Any] = []
                    for idx in 0 ..< items.count {
                        var item = items[idx] as! [String:Any]
                        let upc = item["upc"] as! String
                        let quantity = item["quantity"] as! NSNumber
                        var baseUomcd = "EA"
                        if let baseUcd = item["baseUomcd"] as? String {
                            baseUomcd = baseUcd
                        }
                        
                        let param = saveService.buildBaseProductObject(upc: upc, quantity: quantity.intValue,baseUomcd:baseUomcd )//send baseUomcd
                        products.append(param)
                        
                        guard let name = item["description"] as? String,
                            let id = item["upc"] as? String,
                            let price = item["price"] else {
                                return
                        }
                        
                        // 360 Event
                        BaseController.sendAnalyticsProductToList(id, desc: name, price: "\(price as! Int)")
                    }
                    
                    let fmt = DateFormatter()
                    fmt.dateFormat = "MMM d"
                    var name = fmt.string(from: Date())
                    var number = 0;
                    
                    if self.itemsUserList != nil {
                        for item in  self.itemsUserList! as! [List]{
                          
                            if let nameList = item.name as? String {
                                if nameList.uppercased().hasPrefix(name.uppercased()) {
                                    number = number+1
                                }
                            }
                        }
                    }
                    
                    if number > 0 {
                        name = "\(name) \(number)"
                    }
                    
                    
                    saveService.callService(saveService.buildParams(name, items: products),
                        successBlock: { (result:[String:Any]) -> Void in

                            if let cell = self.tableuserlist!.cellForRow(at: IndexPath(row: 0, section:0)) as? NewListTableViewCell {
                                cell.scanning = false
                            }
                            self.newListEnabled = false
                            self.isShowingWishList  = true
                            self.isShowingSuperlists = true
                            
                            self.newListBtn!.isSelected = false
                            self.newListBtn!.backgroundColor = WMColor.green
                            self.reloadList(
                                success: { () -> Void in
                                    self.alertView!.setMessage(NSLocalizedString("list.message.creatingListFromTicketDone", comment:""))
                                    self.alertView!.showDoneIcon()
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
            }, errorBlock: { (error:NSError) -> Void in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
            }
        )
    }
 
    //MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: string) as NSString
        
        self.itemsUserList = self.searchForItems(txtAfterUpdate as String)
        self.tableuserlist!.reloadData()
        self.editBtn!.isHidden = self.itemsUserList == nil || self.itemsUserList!.count == 0
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Notifications
    
    func keyboardWillShow(_ aNotification: Notification) {
        var info = aNotification.userInfo
        let kbFrame = info![UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardFrame = kbFrame!.cgRectValue
        
        var height = keyboardFrame.size.height
        //height += self.searchContainer!.frame.height
        height += 45.0 //TABBar height
        if self.cellEditing != nil {
            let indexPath =  self.tableuserlist!.indexPath(for: self.cellEditing!)
            self.tableuserlist!.contentInset = UIEdgeInsetsMake(0, 0, height, 0)
            self.tableuserlist!.scrollToRow(at: indexPath!, at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    
    func keyboardWillHide(_ aNotification: Notification) {
        self.tableuserlist!.contentInset = UIEdgeInsets.zero
    }
    
    //MARK: - DB
    
    func retrieveParam(_ key:String) -> Param? {
        let user = UserCurrentSession.sharedInstance.userSigned
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Param", in: self.managedContext!)
        if user != nil {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, user!)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, NSNull())
        }
        var parameter: Param? = nil
        do{
            let result = try self.managedContext!.fetch(fetchRequest) as? [Param]
            if result != nil && result!.count > 0 {
                parameter = result!.first
            }
            
        }
        catch{
            print("retrieveParam error")
        }
        return parameter
    }
    
    func addOrUpdateParam(_ key:String, value:String) {
        if let param = self.retrieveParam(key) {
            param.value = value
        }
        else {
            let param = NSEntityDescription.insertNewObject(forEntityName: "Param", into: self.managedContext!) as? Param
            if let user = UserCurrentSession.sharedInstance.userSigned {
                param!.user = user
            }
            param!.key = key
            param!.value = value
        }
        self.saveContext()
    }
    
    func saveContext() {
        if self.managedContext!.hasChanges {
            do {
                try self.managedContext!.save()
            } catch {
                print("error at save context on UserListViewController")
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        
    }
    
    func searchForItems(_ textUpdate:String) -> [List]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: self.managedContext!)
        if textUpdate != "" {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR  (ANY products.desc CONTAINS[cd] %@)",textUpdate,textUpdate)
        }
        var result: [List]? =  nil
        do{
            result =  try self.managedContext!.fetch(fetchRequest) as? [List]
        }catch{
            print("searchForItems Error")
        }
        return result
    }
    
    func invokeDefaultUserListService() {
        let defaultlist = DefaultListService()
        defaultlist.callService({ (result:[String:Any]) -> Void in
            print("Call DefaultListService sucess")
            self.updateNumberOfDefaultList()
        }, errorBlock: { (error:NSError) -> Void in
            print("Call DefaultListService error \(error)")
            self.updateNumberOfDefaultList()
        })
    }
    
    func invokeWishListService() {
        let service = UserWishlistService()
        service.callCoreDataService({(result:[String:Any]) -> Void in
            print("Call WishList Service sucess")
        }, errorBlock: { (error:NSError) -> Void in
            print("Call WishList Service error \(error)")
        })
    }
    
    func updateNumberOfDefaultList() {
        let defaultListSvc = DefaultListService()
        numberOfDefaultLists = defaultListSvc.getDefaultContent().count
        self.tableuserlist?.reloadData()
    }
    
    func updateListTable(){
        self.reloadList(success: { () -> Void in
          self.removeLoadingView()
            },failure: { (error) -> Void in
               self.removeLoadingView()
           })
    }
    
    //MARK: RefreshControl
    
    func handleRefresh(refreshControl: UIRefreshControl) {
      if UserCurrentSession.hasLoggedUser() {
        let user = UserCurrentSession.sharedInstance
        user.invokeWishListService()
        user.invokeGroceriesUserListService({ () -> Void in
            self.reloadList(success: nil, failure: nil)
            delay(0.5, completion: {
                refreshControl.endRefreshing()
            })
        })
      }else{
        self.reloadList(success: nil, failure: nil)
        delay(0.5, completion: {
           refreshControl.endRefreshing()
        })
       
      }
  }
}

