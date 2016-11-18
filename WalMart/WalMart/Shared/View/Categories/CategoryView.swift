//
//  CategoryView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 8/28/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


class CategoryView : UITableViewCell {
    
    var imageBackground : UIImageView!
    var imageIcon : UIImageView!
    var titleLabel : UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    func setup() {
        
        imageBackground = UIImageView()
        
        imageIcon = UIImageView()
        
        titleLabel = UILabel()
        titleLabel.font = WMFont.fontMyriadProRegularOfSize(25)
        titleLabel.textColor = WMColor.light_blue
        
        
        self.addSubview(imageBackground)
        self.addSubview(imageIcon)
        self.addSubview(titleLabel)
        
    }
    
    
    func setValues(title:String,imageBackgroundURL:String,imageIconURL:String) {
        let svcUrl = serviceUrl("WalmartMG.CategoryIcon")
        let imgURLName = "\(svcUrl)\(imageIconURL)"
        self.imageIcon.setImageWithURL(NSURL(string: imgURLName)!, placeholderImage: UIImage(named: imageIconURL))
        
        let svcUrlCar = serviceUrl("WalmartMG.HeaderCategory")
        let imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"
        self.imageBackground.setImageWithURL(NSURL(string: imgURLNamehead)!, placeholderImage: UIImage(named: imageBackgroundURL))
        
        self.titleLabel.text = title
        
    }
    
    func serviceUrl(serviceName:String) -> String {
        let environment =  NSBundle.mainBundle().objectForInfoDictionaryKey("WMEnvironment") as! String
        let services = NSBundle.mainBundle().objectForInfoDictionaryKey("WMURLServices") as! NSDictionary
        let environmentServices = services.objectForKey(environment) as! NSDictionary
        let serviceURL =  environmentServices.objectForKey(serviceName) as! String
        return serviceURL
    }
    
    
}