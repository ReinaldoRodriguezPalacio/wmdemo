//
//  RatingQuestionTableViewCell.swift
//  WalMart
//
//  Created by Daniel V on 30/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class RatingQuestionTableViewCell : UITableViewCell {
  
  var questionLbl : UILabel!
  var percentageLbl : UILabel!
  var ratingView : UIView!
  var ratingGreenView : UIView!
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  func setup() {
    questionLbl = UILabel()
    questionLbl.font = WMFont.fontMyriadProLightOfSize(14.0)
    questionLbl.numberOfLines = 2
    questionLbl.textColor = WMColor.light_blue
    
    percentageLbl = UILabel()
    percentageLbl.font = WMFont.fontMyriadProRegularOfSize(11.0)
    percentageLbl.numberOfLines = 1
    percentageLbl.textColor = WMColor.gray
    
    ratingView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    ratingView.backgroundColor = WMColor.light_gray
    
    ratingGreenView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    ratingGreenView.backgroundColor = WMColor.green
    self.addSubview(ratingView)
    self.addSubview(ratingGreenView)
  }
  
  func setValues(_ titleTxt:String, detailTxt:String){
    questionLbl.frame = CGRect(x: 16.0, y: 0.0, width: (self.bounds.width - (16.0 * 2)) , height: 46.0)
    //questionLbl.text  = titleTxt
    questionLbl.text = "¿El articulo cumple con las caracteristicas y la descripcion publicada?"
    self.clearView(questionLbl)
    self.addSubview(questionLbl)
    
    self.ratingView.frame = CGRect(x: 16.0, y: self.questionLbl.frame.maxY + 8.0, width: 248.0, height: 8.0)
    
    let percentageRating = (self.ratingView.frame.width * 75) / 100
    self.ratingGreenView.frame = CGRect(x: 16.0, y: self.ratingView.frame.minY, width: percentageRating, height: 8.0)
    
    percentageLbl.frame = CGRect(x: self.ratingView.frame.maxX + 8.0, y: self.ratingView.frame.minY, width: (self.bounds.width - (self.ratingView.frame.maxX + 8.0 + 16.0)), height: 11.0)
    //percentageLbl.text  = detailTxt
    percentageLbl.text  = "100% (1548 / 1548)"
    self.clearView(percentageLbl)
    self.addSubview(percentageLbl)
  }
  
  func clearView(_ view: UIView){
    for subview in view.subviews{
      subview.removeFromSuperview()
    }
  }
}
