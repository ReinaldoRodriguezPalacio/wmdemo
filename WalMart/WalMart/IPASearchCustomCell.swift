//
//  IPASearchCustomCell.swift
//  WalMart
//
//  Created by Vantis on 31/03/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation
import UIKit

class IPASearchCustomCell: UICollectionViewCell {
    
    var btnLista = UIButton()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
       
        self.contentView.addSubview(btnLista)
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    
}
