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
    var arrayAddressShippingGR : NSArray!
    var arrayAddressFiscal : NSArray!
    
    var newAddressButton : WMRoundButton? = nil
    var viewLoad : WMLoadingView!
    var emptyView : IPOAddressEmptyView!
    var addressController : AddressViewController? = nil
    var superAddressController : SuperAddressViewController!
    var alertView : IPOWMAlertViewController? = nil
    
    let SELECTORH : CGFloat = 60.0
    
    var viewBgSelectorBtn : UIView!
    var btnSuper : UIButton!
    var btnTech : UIButton!
    var showGRAddressForm: Bool = false
    
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
        
        //let iconImage = UIImage(named:"button_bg")
        //let iconSelected = UIImage(named:"button_bg_active")
        
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
        
        viewBgSelectorBtn = UIView(frame: CGRectMake(16,  self.header!.frame.maxY + 16, 282, 28))
        viewBgSelectorBtn.layer.borderWidth = 1
        viewBgSelectorBtn.layer.cornerRadius = 14
        viewBgSelectorBtn.layer.borderColor = WMColor.light_blue.CGColor
        
        let titleSupper = NSLocalizedString("profile.address.super",comment:"")
        btnSuper = UIButton(frame: CGRectMake(1, 1, (viewBgSelectorBtn.frame.width / 2) - 1, viewBgSelectorBtn.frame.height - 2))
        btnSuper.setImage(UIImage(color: UIColor.whiteColor(), size: btnSuper.frame.size), forState: UIControlState.Normal)
        btnSuper.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), forState: UIControlState.Selected)
        btnSuper.setTitle(titleSupper, forState: UIControlState.Normal)
        btnSuper.setTitle(titleSupper, forState: UIControlState.Selected)
        btnSuper.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnSuper.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        btnSuper.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnSuper.selected = true
        btnSuper.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width + 1, 0, 0.0);
        btnSuper.addTarget(self, action: #selector(MyAddressViewController.changeSuperTech(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let titleTech = NSLocalizedString("profile.address.tech",comment:"")
        btnTech = UIButton(frame: CGRectMake(btnSuper.frame.maxX, 1, viewBgSelectorBtn.frame.width / 2, viewBgSelectorBtn.frame.height - 2))
        btnTech.setImage(UIImage(color: UIColor.whiteColor(), size: btnSuper.frame.size), forState: UIControlState.Normal)
        btnTech.setImage(UIImage(color: WMColor.light_blue, size: btnSuper.frame.size), forState: UIControlState.Selected)
        btnTech.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btnTech.setTitleColor(WMColor.light_blue, forState: UIControlState.Normal)
        btnTech.setTitle(titleTech, forState: UIControlState.Normal)
        btnTech.setTitle(titleTech, forState: UIControlState.Selected)
        btnTech.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(11)
        btnTech.titleEdgeInsets = UIEdgeInsetsMake(2.0, -btnSuper.frame.size.width + 1, 0, 0.0);
        btnTech.addTarget(self, action: #selector(MyAddressViewController.changeSuperTech(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewBgSelectorBtn.clipsToBounds = true
        viewBgSelectorBtn.backgroundColor = UIColor.whiteColor()
        viewBgSelectorBtn.addSubview(btnSuper)
        viewBgSelectorBtn.addSubview(btnTech)
        
        self.view.addSubview(viewBgSelectorBtn)
        
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
        
        self.viewBgSelectorBtn.frame =  CGRectMake((self.view.bounds.width - 282) / 2  ,  self.header!.frame.maxY + 16, 282, 28)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addressController = nil
        self.alertView = nil
        //self.callServiceAddress()
        self.callServiceAddressGR()
    }
    
    func callServiceAddress(){
       /* viewLoad = WMLoadingView(frame: self.view.bounds)
        viewLoad.backgroundColor = UIColor.whiteColor()
        self.alertView = nil
        self.view.addSubview(viewLoad)
        viewLoad.startAnnimating(self.isVisibleTab)*/
        
        let addressService = AddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            
            self.arrayAddressFiscal = []
            self.arrayAddressShipping = []
            
            if let fiscalAddress = resultCall["fiscalAddresses"] as? NSArray {
                self.arrayAddressFiscal = fiscalAddress
            }
            if let shippingAddress = resultCall["shippingAddresses"] as? NSArray {
                self.arrayAddressShipping = shippingAddress
            }
            
            self.emptyView.hidden = (self.arrayAddressShippingGR.count > 0 || self.arrayAddressFiscal.count > 0 || self.arrayAddressShipping.count > 0)
            
            if self.btnSuper.selected {
                self.newAddressButton!.hidden = !self.emptyView!.hidden || self.arrayAddressShippingGR.count >= 12
                
            }else{
                self.newAddressButton!.hidden = !self.emptyView!.hidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
            }
            
           
            
            self.table.delegate = self
            self.table.dataSource = self
            self.table.reloadData()
            print("sucess")
            if self.viewLoad != nil{
                self.viewLoad.stopAnnimating()
            }
            self.viewLoad = nil
            }, errorBlock: { (error:NSError) -> Void in
                if self.viewLoad != nil{
                    self.viewLoad.stopAnnimating()
                }
                self.viewLoad = nil
                print("errorBlock")
        })
    }
    
    func callServiceAddressGR(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: CGRectMake(0, 46, self.view.bounds.width, self.view.bounds.height - 46))
            viewLoad.backgroundColor = UIColor.whiteColor()
            self.alertView = nil
            self.view.addSubview(viewLoad)
            viewLoad.startAnnimating(self.isVisibleTab)
        }
        
        let addressService = GRAddressByUserService()
        addressService.callService({ (resultCall:NSDictionary) -> Void in
            
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_UPDATE_ADDRESS.rawValue, label:"")
            
            self.arrayAddressShippingGR = []
            
            if  let resultAddress = resultCall["responseArray"] as? NSArray {
                 self.arrayAddressShippingGR = resultAddress
            }

            self.arrayAddressFiscal = []

            self.emptyView.hidden = (self.arrayAddressShippingGR.count > 0 || self.arrayAddressFiscal.count > 0 || self.arrayAddressShipping.count > 0)
            
            if self.btnSuper.selected {
                self.newAddressButton!.hidden = !self.emptyView!.hidden || self.arrayAddressShippingGR.count >= 12
                
            }else{
                self.newAddressButton!.hidden = !self.emptyView!.hidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
            }
            
            //self.newAddressButton!.hidden = !self.emptyView!.hidden || self.arrayAddressShippingGR.count >= 12
            
            self.table.delegate = self
            self.table.dataSource = self
            self.table.reloadData()
            print("sucess")
            //self.viewLoad.stopAnnimating()
            
            self.callServiceAddress()
            
            }, errorBlock: { (error:NSError) -> Void in
                self.callServiceAddress()
                //self.viewLoad.stopAnnimating()
                print("errorBlock")
        })
    }

    
    //MARK: - UITableView
    /*
    *@method: Obtain number of sections on menu
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if btnSuper.selected {
            return 1
        }
        return 2
    }
    
    /*
    *@method: Obtain the number of rows for table view
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            if btnSuper.selected {
                return self.arrayAddressShippingGR!.count
            } else {
                return self.arrayAddressShipping!.count
            }
        }
        if btnSuper.selected {
            return 0
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
        if indexPath.section == 0{
            if btnSuper.selected {
                item = self.arrayAddressShippingGR![indexPath.item] as! NSDictionary
                //isViewLine = (indexPath.row == self.arrayAddressShipping!.count - 1) ? false:true
                isViewLine = true
            } else {
                item = self.arrayAddressShipping![indexPath.item] as! NSDictionary
                isViewLine = (indexPath.row == self.arrayAddressShipping!.count - 1) ? false:true
            }
        }else{
            item = self.arrayAddressFiscal![indexPath.item] as! NSDictionary
        }
        let name = item["name"] as! String
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
        
        cell!.setValues(name, font: WMFont.fontMyriadProRegularOfSize(14), numberOfLines: 2, textColor: WMColor.gray, padding: 12,align:NSTextAlignment.Left, isViewLine:isViewLine, isPrefered:prefered, addressID: addressId)
        
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
                if self.btnSuper.selected {
                    item = self.arrayAddressShippingGR![indexPath!.row] as! NSDictionary
                    if let addId =  item["id"] as? String {
                        addressId = addId
                        self.deleteAddressGR(addressId)
                    }
                }else{
                    if indexPath!.section == 0{
                        item = self.arrayAddressShipping![indexPath!.row] as! NSDictionary
                    }else{
                        item = self.arrayAddressFiscal![indexPath!.row] as! NSDictionary
                    }
                    if let addId =  item["addressID"] as? String {
                        addressId = addId
                    }
                    
                    self.deleteAddress(addressId)
                }
                
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
        if btnSuper.selected {
            
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_SHOW_ADDREES_DETAIL.rawValue, label:"")
            
            self.superAddressController = SuperAddressViewController()
            self.superAddressController.showGRAddressForm = self.showGRAddressForm
            self.superAddressController!.allAddress =  self.arrayAddressShippingGR
            let item = self.arrayAddressShippingGR![indexPath.item] as! NSDictionary
            self.superAddressController.addressId = item["id"] as! String
            self.superAddressController!.view.frame = self.view.frame
            self.superAddressController.setValues(item["id"] as! String)
            self.superAddressController.isPreferred = (item["preferred"] as! Int) == 1
                      
            if let isAddressOK = item["isAddressOk"] as? String {
                self.superAddressController!.sAddredssForm.showErrorLabel(isAddressOK == "False")
            }
            
            self.navigationController!.pushViewController(self.superAddressController, animated: true)
        } else {
           
            
            if self.addressController == nil {
                self.addressController = AddressViewController()
            }
            var item: NSDictionary!
            let allArray = self.arrayAddressShipping!.arrayByAddingObjectsFromArray(arrayAddressFiscal as [AnyObject])
            self.addressController!.allAddress =  allArray
            
            if indexPath.section == 0{
                item = self.arrayAddressShipping![indexPath.item] as! NSDictionary
                self.addressController!.typeAddress = TypeAddress.Shiping
                 //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_BILL_SHOW_ADDREES_DETAIL.rawValue, label:"")
            }else{
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_DELIVERY_SHOW_ADDREES_DETAIL.rawValue, label:"")
                item = self.arrayAddressFiscal![indexPath.item] as! NSDictionary
                if let type = item["corporateName"] as? String{
                    if type == "" {
                        self.addressController!.typeAddress = TypeAddress.FiscalPerson
                    }else{
                        self.addressController!.typeAddress = TypeAddress.FiscalMoral
                    }
                }
            }
            self.addressController!.item = item!
            //self.addressController!.view.frame = self.view.frame
            
            if let isAddressOK = item["isAddressOk"] as? String {
                self.superAddressController!.sAddredssForm.showErrorLabel(isAddressOK == "False")
            }
                     
            self.navigationController!.pushViewController(self.addressController!, animated: true)
        }
    }

    func newAddress(){
        if btnSuper.selected {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_OPEN_GR_NEW_ADDRES.rawValue, label:"" )
            self.superAddressController = SuperAddressViewController()
               self.superAddressController!.allAddress =  self.arrayAddressShippingGR
            
            
            self.navigationController!.pushViewController(self.superAddressController, animated: true)
        } else {
             //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_OPEN_MG_NEW_ADDRES.rawValue, label:"" )
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
    }
    
    func applyPrefered (addressID: String){
        
        viewLoad = WMLoadingView(frame: CGRectMake(0, self.header!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.header!.frame.maxY))
        viewLoad.backgroundColor = UIColor.whiteColor()
        self.alertView = nil
        self.view.addSubview(viewLoad)
         viewLoad.startAnnimating(self.isVisibleTab)
        
        if btnSuper.selected {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_SET_ADDRESS_PREFERRED.rawValue, label: "")
            let service = GRAddressAddService()
            let serviceAddress = GRAddressesByIDService()
            serviceAddress.addressId = addressID
            serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
                
                let name = result["name"] as! String!
                let outerNumber = result["outerNumber"] as! String!
                let innerNumber = result["innerNumber"] as! String!
                let reference1 = result["reference1"] as! String!
                let reference2 = result["reference2"] as! String!
                let zipCode = result["zipCode"] as! String!
                let street = result["street"] as! String!
                let city = result["city"] as! String!
                let state = result["state"] as! String!
                let county = result["county"] as! String!
                
                let neighborhoodID = result["neighborhoodID"] as! String!
                let storeID = result["storeID"] as! String!
                
                let dictSend = service.buildParams(city, addressID: addressID, zipCode: zipCode, street: street, innerNumber: innerNumber, state: state, county: county, neighborhoodID: neighborhoodID, phoneNumber: "", outerNumber: outerNumber, adName: name, reference1: reference1, reference2: reference2, storeID: storeID,storeName: "", operationType: "C", preferred: true)
                
                service.callService(requestParams: dictSend, successBlock: { (result:NSDictionary) -> Void in
                    self.callServiceAddressGR()
                    }, errorBlock: { (error:NSError) -> Void in
                        print("error")
                })
                UserCurrentSession.sharedInstance().getStoreByAddress(result)
                }, errorBlock: { (error:NSError) -> Void in
                
            })
            
        } else {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_SET_ADDRESS_PREFERRED.rawValue, label: "")
            let service = AddPreferedAddress()
            service.buildParams(addressID)
            service.callService(NSDictionary(),  successBlock:{ (resultCall:NSDictionary?) in
                print("success")
                self.callServiceAddress()
                }, errorBlock: {(error: NSError) in
                    self.viewLoad.stopAnnimating()
                    self.viewLoad = nil
                    print("error")
            })
        }
    }

    func deleteAddressGR(idAddress:String){
        
         self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"), imageDone:UIImage(named:"done"), imageError:UIImage(named:"address_error"))
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        
        let service = GRAddressAddService()
        let serviceAddress = GRAddressesByIDService()
        serviceAddress.addressId = idAddress
        serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_GR_DELETE_ADDRESS.rawValue, label: "")
            
            let name = result["name"] as! String!
            let outerNumber = result["outerNumber"] as! String!
            let innerNumber = result["innerNumber"] as! String!
            let reference1 = result["reference1"] as! String!
            let reference2 = result["reference2"] as! String!
            let zipCode = result["zipCode"] as! String!
            let street = result["street"] as! String!
            let city = result["city"] as! String!
            let state = result["state"] as! String!
            let county = result["county"] as! String!
            
            let neighborhoodID = result["neighborhoodID"] as! String!
            let storeID = result["storeID"] as! String!
            
            let dictSend = service.buildParams(city, addressID: idAddress, zipCode: zipCode, street: street, innerNumber: innerNumber, state: state, county: county, neighborhoodID: neighborhoodID, phoneNumber: "", outerNumber: outerNumber, adName: name, reference1: reference1, reference2: reference2, storeID: storeID,storeName: "", operationType: "B", preferred: false)
            
            service.callService(requestParams: dictSend, successBlock: { (result:NSDictionary) -> Void in

             
                if let message = result["message"] as? String {
                    if self.alertView != nil {
                        self.alertView!.setMessage("\(message)")
                        self.alertView!.showDoneIcon()
                    }
                    let serviceAddress = GRAddressesByIDService()
                    serviceAddress.addressId = result["addressID"] as? String
                    serviceAddress.callService([:], successBlock: { (result:NSDictionary) -> Void in
                        UserCurrentSession.sharedInstance().getStoreByAddress(result)
                        }, errorBlock: { (error:NSError) -> Void in
                    })
                }
                self.alertView = nil
                
                if self.btnSuper.selected {
                    self.callServiceAddressGR()
                }else{
                    self.callServiceAddress()
                }
                    
                }, errorBlock: { (error:NSError) -> Void in
                    print("error")
                    self.alertView!.setMessage(error.localizedDescription)
                    self.alertView!.showErrorIcon("Ok")
                     self.alertView = nil
                    
            })
            }, errorBlock: { (error:NSError) -> Void in
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView = nil
        })
    }
    
    
    func deleteAddress(idAddress:String){
        let service = DeleteAddressesByUserService()
        service.buildParams(idAddress)
        
        if self.alertView == nil {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"address_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        }
        
        self.alertView!.setMessage(NSLocalizedString("profile.message.delete",comment:""))
        service.callService(NSDictionary(), successBlock:{ (resultCall:NSDictionary?) in
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_MG_DELETE_ADDRESS.rawValue, label: "")
            
            if let message = resultCall!["message"] as? String {
                if self.alertView != nil {
                    self.alertView!.setMessage("\(message)")
                    self.alertView!.showDoneIcon()
                }
            }//if let message = resultCall!["message"] as? String {
             self.alertView = nil
            if self.btnSuper.selected {
                self.callServiceAddressGR()
            }else{
                self.callServiceAddress()
            }
            }
            , errorBlock: {(error: NSError) in
                print("error")
                self.alertView!.setMessage(error.localizedDescription)
                self.alertView!.showErrorIcon("Ok")
                self.alertView = nil
        })
    }

    //MARK: CHange Súper Tecnologia Hogar y mas
    func changeSuperTech(sender:UIButton) {
        if sender == btnSuper &&  !sender.selected {
            sender.selected = true;
            btnTech.selected = false
            
            self.newAddressButton!.hidden = !self.emptyView!.hidden || arrayAddressShippingGR.count >= 12
            
                 
            table.reloadData()
        } else if sender == btnTech &&  !sender.selected {
            sender.selected = true;
            btnSuper.selected = false
            
            self.newAddressButton!.hidden = !self.emptyView!.hidden || (self.arrayAddressFiscal.count >= 12 && self.arrayAddressShipping.count >= 12)
            
                      
            table.reloadData()
        }//else if sender == btnTech &&  !sender.selected {
    }
    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_MY_ADDRES.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue, label:"")
        super.back()
    }
}
