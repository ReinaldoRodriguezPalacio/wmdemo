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
    var editItem: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        self.editItem.frame = CGRect(x: 15, y: self.frame.height / 2 - self.frame.height * 0.7 / 2, width: self.frame.height * 0.7 , height: self.frame.height * 0.7)
        self.itemView.frame = CGRect(x: self.editItem.frame.maxX + 5, y: 0, width: self.frame.width - 50, height: self.frame.height)
        self.deleteItem.frame = CGRect(x: self.frame.width - 40, y: 0, width: 30, height: self.frame.height)
        
    }
    
    func setup(){
        
        self.editItem = UIButton(frame:CGRect(x: 15, y: self.frame.height / 2 - self.frame.height * 0.7 / 2, width: self.frame.height * 0.7 , height: self.frame.height * 0.7))
        self.editItem.setImage(UIImage(named: "wishlist_edit_active"), for: UIControlState())
        self.addSubview(self.editItem)
        
        self.itemView = UILabel(frame: CGRect(x: self.editItem.frame.maxX + 5, y: 0, width: self.frame.width - 50, height: self.frame.height))
        self.itemView!.font =  WMFont.fontMyriadProRegularOfSize(14)
        self.addSubview(self.itemView)
        
        self.deleteItem = UIButton(frame:CGRect(x: self.frame.width - 40, y: 0,width: 30, height: self.frame.height))
        self.deleteItem.setImage(UIImage(named: "termsClose"), for: UIControlState())
        self.addSubview(self.deleteItem)
        
    }
    
    
    
    func setValues(_ itemNameList:String) {
        self.itemView!.text = itemNameList
    }
    
}
