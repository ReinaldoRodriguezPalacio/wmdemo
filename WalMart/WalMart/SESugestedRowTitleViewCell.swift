//
//  SESugestedRowTitleViewCell.swift
//  WalMart
//
//  Created by Vantis on 20/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class SESugestedRowTitleViewCell: UITableViewCell {
    
    var itemView : UILabel!
    var deleteItem: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        self.itemView.frame = CGRect(x: 15, y: 0, width: self.frame.width - 50, height: self.frame.height)
        self.deleteItem.frame = CGRect(x: self.frame.width - 40, y: 0, width: 30, height: self.frame.height)
        
    }
    
    func setup(){
        
        self.itemView = UILabel(frame: CGRect(x: 15, y: 0, width: self.frame.width - 50, height: self.frame.height))
        self.itemView!.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.addSubview(self.itemView)
        
        self.deleteItem = UIButton(frame:CGRect(x: self.frame.width - 40, y: 0,width: 30, height: self.frame.height))
        self.deleteItem.setImage(UIImage(named: "deleteAddress"), for: UIControlState())
        self.addSubview(self.deleteItem)
        
    }
    
    
    
    func setValues(_ itemNameList:String) {
        self.itemView!.text = itemNameList
    }
    
}
