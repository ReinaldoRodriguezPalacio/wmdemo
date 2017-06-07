//
//  ReportProblemViewController.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ReportProblemViewController: NavigationViewController {
    
    var orderItems: [[String:Any]]? = nil
    var tableProducts: UITableView!
    var mesageLabel: UILabel!
    var reasonLabel: UILabel!
    var reasonField: FormFieldView!
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_PREVIOUSORDERS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.titleLabel!.text = "Reportar un problema"
        
        self.mesageLabel = UILabel()
        self.mesageLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        self.mesageLabel.textColor = WMColor.gray
        self.mesageLabel.text = "Selecciona un motivo por el cuál requieres reportar un problema con este envío."
        self.mesageLabel.numberOfLines = 2
        self.mesageLabel.textAlignment = .left
        
        self.reasonLabel = UILabel()
        self.reasonLabel.font = WMFont.fontMyriadProLightOfSize(14)
        self.reasonLabel.textColor = WMColor.light_blue
        self.reasonLabel.text = "Motivo"
        self.reasonLabel.textAlignment = .left
        
        self.reasonField = FormFieldView(frame: CGRect(x:16, y: self.header!.frame.maxY + 110, width:self.view.frame.width - 32, height: 40))
        self.reasonField.setCustomPlaceholder("Seleciona una opción")
        self.reasonField.typeField = .list
        self.reasonField.setImageTypeField()
        
        self.tableProducts = UITableView()
        self.tableProducts.backgroundColor = UIColor.white
//        self.tableProducts.delegate = self
//        self.tableProducts.dataSource = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.mesageLabel.frame = CGRect(x:16, y: self.header!.frame.maxY, width:self.view.frame.width - 32, height: 64)
        self.reasonLabel.frame = CGRect(x:16, y: self.mesageLabel.frame.maxY, width:self.view.frame.width - 32, height: 46)
        self.reasonField.frame = CGRect(x:16, y: self.reasonLabel.frame.maxY + 110, width:self.view.frame.width - 32, height: 40)
        self.tableProducts.frame = CGRect(x:0, y: self.reasonField.frame.maxY + 16, width:self.view.frame.width, height: self.view.frame.height - (110))
        
    }
    
}
