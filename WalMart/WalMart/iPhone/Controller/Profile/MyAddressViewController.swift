//
//  ListAddressViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class MyAddressViewController: NavigationViewController,  UITableViewDelegate, UITableViewDataSource , AddressViewCellDelegate, SWTableViewCellDelegate {

    var table: UITableView!
    var arrayAddressShipping : NSArray!
     var arrayAddressFiscal : NSArray!
    
    var newAddressButton : WMRoundButton? = nil
    var viewLoad : WMLoadingView!
    var emptyView : IPOAddressEmptyView!
    var addressController : AddressViewController? = nil
    var alertView : IPOWMAlertViewController? = nil
    
    let SELECTORH : CGFloat = 0.0
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_MYADDRESSES.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyAddressViewController.callServiceAddress), name: ProfileNotification.updateProfile.rawValue, object: nil)
        self.table = UITableView()
        self.table.registerClass(AddressViewCell.self, forCellReuseIdentifier: "labelCell")
        
        self.table?.backgroundColor = UIColor.whiteColor()
        
        self.table.separatorStyle = .None
        self.table.autoresizingMask = UIViewAutoresizing.None
        self.titleLabel!.text = NSLocalizedString("profile.myAddress", comment: "")
        self.arrayAddressShipping = NSArray()
        self.arrayAddressFiscal = NSArray()
        
        
        self.newAddressButton = WMRoundButton()
        self.newAddressButton?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.newAddressButton?.setBackgroundColor(WMColor.green, size: CGSizeMake(55.0, 22), forUIControlState: UIControlState.Normal)
        self.newAddressButton!.addTarget(self, action: #selector(MyAddressViewController.newAddress), forControlEvents: UIControlEvents.TouchUpInside)
        self.newAddressButton!.setTitle(NSLocalizedString("profile.address.new", comment:"" ) , forState: UIControlState.Normal)
        self.newAddressButton!.frame = CGRectMake(248.0, 12.0, 55.0, 22.0)
        
        self.header?.addSubview(self.newAddressButton!)
        self.newAddressButton!.hidden = true
        
        self.view.addSubview(self.table!)
        
        emptyView = IPOAddressEmptyView(frame:CGRectZero)
        emptyView.returnAction = {() in
            self.newAddress()
        }
        self.view.addSubview(emptyView)
        
        
        self.view.backgroundColor = UIColor.whiteColor()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonWidth: CGFloat = 55.0
        let buttonHeight: CGFloat = 22.0
        
        let bounds = self.view.bounds
        self.table!.frame =  CGRectMake(0,  self.header!.frame.maxY + SELECTORH , bounds.width, bounds.height - self.header!.frame.maxY - SELECTORH )
        //tamaño
        self.newAddressButton!.frame = CGRectMake(self.view.bounds.width - (buttonWidth + 16.0), (header!.bounds.height - buttonHeight)/2, buttonWidth, buttonHeight)
        //self.newAddressButton!.frame = CGRectMake( self.view.bounds.maxX - 165.0, 12.0, 75.0, 22.0 )
        self.titleLabel!.frame = CGRectMake(self.newAddressButton!.frame.width , 0, self.view.bounds.width - (self.newAddressButton!.frame.width * 2), self.header!.frame.maxY)
        self.emptyView!.frame = CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addressController = nil
        self.alertView = nil
        self.callServiceAddress()
    }
    
    func callServiceAddress(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.whiteColor()
            self.alertView = nil
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
        }
        
        let addressService = ShippingAddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            self.arrayAddressShipping = []
            if let shippingAddress = resultCall["responseArray"] as? NSArray {
                self.arrayAddressShipping = shippingAddress
            }
             self.getInvoiceAddress()
            }, errorBlock: { (error:NSError) -> Void in
               self.getInvoiceAddress()
        })
    }
  
    func getInvoiceAddress(){
        let addressService = InvoiceAddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            
            self.arrayAddressFiscal = []
            
            if let fiscalAddress = resultCall["responseArray"] as? NSArray {
                self.arrayAddressFiscal = fiscalAddress
            }
            self.emptyView.hidden = (self.arrayAddressFiscal.count > 0 || self.arrayAddressShipping.count > 0)
            self.newAddressButton!.hidden = !self.emptyView!.hidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
            
            self.table.delegate = self
            self.table.dataSource = self
            self.table.reloadData()
            print("sucess")
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            }, errorBlock: { (error:NSError) -> Void in
                if (self.arrayAddressShipping.count > 0) {
                    self.emptyView.hidden = (self.arrayAddressFiscal.count > 0 || self.arrayAddressShipping.count > 0)
                    self.newAddressButton!.hidden = !self.emptyView!.hidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
                    self.table.delegate = self
                    self.table.dataSource = self
                    self.table.reloadData()
                     self.viewLoad.stopAnnimating()
                }else{
                    if self.viewLoad != nil{
                        self.viewLoad.stopAnnimating()
                    }
                    self.viewLoad = nil
                    print("errorBlock")
                }
        })

    }
    
    
    //MARK: - UITableView
    /*
    *@method: Obtain number of sections on menu
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return 2
    }
    
    /*
    *@method: Obtain the number of rows for table view
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return self.arrayAddressShipping!.count

        }
        return self.arrayAddressFiscal!.count
        
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height: CGFloat = 46
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? AddressViewCell
        var prefered = false
        var isViewLine = true
        var item : NSDictionary
        var isFisicalAddress = false
        if indexPath.section == 0{
            item = self.arrayAddressShipping![indexPath.item] as! NSDictionary
            isViewLine = (indexPath.row == self.arrayAddressShipping!.count - 1) ? false:true
        }else{
            item = self.arrayAddressFiscal![indexPath.item] as! NSDictionary
            isFisicalAddress = true
        }
        
        var addressName = ""
        if let name = item["name"] as? String {
            addressName = name
        }
        if let name = item["addressName"] as? String {
            addressName = name
        }
        if let pref = item["preferred"] as? NSNumber{
            if pref.integerValue == 1 {
                prefered = true
            }
        }
        
        var addressId = ""
        if let addId =  item["addressID"] as? String {
            addressId = addId
        }

        if let addId =  item["id"] as? String {
            addressId = addId
        }
        
        cell!.setValues(addressName, font: WMFont.fontMyriadProRegularOfSize(14), numberOfLines: 2, textColor: WMColor.gray, padding: 12,align:NSTextAlignment.Left, isViewLine:isViewLine, isPrefered:prefered, addressID: addressId, isFisicalAddress: isFisicalAddress)
        
        cell!.delegateAddres = self
        cell!.delegate = self
        cell!.rightUtilityButtons = getRightButtonDelete()
        
         if let isAddressOK = item["isAddressOk"] as? String {
            cell!.showErrorFieldImage(isAddressOK == "False")
         }else{
            cell!.showErrorFieldImage(false)
        }
        
        
        return cell!
    }
    
    func getRightButtonDelete() -> [UIButton] {
        var toReturn : [UIButton] = []
        
        let buttonDelete = UIButton(frame: CGRectMake(0, 0, 64, 46))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), forState: UIControlState.Normal)
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        switch index {
        case 0:
            print("delete pressed")
            let indexPath = self.table.indexPathForCell(cell)
            if indexPath != nil {
                var addressId = ""
                var item : NSDictionary
                var isFiscalAddress = false
                    if indexPath!.section == 0{
                        item = self.arrayAddressShipping![indexPath!.row] as! NSDictionary
                    }else{
                        item = self.arrayAddressFiscal![indexPath!.row] as! NSDictionary
                        isFiscalAddress = true
                    }
                    if let addId =  item["addressId"] as? String {
                        addressId = addId
                    }
                    self.deleteAddress(addressId, isFisicalAddress: isFiscalAddress)
            }
        default:
            print("other pressed")
        }
        
    }
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    
    /*
    *@method: Create a section view and return
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generic : UIView = UIView(frame: CGRectMake(0,0,tableView.frame.width,36))
        let titleView : UILabel = UILabel(frame:CGRectMake(16,0,tableView.frame.width,36))
        titleView.textColor = WMColor.light_blue
        titleView.font = WMFont.fontMyriadProLightOfSize(14)
        if section == 0 {
            titleView.text = NSLocalizedString("profile.shipping", comment: "")
        }
        else{
            titleView.text = NSLocalizedString("profile.fiscal", comment: "")
        }
        generic.addSubview(titleView)
        generic.backgroundColor = UIColor.whiteColor()
        return generic
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        if self.addressController == nil {
            self.addressController = AddressViewController()
        }
        var item: NSDictionary!
        let allArray = self.arrayAddressShipping!.arrayByAddingObjectsFromArray(arrayAddressFiscal as [AnyObject])
        self.addressController!.allAddress =  allArray
        
        if indexPath.section == 0{
            item = self.arrayAddressShipping![indexPath.item] as! NSDictionary
            self.addressController!.typeAddress = TypeAddress.Shiping
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_BILL_SHOW_ADDREES_DETAIL.rawValue, label:"")
        }else{
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_DELIVERY_SHOW_ADDREES_DETAIL.rawValue, label:"")
            item = self.arrayAddressFiscal![indexPath.item] as! NSDictionary
            if let type = item["corporateName"] as? String{
                if type == "" {
                    self.addressController!.typeAddress = TypeAddress.FiscalPerson
                }else{
                    self.addressController!.typeAddress = TypeAddress.FiscalMoral
                }
            }else{
                self.addressController!.typeAddress = TypeAddress.FiscalPerson
            }
        }
        self.addressController!.item = item!
        
        self.navigationController!.pushViewController(self.addressController!, animated: true)
        
    }

    func newAddress(){
      
        
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_OPEN_MG_NEW_ADDRES.rawValue, label:"" )
        if self.addressController == nil {
                self.addressController = AddressViewController()
        }
        if arrayAddressShipping.count == 0{
            self.addressController!.defaultPrefered = true
        }
            
        let allArray = self.arrayAddressShipping!.arrayByAddingObjectsFromArray(arrayAddressFiscal as [AnyObject])
        self.addressController!.allAddress =  allArray
        self.addressController!.typeAddress = TypeAddress.Shiping
        self.addressController!.addressFiscalCount = self.arrayAddressFiscal.count
        self.addressController!.addressShippingCont = self.arrayAddressShipping!.count
            
           
        self.navigationController!.pushViewController(self.addressController!, animated: true)

    }
    
    func applyPrefered (addressID: String, isFisicalAddress: Bool ){
        viewLoad = WMLoadingView(frame: CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
        viewLoad.backgroundColor = UIColor.whiteColor()
        self.alertView = nil
        self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
                  BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_SET_ADDRESS_PREFERRED.rawValue, label: "")
        
        var  service: AddPreferedAddress? = nil
       
        if isFisicalAddress {
              service = AddPreferedAddressInvoice()
        }else {
            service = AddPreferedAddress()
        }

        service!.buildParams(addressID)
        service!.callService(NSDictionary(),  successBlock:{ (resultCall:NSDictionary?) in
            self.callServiceAddress()
            }, errorBlock: {(error: NSError) in
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
        })
        
    }

    
    func deleteAddress(idAddress:String, isFisicalAddress:Bool){
       
        var  service: DeleteAddressesByUserService? = nil
        
        if isFisicalAddress {
            service = DeleteAddressesInvoiceService()
        }else {
            service = DeleteAddressesByUserService()
        }
        
        
        let params = service!.buildParams(idAddress)
        
        if self.alertView == nil {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        service!.callService(params, successBlock:{ (resultCall:NSDictionary?) in
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_DELETE_ADDRESS.rawValue, label: "")
            
        if let message = resultCall!["message"] as? String {
            if self.alertView != nil {
                self.alertView!.setMessage("\(message)")
                self.alertView!.showDoneIcon()
            }
        }//if let message = resultCall!["message"] as? String {
        self.alertView = nil
    
        self.callServiceAddress()
        }
        , errorBlock: {(error: NSError) in
            print("error")
            self.alertView!.setMessage(error.localizedDescription)
            self.alertView!.showErrorIcon("Ok")
            self.alertView = nil
        })
    }

    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label:"")
        super.back()
    }
}
