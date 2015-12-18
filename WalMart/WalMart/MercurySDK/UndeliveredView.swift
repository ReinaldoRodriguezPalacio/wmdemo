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
    var imageBackground: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        information = UILabel(frame: CGRectMake(8, 43, self.frame.size.width - 16, 76))
        information.textAlignment = NSTextAlignment.Center
        information.textColor = WMColor.UIColorFromRGB(0x0071CE)
        information.font = WMFont.fontMyriadProLightOfSize(18)
        information.numberOfLines = 4
        
        
        
        imageBackground = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        imageBackground.image = UIImage(named: "faildelivery")
        
    
        self.addSubview(imageBackground)
        self.addSubview(information)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    func setEmailForInformation(email:String) {
        information.text = "¡Lo sentimos mucho!\nTomaremos acción inmediatamente\ny te mantendremos al tanto\nen \(email)"
    }

    
}