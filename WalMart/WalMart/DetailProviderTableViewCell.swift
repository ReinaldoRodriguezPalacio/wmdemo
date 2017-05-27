//
//  DetailProviderTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class DetailProvidertableViewCell : UITableViewCell {
  
  var titleLabel : UILabel!
  var detailLabel : UILabel!
  var separatorView : UIView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  func setup() {
    titleLabel = UILabel()
    titleLabel.font = WMFont.fontMyriadProRegularOfSize(16.0)
    titleLabel.numberOfLines = 1
    titleLabel.textColor = WMColor.dark_gray
    
    detailLabel = UILabel()
    detailLabel.font = WMFont.fontMyriadProRegularOfSize(14.0)
    detailLabel.numberOfLines = 7
    detailLabel.textColor = WMColor.gray
    
    separatorView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    separatorView.backgroundColor = WMColor.light_light_gray
    self.addSubview(separatorView)
  }
  
  func setValues(_ titleTxt:String, detailTxt:String){
    titleLabel.frame = CGRect(x: 16.0, y: 16.0, width: (self.bounds.width - (16.0 * 2)) , height: 16.0)
    titleLabel.text  = titleTxt
    self.clearView(titleLabel)
    self.addSubview(titleLabel)
    
    detailLabel.frame = CGRect(x: 16.0, y: self.titleLabel.frame.maxY + 15.0, width: (self.bounds.width - (16.0 * 2)), height: 75.0)
    detailLabel.text  = detailTxt
    self.clearView(detailLabel)
    self.addSubview(detailLabel)
    
    self.separatorView.frame = CGRect(x: 0, y: self.bounds.height - 1.0, width: self.bounds.width, height: 1.0)
  }
  
  func clearView(_ view: UIView){
    for subview in view.subviews{
      subview.removeFromSuperview()
    }
  }
  
}
