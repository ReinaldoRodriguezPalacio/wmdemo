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
    var selectedRow: IndexPath! = nil
    var referedCountLabel: UILabel?
    var referedDescLabel: UILabel?
    var addReferedButton: UIButton?
    var layerLine: CALayer!
    var modalView: AlertModalView?
    var viewLoad: WMLoadingView?
    var alertView: IPOWMAlertViewController? = nil
    
    var confirmRefered: [Any]! = []
    var pendingRefered: [Any]! = []
    var numFreeShipping: Int = 0
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_REFERED.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.titleLabel?.text = NSLocalizedString("refered.title", comment: "")
        
        self.layerLine = CALayer()
        layerLine.backgroundColor = WMColor.light_light_gray.cgColor
        self.view.layer.insertSublayer(layerLine, at: 0)
        
        referedTable = UITableView()
        referedTable.register(ReferedTableViewCell.self, forCellReuseIdentifier: "referedCell")
        referedTable.register(ReferedDetailTableViewCell.self, forCellReuseIdentifier: "referedDetail")
        referedTable.separatorStyle = UITableViewCellSeparatorStyle.none
        referedTable.delegate = self
        referedTable.dataSource = self
        self.view.addSubview(referedTable!)
        
        referedCountLabel = UILabel()
        referedCountLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        referedCountLabel?.textColor = WMColor.light_blue
        referedCountLabel?.text = ""
        referedCountLabel?.textAlignment = .center
        self.view.addSubview(referedCountLabel!)
        
        referedDescLabel = UILabel()
        referedDescLabel?.font = WMFont.fontMyriadProLightOfSize(14)
        referedDescLabel?.textColor = WMColor.light_blue
        referedDescLabel?.numberOfLines = 3
        referedDescLabel?.text =  NSLocalizedString("refered.description.message", comment: "")
        referedDescLabel?.textAlignment = .center
        self.view.addSubview(referedDescLabel!)
        
        addReferedButton = UIButton()
        addReferedButton?.setTitle(NSLocalizedString("refered.button.add", comment: ""), for:UIControlState())
        addReferedButton?.setTitleColor(UIColor.white, for: UIControlState())
        addReferedButton?.backgroundColor = WMColor.light_gray
        addReferedButton?.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        addReferedButton?.layer.cornerRadius = 16
        addReferedButton?.addTarget(self, action: #selector(ReferedViewController.addRefered), for: UIControlEvents.touchUpInside)
        addReferedButton?.isEnabled = false
        self.view.addSubview(addReferedButton!)
        
        self.addViewLoad()
        self.invokeReferedCustomerService()
        self.invokeValidateActiveReferedService()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.referedCountLabel!.frame = CGRect(x: 0, y: headerHeight + 16, width: self.view.frame.width, height: 16)
        self.referedDescLabel!.frame = CGRect(x: 0, y: self.referedCountLabel!.frame.maxY + 16, width: self.view.frame.width, height: 42)
        self.addReferedButton!.frame = CGRect(x: (self.view.frame.width - 132) / 2, y: self.referedDescLabel!.frame.maxY + 16, width: 132, height: 34)
        self.layerLine.frame =  CGRect(x: 0, y: self.addReferedButton!.frame.maxY + 15, width: self.view.frame.width, height: 1)
        self.referedTable!.frame = CGRect(x: 0, y: self.addReferedButton!.frame.maxY + 16, width: self.view.frame.width, height: self.view.frame.height - self.addReferedButton!.frame.maxY)
    }
    
    //MARK: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedRow != nil {
            if selectedRow.section == section {
                return numberOfRowsInSection(section) + 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            let referedCell = referedTable.dequeueReusableCell(withIdentifier: "referedCell", for: indexPath) as! ReferedTableViewCell
            referedCell.setTitleAndCount(titleSection, count:  "\(referedArray.count)")
            cell = referedCell
        }else{
           let cellDetail = referedTable.dequeueReusableCell(withIdentifier: "referedDetail", for: indexPath) as! ReferedDetailTableViewCell
            let refered = referedArray[indexPath.row - 1]
            let name = refered["nameRef"] as! String
            let email = refered["emailRef"] as! String
            cellDetail.setValues(name, email: email)
            cell = cellDetail
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  {
            if selectedRow != nil && indexPath == selectedRow{
                deSelectSection(selectedRow)
            }else{
                if selectedRow != nil{
                    deSelectSection(selectedRow)
                }
                selectSection(indexPath)
            }
        }else if indexPath.section == 1 {
            let refered = self.confirmRefered[indexPath.row - 1]
            let name = refered["nameRef"] as! String
            let email = refered["emailRef"] as! String
            let addreferedForm = ReferedForm(frame: CGRect(x: 0, y: 0,  width: 288, height: 248))
            addreferedForm.showReferedUser(name, mail: email)
            self.modalView = AlertModalView.initModalWithView(NSLocalizedString("refered.title.showrefered", comment: ""),innerView: addreferedForm)
            self.modalView!.showPicker()
        }
    }
    
    func numberOfRowsInSection(_ section:Int) -> Int {
        if section == 0 {
            return self.pendingRefered.count
        }
        else if section == 1{
            return self.confirmRefered.count
        }
        return 0
    }
    
    /**
     Adds new rows for the selected section
     
     - parameter indexPath: selected indexPath
     */
    func selectSection(_ indexPath: IndexPath!) {
        selectedRow = indexPath
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [IndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(IndexPath(row: index, section: indexPath.section))
            }
            self.referedTable.insertRows(at: arratIndexes, with: .automatic)
        }
    }
    
    /**
     Dletes rows of the selected section
     
     - parameter indexPath: selected indexPath
     */
    func deSelectSection(_ indexPath: IndexPath!) {
        selectedRow = nil
        let numberOfItems = numberOfRowsInSection(indexPath.section)
        var arratIndexes : [IndexPath] = []
        if numberOfItems > 0 {
            for index in 1...numberOfItems {
                arratIndexes.append(IndexPath(row: index, section: indexPath.section))
            }
            self.referedTable.deleteRows(at: arratIndexes, with: .automatic)
        }
    }
    
    /**
     Shows a form to adds refered
     */
    func addRefered(){
        let addreferedForm = ReferedForm(frame: CGRect(x: 0, y: 0,  width: 288, height: 248))
        addreferedForm.delegate = self
        self.modalView = AlertModalView.initModalWithView(addreferedForm)
        self.modalView!.showPicker()
    }
    
    /**
     Sets an UILabel with the user refered number
     
     - parameter countRefered: user refered number
     */
    func setCountLabel(_ countRefered:Int){
       var message = ""
        if countRefered == 0{
            message = "No tienes envíos sin costo disponibles"
        }else if countRefered == 1 {
            message = "¡Tienes 1 envío sin costo disponible!"
        }else {
            message = "¡Tienes \(countRefered) envíos sin costo disponibles!"
        }
        self.referedCountLabel!.text = message
    }
    //MARK: Services
    /**
     Gets the user refereds
     */
    func invokeReferedCustomerService(){
        let referedCustomerService = ReferedCustomerService()
        referedCustomerService.callService({ (result:[String:Any]) -> Void in
            if (result["codeMessage"] as! Int) == 0{
                self.numFreeShipping = 0
                if let numFreeShippingRef = result["numFreeShippingRef"] as? Int{
                    self.numFreeShipping = numFreeShippingRef
                }
                
                if let responceArray = result["listEmailsRef"] as? [Any] {
                    for refered in responceArray {
                        let status = refered["statusRef"] as! String
                        if status == "No"{
                            self.pendingRefered.append(refered)
                        }else{
                            self.confirmRefered.append(refered)
                        }
                    }
                }
                
                self.setCountLabel(self.numFreeShipping)
                self.referedTable.reloadData()
            }
             self.removeViewLoad()
            }, errorBlock: {(error:NSError) -> Void in
                print("Error in ReferedCustomerService")
             self.removeViewLoad()
        })
    }
    
    /**
     Service than indicates if the user can add refereds
     */
    func invokeValidateActiveReferedService(){
        let validateActiveReferedService = ValidateActiveReferedService()
        validateActiveReferedService.callService({ (result:[String:Any]) -> Void in
            if let isActive = result["responseObject"] as? Bool{
                if isActive{
                    self.addReferedButton?.isEnabled = true
                    self.addReferedButton?.backgroundColor = WMColor.light_blue
                }
                else{
                    self.addReferedButton?.isEnabled = false
                    self.addReferedButton?.backgroundColor = WMColor.light_gray
                }
            }
            }, errorBlock: {(error:NSError) -> Void in
                print("Error in validateActiveReferedService")
                self.addReferedButton?.isEnabled = false
                self.addReferedButton?.backgroundColor = WMColor.light_gray
        })
    }
    
    func addViewLoad(){
        if viewLoad == nil {
            viewLoad = WMLoadingView(frame:CGRect(x: 0, y: 0, width: (self.parent?.view.bounds.width)!, height: (self.parent?.view.bounds.height)!))
            viewLoad!.backgroundColor = UIColor.white
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
    /**
     Adds refered
     
     - parameter name: refered name
     - parameter mail: refered mail
     */
    func selectSaveButton(_ name:String,mail:String) {
        modalView?.closePicker()
        let addReferedService = AddReferedCustumerService()
        self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"address_error"))
        self.alertView!.view.alpha = 0.96
        addReferedService.callService(requestParams: addReferedService.buildParamsRefered(mail, nameRef: name, isReferedAutorized: true),
            successBlock: {(result:[String:Any]) -> Void in
                //codeMessage 0 == OK; codeMessage -1 == NOOK
                let codeMessage = result["codeMessage"] as! Int
                let messageResult = result["message"] as! String
                if codeMessage == 0
                {
                    self.alertView!.setMessage(messageResult)
                    self.alertView!.showicon(UIImage(named: "alerta_listo"))
                    self.alertView!.showOkButton("OK", colorButton: WMColor.green)

                }else if codeMessage == -1 {
                    self.alertView!.setMessage(messageResult)
                    self.alertView!.showicon(UIImage(named: "alerta_repetir"))
                    self.alertView!.showOkButton("OK", colorButton: WMColor.green)
                }
                
                self.pendingRefered =  []
                self.confirmRefered = []
                
                self.addViewLoad()
                self.invokeReferedCustomerService()
                self.invokeValidateActiveReferedService()
            },
            errorBlock: {(error:NSError) -> Void in
                print("Error AddRefered")
                self.alertView!.setMessage(NSLocalizedString("refered.add.error", comment: ""))
                self.alertView!.showicon(UIImage(named: "alerta_fail"))
                self.alertView!.showOkButton("OK", colorButton: WMColor.green)
            })
    }
    /**
     Close refered add form
     */
    func selectCloseButton() {
        modalView?.closePicker()
    }

}
