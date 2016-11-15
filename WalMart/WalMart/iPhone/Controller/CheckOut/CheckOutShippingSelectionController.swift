//
//  CheckOutShippingSelectionController.swift
//  WalMart
//
//  Created by Everardo Garcia on 06/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


protocol CheckOutShippingSelectionDelegate {
    func selectDataTypeShipping(_ envio: String, util: String, date: String, rowSelected: Int)
}


class CheckOutShippingSelectionController: NavigationViewController, UITableViewDelegate,UITableViewDataSource {

    var tableShippingSelection : UITableView!
    var saveButton : UIButton?
    var arrayTypeSelect : NSMutableArray?
    var titleString : String?
    var delegate: CheckOutShippingSelectionDelegate?
    var rowSelected : Int? = -1
    
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_GRCHECKOUT.rawValue
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.backButton?.isHidden = IS_IPAD
        
        self.titleLabel?.text = titleString
        
        tableShippingSelection = UITableView(frame:CGRect(x: 0, y: 46 , width: self.view.frame.width, height: self.view.frame.height - 46))
        tableShippingSelection.clipsToBounds = true
        tableShippingSelection.backgroundColor =  WMColor.light_light_gray
        tableShippingSelection.backgroundColor =  UIColor.white
        tableShippingSelection.layoutMargins = UIEdgeInsets.zero
        tableShippingSelection.separatorInset = UIEdgeInsets.zero
        tableShippingSelection.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        tableShippingSelection.delegate = self
        tableShippingSelection.dataSource = self
        tableShippingSelection.separatorStyle = .none
        tableShippingSelection.register(CheckOutShippingSelectionCell.self, forCellReuseIdentifier: "CheckOutShippingSelection")
        tableShippingSelection.reloadData()
        
        self.view.addSubview(tableShippingSelection)
     
        self.saveButton = UIButton(frame: CGRect(x:16 , y:16 , width: (self.view.frame.width - 40) / 2  , height:34))
        self.saveButton!.setTitle("Guardar", for: UIControlState())
        self.saveButton!.setTitleColor(UIColor.white, for: UIControlState())
        self.saveButton!.addTarget(self, action: #selector(CheckOutShippingSelectionController.save), for: .touchUpInside)
        self.saveButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.saveButton!.backgroundColor =  WMColor.green
        self.saveButton!.layer.cornerRadius =  17
        self.view.addSubview(self.saveButton!)
    
        let shippingNormal = ["type":"Envío normal" ,"util":"Hasta 7 días" ,"date":"(Fecha estimada de entrega 15/03/2016)" ]
        let shippingEstandar = ["type":"Envío estándar" ,"util":"Hasta 5 días" ,"date":"(Fecha estimada de entrega 13/03/2016)" ]
        let shippingExpress = ["type":"Envío express" ,"util":"Hasta 1 días" ,"date":"(Fecha estimada de entrega 08/03/2016)" ]

        arrayTypeSelect = NSMutableArray()
        
        arrayTypeSelect?.add(shippingNormal)
        arrayTypeSelect?.add(shippingEstandar)
        arrayTypeSelect?.add(shippingExpress)
     
        if rowSelected >= 0 {
            let indexPath = IndexPath(item: rowSelected!, section: 0)
            tableShippingSelection.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        }
        
        self.tableShippingSelection.bringSubview(toFront: self.view)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableShippingSelection.frame = CGRect(x: 0, y: 46 , width: self.view.frame.width, height: self.view.frame.height - 46 - 62)
        self.saveButton!.frame =  CGRect(x: 12 , y: self.view.frame.height - 52 , width: self.view.frame.width - 24 , height: 34)
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let content : UIView = UIView(frame: CGRect(x: 0.0, y: 0.0 , width: self.view.frame.width, height: 32))
        content.backgroundColor = UIColor.white
        
        let titleLabel = UILabel(frame: CGRect(x: 15.0, y: 15.0, width: self.view.frame.width, height: 16))
        titleLabel.text = "Selecciona un tipo de envío"
        titleLabel.textColor = WMColor.light_blue
        titleLabel.font = WMFont.fontMyriadProLightOfSize(14)
        
        
        content.addSubview(titleLabel)
        
        return content
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellText = tableShippingSelection.dequeueReusableCell(withIdentifier: "CheckOutShippingSelection", for: indexPath) as! CheckOutShippingSelectionCell
        
        let dic = self.arrayTypeSelect![(indexPath as NSIndexPath).row] as? [String:Any]
        
        let type = dic!["type"] as! String
        let util = dic!["util"] as! String
        let date = dic!["date"] as! String
        
        cellText.setValues(type, util: util, date: date)
        cellText.type!.textColor = WMColor.dark_gray
        cellText.setCostDelivery("120.22")
        cellText.selectionStyle = UITableViewCellSelectionStyle.none
        
        if (indexPath as NSIndexPath).row == rowSelected {
            cellText.setSelected(true, animated: true)
            cellText.selectedButton!.isSelected = true
        }else {
            cellText.setSelected(false, animated: true)
             cellText.selectedButton!.isSelected = false
            
        }
        
        
        return cellText
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected = (indexPath as NSIndexPath).row
    }
    
    
    func save () {
        //Seleccionar un Tipo de envio
        if self.rowSelected! != -1  {
            let dic = self.arrayTypeSelect![self.rowSelected!] as? [String:Any]
            
            let type = dic!["type"] as! String
            let util = dic!["util"] as! String
            let date = dic!["date"] as! String
            self.delegate?.selectDataTypeShipping(type, util: util, date: date, rowSelected:self.rowSelected!)
        }
        self.navigationController!.popViewController(animated: true)

        
    }
    
}
