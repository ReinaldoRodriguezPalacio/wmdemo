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
        self.view.backgroundColor = UIColor.whiteColor()
        self.cancelButton!.layer.cornerRadius = 20
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
        
        self.personalInfoLabel.frame = CGRectMake(horSpace, 0, fieldWidth, 28)
        self.name.frame = CGRectMake(horSpace, self.personalInfoLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.lastName.frame = CGRectMake(horSpace, self.name.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.email.frame = CGRectMake(horSpace, self.lastName.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.changePasswordLabel.frame = CGRectMake(horSpace, self.email.frame.maxY + topSpace, fieldWidth, 28)
        self.changuePasswordButton!.frame = CGRectMake(horSpace, self.changePasswordLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.passwordInfoLabel.frame = CGRectMake(horSpace, self.changuePasswordButton!.frame.maxY + topSpace, fieldWidth, 14)
        self.passworCurrent!.frame = CGRectMake(horSpace, self.passwordInfoLabel!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.password!.frame = CGRectMake(horSpace, self.passworCurrent!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.confirmPassword!.frame = CGRectMake(horSpace, self.password!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        if self.showPasswordInfo {
            self.aditionalInfoLabel.frame = CGRectMake(horSpace, self.confirmPassword!.frame.maxY + topSpace, fieldWidth, 28)
        }else{
            self.aditionalInfoLabel.frame = CGRectMake(horSpace, self.changuePasswordButton!.frame.maxY + topSpace, fieldWidth, 28)
        }
        
        self.gender.frame = CGRectMake(horSpace, self.aditionalInfoLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.birthDate.frame = CGRectMake(horSpace, self.gender.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.ocupation.frame = CGRectMake(horSpace, self.birthDate.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.phoneInformationLabel.frame = CGRectMake(horSpace, self.ocupation.frame.maxY + topSpace, fieldWidth, 28)
        self.phoneHome!.frame = CGRectMake(horSpace, self.phoneInformationLabel.frame.maxY + topSpace, 317, fieldHeight)
        self.phoneHomeExtension!.frame = CGRectMake(self.phoneHome!.frame.maxX + 16, phoneInformationLabel.frame.maxY + topSpace, 317, fieldHeight)
        self.cellPhone!.frame = CGRectMake(horSpace, self.phoneHomeExtension!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        self.associateLabel.frame = CGRectMake(horSpace, self.cellPhone!.frame.maxY + topSpace, fieldWidth, 28)
        self.isAssociateButton!.frame = CGRectMake(horSpace, self.associateLabel.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.associateNumber!.frame = CGRectMake(horSpace, self.isAssociateButton!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.associateDeterminant!.frame = CGRectMake(horSpace, self.associateNumber!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        self.associateDate!.frame = CGRectMake(horSpace, self.associateDeterminant!.frame.maxY + topSpace, fieldWidth, fieldHeight)
        
        if self.showAssociateInfo {
            self.legalInformationLabel!.frame = CGRectMake(horSpace, self.associateDate!.frame.maxY + horSpace, 103, 14)
            self.legalInformation!.frame = CGRectMake(self.legalInformationLabel!.frame.maxX, self.associateDate!.frame.maxY + horSpace, fieldWidth - 103, 14)
        }else{
            self.legalInformationLabel!.frame = CGRectMake(horSpace, self.isAssociateButton!.frame.maxY + horSpace, 103, 14)
            self.legalInformation!.frame = CGRectMake(self.legalInformationLabel!.frame.maxX, self.isAssociateButton!.frame.maxY + horSpace, fieldWidth - 103, 14)
        }
        
        let downSpace: CGFloat = 118
        self.content.contentSize = CGSize(width: bounds.width, height:  self.legalInformation!.frame.maxY + horSpace)
        self.content.frame = CGRectMake(0, self.header!.frame.maxY , self.view.bounds.width , self.view.bounds.height - downSpace)
        
        self.layerLine.frame = CGRectMake(0, self.content.frame.maxY, self.view.bounds.width, 1)
        self.cancelButton!.frame = CGRectMake((self.view.frame.width/2) - 148,self.layerLine.frame.maxY + 16, 140, 40)
        self.saveButton!.frame = CGRectMake((self.view.frame.width/2) + 8 , self.layerLine.frame.maxY + 16, 140, 40)
    }

    
}
