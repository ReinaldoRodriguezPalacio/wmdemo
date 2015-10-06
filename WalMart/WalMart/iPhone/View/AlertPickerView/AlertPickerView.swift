//
//  AlertPickerView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


protocol AlertPickerViewDelegate {
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String)
    func didDeSelectOption(picker:AlertPickerView)
    
    func viewReplaceContent(frame:CGRect) -> UIView!
    func saveReplaceViewSelected()
    
    func buttomViewSelected(sender:UIButton)
    
}

class AlertPickerView : UIView, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    
    var itemsToShow : [String] = []
    
    var viewContent : UIView!
    var viewContentOptions : UIView!
    var viewHeader: UIView!
    var tableData : UITableView!
    var titleLabel : UILabel!
    var bgView : UIView!
    var viewFooter : UIView!
    var headerView : UIView!
    
    var onClosePicker : (() -> Void)?
    
    var selected : NSIndexPath!
    var delegate : AlertPickerViewDelegate? = nil
    
    var sender : AnyObject? = nil
    
    var buttonRight : WMRoundButton!
    var buttonOk : UIButton!
    
    var viewButtonClose : UIButton!
    var viewReplace : UIView!
    
    var lastTitle : String! = ""
    var titleHeader : String! = ""
    var cellType: TypeField! = TypeField.Check
    var textboxValues: [String:String]? = [:]
    var stopRemoveView: Bool? = false
    var isNewAddres  =  false
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.clearColor()
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        var margin : CGFloat = 8
        
        if IS_IPAD == true {
            margin = 40
        }
        
        let viewButton = UIButton(frame: CGRectMake(margin, margin, 40, 40))
        viewButton.addTarget(self, action: "closePicker", forControlEvents: UIControlEvents.TouchUpInside)
        viewButton.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
        self.addSubview(viewButton)
        
        viewContent = UIView(frame: CGRectMake(0, 0, 286, 316))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.whiteColor()
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRectMake(0, 0, viewContent.frame.width, 46))
        headerView.backgroundColor = WMColor.navigationHeaderBgColor
        viewContent.addSubview(headerView)

        titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.navigationTilteTextColor
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        
        headerView.addSubview(titleLabel)
        
        viewContentOptions = UIView(frame: CGRectMake(0, headerView.frame.height, viewContent.frame.width, viewContent.frame.height - headerView.frame.height))
        
        tableData = UITableView(frame: CGRectMake(0, 0, viewContentOptions.frame.width,viewContentOptions.frame.height - 64))
        tableData.registerClass(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        tableData.registerClass(TextboxTableViewCell.self, forCellReuseIdentifier: "textboxItem")
        tableData.delegate = self
        tableData.dataSource = self

        self.viewContentOptions.addSubview(tableData)
        
        viewFooter = UIView(frame: CGRectMake(0, self.viewContentOptions.frame.height - 64, self.frame.width, 64))
        buttonOk = UIButton(frame: CGRectMake(0, 0, 98, 34))

        buttonOk.backgroundColor = WMColor.UIColorFromRGB(0x2970ca)
        buttonOk.layer.cornerRadius = 17
        buttonOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonOk.setTitle("Ok", forState: UIControlState.Normal)
        buttonOk.center = CGPointMake(self.viewContent.frame.width / 2, 32)
        buttonOk.addTarget(self, action: "okAction", forControlEvents: UIControlEvents.TouchUpInside)
        
        viewFooter.backgroundColor = UIColor.whiteColor()
        viewFooter.addSubview(buttonOk)
        
        self.viewContentOptions.addSubview(viewFooter)
        self.viewContent.addSubview(self.viewContentOptions)
        self.stopRemoveView! = false
        self.addSubview(viewContent)
        
    
    }
    
    override func layoutSubviews() {
        viewContent.center = self.center
        headerView.frame = CGRectMake(0, 0, viewContent.frame.width, 46)
        if !isNewAddres {
            titleLabel.frame = headerView.bounds
        }
        if buttonRight != nil  {
            buttonRight.frame = CGRectMake(self.viewContent.frame.width - 80, 12, 64, 22)
        }
    }
    
    func setValues(title:NSString,values:[String]) {
        self.titleHeader = title as String
        self.titleLabel.text = title as String
        self.itemsToShow = values
        tableData.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToShow.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if cellType == TypeField.Alphanumeric
        {
            self.tableData.separatorStyle = UITableViewCellSeparatorStyle.None
            
            let cell = tableView.dequeueReusableCellWithIdentifier("textboxItem") as! TextboxTableViewCell!
            cell.textbox!.setCustomPlaceholder(itemsToShow[indexPath.row])
            cell.textbox!.maxLength = 0
            
            if indexPath.row == 0 {
                cell.textbox!.maxLength = 8
                cell.textbox!.setCustomDelegate(self)
            }
            if indexPath.row == 2 {
                cell.textbox!.maxLength = 4
                cell.textbox!.setCustomDelegate(self)
            }
            cell.textbox!.delegate = self
            cell.textbox!.nameField = itemsToShow[indexPath.row]
            cell.textLabel?.text = itemsToShow[indexPath.row]
            if self.selected != nil {
                cell.setSelected(indexPath.row == self.selected.row, animated: true)
            }
            
            if itemsToShow[indexPath.row] == NSLocalizedString("checkout.discount.dateAdmission", comment:"") {
                cell.setDatePickerInputView()
            }
            
            return cell
        }
        else
        {
            self.tableData.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSelItem") as! SelectItemTableViewCell!
            cell.textLabel?.text = itemsToShow[indexPath.row]
            if self.selected != nil {
                cell.setSelected(indexPath.row == self.selected.row, animated: true)
            }
            return cell
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.selected.row != indexPath.row {
            let lastSelected = self.selected
            self.selected = indexPath
            tableView.reloadRowsAtIndexPaths([self.selected ,lastSelected], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let textCell = itemsToShow[indexPath.row]
        return  SelectItemTableViewCell.sizeText(textCell, width: 247.0)
    }
    
    func okAction() {
        if self.selected != nil && itemsToShow.count > 0 {
            delegate?.didSelectOption(self,indexPath:self.selected,selectedStr: self.itemsToShow[self.selected.row])
        }else {
             delegate?.didDeSelectOption(self)
        }
        if !self.stopRemoveView!
        {
          self.removeFromSuperview()
        }
        self.stopRemoveView! = false
    }
    
    
    func closePicker() {
        onClosePicker?()
        self.removeFromSuperview()
    }
    
    //MARK TextField delegate
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool
    {
        let formField = textField as! FormFieldView
        let textValue = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString:string)
    
        textboxValues?[formField.nameField] = textValue as String
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let formField = textField as! FormFieldView
        var text = formField.text
        
        if NSLocalizedString("checkout.discount.dateAdmission", comment:"") == formField.nameField! && !text!.isEmpty
        {
            text = TextboxTableViewCell.parseDateString(text!,format:"d MMMM yyyy")
        }
        
        textboxValues?[formField.nameField] = text
    }
    //MARK Show alerts
    
    class func initPicker()  -> AlertPickerView? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            return initPicker(vc!)
        }
        return nil
    }
    
    class func initPicker(controller:UIViewController) -> AlertPickerView? {
        let newAlert = AlertPickerView(frame:controller.view.bounds)
        controller.view.addSubview(newAlert)
        newAlert.startAnimating()
        return newAlert
    }
    
    class func initPickerWithDefault() -> AlertPickerView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertPickerView(frame:vc!.view.bounds)
        return newAlert
    }
    
    func showPicker() {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        vc!.view.addSubview(self)
        //vc!.view.bringSubviewToFront(self)
        self.startAnimating()
        
    }

    
    //MARK: Animated
    
    func startAnimating() {
        
        
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(fromView: self.superview!)
        let imgBackBlur = imgBack.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = WMColor.UIColorFromRGB(0x000000, alpha: 0.6)
        self.bgView.addSubview(bgViewAlpha)
        
        tableData.reloadData()
        
        bgView.alpha = 0
        viewContent.transform = CGAffineTransformMakeTranslation(0,500)
        
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                 self.viewContent.transform = CGAffineTransformIdentity
            })
            
