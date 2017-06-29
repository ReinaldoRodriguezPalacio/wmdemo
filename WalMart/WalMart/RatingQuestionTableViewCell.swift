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
    percentageLbl.textAlignment = .right
    
    ratingView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    ratingView.backgroundColor = WMColor.light_gray
    
    ratingGreenView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
    ratingGreenView.backgroundColor = WMColor.green
    self.addSubview(ratingView)
    self.addSubview(ratingGreenView)
  }
  
  func setValues(_ questionData:[String:Any], totalQuestion:Int){
    questionLbl.frame = CGRect(x: 16.0, y: 0.0, width: (self.bounds.width - (16.0 * 2)) , height: 46.0)
    questionLbl.text = questionData["label"] as! String
    self.clearView(questionLbl)
    self.addSubview(questionLbl)
    
    let numbAprobed = questionData["correct"] as! Int
    
    let whdthRating : CGFloat = self.bounds.width - 32 - (IS_IPAD ? 93.0 : 95.0)
    
    if IS_IPAD {
      self.ratingView.frame = CGRect(x: 16.0, y: self.questionLbl.frame.maxY + 7.0, width: whdthRating, height: 10.0)
    } else {
      self.ratingView.frame = CGRect(x: 16.0, y: self.questionLbl.frame.maxY + 8.0, width: whdthRating, height: 8.0)
    }
    
    let widthDoub = Double(self.ratingView.frame.width)
    //let rango = (Double(numbAprobed!) / Double(totalQuestion)) * 100
    let percentageRating : Double = (widthDoub * (questionData["okPercentage"] as! Double) ) / 100.0
    self.ratingGreenView.frame = CGRect(x: 16.0, y: self.ratingView.frame.minY, width: CGFloat(percentageRating), height: self.ratingView.frame.height)
    
    percentageLbl.frame = CGRect(x: self.bounds.width - 16.0 - (IS_IPAD ? 90.0 : 91.0), y: self.ratingView.frame.minY, width: IS_IPAD ? 90.0 : 91.0 , height: 11.0)
    percentageLbl.text  = "\(String(format: "%.1f", questionData["okPercentage"] as! Double))% (\(numbAprobed) / \(totalQuestion))"
    self.clearView(percentageLbl)
    self.addSubview(percentageLbl)
  }
  
  func clearView(_ view: UIView){
    for subview in view.subviews{
      subview.removeFromSuperview()
    }
  }
}
