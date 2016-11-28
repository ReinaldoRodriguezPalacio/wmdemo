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
    
    
    func setValues(_ title:String,imageBackgroundURL:String,imageIconURL:String) {
        let svcUrl = serviceUrl("WalmartMG.CategoryIcon")
        let imgURLName = "\(svcUrl)\(imageIconURL)"
        self.imageIcon.setImageWith(URL(string: imgURLName)!, placeholderImage: UIImage(named: imageIconURL))
        
        let svcUrlCar = serviceUrl("WalmartMG.HeaderCategory")
        let imgURLNamehead = "\(svcUrlCar)\(imageBackgroundURL)"
        self.imageBackground.setImageWith(URL(string: imgURLNamehead)!, placeholderImage: UIImage(named: imageBackgroundURL))
        
        self.titleLabel.text = title
        
    }
    
    func serviceUrl(_ serviceName:String) -> String {
        let environment =  Bundle.main.object(forInfoDictionaryKey: "WMEnvironment") as! String
        let services = Bundle.main.object(forInfoDictionaryKey: "WMURLServices") as! [String:Any]
        let environmentServices = services[environment] as! [String:Any]
        let serviceURL =  environmentServices[serviceName] as! String
        return serviceURL
    }
    
    
}
