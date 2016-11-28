//
//  ProfileViewCell.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 19/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class ProfileViewCell: UITableViewCell {
    var title: UILabel?
    var tsepInView: UIView?
    var imageProfile: UIImageView?
    var viewBgSel : UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewBgSel = UIView()
        viewBgSel.backgroundColor = WMColor.dark_blue
        viewBgSel.alpha = 0.2
        
        self.backgroundColor = UIColor.clear
        self.title = UILabel()
        self.title!.backgroundColor = UIColor.clear
        self.imageProfile = UIImageView()
        self.tsepInView = UIView()
        self.tsepInView!.backgroundColor = UIColor.white
        
        self.addSubview(self.viewBgSel!)
        self.addSubview(self.tsepInView!)
        self.addSubview(self.title!)
        self.addSubview(self.imageProfile!)
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        let bounds = self.frame.size
        //self.contentView.frame = CGRectMake(0.0, 0.0, bounds.width, bounds.height)
        self.viewBgSel!.frame =  CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height - AppDelegate.separatorHeigth())
        self.imageProfile!.frame = CGRect(x: 20, y: 20, width: 25 , height: 25)
        self.title!.frame = CGRect(x: self.imageProfile!.frame.maxX + 20 , y: 25, width: 250, height: 20)
        self.tsepInView!.frame = CGRect(x: self.title!.frame.minX , y: bounds.height - AppDelegate.separatorHeigth() , width: bounds.width - self.title!.frame.minX , height: AppDelegate.separatorHeigth())
    }
    
    func setValues(_ value:String,image:String, size:CGFloat,colorText:UIColor, colorSeparate: UIColor  ) {
        self.title!.text = value
        self.imageProfile!.image = UIImage(named:image)
        self.title!.font = WMFont.fontMyriadProLightOfSize(size)
        self.title!.textColor = colorText
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
       // super.setSelected(selected, animated: true)
        viewBgSel.isHidden = !selected
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //super.setHighlighted(highlighted, animated: highlighted)
        viewBgSel.isHidden = true
    }
    
   

}
