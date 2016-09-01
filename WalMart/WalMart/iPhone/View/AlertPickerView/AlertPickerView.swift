//
//  AlertPickerView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


@objc protocol AlertPickerViewDelegate {
    func didSelectOption(picker:AlertPickerView,indexPath: NSIndexPath,selectedStr:String)
    func didDeSelectOption(picker:AlertPickerView)
    
    func viewReplaceContent(frame:CGRect) -> UIView!
    func saveReplaceViewSelected()
    func buttomViewSelected(sender:UIButton)
    optional func closeAlertPk()
}

protocol AlertPickerSelectOptionDelegate {
    func didSelectOptionAtIndex(indexPath: NSIndexPath)
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
    var leftAction : (() -> Void)?
    var rightAction : (() -> Void)?
    
    var selected : NSIndexPath!
    var delegate : AlertPickerViewDelegate? = nil
    var selectOptionDelegate: AlertPickerSelectOptionDelegate? = nil
    
    var sender : AnyObject? = nil
    
    var buttonOk : UIButton!
    var buttonLeft : UIButton!
    
    var closeButton : UIButton?
    var viewButtonClose : UIButton!
    var viewReplace : UIView!
    
    var lastTitle : String! = ""
    var titleHeader : String! = ""
    var cellType: TypeField! = TypeField.Check
    var textboxValues: [String:String]? = [:]
    var stopRemoveView: Bool? = false
    var isNewAddres: Bool  =  false
    var selectDelegate: Bool = false
    var showLeftButton: Bool = false
    var layerLine: CALayer?
    var contentHeight: CGFloat! = 316
    var contentWidth: CGFloat! = 288
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    init(frame: CGRect, showLeftButton:Bool) {
        super.init(frame:frame)
        self.showLeftButton = showLeftButton
        setup()
    }
    
    func setup() {
        
        
        self.tag = 5000
        
        self.backgroundColor = UIColor.clearColor()
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        self.contentHeight = 316
        
        viewContent = UIView(frame: CGRectMake(0, 0, 286, self.contentHeight!))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.whiteColor()
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRectMake(0, 0, viewContent.frame.width, 46))
        headerView.backgroundColor = WMColor.light_light_gray
        viewContent.addSubview(headerView)
        
