//
//  UserListViewController.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 1/13/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class UserListViewController : UserListNavigationBaseViewController, UITableViewDelegate, UITableViewDataSource, NewListTableViewCellDelegate, SWTableViewCellDelegate, UITextFieldDelegate, ListTableViewCellDelegate, BarCodeViewControllerDelegate, UIScrollViewDelegate {
    
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
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MYLIST.rawValue
    }
    
    var numberOfDefaultLists = 0
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
        }()
    
    override func viewDidLoad() {
        self.hiddenBack = true
        super.viewDidLoad()
        
        tableuserlist?.multipleTouchEnabled = true
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_MYLIST.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }
        
        let iconImage = UIImage(color: WMColor.light_blue, size: CGSizeMake(110, 44), radius: 22) // UIImage(named:"button_bg")
        let iconSelected = UIImage(color: WMColor.UIColorFromRGB(0x8EBB36), size: CGSizeMake(110, 44), radius: 22)
        
        self.titleLabel?.text = NSLocalizedString("list.title",comment:"")
        self.titleLabel?.textAlignment = .Left
        self.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        
        self.newListBtn = UIButton(type: .Custom)
        self.newListBtn!.setTitle(NSLocalizedString("list.new", comment:""), forState: .Normal)
        self.newListBtn!.setTitle(NSLocalizedString("list.endnew", comment:""), forState: .Selected)
        self.newListBtn!.setTitleColor(WMColor.navigationFilterTextColor, forState: .Normal)
        self.newListBtn!.setTitleColor(WMColor.UIColorFromRGB(0x2970CA), forState: .Selected)
        self.newListBtn!.addTarget(self, action: "showNewListField", forControlEvents: .TouchUpInside)
        self.newListBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36)//WMColor.green
        self.newListBtn!.layer.cornerRadius = 11.0
        self.newListBtn!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.header!.addSubview(self.newListBtn!)
        
        self.editBtn = UIButton(type: .Custom)
        self.editBtn!.setTitle(NSLocalizedString("list.edit", comment:""), forState: .Normal)
        self.editBtn!.setTitle(NSLocalizedString("list.endedit", comment:""), forState: .Selected)
        self.editBtn!.setBackgroundImage(iconImage, forState: .Normal)
        self.editBtn!.setBackgroundImage(iconSelected, forState: .Highlighted)
        self.editBtn!.setBackgroundImage(iconSelected, forState: .Selected)
        self.editBtn!.addTarget(self, action: "showEditionMode", forControlEvents: .TouchUpInside)
        self.editBtn!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(11)
        //self.editBtn!.backgroundColor = WMColor.UIColorFromRGB(0x005AA2)
        self.editBtn!.layer.cornerRadius = 11.0
        self.editBtn!.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0.0);
        self.header!.addSubview(self.editBtn!)
        
        self.searchContainer!.backgroundColor = UIColor.whiteColor()
        
        self.searchField = FormFieldView()
        self.searchField!.maxLength = 100
        self.searchField!.delegate = self
        self.searchField!.setCustomPlaceholderRegular(NSLocalizedString("list.search.placeholder",comment:""))
        self.searchField!.typeField = .String
        self.searchField!.nameField = NSLocalizedString("list.search.placeholder",comment:"")
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = WMColor.lineSaparatorColor
        
        self.searchContainer!.addSubview(viewSeparator)
        self.searchContainer!.addSubview(searchField!)
        
        self.tableuserlist!.registerClass(ListTableViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableuserlist!.registerClass(NewListTableViewCell.self, forCellReuseIdentifier: self.NEWCELL_ID)
        
        let defaultListSvc = DefaultListService()
        numberOfDefaultLists = defaultListSvc.getDefaultContent().count
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadListFormUpdate", name: "ReloadListFormUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "duplicateList", name: "DUPLICATE_LIST", object: nil)
        self.showLoadingView()
        self.reloadList(
            success:{() -> Void in
                self.removeLoadingView()
            },
            failure: {(error:NSError) -> Void in
                self.removeLoadingView()
            }
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if CGRectEqualToRect(self.newListBtn!.frame, CGRectZero) {
            let headerBounds = self.header!.frame.size
            let buttonWidth: CGFloat = 55.0
            let buttonHeight: CGFloat = 22.0
            self.titleLabel!.frame = CGRectMake(16.0, 0.0, (headerBounds.width/2) - 16.0, headerBounds.height)
            self.newListBtn!.frame = CGRectMake(headerBounds.width - (buttonWidth   + 16.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
            self.editBtn!.frame = CGRectMake(self.newListBtn!.frame.minX - (buttonWidth + 8.0), (headerBounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        }
        
        let bounds = self.view.frame.size
        self.searchField!.frame = CGRectMake(16.0, 12.0, bounds.width - 32.0, 40.0)
        
        self.viewSeparator.frame = CGRectMake(0, searchContainer!.frame.height  - AppDelegate.separatorHeigth() , searchContainer!.frame.width,   AppDelegate.separatorHeigth())
    }
    
    func reloadListFormUpdate (){
        print("Notificacion para actualizar lista")
        self.reloadList(success: nil, failure: nil)
        print("Lista actualizada correctamente")
    }
    // va
    func checkEditBtn(){
        if self.itemsUserList == nil || self.itemsUserList!.count == 0{
            if self.isEditingUserList {
                self.showEditionMode()
            }
            UIView.animateWithDuration(0.4, animations: {
                self.editBtn!.hidden = true
                self.editBtn?.enabled = false
            })
        }
        else{
            UIView.animateWithDuration(0.4, animations: {
                self.editBtn!.hidden = false
                self.editBtn?.enabled = true
            })
        }
    }
    
    
    
    //MARK: - List Utilities
    
    func duplicateList(){
        let indexpath = self.tableuserlist!.indexPathForSelectedRow // NSIndexPath(forRow: 1, inSection: 1)
        let cell =  self.tableuserlist!.cellForRowAtIndexPath(indexpath!) as? ListTableViewCell
        self.duplicateList(cell!)
    }
    
    func changeVisibilityBtn(button: UIButton, visibility: CGFloat) {
        UIView.animateWithDuration(0.3, animations: {
            button.alpha = visibility
        })
    }
    
    func changeFrameEditBtn(front: Bool, side: String) {
        if front == true {
            self.header!.bringSubviewToFront(self.editBtn!)
        }
        else{
            self.header!.bringSubviewToFront(self.newListBtn!)
        }
        UIView.animateWithDuration(0.4, animations: {
            if side == "left" {
                self.editBtn!.frame = CGRectMake(self.newListBtn!.frame.minX - (self.newListBtn!.frame.width + 8.0), self.newListBtn!.frame.minY, self.newListBtn!.frame.width, self.newListBtn!.frame.height)
            }
            else if side == "right" {
                self.editBtn!.frame = self.newListBtn!.frame
            }
        })
    }
    
    func reloadList(success success:(()->Void)?, failure:((error:NSError)->Void)?){
        if let _ = UserCurrentSession.sharedInstance().userSigned {
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in
                    self.itemsUserList = result["responseArray"] as? [AnyObject]
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
            self.isShowingWishList = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            self.itemsUserList = self.retrieveNotSyncList()
            self.tableuserlist!.reloadData()
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
    
    func reloadWithoutTableReload(success success:(()->Void)?, failure:((error:NSError)->Void)?){
        if let _ = UserCurrentSession.sharedInstance().userSigned {
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in
                    self.isShowingWishList = !self.isEditingUserList
                    self.isShowingSuperlists = !self.isEditingUserList
                    self.itemsUserList = result["responseArray"] as? [AnyObject]
                    if !self.newListEnabled && !self.isEditingUserList {
                        self.showSearchField({ () -> Void in
                            }, atFinished: { () -> Void in
                            }, animated:false)
                    }
                    //self.editBtn!.hidden = (self.itemsUserList == nil || self.itemsUserList!.count == 0)
                    success?()
                    return
                },
                errorBlock: { (error:NSError) -> Void in
                    //                    self.editBtn!.hidden = true
                    failure?(error: error)
                    return
                }
            )
        }
        else {
            self.isShowingWishList = !self.isEditingUserList
            self.isShowingSuperlists = !self.isEditingUserList
            self.itemsUserList = self.retrieveNotSyncList()
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
    
    func showEditionMode() {
        

        self.cellEditing = nil
        self.newListBtn?.enabled = false
        self.editBtn?.enabled = false
        
        if !self.isEditingUserList {
            
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_EDIT_LIST.rawValue, label: "")
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
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
                                cell.showLeftUtilityButtonsAnimated(false)
                            }
                        }
                        self.newListBtn?.enabled = true
                        self.editBtn?.enabled = true
                    })
                    self.tableuserlist!.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
                    CATransaction.commit()
                }
            )
        }
        else {
            self.showSearchField({
                self.changeFrameEditBtn(true, side: "left")
                }, atFinished: { () -> Void in
                    
                    if let _ = UserCurrentSession.sharedInstance().userSigned {
                        self.alertView = nil
                        self.invokeUpdateListService()
                    }
                    else {
                        self.changeEntityNames()
                    }
                    
                    self.isShowingWishList = true
                    self.isShowingSuperlists = true
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({ () -> Void in
                        var cells = self.tableuserlist!.visibleCells
                        for var idx = 0; idx < cells.count; idx++ {
                            if let cell = cells[idx] as? ListTableViewCell {
                                cell.listName!.text = cell.textField!.text
                                cell.hideUtilityButtonsAnimated(false)
                                cell.setEditing(false, animated: false)
                                cell.enableEditList(false)
                            }
                        }
                        
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.newListBtn?.alpha = 1
                        })
                        
                        self.newListBtn?.enabled = true
                        self.editBtn?.enabled = true
                    })
                    self.tableuserlist!.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
                    self.tableuserlist!.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
                    self.selectRowIfNeeded()
                    CATransaction.commit()
                    
                    
                }, animated:true)
        }
        
        self.isEditingUserList = !self.isEditingUserList
        self.editBtn!.selected = self.isEditingUserList
    }
    
    //MARK: - NewList
    
    func selectRowIfNeeded() {
    }
    
    func showNewListField() {
        if self.itemsUserList!.count >= 12 {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
            self.alertView!.showErrorIcon("Ok")
        }
        else {
            
            self.newListBtn!.enabled = false
            self.editBtn!.enabled = false
            if !self.newListEnabled {

                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_NEW_LIST.rawValue, label: "")
                
                self.isShowingWishList = false
                self.isShowingSuperlists = false
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableuserlist!.setContentOffset(CGPointZero, animated:false)
                    self.editBtn!.alpha = 0
                    //self.tableuserlist!.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    }, completion: { (complete:Bool) -> Void in
                        self.hideSearchField({
                            }, atFinished: { () -> Void in
                                self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0xE3E3E5)
                                
                                CATransaction.begin()
                                CATransaction.setCompletionBlock({ () -> Void in
                                    
                                    CATransaction.begin()
                                    CATransaction.setCompletionBlock({ () -> Void in
                                        var cells = self.tableuserlist!.visibleCells
                                        for var idx = 0; idx < cells.count; idx++ {
                                            if let cell = cells[idx] as? ListTableViewCell {
                                                cell.enableDuplicateList(true)
                                                cell.canDelete = false
                                            }
                                        }
                                        self.newListBtn!.enabled = true
                                        self.editBtn!.enabled = true
                                    })
                                    CATransaction.commit()
                                    
                                    self.newListEnabled = !self.newListEnabled
                                    self.newListBtn!.selected = self.newListEnabled
                                    self.tableuserlist!.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
                                })
                                self.tableuserlist!.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
                                CATransaction.commit()
                                
                                //                        self.enabledHelpView = true
                                //                        self.editBtn!.enabled = false
                        })
                })
                
            }
            else {
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_CANCEL_NEW_LIST.rawValue, label: "")
                
                self.showSearchField({
                    self.editBtn!.alpha = 1
                    
                    self.newListEnabled = !self.newListEnabled
                    self.newListBtn!.selected = self.newListEnabled
                    
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({ () -> Void in
                        CATransaction.begin()
                        CATransaction.setCompletionBlock({ () -> Void in
                            var cells = self.tableuserlist!.visibleCells
                            for var idx = 0; idx < cells.count; idx++ {
                                if let cell = cells[idx] as? ListTableViewCell {
                                    cell.enableDuplicateList(false)
                                    cell.canDelete = true
                                }
                            }
                            self.newListBtn!.enabled = true
                        })
                        self.isShowingWishList = true
                        self.isShowingSuperlists = true
                        self.tableuserlist!.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
                        CATransaction.commit()
                    })
                    self.tableuserlist!.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
                    CATransaction.commit()
                    
                    self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36) // WMColor.green
                    }, atFinished: {
                        self.editBtn!.enabled = true
                        
                    }, animated:true
                )
            }
        }
    }
    
    //MARK: - NewListTableViewCellDelegate
    
    func cancelNewList() {
        self.showNewListField()
    }
    
    func createNewList(value:String) {
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.creatingList", comment:""))
        
        let svcList = GRSaveUserListService()
        svcList.callService(svcList.buildParams(value),
            successBlock: { (result:NSDictionary) -> Void in
                
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_CREATE_NEW_LIST.rawValue, label: value)
                
                self.checkEditBtn()
                self.newListEnabled = false
                self.isShowingWishList  = true
                self.isShowingSuperlists = true
                
                self.newListBtn!.selected = false
                self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36)//WMColor.green
                self.reloadList(
                    success: { () -> Void in
                        self.alertView!.setMessage(NSLocalizedString("list.message.listDone", comment:""))
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
    
    func scanTicket() {
        let barCodeController = BarCodeViewController()
        barCodeController.helpText = NSLocalizedString("list.message.help.barcode", comment:"")
        barCodeController.delegate = self
        barCodeController.searchProduct = false
        barCodeController.createListDelegate = true
        self.presentViewController(barCodeController, animated: true, completion: nil)
    }
    
    //MARK: - ListTableViewCellDelegate
    
    func duplicateList(cell:ListTableViewCell) {
        if let indexPath = self.tableuserlist!.indexPathForCell(cell) {
            
            if let listItem = self.itemsUserList![indexPath.row] as? NSDictionary {
                let listId = listItem["id"] as! String
                let listName = listItem["name"] as! String
//                self.invokeSaveListToDuplicateService(forListId: listId, andName: listName, successDuplicateList: { () -> Void in
//                    println("pase por acas")
//                }, itemsUserList: self.itemsUserList!)
                //self.invokeSaveListToDuplicateService(forListId: listId, andName: listName,succ)
                self.invokeSaveListToDuplicateService(forListId: listId, andName: listName, successDuplicateList: { () -> Void in
                    self.newListEnabled = false
                    self.isShowingWishList  = true
                    self.isShowingSuperlists = true
                    self.newListBtn!.selected = false
                    self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36)//WMColor.green
                    self.reloadList(
                        success: { () -> Void in
                            self.alertView!.setMessage(NSLocalizedString("list.copy.done", comment:""))
                            self.alertView!.showDoneIcon()
                        },
                        failure: { (error) -> Void in
                            self.alertView!.setMessage(error.localizedDescription)
                            self.alertView!.showErrorIcon("Ok")
                        }
                    )
                })
            }
            else if let listItem = self.itemsUserList![indexPath.row] as? List {
                if self.itemsUserList!.count <= 11 {
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
                    self.alertView!.setMessage(NSLocalizedString("list.message.creatingList", comment:""))
                    
                    let copyName = self.buildDuplicateNameList(listItem.name, forListId: nil)
                    let clist = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: self.managedContext!) as? List
                    clist!.name = copyName
                    clist!.registryDate = NSDate()
                    clist!.countItem = NSNumber(integer: 0)
                    
                    let fetchRequest = NSFetchRequest()
                    fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
                    fetchRequest.predicate = NSPredicate(format: "list == %@", listItem)
                     var result: [Product]? = nil
                    do{
                         result = try self.managedContext!.executeFetchRequest(fetchRequest) as? [Product]
                    }catch{
                       print("Error executeFetchRequest")
                    }
                    if result != nil && result!.count > 0 {
                        clist!.countItem = NSNumber(integer: result!.count)
                        for var idx = 0; idx < result!.count; idx++ {
                            let item = result![idx]
                            let detail = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.managedContext!) as? Product
                            detail!.upc = item.upc
                            detail!.img = item.img
                            detail!.desc = item.desc
                            detail!.price = item.price
                            detail!.quantity = item.quantity
                            detail!.list = clist!
                        }
                    }
                    
                    self.saveContext()
                    self.newListEnabled = false
                    self.isShowingWishList  = true
                    self.isShowingSuperlists = true
                    
                    self.newListBtn!.selected = false
                    self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36) //WMColor.green
                    self.reloadList(
                        success: { () -> Void in
                            self.alertView!.setMessage(NSLocalizedString("list.message.listDuplicated", comment:""))
                            self.alertView!.showDoneIcon()
                        },
                        failure: { (error) -> Void in
                            self.alertView!.setMessage(error.localizedDescription)
                            self.alertView!.showErrorIcon("Ok")
                        }
                    )
                }
                else{
                    self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
                    self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
                    self.alertView!.showErrorIcon("Ok")
                }
            }
        }
    }
    
    func didListChangeName(cell:ListTableViewCell, text:String?) {
        if let indexPath = self.tableuserlist!.indexPathForCell(cell) {
            if self.listToUpdate == nil {
                self.listToUpdate = [:]
            }
            
            let idx = self.newListEnabled ? indexPath.row - 1 : indexPath.row
            if let listItem = self.itemsUserList![idx] as? NSDictionary {
                let listId = listItem["id"] as! String
                
//                if text == nil || text!.isEmpty {
//                    self.listToUpdate!.removeValueForKey(listId)
//                    return
//                }
                
                self.listToUpdate![listId] = text
            }
            else if let listEntity = self.itemsUserList![idx] as? List {
                let entityId = listEntity.objectID.URIRepresentation().absoluteString
                
//                if cell.textField!.text == nil || cell.textField!.text!.isEmpty {
//                    self.listToUpdate!.removeValueForKey(entityId!)
//                }
                
                self.listToUpdate![entityId] = text
            }
            //println("list with id \(listId) included for update with name: \(cell.textField!.text!)")
        }
    }
    
    func editCell(cell: SWTableViewCell) {
      self.cellEditing = cell
    }
    
    //MARK: - SWTableViewCellDelegate
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            if let cellList = cell as? ListTableViewCell {
                cellList.duplicate()
            }
        case 1:
            if let indexPath = self.tableuserlist!.indexPathForCell(cell) {
                if let listItem = self.itemsUserList![indexPath.row] as? NSDictionary {
                    if let listId = listItem["id"] as? String {

                        
                        self.invokeDeleteListService(listId)
                    }
                }
                    //Si existe como entidad solo debe eliminarse de la BD
                else if let listEntity = self.itemsUserList![indexPath.row] as? List {
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
                }
            }
        default:
            print("other pressed")
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            cell.showRightUtilityButtonsAnimated(true)
        default :
            print("other pressed")
        }
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        switch state {
        case SWCellState.CellStateLeft:
            return self.isEditingUserList
        case SWCellState.CellStateRight:
            if self.isEditingUserList { return true }
            if let validateCanDelete = cell as? ListTableViewCell {
                return validateCanDelete.canDelete
            } else {
                return true
            }
        case SWCellState.CellStateCenter:
            return !self.isEditingUserList
        //default:
        //    return !self.isEditingUserList
        }
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return !self.isEditingUserList
    }
    
    // MARK: - Actions
    
    func showSearchField(aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?,animated:Bool) {
        self.isToggleBarEnabled = false
        self.searchContainer!.hidden = false
        self.searchConstraint!.constant = self.SC_HEIGHT
        if animated {
            //            UIView.animateWithDuration(0.5,
            UIView.animateWithDuration(0.4,
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
    
    func hideSearchField(aditionalAnimations:(()->Void)?, atFinished action:(()->Void)?) {
        self.isToggleBarEnabled = false
        self.searchConstraint!.constant = -5.0 //La seccion de busqueda es mas grande que el header
        //        UIView.animateWithDuration(0.5,
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.view.layoutIfNeeded()
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
    
    func showHelpTicketView() {
        if self.helpView != nil {
            self.helpView!.removeFromSuperview()
            self.helpView = nil
        }
        
        var requiredHelp = true
        if let param = self.retrieveParam("ticketCamHelp") {
            requiredHelp = !(param.value == "false")
        }
        
        if requiredHelp && UserCurrentSession.sharedInstance().userSigned != nil {
            self.helpView = UIView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
            self.helpView!.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.70)
            self.helpView!.alpha = 0.0
            self.helpView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeHelpTicketView"))
            self.view.addSubview(self.helpView!)
            
            let icon = UIImageView(image: UIImage(named: "list_scan_ticket_help"))
            icon.frame = CGRectMake(12.0, self.header!.frame.maxY + 16.0, 48.0, 48.0)
            self.helpView!.addSubview(icon)
            
            let message = UILabel(frame: CGRectMake(icon.frame.maxX + 12.0, self.header!.frame.maxY + 20.0, self.view.bounds.width - 88.0, 40.0))
            message.numberOfLines = 0
            message.textColor = UIColor.whiteColor()
            message.textAlignment = .Center
            message.font = WMFont.fontMyriadProRegularOfSize(16.0)
            message.text = NSLocalizedString("list.message.help", comment:"")
            self.helpView!.addSubview(message)
            
            let arrow = UIImageView(image: UIImage(named: "list_arrow_help"))
            arrow.frame = CGRectMake(icon.frame.midX, message.frame.maxY - 5.0, 80.0, 28.0)
            self.helpView!.addSubview(arrow)
            
            UIView.animateWithDuration(0.5,
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
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.helpView!.alpha = 0.0
                },
                completion: { (finished:Bool) -> Void in
                    if finished {
                        self.enabledHelpView = false
                        self.helpView!.removeFromSuperview()
                        self.helpView = nil
                        self.addOrUpdateParam("ticketCamHelp", value: "false")
                        if let cell = self.tableuserlist!.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? NewListTableViewCell {
                            cell.inputNameList!.becomeFirstResponder()
                        }
                    }
                }
            )
        }
    }
    
    func showWishlist() {
        WishlistService.shouldupdate = true
        let vc = storyboard!.instantiateViewControllerWithIdentifier("wishlitsItemVC")
        self.navigationController!.pushViewController(vc, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_TAPPED_VIEW_DETAILS_WISHLIST.rawValue, label: "")
        
    }
    
    func showDefaultLists() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("defaultListVC")
        self.navigationController!.pushViewController(vc, animated: true)
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_TAPPED_VIEW_DETAILS_SUPERLIST.rawValue, label: "")
        
    }
    
    
    
    //    func showWishlistHelpIfNeeded() {
    //        var requiredHelp = true
    //        if let param = self.retrieveParam("wishlistHelp") {
    //            requiredHelp = !(param.value == "false")
    //        }
    //
    //        if requiredHelp && self.viewTapHelp == nil {
    //            var bounds = self.view.frame.size
    //
    //            self.viewTapHelp = UIView(frame: self.view.frame)
    //            self.viewTapHelp!.addGestureRecognizer(UITapGestureRecognizer(target:self, action:"removeWishlistHelp:"))
    //            self.viewTapHelp!.backgroundColor = UIColor.clearColor()
    //            self.view.addSubview(self.viewTapHelp!)
    //
    //            let bgHelp = UIView(frame: self.viewTapHelp!.bounds)
    //            bgHelp.backgroundColor = UIColor.blackColor()
    //            bgHelp.alpha = 0.6
    //            self.viewTapHelp!.addSubview(bgHelp)
    //
    //            self.iconImageHelp = UIImageView()
    //            self.iconImageHelp.image = UIImage(named:"wishlist_help")
    //            if self.isShowingTabBar {
    //                self.iconImageHelp!.frame = CGRectMake(bounds.width - 56.0, bounds.height - 101.0, 40.0, 40.0)
    //            }
    //            else {
    //                self.iconImageHelp!.frame = CGRectMake(bounds.width - 56.0, bounds.height - 56.0, 40.0, 40.0)
    //            }
    //            self.viewTapHelp!.addSubview(self.iconImageHelp!)
    //
    //            self.arrowImageHelp = UIImageView()
    //            self.arrowImageHelp.image = UIImage(named:"wishlist_arrow_help")
    //            self.arrowImageHelp.frame = CGRectMake(self.iconImageHelp.frame.minX - 62 , self.iconImageHelp.frame.minY - 17.0, 70.0, 48.0)
    //            self.viewTapHelp!.addSubview(arrowImageHelp)
    //
    //            self.helpLabel = UILabel()
    //            self.helpLabel!.textColor = UIColor.whiteColor()
    //            self.helpLabel!.textAlignment = .Center
    //            self.helpLabel!.numberOfLines = 2
    //            self.helpLabel!.font = WMFont.fontMyriadProRegularOfSize(16.0)
    //            self.helpLabel!.backgroundColor = UIColor.clearColor()
    //            self.helpLabel!.attributedText = SearchSingleViewCell.attributedText("WishList", value: NSLocalizedString("wishlist.message.help", comment:""), fontKey: WMFont.fontMyriadProBoldOfSize(16.0), fontValue: WMFont.fontMyriadProRegularOfSize(16.0))
    //            self.helpLabel?.frame = CGRectMake(51 , self.iconImageHelp!.frame.minY - 44.0, bounds.width - 102, 35.0)
    //            self.viewTapHelp!.addSubview(self.helpLabel!)
    //        }
    //
    //    }
    
    func removeWishlistHelp(recognizer:UITapGestureRecognizer){
        UIView.animateWithDuration(0.5,
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
    
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
        self.viewLoad!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(self.isVisibleTab)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showListDetail" {
            if let controller = segue.destinationViewController as? UserListDetailViewController {
                controller.itemsUserList = self.itemsUserList
                controller.listId = self.selectedListId
                controller.listName = self.selectedListName
                controller.listEntity = self.selectedEntityList
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.itemsUserList!.count
        }
        var size = (self.newListEnabled ? 1 : 0)
        size = size + (self.isShowingWishList && needsToShowWishList ? 1 : 0)
        size = size + (self.isShowingSuperlists ? 1 : 0)
        return size
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //WishList
        if  indexPath.section == 0 {
            
            if indexPath.row == 0 && self.newListEnabled {
                let listCell = tableView.dequeueReusableCellWithIdentifier(self.NEWCELL_ID) as! NewListTableViewCell
                listCell.delegate = self
                listCell.accessoryView = nil
                return listCell
            }
            var currentRow = (self.newListEnabled ? 1 : 0)
            
            let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID) as! ListTableViewCell
            listCell.delegate = self
            listCell.listDelegate = self
            
            if (indexPath.row == 0 && self.isShowingWishList && self.needsToShowWishList)  {
                listCell.setValues(name: "WishList", count: "\(UserCurrentSession.sharedInstance().userItemsInWishlist())", icon: UIImage(named: "wishlist")!,enableEditing: false)
                listCell.canDelete = false
                listCell.enableDuplicateList(self.newListEnabled)
                listCell.shouldChangeState = !self.isEditingUserList
                listCell.setEditing(self.isEditingUserList, animated: false)
                listCell.showLeftUtilityButtonsAnimated(false)
                listCell.enableEditList(self.isEditingUserList)
                listCell.accessoryView = nil
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
                listCell.showLeftUtilityButtonsAnimated(false)
                listCell.enableEditList(self.isEditingUserList)
                listCell.accessoryView = UIImageView(image:UIImage(named:"practilist_gooo"))
                
                return listCell
            }
        }
        
        let listCell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID) as! ListTableViewCell
        listCell.delegate = self
        listCell.listDelegate = self
        
        if let listItem = self.itemsUserList![indexPath.row] as? NSDictionary {
            listCell.setValues(listObject:listItem)
        } else if let listEntity = self.itemsUserList![indexPath.row] as? List {
            listCell.setValues(listEntity: listEntity)
        }
        listCell.canDelete = true
        listCell.enableDuplicateList(self.newListEnabled)
        listCell.shouldChangeState = !self.isEditingUserList
        listCell.setEditing(self.isEditingUserList, animated: false)
        listCell.showLeftUtilityButtonsAnimated(false)
        listCell.enableEditList(self.isEditingUserList)
        if self.isEditingUserList {
            listCell.showLeftUtilityButtonsAnimated(false)
        }
        listCell.accessoryView = nil
        
        return listCell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
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
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_LISTS.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_MY_LISTS.rawValue, action: WMGAIUtils.ACTION_TAPPED_VIEW_DETAILS_MYLIST.rawValue, label: "")
        
        if let listItem = self.itemsUserList![indexPath.row] as? NSDictionary {
            if let listId = listItem["id"] as? String {
                self.selectedListId = listId
                self.selectedListName = listItem["name"] as? String
                

                self.performSegueWithIdentifier("showListDetail", sender: self)
            }
        }
        else if let listEntity = self.itemsUserList![indexPath.row] as? List {
            self.selectedEntityList = listEntity
            self.selectedListId = listEntity.idList
            self.selectedListName = listEntity.name
            
            
            self.performSegueWithIdentifier("showListDetail", sender: self)
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.isToggleBarEnabled {
            super.scrollViewDidScroll(scrollView)
        }
    }
    
    
    
    //MARK: - Utils
  
    func changeEntityNames() {
        if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
            let array = Array(self.listToUpdate!.keys)
            for var idx = 0; idx < array.count; idx++ {
                let idList = array[idx]
                
                var list:List? = nil
                for var idxl = 0; idxl < self.itemsUserList!.count; idxl++ {
                    if let entity = self.itemsUserList![idxl] as? List {
                        if entity.objectID.URIRepresentation().absoluteString == idList {
                            list = entity
                            break
                        }
                    }
                }
                
                if list != nil {
                    
                    let name = self.listToUpdate![idList]!
                    if name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
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
    
    func invokeDeleteListService(listId:String) {
        if !self.deleteListServiceInvoked {
            self.deleteListServiceInvoked = true
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.message.deletingList", comment:""))
            
            let service = GRDeleteUserListService()
            service.buildParams(listId)
            service.callService(nil,
                successBlock:{ (result:NSDictionary) -> Void in
                    self.reloadList(
                        success: { () -> Void in
                            self.alertView!.setMessage(NSLocalizedString("list.message.deleteListDone", comment:""))
                            self.alertView!.showDoneIcon()
                            self.deleteListServiceInvoked = false
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
    
   
    
    func invokeUpdateListService() {
        if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
            if  self.alertView == nil {
                self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"), imageError: UIImage(named:"list_alert_error"))
            }
            self.alertView!.setMessage(NSLocalizedString("list.message.updatingListNames", comment:""))
            
            let array = Array(self.listToUpdate!.keys)
            let firstKey = array.first
            let name = self.listToUpdate![firstKey!]
            
            if name == nil || name!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
                self.alertView!.setMessage(NSLocalizedString("list.new.validation.name", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            
            if !validateListName(firstKey!, nameList: name!) {
                self.alertView!.setMessage(NSLocalizedString("gr.list.samename", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            
            let whitespaceset = NSCharacterSet.whitespaceCharacterSet()
            
            let trimmedString = name!.stringByTrimmingCharactersInSet(whitespaceset)
            let length = trimmedString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
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
            
            let alphanumericset = NSCharacterSet(charactersInString: "áéíóúÁÉÍÓÚabcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ1234567890 ").invertedSet
            let cleanedName = (trimmedString.componentsSeparatedByCharactersInSet(alphanumericset) as NSArray).componentsJoinedByString("")
            if trimmedString != cleanedName {
                self.alertView!.setMessage(NSLocalizedString("list.new.validation.name.notvalid", comment:""))
                self.alertView!.showErrorIcon(NSLocalizedString("Ok", comment:""))
                return
            }
            
            
            
            
            
            let detailService = GRUserListDetailService()
            detailService.buildParams(firstKey!)
            detailService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in
                    let service = GRUpdateListService()
                    service.callService(name!,
                        successBlock: { (result:NSDictionary) -> Void in
                            self.listToUpdate!.removeValueForKey(firstKey!)
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
                            self.listToUpdate!.removeValueForKey(firstKey!)
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
                    self.listToUpdate!.removeValueForKey(firstKey!)
                    if self.listToUpdate != nil && self.listToUpdate!.count > 0 {
                        self.invokeUpdateListService()
                    }
                    else {
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                    }
                }
            )
            
        }
    }
    
    func validateListName(idLits:String,nameList:String) -> Bool {
        //Validate list exist
        if let itemsList = self.itemsUserList {
            for itemInList in itemsList {
                if let itemInListVal = itemInList as? NSDictionary {
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
    func barcodeCaptured(value:String?) {
        if value == nil {
            return
        }
        print("Code \(value)")
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.retrieveProductsFromTicket", comment:""))
        let service = GRProductByTicket()
        service.callService(service.buildParams(value!),
            successBlock: { (result: NSDictionary) -> Void in
                if let items = result["items"] as? [AnyObject] {
                    
                    if items.count == 0 {
                        self.alertView!.setMessage(NSLocalizedString("list.message.noProductsForTicket", comment:""))
                        self.alertView!.showErrorIcon("Ok")
                        return
                    }
                    
                    let saveService = GRSaveUserListService()
                    
                    self.alertView!.setMessage(NSLocalizedString("list.message.creatingListFromTicket", comment:""))
                    
                    var products:[AnyObject] = []
                    for var idx = 0; idx < items.count; idx++ {
                        var item = items[idx] as! [String:AnyObject]
                        let upc = item["upc"] as! String
                        let quantity = item["quantity"] as! NSNumber
                        let param = saveService.buildBaseProductObject(upc: upc, quantity: quantity.integerValue)
                        products.append(param)
                    }
                    
                    let fmt = NSDateFormatter()
                    fmt.dateFormat = "MMM d"
                    var name = fmt.stringFromDate(NSDate())
                    var number = 0;
                    
                    if self.itemsUserList != nil {
                        for item in  self.itemsUserList as! [NSDictionary]{
                            if let nameList = item["name"] as? String {
                                if nameList.uppercaseString.hasPrefix(name.uppercaseString) {
                                    number = number+1
                                }
                            }
                        }
                    }
                    
                    if number > 0 {
                        name = "\(name) \(number)"
                    }
                    
                    
                    saveService.callService(saveService.buildParams(name, items: products),
                        successBlock: { (result:NSDictionary) -> Void in
                            if let cell = self.tableuserlist!.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? NewListTableViewCell {
                                cell.scanning = false
                            }
                            self.newListEnabled = false
                            self.isShowingWishList  = true
                            self.isShowingSuperlists = true
                            
                            self.newListBtn!.selected = false
                            self.newListBtn!.backgroundColor = WMColor.UIColorFromRGB(0x8EBB36)
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
    
    
    
    
    //MARK: - TabBar
    
    override func willShowTabbar() {
        self.isShowingTabBar = true
        /*UIView.animateWithDuration(0.2, animations: { () -> Void in
            var bounds = self.view.frame.size
            self.showWishlistBtn!.frame = CGRectMake(bounds.width - 56.0, bounds.height - 101.0, 40.0, 40.0)
        })*/
    }
    
    override func willHideTabbar() {
        self.isShowingTabBar = false
        /*UIView.animateWithDuration(0.2, animations: { () -> Void in
            var bounds = self.view.frame.size
            self.showWishlistBtn!.frame = CGRectMake(bounds.width - 56.0, bounds.height - 56.0, 40.0, 40.0)
        })*/
    }
    
    //MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : NSString = textField.text! as String
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        
        self.itemsUserList = self.searchForItems(txtAfterUpdate as String)
        self.tableuserlist!.reloadData()
        self.editBtn!.hidden = self.itemsUserList == nil || self.itemsUserList!.count == 0
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Notifications
    
    func keyboardWillShow(aNotification: NSNotification) {
        var info = aNotification.userInfo
        let kbFrame = info![UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardFrame = kbFrame!.CGRectValue()
        
        var height = keyboardFrame.size.height
        //height += self.searchContainer!.frame.height
        height += 45.0 //TABBar height
        if self.cellEditing != nil {
            let indexPath =  self.tableuserlist!.indexPathForCell(self.cellEditing!)
            self.tableuserlist!.contentInset = UIEdgeInsetsMake(0, 0, height, 0)
            self.tableuserlist!.scrollToRowAtIndexPath(indexPath!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    }
    
    func keyboardWillHide(aNotification: NSNotification) {
        self.tableuserlist!.contentInset = UIEdgeInsetsZero
    }
    
    //MARK: - DB
    
    func retrieveNotSyncList() -> [List]? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == nil")
        var result: [List]? = nil
        do{
            result = try self.managedContext!.executeFetchRequest(fetchRequest) as? [List]
        }
        catch{
            print("retrieveNotSyncList error")
        }
        return result
    }
    
    func retrieveParam(key:String) -> Param? {
        let user = UserCurrentSession.sharedInstance().userSigned
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("Param", inManagedObjectContext: self.managedContext!)
        if user != nil {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, user!)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "key == %@ && user == %@", key, NSNull())
        }
        var parameter: Param? = nil
        do{
            let result = try self.managedContext!.executeFetchRequest(fetchRequest) as? [Param]
            if result != nil && result!.count > 0 {
                parameter = result!.first
            }
            
        }
        catch{
            print("retrieveParam error")
        }
        return parameter
    }
    
    func addOrUpdateParam(key:String, value:String) {
        if let param = self.retrieveParam(key) {
            param.value = value
        }
        else {
            let param = NSEntityDescription.insertNewObjectForEntityForName("Param", inManagedObjectContext: self.managedContext!) as? Param
            if let user = UserCurrentSession.sharedInstance().userSigned {
                param!.user = user
            }
            param!.key = key
            param!.value = value
        }
        self.saveContext()
    }
    
    func saveContext() {
        do {
            try self.managedContext!.save()
        } catch {
            print("error at save context on UserListViewController")
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        self.view.endEditing(true)
    }
    
    
    func searchForItems(textUpdate:String) -> [List]? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: self.managedContext!)
        if textUpdate != "" {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR  (ANY products.desc CONTAINS[cd] %@)",textUpdate,textUpdate)
        }
        let labelTracker : String = String(format: "name CONTAINS[cd] %@ OR  (ANY products.desc CONTAINS[cd] %@)", textUpdate,textUpdate)
        //Event
//        //TODOGAI
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.send(GAIDictionaryBuilder.createEventWithCategory(WMGAIUtils.SCREEN_LISTS.rawValue,
//                action:WMGAIUtils.GR_EVENT_LISTS_SEARCHCOMPLETE.rawValue,
//                label: labelTracker,
//                value: nil).build() as [NSObject:AnyObject])
//        }
        var result: [List]? =  nil
        do{
            result =  try self.managedContext!.executeFetchRequest(fetchRequest) as? [List]
            print(result)

        }catch{
            print("searchForItems Error")
        }
        return result
    }
    
}