//
//  ListsSelectorViewController.swift
//  WalMart
//
//  Created by neftali on 05/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol ListSelectorDelegate {
    func listSelectorDidShowList(_ listId: String, andName name:String)
    func listSelectorDidAddProduct(inList listId:String)
    func listSelectorDidDeleteProduct(inList listId:String)
    
    func listSelectorDidShowListLocally(_ list: List)
    func listSelectorDidAddProductLocally(inList list:List)
    func listSelectorDidDeleteProductLocally(_ product:Product, inList list:List)
    
    func listSelectorDidClose()
    func shouldDelegateListCreation() -> Bool
    func listSelectorDidCreateList(_ name:String)
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
    var list: [Any]?
    var delegate: ListSelectorDelegate?
    var hiddenOpenList : Bool = false
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_ADDTOLIST.rawValue
    }
    
    lazy var managedContext: NSManagedObjectContext? = {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel = UILabel()
        self.titleLabel!.text = NSLocalizedString("list.selector.title", comment:"")
        self.titleLabel!.textColor = UIColor.white
        self.titleLabel!.textAlignment = .center
        self.titleLabel!.font = WMFont.fontMyriadProSemiboldOfSize(14)
        self.titleLabel!.backgroundColor = UIColor.clear
        self.view.addSubview(self.titleLabel!)
        
        self.closeBtn = UIButton(type: .custom)
        self.closeBtn!.setImage(UIImage(named:"close"), for: UIControlState())
        self.closeBtn!.addTarget(self, action: #selector(ListsSelectorViewController.closeSelector), for: .touchUpInside)
        self.view.addSubview(self.closeBtn!)
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 200, width: 320, height: 400))
        self.tableView!.backgroundColor = UIColor.clear
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView!.autoresizingMask = UIViewAutoresizing()
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor.clear
        self.view.addSubview(self.tableView!)
        
        self.tableView!.register(ListSelectorViewCell.self, forCellReuseIdentifier: self.CELL_ID)
        self.tableView!.register(NewListSelectorViewCell.self, forCellReuseIdentifier: self.NEWCELL_ID)
        
        self.loading = WMLoadingView(frame: CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46))
        self.loading!.startAnnimating(true)
        self.view.addSubview(self.loading!)

        self.showLoadingIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        let frame = self.view.bounds
        self.titleLabel!.frame = CGRect(x: 15.0, y: 0.0, width: frame.size.width - 30.0, height: 48.0)
        self.closeBtn!.frame = CGRect(x: frame.width - 44.0, y: 2.0, width: 44.0, height: 44.0)
        self.tableView!.frame = CGRect(x: 0.0, y: 48.0, width: frame.size.width, height: frame.size.height - 48.0)
        self.loading!.frame = CGRect(x: 0,y: 0, width: frame.size.width, height: frame.size.height)
    }

    override func viewDidAppear(_ animated: Bool) {
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
        self.tableView!.isHidden = self.list == nil
        self.titleLabel!.isHidden = self.list == nil
        self.loading!.isHidden = self.list != nil
    }
    
    func loadLocalList() {
        if let user = UserCurrentSession.sharedInstance.userSigned {
            self.list = self.retrieveItems(forUser: user)
            self.list =  self.list?.sorted(by: { (first:Any, second:Any) -> Bool in
                let firstString = first as! List
                let secondString = second as! List
                return firstString.name < secondString.name
                
            })
            //self.retrieveItemsFromService()
        }
        else {
            let service = GRUserListService()
            self.list = service.retrieveNotSyncList()
            self.list =  self.list?.sorted(by: { (first:Any, second:Any) -> Bool in
                let firstString = first as! List
                let secondString = second as! List
                return firstString.name < secondString.name
                
            })
        }
        self.tableView!.reloadData()
        self.showLoadingIfNeeded()
    }

    func generateBlurImage(_ viewBg:UIView, frame:CGRect) {
        self.imageBlurView = self.createBlurImage(viewBg, frame: frame)
        self.view.insertSubview(self.imageBlurView!, at: 0)
        
        let bg = UIView(frame: frame)
        bg.backgroundColor = WMColor.light_blue.withAlphaComponent(0.9)
        self.view.insertSubview(bg, aboveSubview: self.imageBlurView!)
    }
    
    func createBlurImage(_ viewBg:UIView, frame:CGRect) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0);
        viewBg.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let cloneImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.list != nil ? self.list!.count : 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let listCell = tableView.dequeueReusableCell(withIdentifier: self.NEWCELL_ID, for: indexPath) as! NewListSelectorViewCell
            listCell.backgroundColor = UIColor.clear
            listCell.contentView.backgroundColor = UIColor.clear
            listCell.delegate = self
            return listCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: self.CELL_ID) as! ListSelectorViewCell
        cell.delegate = self
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.hiddenOpenList = self.hiddenOpenList
        let idx = indexPath.row - 1
        if let item = self.list![idx] as? [String:Any] {
            let isIncluded = self.validateProductInList(forProduct: self.productUpc, inListWithId: item["id"] as! String)
            cell.setListObject(item, productIncluded: isIncluded)
        }
        
        if let entity = self.list![idx] as? List {
            let isIncluded = self.validateProductInList(forProduct: self.productUpc, inList: entity)
            cell.setListEntity(entity, productIncluded: isIncluded)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }

        let idx = indexPath.row - 1
        if let item = self.list![idx] as? [String:Any] {
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "List", in: self.managedContext!)
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "registryDate", ascending: false)]
        let result: [List] = (try! self.managedContext!.fetch(fetchRequest)) as! [List]
        return result
    }

    func retrieveItemsFromService(){
        let userListsService = GRUserListService()
        userListsService.callService([:],
            successBlock: { (result:[String:Any]) -> Void in
                self.list = result["responseArray"] as? [Any]
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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "upc == %@ && list.idList == %@", upc!, listId)
            var result: [Product] = (try! self.managedContext!.fetch(fetchRequest)) as! [Product]
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
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedContext!)
            fetchRequest.predicate = NSPredicate(format: "upc == %@ && list == %@", upc!, entity)
            var result: [Product] = (try! self.managedContext!.fetch(fetchRequest)) as! [Product]
            if result.count > 0 {
                detail = result[0]
            }
        }
        return detail
    }
    
    /**
     Save context data base
     */
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
    
    func didShowListDetail(_ cell: ListSelectorViewCell) {
        if let indexPath = self.tableView!.indexPath(for: cell) {
            let idx = indexPath.row - 1
            if let item = self.list![idx] as? [String:Any] {
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
    
    /**
     Create new from list selector, in DB or use service
     
     - parameter value: name new list
     */
    func createNewList(_ value:String) {
        if self.list?.count < 12{
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
                successBlock: { (result:[String:Any]) -> Void in
                
                    //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ADD_TO_LIST.rawValue, action: WMGAIUtils.ACTION_CREATE_NEW_LIST.rawValue, label: "")
                
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
        }else{
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"list_alert"), imageDone: UIImage(named:"done"),imageError: UIImage(named:"list_alert_error"))
            self.alertView!.setMessage(NSLocalizedString("list.error.validation.max",comment:""))
            self.alertView!.showErrorIcon("Ok")
        }
    }

    func scanTicket() {
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    
}
