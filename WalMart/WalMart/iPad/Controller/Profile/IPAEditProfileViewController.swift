//
//  IPAEditProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 14/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class IPAEditProfileViewController: EditProfileViewController {

    override func viewDidLoad() {
        self.hiddenBack = true
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.cancelButton!.removeFromSuperview()
        self.cancelButton = nil
        self.saveButton!.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     builds component elements
     */
    override func buildComponetViews() {
        let bounds = self.view.bounds
        let topSpace: CGFloat = 8.0
        let horSpace: CGFloat = 16.0
        let fieldWidth = self.view.bounds.width - (horSpace*2)
        let fieldHeight: CGFloat = 40.0
        
        self.personalInfoLabel.frame = CGRect(x: horSpace, y: 0, width: fieldWidth, height: 28)
        self.name.frame = CGRect(x: horSpace, y: self.personalInfoLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.lastName.frame = CGRect(x: horSpace, y: self.name.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.email.frame = CGRect(x: horSpace, y: self.lastName.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.changePasswordLabel.frame = CGRect(x: horSpace, y: self.email.frame.maxY + topSpace, width: fieldWidth, height: 28)
        self.changuePasswordButton!.frame = CGRect(x: horSpace, y: self.changePasswordLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.passwordInfoLabel.frame = CGRect(x: horSpace, y: self.changuePasswordButton!.frame.maxY + topSpace, width: fieldWidth, height: 14)
        self.passworCurrent!.frame = CGRect(x: horSpace, y: self.passwordInfoLabel!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.password!.frame = CGRect(x: horSpace, y: self.passworCurrent!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.confirmPassword!.frame = CGRect(x: horSpace, y: self.password!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        if self.showPasswordInfo {
            self.aditionalInfoLabel.frame = CGRect(x: horSpace, y: self.confirmPassword!.frame.maxY + topSpace, width: fieldWidth, height: 28)
        }else{
            self.aditionalInfoLabel.frame = CGRect(x: horSpace, y: self.changuePasswordButton!.frame.maxY + topSpace, width: fieldWidth, height: 28)
        }
        
        self.gender.frame = CGRect(x: horSpace, y: self.aditionalInfoLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.birthDate.frame = CGRect(x: horSpace, y: self.gender.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.ocupation.frame = CGRect(x: horSpace, y: self.birthDate.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.phoneInformationLabel.frame = CGRect(x: horSpace, y: self.ocupation.frame.maxY + topSpace, width: fieldWidth, height: 28)
        self.phoneHome!.frame = CGRect(x: horSpace, y: self.phoneInformationLabel.frame.maxY + topSpace, width: 317, height: fieldHeight)
        self.phoneHomeExtension!.frame = CGRect(x: self.phoneHome!.frame.maxX + 16, y: phoneInformationLabel.frame.maxY + topSpace, width: 317, height: fieldHeight)
        self.cellPhone!.frame = CGRect(x: horSpace, y: self.phoneHomeExtension!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        self.associateLabel.frame = CGRect(x: horSpace, y: self.cellPhone!.frame.maxY + topSpace, width: fieldWidth, height: 28)
        self.isAssociateButton!.frame = CGRect(x: horSpace, y: self.associateLabel.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.associateNumber!.frame = CGRect(x: horSpace, y: self.isAssociateButton!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.associateDeterminant!.frame = CGRect(x: horSpace, y: self.associateNumber!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        self.associateDate!.frame = CGRect(x: horSpace, y: self.associateDeterminant!.frame.maxY + topSpace, width: fieldWidth, height: fieldHeight)
        
        if self.showAssociateInfo {
            self.legalInformationLabel!.frame = CGRect(x: horSpace, y: self.associateDate!.frame.maxY + horSpace, width: 103, height: 14)
            self.legalInformation!.frame = CGRect(x: self.legalInformationLabel!.frame.maxX, y: self.associateDate!.frame.maxY + horSpace, width: fieldWidth - 103, height: 14)
        }else{
            self.legalInformationLabel!.frame = CGRect(x: horSpace, y: self.isAssociateButton!.frame.maxY + horSpace, width: 103, height: 14)
            self.legalInformation!.frame = CGRect(x: self.legalInformationLabel!.frame.maxX, y: self.isAssociateButton!.frame.maxY + horSpace, width: fieldWidth - 103, height: 14)
        }
        
        let downSpace: CGFloat = 118
        self.content.contentSize = CGSize(width: bounds.width, height:  self.legalInformation!.frame.maxY + horSpace)
        self.content.frame = CGRect(x: 0, y: self.header!.frame.maxY , width: self.view.bounds.width , height: self.view.bounds.height - downSpace)
        
        self.layerLine.frame = CGRect(x: 0, y: self.content.frame.maxY, width: self.view.bounds.width, height: 1)
        self.saveButton!.frame = CGRect(x: (self.view.frame.width/2) - 70 , y: self.layerLine.frame.maxY + 16, width: 140, height: 40)
    }

    
}
