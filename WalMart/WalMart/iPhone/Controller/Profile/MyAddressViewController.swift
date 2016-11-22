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
    var arrayAddressShipping : [[String:Any]]!
     var arrayAddressFiscal : [[String:Any]]!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyAddressViewController.callServiceAddress), name: NSNotification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
        self.table = UITableView()
        self.table.register(AddressViewCell.self, forCellReuseIdentifier: "labelCell")
        
        self.table?.backgroundColor = UIColor.white
        
        self.table.separatorStyle = .none
        self.table.autoresizingMask = UIViewAutoresizing()
        self.titleLabel!.text = NSLocalizedString("profile.myAddress", comment: "")
        self.arrayAddressShipping = [[String:Any]]()
        self.arrayAddressFiscal = [[String:Any]]()
        
        
        self.newAddressButton = WMRoundButton()
        self.newAddressButton?.setFontTitle(WMFont.fontMyriadProRegularOfSize(11))
        self.newAddressButton?.setBackgroundColor(WMColor.green, size: CGSize(width: 55.0, height: 22), forUIControlState: UIControlState())
        self.newAddressButton!.addTarget(self, action: #selector(MyAddressViewController.newAddress), for: UIControlEvents.touchUpInside)
        self.newAddressButton!.setTitle(NSLocalizedString("profile.address.new", comment:"" ) , for: UIControlState())
        self.newAddressButton!.frame = CGRect(x: 248.0, y: 12.0, width: 55.0, height: 22.0)
        
        self.header?.addSubview(self.newAddressButton!)
        self.newAddressButton!.isHidden = true
        
        self.view.addSubview(self.table!)
        
        emptyView = IPOAddressEmptyView(frame:CGRect.zero)
        emptyView.returnAction = {() in
            self.newAddress()
        }
        self.view.addSubview(emptyView)
        
        
        self.view.backgroundColor = UIColor.white

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonWidth: CGFloat = 55.0
        let buttonHeight: CGFloat = 22.0
        
        let bounds = self.view.bounds
        self.table!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY + SELECTORH , width: bounds.width, height: bounds.height - self.header!.frame.maxY - SELECTORH )
        //tamaño
        self.newAddressButton!.frame = CGRect(x: self.view.bounds.width - (buttonWidth + 16.0), y: (header!.bounds.height - buttonHeight)/2, width: buttonWidth, height: buttonHeight)
        //self.newAddressButton!.frame = CGRectMake( self.view.bounds.maxX - 165.0, 12.0, 75.0, 22.0 )
        self.titleLabel!.frame = CGRect(x: self.newAddressButton!.frame.width , y: 0, width: self.view.bounds.width - (self.newAddressButton!.frame.width * 2), height: self.header!.frame.maxY)
        self.emptyView!.frame = CGRect(x: 0, y: 46, width: self.view.bounds.width, height: self.view.bounds.height - 46)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addressController = nil
        self.alertView = nil
        self.callServiceAddress()
    }
    
    func callServiceAddress(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad.backgroundColor = UIColor.white
            self.alertView = nil
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
        }
        
        let addressService = ShippingAddressByUserService()
        addressService.callService({ (resultCall:[String:Any]) -> Void in
            self.arrayAddressShipping = []
            if let shippingAddress = resultCall["responseArray"] as? [[String:Any]] {
                self.arrayAddressShipping = shippingAddress
            }
             self.getInvoiceAddress()
            }, errorBlock: { (error:NSError) -> Void in
               self.getInvoiceAddress()
        })
    }
  
    func getInvoiceAddress(){
        let addressService = InvoiceAddressByUserService()
        addressService.callService({ (resultCall:[String:Any]) -> Void in
            
            self.arrayAddressFiscal = []
            
            if let fiscalAddress = resultCall["responseArray"] as? [[String:Any]] {
                self.arrayAddressFiscal = fiscalAddress
            }
            self.emptyView.isHidden = (self.arrayAddressFiscal.count > 0 || self.arrayAddressShipping.count > 0)
            self.newAddressButton!.isHidden = !self.emptyView!.isHidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
            
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
                    self.emptyView.isHidden = (self.arrayAddressFiscal.count > 0 || self.arrayAddressShipping.count > 0)
                    self.newAddressButton!.isHidden = !self.emptyView!.isHidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
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
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    
    /*
    *@method: Obtain the number of rows for table view
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return self.arrayAddressShipping!.count

        }
        return self.arrayAddressFiscal!.count
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 46
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? AddressViewCell
        var prefered = false
        var item : [String:Any]
        var isFisicalAddress = false
        if (indexPath as NSIndexPath).section == 0{
            item = self.arrayAddressShipping![(indexPath as NSIndexPath).item] as! [String:Any]
        }else{
            item = self.arrayAddressFiscal![(indexPath as NSIndexPath).item] as! [String:Any]
            isFisicalAddress = true
        }
        
        var addressName = ""
        if let name = item["name"] as? String {
            addressName = name
        }
        if let name = item["addressName"] as? String {
            addressName = name
        }
        if (indexPath as NSIndexPath).row == 0{
            prefered = true
        }
        
        var addressId = ""
        if let addId =  item["addressId"] as? String {
            addressId = addId
        }

        if let addId =  item["id"] as? String {
            addressId = addId
        }
        
        cell!.setValues(addressName, font: WMFont.fontMyriadProRegularOfSize(14), numberOfLines: 2, textColor: WMColor.reg_gray, padding: 12,align:NSTextAlignment.left, isPrefered:prefered, addressID: addressId, isFisicalAddress: isFisicalAddress)
        
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
        
        let buttonDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 46))
        buttonDelete.setTitle(NSLocalizedString("wishlist.delete",comment:""), for: UIControlState())
        buttonDelete.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        buttonDelete.backgroundColor = WMColor.red
        toReturn.append(buttonDelete)
        
        return toReturn
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch index {
        case 0:
            print("delete pressed")
            let indexPath = self.table.indexPath(for: cell)
            if indexPath != nil {
                var addressId = ""
                var item : [String:Any]
                var isFiscalAddress = false
                    if (indexPath! as NSIndexPath).section == 0{
                        item = self.arrayAddressShipping![(indexPath! as NSIndexPath).row] as! [String:Any]
                    }else{
                        item = self.arrayAddressFiscal![(indexPath! as NSIndexPath).row] as! [String:Any]
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
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    
    /*
    *@method: Create a section view and return
    */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let generic : UIView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.width,height: 36))
        let titleView : UILabel = UILabel(frame:CGRect(x: 16,y: 0,width: tableView.frame.width,height: 36))
        titleView.textColor = WMColor.light_blue
        titleView.font = WMFont.fontMyriadProLightOfSize(14)
        if section == 0 {
            titleView.text = NSLocalizedString("profile.shipping", comment: "")
        }
        else{
            titleView.text = NSLocalizedString("profile.fiscal", comment: "")
        }
        generic.addSubview(titleView)
        generic.backgroundColor = UIColor.white
        return generic
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if self.addressController == nil {
            self.addressController = AddressViewController()
        }
        var item: [String:Any]!
        var allArray: [[String:Any]] = self.arrayAddressShipping!
        allArray.append(array:arrayAddressFiscal)
        self.addressController!.allAddress =  allArray
        
        if (indexPath as NSIndexPath).section == 0{
            item = self.arrayAddressShipping![(indexPath as NSIndexPath).item]
            self.addressController!.typeAddress = TypeAddress.shiping
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_BILL_SHOW_ADDREES_DETAIL.rawValue, label:"")
        }else{
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_DELIVERY_SHOW_ADDREES_DETAIL.rawValue, label:"")
            item = self.arrayAddressFiscal![(indexPath as NSIndexPath).item]
            if let type = item["persona"] as? String{
                if type == "F" {
                    self.addressController!.typeAddress = TypeAddress.fiscalPerson
                }else{
                    self.addressController!.typeAddress = TypeAddress.fiscalMoral
                }
            }else{
                self.addressController!.typeAddress = TypeAddress.fiscalPerson
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
        
        var allArray: [[String:Any]] = self.arrayAddressShipping!
        allArray.append(array: arrayAddressFiscal)
        self.addressController!.allAddress =  allArray
        self.addressController!.typeAddress = TypeAddress.shiping
        self.addressController!.addressFiscalCount = self.arrayAddressFiscal.count
        self.addressController!.addressShippingCont = self.arrayAddressShipping!.count
            
           
        self.navigationController!.pushViewController(self.addressController!, animated: true)

    }
    
    func applyPrefered (_ addressID: String, isFisicalAddress: Bool ){
        viewLoad = WMLoadingView(frame: CGRect(x: 0, y: self.header!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.header!.frame.maxY))
        viewLoad.backgroundColor = UIColor.white
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

       
        service!.callService(service!.buildParamsInvoice(addressID),  successBlock:{ (resultCall:[String:Any]?) in
            self.callServiceAddress()
            }, errorBlock: {(error: NSError) in
                self.viewLoad.stopAnnimating()
                self.viewLoad = nil
        })
        
    }

    
    func deleteAddress(_ idAddress:String, isFisicalAddress:Bool){
        
        var  service: DeleteAddressesByUserService? = nil
        
        if isFisicalAddress {
            service = DeleteAddressesInvoiceService()
          
        }else {
            service = DeleteAddressesByUserService()
        }
         let  params = service!.buildParams(idAddress)
        
        if self.alertView == nil {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        service!.callService(params, successBlock:{ (resultCall:[String:Any]?) in
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
