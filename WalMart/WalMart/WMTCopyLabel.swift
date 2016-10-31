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
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(WMTCopyLable.showMenu(_:))))
    }
    func showMenu(_ sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    override func copy(_ sender: AnyObject?) {
        let board = UIPasteboard.general
        board.string = stringCopy
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    override var canBecomeFirstResponder : Bool {
        return true
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(NSObject.copy(_:)) {
            return true
        }
        return false
    }
    
}