//            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
//                 self.viewContent.transform = CGAffineTransformMakeScale(1,0.01)
//            })
//            
//            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
//                self.viewContent.transform = CGAffineTransformMakeScale(1,1)
//            })
            
            }) { (complete:Bool) -> Void in
            
        }
        
    }
    
    override func removeFromSuperview() {
        UIView.animateKeyframesWithDuration(0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.CalculationModePaced, animations: { () -> Void in
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 0.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransformMakeTranslation(0,500)
            })
            
            //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
            //                 self.viewContent.transform = CGAffineTransformMakeScale(1,0.01)
            //            })
            //
            //            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.0, animations: { () -> Void in
            //                self.viewContent.transform = CGAffineTransformMakeScale(1,1)
            //            })
            
            }) { (complete:Bool) -> Void in
                self.removeComplete()
        }
       
    }
    
    func removeComplete(){
        super.removeFromSuperview()
    }
    
    
    
    func addRigthActionButton(buttonRight:WMRoundButton) {
        if self.buttonRight != nil {
            self.buttonRight.removeFromSuperview()
            self.buttonRight = nil
        }
        self.buttonRight = buttonRight
        self.buttonRight.addTarget(self, action: "newItemForm", forControlEvents: UIControlEvents.TouchUpInside)
        self.buttonRight.frame = CGRectMake(self.viewContent.frame.width - 80, 12, 64, 22)
        self.viewContent.addSubview(buttonRight)
    }
    
    func hiddenRigthActionButton(hidden:Bool) {
        if self.buttonRight != nil {
            self.buttonRight.hidden = hidden
        }
    }
    
    func newItemForm () {
        if self.buttonRight.selected {
           //Save action
            self.delegate?.saveReplaceViewSelected()
        } else {
            self.buttonRight.setBackgroundColor(WMColor.UIColorFromRGB(0x8EBB36), size:CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
            lastTitle = self.buttonRight.titleLabel?.text
            isNewAddres =  true
            if !IS_IPAD{
                self.titleLabel.textAlignment = .Left
                self.titleLabel.frame =  CGRectMake(40, self.titleLabel.frame.origin.y, self.titleLabel.frame.width, self.titleLabel.frame.height)
            }
            
            self.buttonRight.setTitle(NSLocalizedString("profile.save", comment: ""), forState: UIControlState.Normal)
            
            viewButtonClose = UIButton(frame: CGRectMake(0, 0, self.headerView.frame.height,  self.headerView.frame.height))
            viewButtonClose.addTarget(self, action: "closeNew", forControlEvents: UIControlEvents.TouchUpInside)
            viewButtonClose.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
            viewButtonClose.alpha = 0
            self.headerView.addSubview(viewButtonClose)
            
            self.buttonRight.selected = true
            let finalContentFrame = CGRectMake(8, 40, self.frame.width - 16, self.frame.height - 80)
            let finalContentInnerFrame = CGRectMake(0, self.headerView.frame.maxY, finalContentFrame.width, finalContentFrame.height - self.headerView.frame.maxY)
            self.viewReplace = self.delegate?.viewReplaceContent(finalContentInnerFrame)
            self.viewReplace?.alpha = 0
            self.viewContent.addSubview(viewReplace!)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
          
                self.viewContent.frame = finalContentFrame
                self.viewContent.center = self.center
                self.viewReplace?.alpha = 1
                self.viewContentOptions.alpha = 0
                self.viewButtonClose.alpha = 1
                }) { (completed:Bool) -> Void in
                    
            }
        }
    }
    
    func closeNew() {
        onClosePicker?()
        isNewAddres =  false
         self.buttonRight.setBackgroundColor(WMColor.UIColorFromRGB(0x2970ca), size:CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
         self.titleLabel.textAlignment = .Center
         self.titleLabel.frame =  CGRectMake(0, self.titleLabel.frame.origin.y, self.titleLabel.frame.width, self.titleLabel.frame.height)
        
        self.buttonRight.selected = false
        self.titleLabel.text = self.titleHeader
        self.buttonRight.setTitle(lastTitle, forState: UIControlState.Normal)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewContent.frame = CGRectMake(0, 0, 286, 316)
             self.viewContent.center = self.center
            self.viewContentOptions.alpha = 1
            self.viewReplace?.alpha = 0
            }) { (complete:Bool) -> Void in
                self.viewReplace?.removeFromSuperview()
                self.viewButtonClose.removeFromSuperview()
        }
    }
    
    
}