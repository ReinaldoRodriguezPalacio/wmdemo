//
//  AlertPickerView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


@objc protocol AlertPickerViewDelegate {
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String)
    func didDeSelectOption(_ picker:AlertPickerView)
    
    func viewReplaceContent(_ frame:CGRect) -> UIView!
    func buttomViewSelected(_ sender:UIButton)
    @objc optional func closeAlertPk()
}

protocol AlertPickerSelectOptionDelegate {
    func didSelectOptionAtIndex(_ indexPath: IndexPath)
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
    
    var selected : IndexPath!
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
    var cellType: TypeField! = TypeField.check
    var textboxValues: [String:String]? = [:]
    var stopRemoveView: Bool? = false
    var isNewAddres: Bool  =  false
    var selectDelegate: Bool = false
    var showLeftButton: Bool = false
    var layerLine: CALayer?
    var contentHeight: CGFloat! = 316
    var contentWidth: CGFloat! = 288
    var showDisclosure = false
    var showPrefered = false
    
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
        
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        self.contentHeight = 316
        
        viewContent = UIView(frame: CGRect(x: 0, y: 0, width: 286, height: self.contentHeight!))
        viewContent.layer.cornerRadius = 6.0
        viewContent.backgroundColor = UIColor.white
        viewContent.clipsToBounds = true
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: viewContent.frame.width, height: 46))
        headerView.backgroundColor = WMColor.light_light_gray
        viewContent.addSubview(headerView)
        
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.headerView.frame.height,  height: self.headerView.frame.height))
        closeButton!.addTarget(self, action: #selector(AlertPickerView.closePicker), for: UIControlEvents.touchUpInside)
        closeButton!.setImage(UIImage(named: "detail_close"), for: UIControlState())
        headerView.addSubview(closeButton!)

        titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.textColor =  WMColor.light_blue
        titleLabel.textAlignment = .center
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(14)
        titleLabel.numberOfLines = 2
        
        headerView.addSubview(titleLabel)

        viewContentOptions = UIView(frame: CGRect(x: 0, y: headerView.frame.height, width: viewContent.frame.width, height: viewContent.frame.height - headerView.frame.height))
        
        tableData = UITableView(frame: CGRect(x: 0, y: 5, width: viewContentOptions.frame.width,height: viewContentOptions.frame.height - 64))
        tableData.register(SelectItemTableViewCell.self, forCellReuseIdentifier: "cellSelItem")
        tableData.register(TextboxTableViewCell.self, forCellReuseIdentifier: "textboxItem")
        tableData.delegate = self
        tableData.dataSource = self
        tableData.separatorStyle = .none

        self.viewContentOptions.addSubview(tableData)
        
        viewFooter = UIView(frame: CGRect(x: 0, y: self.viewContentOptions.frame.height - 64, width: self.frame.width, height: 64))
        buttonOk = UIButton(frame: CGRect(x: 0, y: 0, width: 98, height: 34))

        buttonOk.backgroundColor = WMColor.green
        buttonOk.layer.cornerRadius = 17
        buttonOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonOk.setTitle("Ok", for: UIControlState())
        buttonOk.center = CGPoint(x: self.viewContent.frame.width / 2, y: 32)
        buttonOk.addTarget(self, action: #selector(AlertPickerView.okAction), for: UIControlEvents.touchUpInside)
        
        buttonLeft = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 34))
        buttonLeft.backgroundColor = WMColor.empty_gray_btn
        buttonLeft.layer.cornerRadius = 17
        buttonLeft.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonLeft.setTitle("Cancelar", for: UIControlState())
        buttonLeft.center = CGPoint(x: (self.viewContent.frame.width / 2) - 68 , y: 32)
        buttonLeft.addTarget(self, action: #selector(AlertPickerView.actionLeft), for: UIControlEvents.touchUpInside)
        
        if self.showLeftButton{
            buttonOk.frame = CGRect(x: 0, y: 0, width: 120, height: 34)
            buttonOk.center = CGPoint(x: (self.viewContent.frame.width / 2) + 68 , y: 32)
            viewFooter.addSubview(buttonLeft)
        }
        
        viewFooter.backgroundColor = UIColor.white
        viewFooter.addSubview(buttonOk)
        
        layerLine = CALayer()
        layerLine!.backgroundColor = WMColor.light_light_gray.cgColor
        viewFooter!.layer.insertSublayer(layerLine!, at: 1000)
    
        self.viewContentOptions.addSubview(viewFooter)
        self.viewContent.addSubview(self.viewContentOptions)
        self.stopRemoveView! = false
        self.addSubview(viewContent)
        
    
    }
    
    
    override func layoutSubviews() {
        
        viewContent.frame = CGRect(x: 0, y: 0, width: self.contentWidth, height: self.contentHeight)
        headerView.frame = CGRect(x: 0, y: 0, width: viewContent.frame.width, height: 46)
        viewContentOptions.frame = CGRect(x: 0, y: headerView.frame.height, width: viewContent.frame.width, height: viewContent.frame.height - headerView.frame.height)
        tableData.frame = CGRect(x: 0, y: 5, width: viewContentOptions.frame.width,height: viewContentOptions.frame.height - 64)
        viewContent.center = self.center
        closeButton?.frame = CGRect(x: 2, y: 0, width: 28,  height: self.headerView.frame.height)
        layerLine?.frame = CGRect(x: 0, y: 1, width: viewContent.frame.width, height: 1)
        viewFooter?.frame = CGRect(x: 0, y: self.viewContentOptions.frame.height - 64, width: self.frame.width, height: 64)
        if !isNewAddres {
            titleLabel.frame = headerView.bounds
        }
    }
    
    func setValues(_ title:NSString,values:[String]) {
        self.titleHeader = title as String
        self.titleLabel.text = title as String
        self.itemsToShow = values
        tableData.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if cellType == TypeField.alphanumeric
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textboxItem") as! TextboxTableViewCell!
            cell?.textbox!.setCustomPlaceholder(itemsToShow[(indexPath as NSIndexPath).row])
            cell?.textbox!.maxLength = 0
            cell?.textbox!.disablePaste =  true
            
            if (indexPath as NSIndexPath).row == 0 {
                cell?.textbox!.maxLength = 8
                cell?.textbox!.setCustomDelegate(self)
            }
            if (indexPath as NSIndexPath).row == 2 {
                cell?.textbox!.maxLength = 4
                cell?.textbox!.setCustomDelegate(self)
            }
            cell?.textbox!.delegate = self
            cell?.textbox!.nameField = itemsToShow[(indexPath as NSIndexPath).row]
            cell?.textLabel?.text = itemsToShow[(indexPath as NSIndexPath).row]
            if self.selected != nil {
                cell?.setSelected((indexPath as NSIndexPath).row == self.selected.row, animated: true)
            }
            
            if itemsToShow[(indexPath as NSIndexPath).row] == NSLocalizedString("checkout.discount.dateAdmission", comment:"") {
                cell?.setDatePickerInputView()
            }
            
            return cell!
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelItem") as! SelectItemTableViewCell!
            cell?.selectionStyle = .none
            cell?.textLabel?.text = itemsToShow[(indexPath as NSIndexPath).row]
            if self.selected != nil {
                cell?.setSelected((indexPath as NSIndexPath).row == self.selected.row, animated: true)
            }
            if self.selectDelegate{
                cell?.showButton?.isHidden = false
                cell?.showButton?.tag = (indexPath as NSIndexPath).row
                cell?.showButton?.addTarget(self, action: #selector(AlertPickerView.cellShowButtonSelected(_:)), for: UIControlEvents.touchUpInside)
            }
            
            cell?.disclosureImage.isHidden = !self.showDisclosure
            cell?.preferedImage.isHidden = !(self.showPrefered && (indexPath as NSIndexPath).row == 0)
            return cell!
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selected == indexPath {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.setSelected(true, animated: false)
            return
        }
        
        if self.selected == nil{
            self.selected = indexPath
        }
        
        if self.selected.row != (indexPath as NSIndexPath).row {
            let lastSelected = self.selected
            self.selected = indexPath
            tableView.reloadRows(at: [self.selected ,lastSelected!], with: UITableViewRowAnimation.none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let textCell = itemsToShow[(indexPath as NSIndexPath).row]
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
    
    func setLeftButtonStyle(_ color:UIColor,titleText:String, titleColor:UIColor){
        buttonLeft.backgroundColor = color
        buttonLeft.setTitle(titleText, for: UIControlState())
        buttonLeft.setTitleColor(titleColor, for: UIControlState())
    }
    
    
    func closePicker() {
        self.delegate?.closeAlertPk?()
        onClosePicker?()
        self.removeFromSuperview()
    }
    
    //MARK TextField delegate
    
    func textField(_ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool
    {
        let formField = textField as! FormFieldView
        let textValue = (textField.text! as NSString).replacingCharacters(in: range, with:string)
        
        let text = (textValue as String).trim()
        if text == ""
        {
            textboxValues?.removeValue(forKey: formField.nameField)
        }
        else{
            textboxValues?[formField.nameField] = text
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let formField = textField as! FormFieldView
        var text = formField.text
        
        if NSLocalizedString("checkout.discount.dateAdmission", comment:"") == formField.nameField! && !text!.isEmpty{
            text = TextboxTableViewCell.parseDateString(text!,format:"d MMMM yyyy")
        }
        
        text?.trim()
        
        if text == ""{
            textboxValues?.removeValue(forKey: formField.nameField)
        }
        else{
            textboxValues?[formField.nameField] = text
        }
    }
    //MARK Show alerts
    
    class func initPicker()  -> AlertModalView? {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        if vc != nil {
            return initPicker(vc!)
        }
        return nil
    }
    
    class func initPicker(_ controller:UIViewController) -> AlertModalView? {
        let newAlert = AlertModalView(frame:controller.view.bounds)
        controller.view.addSubview(newAlert)
        newAlert.startAnimating()
        return newAlert
    }
    
    class func initPickerWithDefault() -> AlertPickerView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = AlertPickerView(frame:vc!.view.bounds)
        return newAlert
    }
    
    class func initPickerWithLeftButton() -> AlertPickerView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = AlertPickerView(frame:vc!.view.bounds,showLeftButton: true)
        return newAlert
    }
    
    func showPicker() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        vc!.view.addSubview(self)
        //vc!.view.bringSubviewToFront(self)
        self.startAnimating()
        
    }

    
    //MARK: Animated
    
    func startAnimating() {
        
        
        let imgBgView = UIImageView(frame: self.bgView.bounds)
        let imgBack = UIImage(from: self.superview!)
        let imgBackBlur = imgBack?.applyLightEffect()
        imgBgView.image = imgBackBlur
        self.bgView.addSubview(imgBgView)
        
        let bgViewAlpha = UIView(frame: self.bgView.bounds)
        bgViewAlpha.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.bgView.addSubview(bgViewAlpha)
        
        tableData.reloadData()
        
        bgView.alpha = 0
        viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
        
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModeCubicPaced, animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                 self.viewContent.transform = CGAffineTransform.identity
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
        UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: UIViewKeyframeAnimationOptions.calculationModePaced, animations: { () -> Void in
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.bgView.alpha = 0.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0, animations: { () -> Void in
                self.viewContent.transform = CGAffineTransform(translationX: 0,y: 500)
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
        //self.buttonLeft.setBackgroundColor(WMColor.green, size:CGSizeMake(64.0, 22), forUIControlState: UIControlState.Normal)
        lastTitle = self.buttonLeft.titleLabel?.text
        isNewAddres =  true

        viewButtonClose = UIButton(frame: CGRect(x: 0, y: 0, width: self.headerView.frame.height,  height: self.headerView.frame.height))
        viewButtonClose.addTarget(self, action: #selector(AlertPickerView.closeNew), for: UIControlEvents.touchUpInside)
        viewButtonClose.setImage(UIImage(named: "BackProduct"), for: UIControlState())
        viewButtonClose.alpha = 0
        self.headerView.addSubview(viewButtonClose)
        self.closeButton!.isHidden = true
            
        self.buttonLeft.isSelected = true
        let finalContentHeight: CGFloat = self.frame.height - 80
        let finalContentFrame = CGRect(x: 8, y: 40, width: 289, height: finalContentHeight > 468 ? 468 : finalContentHeight)
        let finalContentInnerFrame = CGRect(x: 0, y: self.headerView.frame.maxY, width: finalContentFrame.width, height: finalContentFrame.height - (self.headerView.frame.maxY ) )
        self.viewReplace = self.delegate?.viewReplaceContent(finalContentInnerFrame)
        self.viewReplace?.alpha = 0
        self.viewContent.addSubview(viewReplace!)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.contentHeight = finalContentFrame.height
            self.contentWidth = finalContentFrame.width
            self.viewContent.frame = finalContentFrame
            self.viewContent.center = self.center
            self.viewReplace?.alpha = 1
            self.viewContentOptions.alpha = 0
            self.viewButtonClose.alpha = 1
            }, completion: { (completed:Bool) -> Void in
                    
        }) 
    }
    
    func cellShowButtonSelected(_ sender:UIButton){
        self.selectOptionDelegate?.didSelectOptionAtIndex(IndexPath(row: sender.tag, section: 0))
    }
    
    func closeNew() {
        onClosePicker?()
        isNewAddres =  false
         self.titleLabel.textAlignment = .center
         self.titleLabel.frame =  CGRect(x: 0, y: self.titleLabel.frame.origin.y, width: self.titleLabel.frame.width, height: self.titleLabel.frame.height)
        
        self.buttonLeft.isSelected = false
        self.titleLabel.text = self.titleHeader
        self.buttonLeft.setTitle(lastTitle, for: UIControlState())
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.contentHeight = 316
            self.contentWidth = 288
            self.viewContent.frame = CGRect(x: 0, y: 0, width: 288, height: 316)
            self.viewContent.center = self.center
            self.viewContentOptions.alpha = 1
            self.viewReplace?.alpha = 0
            self.viewButtonClose.isHidden = true
            self.closeButton!.isHidden = false
            }, completion: { (complete:Bool) -> Void in
                self.viewReplace?.removeFromSuperview()
                self.viewButtonClose.removeFromSuperview()
        }) 
    }
    
    
}
