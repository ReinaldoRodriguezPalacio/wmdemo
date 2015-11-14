//
//  ListsSelectorViewController.swift
//  WalMart
//
//  Created by neftali on 05/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData

protocol ListSelectorDelegate {
    func listSelectorDidShowList(listId: String, andName name:String)
    func listSelectorDidAddProduct(inList listId:String)
    func listSelectorDidDeleteProduct(inList listId:String)
    
    func listSelectorDidShowListLocally(list: List)
    func listSelectorDidAddProductLocally(inList list:List)
    func listSelectorDidDeleteProductLocally(product:Product, inList list:List)
    
    func listSelectorDidClose()
    func shouldDelegateListCreation() -> Bool
    func listSelectorDidCreateList(name:String)
}

class ListsSelectorViewController: BaseController, UITableViewDelegate, UITableViewDataSource, ListSelectorCellDelegate, NewListTableViewCellDelegate , UIScrollViewDelegate{

    let CELL_ID = "listCell"
    let NEWCELL_ID = "newlistCell"

    var titleLabel: UILabel?
    var closeBtn: UIButton?
    var tableView: UITableView?
    var loading: WMLoadingView?
    var imageBlurView : UIImageView?

    var alertView: IPOWMAlertViewController?
    
    var productUpc: String?
    var list: [AnyObject]?
    var delegate: ListSelectorDelegate?
    var hiddenOpenList : Bool = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_ADDTOLIST.rawValue
    }
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel = UILabel()
        self.titleLabel!.text = NSLocalizedString("list.selector.title", comment:"")
        self.titleLabel!.textColor = UIColor.whiteColor()
        self.titleLabel!.textAlignment = .Center
        self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        self.titleLabel!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.titleLabel!)
        
        self.closeBtn = UIButton(type: .Custom)
        self.closeBtn!.setImage(UIImage(named:"close"), forState: .Normal)
        self.closeBtn!.addTarget(self, action: "closeSelector", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.closeBtn!)
        
        self.tableView = UITableView(frame: CGRectMake(0, 200, 320, 400))
        self.tableView!.backgroundColor = UIColor.clearColor()
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView!.autoresizingMask = UIViewAutoresizing.None
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.tableView!)
        
        self.tableView!.registerClass(ListSelectorViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableView!.registerClass(NewListSelectorViewCell.self, forCellReuseIdentifier: self.NEWCELL_ID)
        
        self.loading = WMLoadingView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
        self.loading!.startAnnimating(true)
        self.view.addSubview(self.loading!)

        self.showLoadingIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        let frame = self.view.bounds
        self.titleLabel!.frame = CGRectMake(15.0, 0.0, frame.size.width - 30.0, 48.0)
        self.closeBtn!.frame = CGRectMake(frame.width - 44.0, 2.0, 44.0, 44.0)
        self.tableView!.frame = CGRectMake(0.0, 48.0, frame.size.width, frame.size.height - 48.0)
        self.loading!.frame = CGRectMake(0,0, frame.size.width, frame.size.height)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadLocalList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    
    func closeSelector() {
        self.delegate?.listSelectorDidClose()
    }
    
    // MARK: - Utils
    func showLoadingIfNeeded() {
        self.tableView!.hidden = self.list == nil
        self.titleLabel!.hidden = self.list == nil
        self.loading!.hidden = self.list != nil
    }
    
    func loadLocalList() {
        if let user = UserCurrentSession.sharedInstance().userSigned {
            self.list = self.retrieveItems(forUser: user)
            //self.retrieveItemsFromService()
        }
        else {
            self.list = self.retrieveNotSyncList()
        }
        self.tableView!.reloadData()
        self.showLoadingIfNeeded()
    }

    func generateBlurImage(viewBg:UIView, frame:CGRect) {
        self.imageBlurView = self.createBlurImage(viewBg, frame: frame)
        self.view.insertSubview(self.imageBlurView!, atIndex: 0)
        
        let bg = UIView(frame: frame)
        bg.backgroundColor = WMColor.productAddToCartQuantitySelectorBgColor
        self.view.insertSubview(bg, aboveSubview: self.imageBlurView!)
    }
    
    func createBlurImage(viewBg:UIView, frame:CGRect) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0);
        viewBg.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let blurredImage = cloneImage.applyLightEffect()
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.clipsToBounds = true
        imageView.image = blurredImage

        return imageView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.list != nil ? self.list!.count : 0) + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let listCell = tableView.dequeueReusableCellWithIdentifier(self.NEWCELL_ID, forIndexPath: indexPath) as! NewListSelectorViewCell
            listCell.backgroundColor = UIColor.clearColor()
            listCell.contentView.backgroundColor = UIColor.clearColor()
            listCell.delegate = self
            return listCell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(self.CELL_ID) as! ListSelectorViewCell
        cell.delegate = self
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.hiddenOpenList = self.hiddenOpenList
        let idx = indexPath.row - 1
        if let item = self.list![idx] as? NSDictionary {
            let isIncluded = self.validateProductInList(forProduct: self.productUpc, inListWithId: item["id"] as! String)
            cell.setListObject(item, productIncluded: isIncluded)
        }
        
        if let entity = self.list![idx] as? List {
            let isIncluded = self.validateProductInList(forProduct: self.productUpc, inList: entity)
            cell.setListEntity(entity, productIncluded: isIncluded)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            return
        }

        let idx = indexPath.row - 1
        if let item = self.list![idx] as? NSDictionary {
            let listId = item["id"] as? String
            let product = self.retrieveProductInList(forProduct: self.productUpc, inListWithId: listId!)
            if product != nil {
                self.delegate?.listSelectorDidDeleteProduct(inList: listId!)
            }
            else {
                self.delegate?.listSelectorDidAddProduct(inList: listId!)
            }
        }
        else if let entity = self.list![idx] as? List {
            let product = self.retrieveProductInList(forProduct: self.productUpc, inList: entity)
            //Actualizacion a servicio a traves del delegate
            if entity.idList != nil {
                if product != nil {
                    self.delegate?.listSelectorDidDeleteProduct(inList: entity.idList!)
                }
                else {
                    self.delegate?.listSelectorDidAddProduct(inList: entity.idList!)
                }
            }
            //Actualizacion local a DB
            else {
                if product != nil {
                    self.delegate?.listSelectorDidDeleteProductLocally(product!, inList: entity)
                }
                else {
                    self.delegate?.listSelectorDidAddProductLocally(inList: entity)
                }
            }
        }
        
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if let newCell = cell as? NewListSelectorViewCell {
//            newCell.inputNameList!.becomeFirstResponder()
//        }
//    }
    
    // MARK: - DB
    
    func retrieveItems(forUser user:User) -> [List]? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "registryDate", ascending: false)]
        let result: [List] = (try! self.managedContext!.executeFetchRequest(fetchRequest)) as! [List]
        return result
    }

    func retrieveNotSyncList() -> [List]? {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("List", inManagedObjectContext: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "idList == nil")
        var result: [List]? = nil
        do{
          result = try self.managedContext!.executeFetchRequest(fetchRequest) as? [List]
        }
        catch let error as NSError{
            print("Fetch failed: \(error.localizedDescription)")
        }
        return result
    }

    func retrieveItemsFromService(){
        let userListsService = GRUserListService()
        userListsService.callService([:],
            successBlock: { (result:NSDictionary) -> Void in
                self.list = result["responseArray"] as? [AnyObject]
                //println(self.itemsUserList)
                self.tableView!.reloadData()
            },
            errorBlock: { (error:NSError) -> Void in
                
        })
    }

    
    func validateProductInList(forProduct upc:String?, inListWithId listId:String) -> Bool {
        let detail: Product? = self.retrieveProductInList(forProduct: upc, inListWithId: listId)
        return detail != nil
    }

    func retrieveProductInList(forProduct upc:String?, inListWithId listId:String) -> Product? {
        var detail: Product? = nil
        if upc != nil {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "upc == %@ && list.idList == %@", upc!, listId)
            var result: [Product] = (try! self.managedContext!.executeFetchRequest(fetchRequest)) as! [Product]
            if result.count > 0 {
                detail = result[0]
            }
        }
        return detail
    }

    func validateProductInList(forProduct upc:String?, inList entity:List) -> Bool {
        let detail: Product? = self.retrieveProductInList(forProduct: upc, inList: entity)
        return detail != nil
    }

    func retrieveProductInList(forProduct upc:String?, inList entity:List) -> Product? {
        var detail: Product? = nil
        if upc != nil {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "upc == %@ && list == %@", upc!, entity)
            var result: [Product] = (try! self.managedContext!.executeFetchRequest(fetchRequest)) as! [Product]
            if result.count > 0 {
                detail = result[0]
            }
        }
        return detail
    }
    
    func saveContext() {
        var error: NSError? = nil
        do {
            try self.managedContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            print("error at save context on UserListViewController: \(error!.localizedDescription)")
        }
    }

    //MARK: - ListSelectorCellDelegate
    
    func didShowListDetail(cell: ListSelectorViewCell) {
        if let indexPath = self.tableView!.indexPathForCell(cell) {
            let idx = indexPath.row - 1
            if let item = self.list![idx] as? NSDictionary {
                self.delegate!.listSelectorDidShowList(item["id"] as! String, andName: item["name"] as! String)
            }
            else if let entity = self.list![idx] as? List {
                if entity.idList == nil {
                    self.delegate!.listSelectorDidShowListLocally(entity)
                }
                else {
                    self.delegate!.listSelectorDidShowList(entity.idList!, andName: entity.name)
                }
            }
        }
    }

    //MARK: - NewListTableViewCellDelegate
    
    func cancelNewList() {
    }
    
    func createNewList(value:String) {
        if self.delegate != nil {
            if self.delegate!.shouldDelegateListCreation() {
                self.delegate!.listSelectorDidCreateList(value)
                return
            }
        }
        
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
        self.alertView!.setMessage(NSLocalizedString("list.message.creatingList", comment:""))

        let svcList = GRSaveUserListService()
        svcList.callService(svcList.buildParams(value),
            successBlock: { (result:NSDictionary) -> Void in
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, action: WMGAIUtils.ACTION_CREATE_NEW_LIST.rawValue, label: "")
                
                self.loadLocalList()
                self.alertView!.setMessage(NSLocalizedString("list.message.listDone", comment:""))
                self.alertView!.showDoneIcon()
                self.alertView!.afterRemove = {
                }
            },
            errorBlock: { (error:NSError) -> Void in
                print(error)
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView!.afterRemove = {
                }
            }
        )
    }

    func scanTicket() {
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    
}
