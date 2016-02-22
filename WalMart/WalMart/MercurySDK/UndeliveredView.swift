//
//  UndeliveredView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 12/15/15.
//  Copyright © 2015 BCG Inc. All rights reserved.
//

import Foundation


class UndeliveredView : UIView {
    
    
    var information: UILabel!
    var title: UILabel!
    var imageBackground: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        title = UILabel(frame: CGRectMake(8, 20, self.frame.size.width - 16, 76))
        title.textAlignment = NSTextAlignment.Center
        title.textColor = WMColor.light_blue
        title.font = MercuryFont.fontSFUIRegularOfSize(25)
        title.text = "Orden no recibida"
        title.numberOfLines = 1
        
        
        information = UILabel(frame: CGRectMake(8, 90, self.frame.size.width - 16, 76))
        information.textAlignment = NSTextAlignment.Center
        information.textColor = WMColor.light_blue
        information.font = MercuryFont.fontSFUILightOfSize(18)
        information.numberOfLines = 4
        
        imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        imageBackground.image = UIImage(named: "faildelivery")
        
        
        self.addSubview(imageBackground)
        self.addSubview(title)
        self.addSubview(information)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setEmailForInformation(email:String) {
        information.text = "Investigaremos de inmediato\ny te mantendremos al tanto en\n\(email)"
    }
    
    
}