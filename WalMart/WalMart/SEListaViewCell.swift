//
//  SEListaViewCell.swift
//  WalMart
//
//  Created by Vantis on 13/07/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation


class SEListaViewCell: UITableViewCell {
    
    var itemView : UILabel!
    var deleteItem: UIButton!
    var separator: UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        self.itemView.frame = CGRect(x: 15, y: 5, width: self.frame.width - 90, height: 30)
        self.deleteItem.frame = CGRect(x: self.frame.width - 40, y: 5,width: 30, height: 30)
        self.separator!.frame = CGRect(x: self.frame.maxX, y: self.bounds.height - 1,width: self.frame.width, height: 1)
        
    }
    
    func setup(){
        
        self.itemView = UILabel(frame: CGRect(x: 15, y: 5, width: self.frame.width - 90, height: 30))
        self.itemView!.font =  WMFont.fontMyriadProLightOfSize(14) //WMFont.fontMyriadProRegularOfSize(14)
        self.addSubview(self.itemView)
        
        self.deleteItem = UIButton(frame:CGRect(x: self.frame.width - 40, y: 5,width: 30, height: 30))
        self.deleteItem.setImage(UIImage(named: "termsClose"), for: UIControlState())
        self.addSubview(self.deleteItem)
        
        self.separator = UIView(frame:CGRect(x: self.frame.maxX, y: self.bounds.height - 1,width: self.frame.width, height: 1))
        self.separator!.backgroundColor = WMColor.light_gray
        self.addSubview(self.separator!)
        
    }
    
    
    
    func setValues(_ itemNameList:String) {
        self.itemView!.text = itemNameList
    }
    
}
