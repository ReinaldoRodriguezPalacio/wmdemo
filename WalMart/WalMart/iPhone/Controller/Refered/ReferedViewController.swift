//
//  ReferedViewController.swift
//  WalMart
//
//  Created by Alonso Salcido on 10/11/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation

class ReferedViewController: NavigationViewController,UITableViewDataSource,UITableViewDelegate, ReferedFormDelegate{
    
    let headerHeight: CGFloat = 46
    
    var referedTable: UITableView!
    var selectedRow: NSIndexPath! = nil
    var referedCountLabel: UILabel?
    var referedDescLabel: UILabel?
    var addReferedButton: UIButton?
    var layerLine: CALayer!
    var modalView: AlertModalView?
    var viewLoad: WMLoadingView?
    var alertView: IPOWMAlertViewController? = nil
    
    var confirmRefered: [AnyObject]! = []
    var pendingRefered: [AnyObject]! = []
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REFERED.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.titleLabel?.text = NSLocalizedString("refered.title", comment: "")
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.lineSaparatorColor.CGColor
        self.view.layer.insertSublayer(layerLine, atIndex: 0)
        
        referedTable = UITableView()
        referedTable.registerClass(ReferedTableViewCell.self, forCellReuseIdentifier: "referedCell")
        referedTable.registerClass(ReferedDetailTableViewCell.self, forCellReuseIdentifier: "referedDetail")
        referedTable.separatorStyle = UITableViewCellSeparatorStyle.None
        referedTable.delegate = self
        referedTable.dataSource = self
        self.view.addSubview(referedTable!)
        
        referedCountLabel = UILabel()
        referedCountLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        referedCountLabel?.textColor = WMColor.listAddressHeaderSectionColor
        referedCountLabel?.text = ""
        referedCountLabel?.textAlignment = .Center
        self.view.addSubview(referedCountLabel!)
        
        referedDescLabel = UILabel()
        referedDescLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        referedDescLabel?.textColor = WMColor.listAddressHeaderSectionColor
        referedDescLabel?.numberOfLines = 3
        referedDescLabel?.text =  NSLocalizedString("refered.description.message", comment: "")
        referedDescLabel?.textAlignment = .Center
        self.view.addSubview(referedDescLabel!)
        
        addReferedButton = UIButton()
        addReferedButton?.setTitle(NSLocalizedString("refered.button.add", comment: ""), forState:.Normal)
        addReferedButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addReferedButton?.backgroundColor = WMColor.light_gray
        addReferedButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addReferedButton?.layer.cornerRadius = 16
        addReferedButton?.addTarget(self, action: "addRefered", forControlEvents: UIControlEvents.TouchUpInside)
        addReferedButton?.enabled = false
        self.view.addSubview(addReferedButton!)
        
