//
//  AlertPickerView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 2/11/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


@objc protocol AlertPickerViewDelegate: class {
    func didSelectOption(_ picker:AlertPickerView,indexPath: IndexPath,selectedStr:String)
    func didDeSelectOption(_ picker:AlertPickerView)
    
    func viewReplaceContent(_ frame:CGRect) -> UIView!
    func saveReplaceViewSelected()
    func buttomViewSelected(_ sender:UIButton)
    @objc optional func closeAlertPk()
}

protocol AlertPickerSelectOptionDelegate: class {
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
    
    var selected : IndexPath!
    weak var delegate : AlertPickerViewDelegate? = nil
    var selectOptionDelegate: AlertPickerSelectOptionDelegate? = nil
    
    var sender : AnyObject? = nil
    
    var buttonRight : WMRoundButton!
    var buttonOk : UIButton!
    var buttonCancel : UIButton!
    
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
    var showCancelButton: Bool = false
    var layerLine: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    init(frame: CGRect, showCancelButton:Bool) {
        super.init(frame:frame)
        self.showCancelButton = true
        setup()
    }
    
    func setup() {
        
        
        self.tag = 5000
        
        self.backgroundColor = UIColor.clear
        
        bgView = UIView(frame: self.bounds)
        self.addSubview(bgView)
        
        viewContent = UIView(frame: CGRect(x: 0, y: 0, width: 286, height: 316))
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

        self.viewContentOptions.addSubview(tableData)
        
        viewFooter = UIView(frame: CGRect(x: 0, y: self.viewContentOptions.frame.height - 64, width: self.frame.width, height: 64))
        buttonOk = UIButton(frame: CGRect(x: 0, y: 0, width: 98, height: 34))

        buttonOk.backgroundColor = WMColor.green
        buttonOk.layer.cornerRadius = 17
        buttonOk.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonOk.setTitle("Ok", for: UIControlState())
        buttonOk.center = CGPoint(x: self.viewContent.frame.width / 2, y: 32)
        buttonOk.addTarget(self, action: #selector(AlertPickerView.okAction), for: UIControlEvents.touchUpInside)
        
        buttonCancel = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 34))
        buttonCancel.backgroundColor = WMColor.empty_gray_btn
        buttonCancel.layer.cornerRadius = 17
        buttonCancel.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        buttonCancel.setTitle("Cancelar", for: UIControlState())
        buttonCancel.center = CGPoint(x: (self.viewContent.frame.width / 2) - 68 , y: 32)
        buttonCancel.addTarget(self, action: #selector(AlertPickerView.closePicker), for: UIControlEvents.touchUpInside)
        
        if self.showCancelButton{
            buttonOk.frame = CGRect(x: 0, y: 0, width: 120, height: 34)
            buttonOk.center = CGPoint(x: (self.viewContent.frame.width / 2) + 68 , y: 32)
            viewFooter.addSubview(buttonCancel)
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
        viewContent.center = self.center
        headerView.frame = CGRect(x: 0, y: 0, width: viewContent.frame.width, height: 46)
        closeButton?.frame = CGRect(x: 2, y: 0, width: 28,  height: self.headerView.frame.height)
        layerLine?.frame = CGRect(x: 0, y: 1, width: viewContent.frame.width, height: 1)
        if !isNewAddres {
            titleLabel.frame = headerView.bounds
        }
        if buttonRight != nil  {
            buttonRight.frame = CGRect(x: self.viewContent.frame.width - 80, y: 12, width: 64, height: 22)
        }
    }
    
    func setValues(_ title:String,values:[String]) {
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
            self.tableData.separatorStyle = UITableViewCellSeparatorStyle.none
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textboxItem") as! TextboxTableViewCell!
            cell?.textbox!.setCustomPlaceholder(itemsToShow[indexPath.row])
            cell?.textbox!.maxLength = 0
            cell?.textbox!.disablePaste =  true
            
            if indexPath.row == 0 {
                cell?.textbox!.maxLength = 8
                cell?.textbox!.setCustomDelegate(self)
            }
            if indexPath.row == 2 {
                cell?.textbox!.maxLength = 4
                cell?.textbox!.setCustomDelegate(self)
            }
            cell?.textbox!.delegate = self
            cell?.textbox!.nameField = itemsToShow[indexPath.row]
            cell?.textLabel?.text = itemsToShow[indexPath.row]
            if self.selected != nil {
                cell?.setSelected(indexPath.row == self.selected.row, animated: true)
            }
            
            if itemsToShow[indexPath.row] == NSLocalizedString("checkout.discount.dateAdmission", comment:"") {
                cell?.setDatePickerInputView()
            }
            
            return cell!
        }
        else
        {
            self.tableData.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelItem") as! SelectItemTableViewCell!
            cell?.selectionStyle = .none
            cell?.textLabel?.text = itemsToShow[indexPath.row]
            if self.selected != nil {
                cell?.setSelected(indexPath.row == self.selected.row, animated: true)
            }
            if self.selectDelegate{
                cell?.showButton?.isHidden = false
                cell?.showButton?.tag = indexPath.row
                cell?.showButton?.addTarget(self, action: #selector(AlertPickerView.cellShowButtonSelected(_:)), for: UIControlEvents.touchUpInside)
            }
            return cell!
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selected == nil{
            self.selected = indexPath
        }
        
        if self.selected.row != indexPath.row {
            let lastSelected = self.selected
            self.selected = indexPath
            tableView.reloadRows(at: [self.selected ,lastSelected!], with: UITableViewRowAnimation.none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            let _ = textboxValues?.removeValue(forKey: formField.nameField)
        }
        else{
            textboxValues?[formField.nameField] = text
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let formField = textField as! FormFieldView
        var text = formField.text
        
        if NSLocalizedString("checkout.discount.dateAdmission", comment:"") == formField.nameField! && !text!.isEmpty
        {
            text = TextboxTableViewCell.parseDateString(text!,format:"d MMMM yyyy")
        }
        
        let _ = text?.trim()
        
        if text == ""
        {
            let _ = textboxValues?.removeValue(forKey: formField.nameField)
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
    
    class func initPickerWithDefaultCancelButton() -> AlertPickerView {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        let newAlert = AlertPickerView(frame:vc!.view.bounds,showCancelButton: true)
        return newAlert
    }
    
    func showPicker() {
        let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        vc!.view.addSubview(self)
        //vc!.view.bringSubviewToFront(self)
        self.startAnimating()
        
    }
    
    func showPickerOverModal( viewBase: UIView) {
        //let vc : UIViewController? = UIApplication.shared.keyWindow!.rootViewController
        viewBase.addSubview(self)
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
    
    
    
    func addRigthActionButton(_ buttonRight:WMRoundButton) {
        if self.buttonRight != nil {
            self.buttonRight.removeFromSuperview()
            self.buttonRight = nil
        }
        self.buttonRight = buttonRight
        self.buttonRight.addTarget(self, action: #selector(AlertPickerView.newItemForm), for: UIControlEvents.touchUpInside)
        self.buttonRight.frame = CGRect(x: self.viewContent.frame.width - 80, y: 12, width: 64, height: 22)
        self.viewContent.addSubview(buttonRight)
    }
    
    func hiddenRigthActionButton(_ hidden:Bool) {
        if self.buttonRight != nil {
            self.buttonRight.isHidden = hidden
        }
    }
    
    func newItemForm () {
        if self.buttonRight.isSelected {
           //Save action
            self.delegate?.saveReplaceViewSelected()
        } else {
            self.buttonRight.setBackgroundColor(WMColor.green, size:CGSize(width: 64.0, height: 22), forUIControlState: UIControlState())
            lastTitle = self.buttonRight.titleLabel?.text
            isNewAddres =  true
            if !IS_IPAD{
                self.titleLabel.textAlignment = .left
                self.titleLabel.frame =  CGRect(x: 40, y: self.titleLabel.frame.origin.y, width: self.titleLabel.frame.width, height: self.titleLabel.frame.height)
            }
            
            self.buttonRight.setTitle(NSLocalizedString("profile.save", comment: ""), for: UIControlState())
            
            viewButtonClose = UIButton(frame: CGRect(x: 0, y: 0, width: self.headerView.frame.height,  height: self.headerView.frame.height))
            viewButtonClose.addTarget(self, action: #selector(AlertPickerView.closeNew), for: UIControlEvents.touchUpInside)
            viewButtonClose.setImage(UIImage(named: "BackProduct"), for: UIControlState())
            viewButtonClose.alpha = 0
            self.headerView.addSubview(viewButtonClose)
            self.closeButton!.isHidden = true
            
            self.buttonRight.isSelected = true
            let finalContentFrame = CGRect(x: 8, y: 40, width: self.frame.width - 16, height: self.frame.height - 80)
            let finalContentInnerFrame = CGRect(x: 0, y: self.headerView.frame.maxY, width: finalContentFrame.width, height: finalContentFrame.height - self.headerView.frame.maxY)
            self.viewReplace = self.delegate?.viewReplaceContent(finalContentInnerFrame)
            self.viewReplace?.alpha = 0
            self.viewContent.addSubview(viewReplace!)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
          
                self.viewContent.frame = finalContentFrame
                self.viewContent.center = self.center
                self.viewReplace?.alpha = 1
                self.viewContentOptions.alpha = 0
                self.viewButtonClose.alpha = 1
                }, completion: { (completed:Bool) -> Void in
                    
            }) 
        }
    }
    
    func cellShowButtonSelected(_ sender:UIButton){
        self.selectOptionDelegate?.didSelectOptionAtIndex(IndexPath(row: sender.tag, section: 0))
    }
    
    func closeNew() {
        onClosePicker?()
        isNewAddres =  false
         self.buttonRight.setBackgroundColor(WMColor.light_blue, size:CGSize(width: 64.0, height: 22), forUIControlState: UIControlState())
         self.titleLabel.textAlignment = .center
         self.titleLabel.frame =  CGRect(x: 0, y: self.titleLabel.frame.origin.y, width: self.titleLabel.frame.width, height: self.titleLabel.frame.height)
        
        self.buttonRight.isSelected = false
        self.titleLabel.text = self.titleHeader
        self.buttonRight.setTitle(lastTitle, for: UIControlState())
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.viewContent.frame = CGRect(x: 0, y: 0, width: 286, height: 316)
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
