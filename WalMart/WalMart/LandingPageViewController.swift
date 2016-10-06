//
//  LandingPageViewController.swift
//  WalMart
//
//  Created by Daniel V on 30/09/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class LandingPageViewController : BackToSchoolCategoryViewController{
    
    var header: UIView? = nil
    var backButton : UIButton? = nil
    var titleLabelEdit: UILabel? = nil
    var hiddenBack = false
    
    var titleHeader = String?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.buttonClose.hidden = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
    }
    
    func setup() {
        self.header = UIView()
        titleLabelEdit = UILabel()
        var titleText = titleHeader!
        if titleText.length() > 47
        {
            titleText = titleText.substring(0, length: 44) + "..."
        }
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "search_edit")
        let attachmentString = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString(string: "\(titleText) ")
        myString.appendAttributedString(attachmentString)
        titleLabelEdit!.numberOfLines = 2
        titleLabelEdit!.attributedText = myString
        titleLabelEdit!.userInteractionEnabled = true
        titleLabelEdit!.textColor =  WMColor.light_blue
        titleLabelEdit!.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabelEdit!.numberOfLines = 2
        titleLabelEdit!.textAlignment = .Center
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LandingPageViewController.editSearch))
        titleLabelEdit!.addGestureRecognizer(tapGesture)
        
        self.header?.backgroundColor = WMColor.light_light_gray
        self.header?.addSubview(titleLabelEdit!)
        self.view.addSubview(self.header!)
        
        if !hiddenBack{
            self.backButton = UIButton()
            self.backButton!.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
            self.backButton!.addTarget(self, action: #selector(NavigationViewController.back), forControlEvents: UIControlEvents.TouchUpInside)
            self.header?.addSubview(self.backButton!)
        }
        
        self.titleLabelEdit?.textAlignment = NSTextAlignment.Center
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.imageBackground.frame = CGRectMake(0,startView ,self.view.frame.width , CELL_HEIGHT)
        self.searchView.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.frame.width, 84)
        self.separator.frame = CGRectMake(0, self.searchView!.bounds.maxY - 1, self.view.frame.width, 1)
        self.clearButton!.frame = CGRectMake(self.searchView.frame.width - self.searchFieldSpace, 22, 55, 40)
        
        if self.titleLabelEdit != nil && self.titleLabelEdit!.frame.width == 0 {
            self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
            self.titleLabelEdit!.frame = CGRectMake(46, 0, self.header!.frame.width - 92, self.header!.frame.maxY)
        }
        if backButton != nil{
            self.backButton!.frame = CGRectMake(0, 0  ,46,46)
        }
        
        self.searchField.frame = CGRectMake(16, 22, self.view.frame.width - (self.searchFieldSpace + 32), 0.0)
        self.schoolsTable.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.bounds.width, self.view.bounds.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(){
        self.navigationController?.popToRootViewControllerAnimated(true)
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
    }
    
    func editSearch(){
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.EditSearch.rawValue, object: titleHeader!)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let school = self.filterList![indexPath.row]
        let gradesController = GradesListViewController()
        gradesController.departmentId = self.departmentId
        gradesController.familyId = school["id"] as! String
        gradesController.schoolName = titleHeader //school["name"] as! String
        gradesController.isSearching = true
        self.navigationController?.pushViewController(gradesController, animated: true)
    }
    
    override func showImageHeader(didShow:Bool) {
        if didShow {
            self.startView = 46.0
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageBackground.frame = CGRectMake(0, self.startView,self.view.frame.width , 98)
                self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
                self.schoolsTable.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.bounds.width, self.view.bounds.height - self.searchView!.frame.maxY)
                }) { (complete:Bool) -> Void in
            }
        }else{
            self.startView = -52
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageBackground.frame = CGRectMake(0,self.startView,self.view.frame.width , 98)
                self.header!.frame = CGRectMake(0, 0, self.view.bounds.width, 46)
                self.schoolsTable.frame = CGRectMake(0, self.imageBackground!.frame.maxY, self.view.bounds.width, self.view.bounds.height)
                }) { (complete:Bool) -> Void in
            }
        }
    }
    
    
}