        self.addViewLoad()
        self.invokeReferedCustomerService()
        self.invokeValidateActiveReferedService()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.referedCountLabel!.frame = CGRectMake(0, headerHeight + 16, self.view.frame.width, 16)
        self.referedDescLabel!.frame = CGRectMake(0, self.referedCountLabel!.frame.maxY + 16, self.view.frame.width, 42)
        self.addReferedButton!.frame = CGRectMake((self.view.frame.width - 132) / 2, self.referedDescLabel!.frame.maxY + 16, 132, 34)
        self.layerLine.frame =  CGRectMake(0, self.addReferedButton!.frame.maxY + 15, self.view.frame.width, 1)
        self.referedTable!.frame = CGRectMake(0, self.addReferedButton!.frame.maxY + 16, self.view.frame.width, self.view.frame.height - self.addReferedButton!.frame.maxY)
    }
    
    //MARK: Tableview Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedRow != nil {
            if selectedRow.section == section {
                return numberOfRowsInSection(section) + 1
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = nil
        var referedArray = []
        var titleSection = ""
        
        if indexPath.section == 0{
            referedArray = self.pendingRefered
            titleSection = NSLocalizedString("refered.title.pendig", comment: "")
        }
        else{
            referedArray = self.confirmRefered
            titleSection = NSLocalizedString("refered.title.confirm", comment: "")
        }
        
        if indexPath.row == 0{
            let referedCell = referedTable.dequeueReusableCellWithIdentifier("referedCell", forIndexPath: indexPath) as! ReferedTableViewCell
            referedCell.setTitleAndCount(titleSection, count:  "\(referedArray.count)")
            cell = referedCell
        }else{
           let cellDetail = referedTable.dequeueReusableCellWithIdentifier("referedDetail", forIndexPath: indexPath) as! ReferedDetailTableViewCell
            let refered = referedArray[indexPath.row - 1]
            let name = refered["nameRef"] as! String
            let email = refered["emailRef"] as! String
            cellDetail.setValues(name, email: email)
            cell = cellDetail
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0  {
            if selectedRow != nil{
                deSelectSection(selectedRow)
            }
            selectSection(indexPath)
        }else if indexPath.section == 1 {
            let refered = self.confirmRefered[indexPath.row - 1]
            let name = refered["nameRef"] as! String
            let email = refered["emailRef"] as! String
            let addreferedForm = ReferedForm(frame: CGRectMake(0, 0,  288, 248))
            addreferedForm.showReferedUser(name, mail: email)
            self.modalView = AlertModalView.initModalWithView(NSLocalizedString("refered.title.showrefered", comment: ""),innerView: addreferedForm)
            self.modalView!.showPicker()
        }
    }
    
    func numberOfRowsInSection(section:Int) -> Int {
        if section == 0 {
            return self.pendingRefered.count
        }
        else if section == 1{
            return self.confirmRefered.count
        }
        return 0
    }
    
    func selectSection(indexPath: NSIndexPath!) {
        selectedRow = indexPath
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [NSIndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(NSIndexPath(forRow: index, inSection: indexPath.section))
            }
            self.referedTable.insertRowsAtIndexPaths(arratIndexes, withRowAnimation: .Automatic)
        }
    }
    
    func deSelectSection(indexPath: NSIndexPath!) {
        selectedRow = nil
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [NSIndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(NSIndexPath(forRow: index, inSection: indexPath.section))
            }
            self.referedTable.deleteRowsAtIndexPaths(arratIndexes, withRowAnimation: .Automatic)
        }
    }
    
    func addRefered(){
        let addreferedForm = ReferedForm(frame: CGRectMake(0, 0,  288, 248))
        addreferedForm.delegate = self
        self.modalView = AlertModalView.initModalWithView(addreferedForm)
        self.modalView!.showPicker()
    }
    
    func setCountLabel(countRefered:Int){
       var message = ""
        if countRefered == 0{
            message = "No tienes envíos gratis disponibles"
        }else if countRefered == 1 {
            message = "¡Tienes 1 envío gratis disponible!"
        }else {
            message = "¡Tienes \(countRefered) envíos gratis disponibles!"
        }
        self.referedCountLabel!.text = message
    }
    //MARK: Services
    
    func invokeReferedCustomerService(){
        let referedCustomerService = ReferedCustomer()
        referedCustomerService.callService({ (result:NSDictionary) -> Void in
            if (result["codeMessage"] as! Int) == 0{
                let responceArray = result["responseArray"] as! [AnyObject]
                for refered in responceArray {
                    let status = refered["statusRef"] as! String
                    if status == "No"{
                      self.pendingRefered.append(refered)
                    }else{
                        self.confirmRefered.append(refered)
                    }
                }
                self.setCountLabel(self.pendingRefered.count + self.confirmRefered.count)
                self.referedTable.reloadData()
            }
             self.removeViewLoad()
            }, errorBlock: {(error:NSError) -> Void in
                print("Error in ReferedCustomerService")
             self.removeViewLoad()
        })
    }
    
    func invokeValidateActiveReferedService(){
        let validateActiveReferedService = ValidateActiveRefered()
        validateActiveReferedService.callService({ (result:NSDictionary) -> Void in
            if let isActive = result["responseObject"] as? Bool{
                if isActive{
                    self.addReferedButton?.enabled = true
                    self.addReferedButton?.backgroundColor = WMColor.listAddressHeaderSectionColor
                }
                else{
                    self.addReferedButton?.enabled = false
                    self.addReferedButton?.backgroundColor = WMColor.light_gray
                }
            }
            }, errorBlock: {(error:NSError) -> Void in
                print("Error in validateActiveReferedService")
                self.addReferedButton?.enabled = false
                self.addReferedButton?.backgroundColor = WMColor.light_gray
        })
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame: self.view.bounds)
            viewLoad!.backgroundColor = UIColor.whiteColor()
            viewLoad!.startAnnimating(true)
            self.view.addSubview(viewLoad!)
        }
    }
    
    func removeViewLoad(){
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }
    
    //MARK: ReferedFormDelegate
    
    func selectSaveButton(name:String,mail:String) {
        modalView?.closePicker()
        let addReferedService = AddReferedCustumer()
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        self.alertView!.view.alpha = 0.96
        addReferedService.callService(requestParams: addReferedService.buildParamsRefered(mail, nameRef: name, isReferedAutorized: true),
            successBlock: {(result:NSDictionary) -> Void in
                //codeMessage 0 == OK; codeMessage -1 == NOOK
                let codeMessage = result["codeMessage"] as! Int
                if codeMessage == 0
                {
                    self.alertView!.setMessage(NSLocalizedString("refered.add.success", comment: ""))
                    self.alertView!.showicon(UIImage(named: "alerta_listo"))
                    self.alertView!.showOkButton("OK", colorButton: WMColor.productAddToCartGoToShoppingBg)

                }else if codeMessage == -1 {
                    self.alertView!.setMessage(NSLocalizedString("refered.add.repeat", comment: ""))
                    self.alertView!.showicon(UIImage(named: "alerta_repetir"))
                    self.alertView!.showOkButton("OK", colorButton: WMColor.productAddToCartGoToShoppingBg)
                }
            },
            errorBlock: {(error:NSError) -> Void in
                print("Error AddRefered")
                self.alertView!.setMessage(NSLocalizedString("refered.add.error", comment: ""))
                self.alertView!.showicon(UIImage(named: "alerta_fail"))
                self.alertView!.showOkButton("OK", colorButton: WMColor.productAddToCartGoToShoppingBg)
            })
    }
    
    func selectCloseButton() {
        modalView?.closePicker()
    }

}