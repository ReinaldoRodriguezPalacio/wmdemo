//
//  SearchTiresBarView.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 18/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol SearchTiresBarViewDelegate: class {
    func showTiresSearch()
}


class SearchTiresBarView: UIView {

    var tiresLabel: UILabel?
    var tireIcon: UIImageView?
    var tiresButton: UIButton?
    var tiresSearch: Bool = false
    weak var delegate: SearchTiresBarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        
        self.backgroundColor = IS_IPAD ? WMColor.dark_blue : WMColor.light_blue
        self.clipsToBounds = true
        
        self.tiresButton = UIButton(type: .custom)
        self.tiresButton!.setTitle(NSLocalizedString("home_help.search",comment: ""), for: .normal)
        self.tiresButton!.layer.cornerRadius = 11
        self.tiresButton!.setTitleColor(UIColor.white, for: .normal)
        self.tiresButton!.backgroundColor = WMColor.green
        self.tiresButton!.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
        self.tiresButton!.addTarget(self, action: #selector(SearchTiresBarView.showTiresSearch), for: UIControlEvents.touchUpInside)
        self.addSubview(self.tiresButton!)
        
        self.tiresLabel = UILabel()
        self.tiresLabel!.textColor = UIColor.white
        self.tiresLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
        self.tiresLabel!.numberOfLines = 2
        self.tiresLabel!.text = IS_IPAD ? "Encuentra las llantas perfectas para tu automóvil aquí." : "Encuentra las llantas perfectas\npara tu automóvil aquí."
        self.addSubview(self.tiresLabel!)
        
        self.tireIcon = UIImageView(image:UIImage(named: "tire_icon"))
        self.addSubview(self.tireIcon!)
        
        let key = IS_IPAD ? "showTiresSearchButtonIpad" : "showTiresSearchButton"
        self.tiresSearch = Bundle.main.object(forInfoDictionaryKey: key) as! Bool
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.tiresButton!.frame = CGRect(x: self.frame.width - 71, y: 12, width: 55, height: 22)
        self.tiresLabel!.frame = CGRect(x: 52, y: 0, width:self.frame.width - 123, height: 46)
        self.tireIcon!.frame = CGRect(x: 16, y: 11, width:24, height: 24)
    }
    
    func showTiresSearch() {
        delegate?.showTiresSearch()
    }

}
