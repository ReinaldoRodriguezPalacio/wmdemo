//
//  WMTCopyLabel.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 5/26/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation


class WMTCopyLable: UILabel {
    
    var stringCopy : String! = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        sharedInit()
    }
    func sharedInit() {
        userInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(WMTCopyLable.showMenu(_:))))
    }
    func showMenu(sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.sharedMenuController()
        if !menu.menuVisible {
            menu.setTargetRect(bounds, inView: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    override func copy(sender: AnyObject?) {
        let board = UIPasteboard.generalPasteboard()
        board.string = stringCopy
        let menu = UIMenuController.sharedMenuController()
        menu.setMenuVisible(false, animated: true)
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) {
            return true
        }
        return false
    }
    
}