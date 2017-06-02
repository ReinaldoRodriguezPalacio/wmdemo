//
//  RatingStarsTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 30/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class RatingStarsTableViewCell : UITableViewCell {
  
  var ratingLbl : UILabel!
  var ratingStarsView : UIView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  func setup() {
    ratingLbl = UILabel()
    ratingLbl.font = WMFont.fontMyriadProLightOfSize(14.0)
    ratingLbl.numberOfLines = 1
    ratingLbl.textColor = WMColor.light_blue
    
    ratingStarsView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    ratingStarsView.backgroundColor = UIColor.white
    self.addSubview(ratingStarsView)
  }
  
  func setValues(_ numberStars:String, totalQuestion:Int){
    ratingLbl.frame = CGRect(x: 16.0, y: 16.0, width: (self.bounds.width - (16.0 * 2)) , height: 15.0)
    ratingLbl.text = "(\(numberStars) / 5 ) \(totalQuestion) valoraciones"
    self.clearView(ratingLbl)
    self.addSubview(ratingLbl)
    
    self.ratingStarsView.frame = CGRect(x: 16.0, y: self.ratingLbl.frame.maxY + 18.0, width: self.bounds.width - (32.0), height: 24.0)
    self.createStartImage(numberStars)
  }
  
  func clearView(_ view: UIView){
    for subview in view.subviews{
      subview.removeFromSuperview()
    }
  }
  
  func createStartImage(_ stars:String){
    var left :CGFloat = 0.0
    let values = stars.components(separatedBy: ".")
    for index in 0  ..< 5  {
      
      var imageStar = "star_RatingSelect"
      let n1 = values[0]

      if index >= Int(n1)! {
        if index == Int(n1)! && values[1] != "0" && values[1] != "00" {
          imageStar = "star_RatingMedium"
        } else {
          imageStar = "star_RatingNotSelect"
        }
      }
      
      let start = UIImageView(image: UIImage(named: imageStar))
      start.frame = CGRect(x: left ,y: 0,width: 24,height: 24)
      self.ratingStarsView.addSubview(start)
      left = left + 48
    }
  }
}