        closeButton = UIButton(frame: CGRectMake(0, 0, self.headerView.frame.height,  self.headerView.frame.height))
        closeButton!.addTarget(self, action: #selector(AlertPickerView.closePicker), forControlEvents: UIControlEvents.TouchUpInside)
        closeButton!.setImage(UIImage(named: "detail_close"), forState: UIControlState.Normal)
        headerView.addSubview(closeButton!)

        titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .Center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        
        headerView.addSubview(titleLabel)

        viewContentOptions = UIView(frame: CGRectMake(0, headerView.frame.height, viewContent.frame.width, viewContent.frame.height - headerView.frame.height))
        
        tableData = UITableView(frame: CGRectMake(0, 5, viewContentOptions.frame.width,viewContentOptions.frame.height - 64))
        tableData.registerClass(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        tableData.registerClass(TextboxTableViewCell.self, forCellReuseIdentifier: "textboxItem")
        tableData.delegate = self
        tableData.dataSource = self

        self.viewContentOptions.addSubview(tableData)
        
        viewFooter = UIView(frame: CGRectMake(0, self.viewContentOptions.frame.height - 64, self.frame.width, 64))
        buttonOk = UIButton(frame: CGRectMake(0, 0, 98, 34))

        buttonOk.backgroundColor = WMColor.green
        buttonOk.layer.cornerRadius = 17
        buttonOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonOk.setTitle("Ok", forState: UIControlState.Normal)
        buttonOk.center = CGPointMake(self.viewContent.frame.width / 2, 32)
        buttonOk.addTarget(self, action: #selector(AlertPickerView.okAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonLeft = UIButton(frame: CGRectMake(0, 0, 120, 34))
        buttonLeft.backgroundColor = WMColor.empty_gray_btn
        buttonLeft.layer.cornerRadius = 17
        buttonLeft.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonLeft.setTitle("Cancelar", forState: UIControlState.Normal)
        buttonLeft.center = CGPointMake((self.viewContent.frame.width / 2) - 68 , 32)
        buttonLeft.addTarget(self, action: #selector(AlertPickerView.actionLeft), forControlEvents: UIControlEvents.TouchUpInside)
        
        if self.showLeftButton{
            buttonOk.frame = CGRectMake(0, 0, 120, 34)
            buttonOk.center = CGPointMake((self.viewContent.frame.width / 2) + 68 , 32)
            viewFooter.addSubview(buttonLeft)
        }
        
        viewFooter.backgroundColor = UIColor.whiteColor()
        viewFooter.addSubview(buttonOk)
        
        layerLine = CALayer()
        layerLine!.backgroundColor = WMColor.light_light_gray.CGColor
        viewFooter!.layer.insertSublayer(layerLine!, atIndex: 1000)
    
        self.viewContentOptions.addSubview(viewFooter)
        self.viewContent.addSubview(self.viewContentOptions)
        self.stopRemoveView! = false
        self.addSubview(viewContent)
        
    
    }
    
    
    override func layoutSubviews() {
        
        viewContent.frame = CGRectMake(0, 0, self.contentWidth, self.contentHeight)
        headerView.frame = CGRectMake(0, 0, viewContent.frame.width, 46)
        viewContentOptions.frame = CGRectMake(0, headerView.frame.height, viewContent.frame.width, viewContent.frame.height - headerView.frame.height)
        tableData.frame = CGRectMake(0, 5, viewContentOptions.frame.width,viewContentOptions.frame.height - 64)
        viewContent.center = self.center
        closeButton?.frame = CGRectMake(2, 0, 28,  self.headerView.frame.height)
        layerLine?.frame = CGRectMake(0, 1, viewContent.frame.width, 1)
        viewFooter?.frame = CGRectMake(0, self.viewContentOptions.frame.height - 64, self.frame.width, 64)
        if !isNewAddres {
            titleLabel.frame = headerView.bounds
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
            
            let cell = tableView.dequeueReusableCellWithIdentifier("textboxItem") as! TextboxTableViewCell!
            cell.textbox!.setCustomPlaceholder(itemsToShow[indexPath.row])
            cell.textbox!.maxLength = 0
            cell.textbox!.disablePaste =  true
            
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
            let cell = tableView.dequeueReusableCellWithIdentifier("cellSelItem") as! SelectItemTableViewCell!
            cell.selectionStyle = .None
            cell.textLabel?.text = itemsToShow[indexPath.row]
            if self.selected != nil {
                cell.setSelected(indexPath.row == self.selected.row, animated: true)
            }
            if self.selectDelegate{
                cell.showButton?.hidden = false
                cell.showButton?.tag = indexPath.row
                cell.showButton?.addTarget(self, action: #selector(AlertPickerView.cellShowButtonSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            return cell
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.selected == nil{
            self.selected = indexPath
        }
        
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
            selectOptionDelegate?.didSelectOptionAtIndex(self.selected)
        }else {
             delegate?.didDeSelectOption(self)
        }
        if !self.stopRemoveView!
        {
          self.removeFromSuperview()
        }
        self.stopRemoveView! = false
    }
    
    func setLeftButtonStyle(color:UIColor,titleText:String, titleColor:UIColor){
        buttonLeft.backgroundColor = color
        buttonLeft.setTitle(titleText, forState: UIControlState.Normal)
        buttonLeft.setTitleColor(titleColor, forState: .Normal)
    }
    
    
    func closePicker() {
        self.delegate?.closeAlertPk?()
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
        
        let text = (textValue as String).trim()
        if text == ""
        {
            textboxValues?.removeValueForKey(formField.nameField)
        }
        else{
            textboxValues?[formField.nameField] = text
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let formField = textField as! FormFieldView
        var text = formField.text
        
        if NSLocalizedString("checkout.discount.dateAdmission", comment:"") == formField.nameField! && !text!.isEmpty{
            text = TextboxTableViewCell.parseDateString(text!,format:"d MMMM yyyy")
        }
        
        text?.trim()
        
        if text == ""{
            textboxValues?.removeValueForKey(formField.nameField)
        }
        else{
            textboxValues?[formField.nameField] = text
        }
    }
    //MARK Show alerts
    
    class func initPicker()  -> AlertModalView? {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        if vc != nil {
            return initPicker(vc!)
        }
        return nil
    }
    
    class func initPicker(controller:UIViewController) -> AlertModalView? {
        let newAlert = AlertModalView(frame:controller.view.bounds)
        controller.view.addSubview(newAlert)
        newAlert.startAnimating()
        return newAlert
    }
    
    class func initPickerWithDefault() -> AlertPickerView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertPickerView(frame:vc!.view.bounds)
        return newAlert
    }
    
    class func initPickerWithLeftButton() -> AlertPickerView {
        let vc : UIViewController? = UIApplication.sharedApplication().keyWindow!.rootViewController
        let newAlert = AlertPickerView(frame:vc!.view.bounds,showLeftButton: true)
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
        bgViewAlpha.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
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
    
    
    func actionLeft() {
        if leftAction != nil {
          leftAction!()
        }else{
           newItemForm()
        }
        
    }
    
    
    func newItemForm () {
        if self.buttonLeft.selected {
           //Save action
            self.delegate?.saveReplaceViewSelected()
        } else {
            //self.buttonLeft.setBackgroundColor(WMColor.green, size:CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
            lastTitle = self.buttonLeft.titleLabel?.text
            isNewAddres =  true

            viewButtonClose = UIButton(frame: CGRectMake(0, 0, self.headerView.frame.height,  self.headerView.frame.height))
            viewButtonClose.addTarget(self, action: #selector(AlertPickerView.closeNew), forControlEvents: UIControlEvents.TouchUpInside)
            viewButtonClose.setImage(UIImage(named: "BackProduct"), forState: UIControlState.Normal)
            viewButtonClose.alpha = 0
            self.headerView.addSubview(viewButtonClose)
            self.closeButton!.hidden = true
            
            self.buttonLeft.selected = true
            let finalContentFrame = CGRectMake(8, 40, self.frame.width - 16, self.frame.height - 80)
            let finalContentInnerFrame = CGRectMake(0, self.headerView.frame.maxY, finalContentFrame.width, finalContentFrame.height - self.headerView.frame.maxY)
            self.viewReplace = self.delegate?.viewReplaceContent(finalContentInnerFrame)
            self.viewReplace?.alpha = 0
            self.viewContent.addSubview(viewReplace!)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.contentHeight = finalContentFrame.height
                self.contentWidth = finalContentFrame.width
                self.viewContent.frame = finalContentFrame
                self.viewContent.center = self.center
                self.viewReplace?.alpha = 1
                self.viewContentOptions.alpha = 0
                self.viewButtonClose.alpha = 1
                }) { (completed:Bool) -> Void in
                    
            }
        }
    }
    
    func cellShowButtonSelected(sender:UIButton){
        self.selectOptionDelegate?.didSelectOptionAtIndex(NSIndexPath(forRow: sender.tag, inSection: 0))
    }
    
    func closeNew() {
        onClosePicker?()
        isNewAddres =  false
         self.titleLabel.textAlignment = .Center
         self.titleLabel.frame =  CGRectMake(0, self.titleLabel.frame.origin.y, self.titleLabel.frame.width, self.titleLabel.frame.height)
        
        self.buttonLeft.selected = false
        self.titleLabel.text = self.titleHeader
        self.buttonLeft.setTitle(lastTitle, forState: UIControlState.Normal)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.contentHeight = 316
            self.contentWidth = 288
            self.viewContent.frame = CGRectMake(0, 0, 288, 316)
            self.viewContent.center = self.center
            self.viewContentOptions.alpha = 1
            self.viewReplace?.alpha = 0
            self.viewButtonClose.hidden = true
            self.closeButton!.hidden = false
            }) { (complete:Bool) -> Void in
                self.viewReplace?.removeFromSuperview()
                self.viewButtonClose.removeFromSuperview()
        }
    }
    
    
}