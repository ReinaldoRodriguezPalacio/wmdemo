//
//  OrderOptionsTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 07/06/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class OrderOptionsTableViewCell : SWTableViewCell {
  
  var titleLabel : UILabel? = nil
  var separatorView : UIView!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  /*override init(frame: CGRect) {
   super.init(frame: frame)
   setup()
   }*/
  
  func setup() {
    
    titleLabel = UILabel()
    titleLabel!.font = WMFont.fontMyriadProRegularOfSize(16.0)
    titleLabel!.numberOfLines = 1
    titleLabel!.textColor = WMColor.gray
    
    separatorView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    separatorView.backgroundColor = WMColor.light_light_gray
    self.addSubview(separatorView)
  }
  
  /**
   Set text in cell for title
   
   - parameter titleTxt:         text title
   */
  func setValues(_ titleTxt:String) {
    
    titleLabel!.frame = CGRect(x: 16.0, y: 15.0, width: (self.bounds.width - (16.0 * 2)) , height: 16.0)
    titleLabel!.text  = titleTxt
    self.clearView(titleLabel!)
    self.addSubview(titleLabel!)
    
    self.separatorView.frame = CGRect(x: 0, y: self.bounds.height - 1.0, width: self.bounds.width, height: 1.0)
  }
  
  func clearView(_ view: UIView){
    for subview in view.subviews{
      subview.removeFromSuperview()
    }
  }
  
  
}
