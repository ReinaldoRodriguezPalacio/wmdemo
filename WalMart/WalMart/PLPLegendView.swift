//
//  PLPLegendView.swift
//  WalMart
//
//  Created by Daniel V on 18/08/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

class PLPLegendView: UIView, UIGestureRecognizerDelegate {
    
    var arrayPlp : NSArray? = []
    var isVertical : Bool = true
    var countPromotion: Int = 0
    var legendView : LegendView?
    var viewRecent : UIView?
    var xyViewPicture : CGFloat = IS_IPAD ? 4.0 : 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init(isvertical : Bool, PLPArray: NSArray, viewPresentLegend:UIView) {
        super.init(frame: CGRect.zero)
        
        self.arrayPlp = PLPArray
        self.isVertical = isvertical
        self.viewRecent = viewPresentLegend
        setup()
    }
    
    func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PLPLegendView.showViewPLP))
        self.addGestureRecognizer(tapGesture)
        
        self.setPLP()
    }
    
    override func layoutSubviews() {

    }
    
    func setPLP(){
        self.countPromotion =  self.arrayPlp!.count
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        var yView : CGFloat = self.isVertical ? 0.0 : 8.0
        var xView : CGFloat = self.isVertical ? 8.0 : 0.0
        let ySpace : CGFloat = IS_IPAD ? 6.0 : 4.0
        let heighView : CGFloat = 14.0
        let widthView : CGFloat = 18.0
        
        //Show PLP in Cell
        if self.arrayPlp!.count > 0 {
            for lineToShow in self.arrayPlp! {
                //Se muestran etiquetas para promociones, etc.
                let promotion = UIView(frame: CGRect(x: xView, y: yView, width: widthView, height: heighView))
                promotion.backgroundColor = lineToShow["color"] as? UIColor
                promotion.layer.cornerRadius = 2.0
                
                let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: widthView, height: heighView))
                textLabel.text =  lineToShow["text"] as? String
                textLabel.textColor = UIColor.white
                textLabel.font = WMFont.fontMyriadProRegularOfSize(9)
                textLabel.textAlignment = .center
                promotion.addSubview(textLabel)
                
                self.addSubview(promotion)
                
                if self.isVertical {
                    yView = promotion.frame.maxY + ySpace
                } else {
                    xView = promotion.frame.maxX + ySpace
                }
            }
        }
        //self.backgroundColor = WMColor.dark_gray
    }
    
    //show Legend View
    func showViewPLP(){
        print("** Seleccionar leyenda PLPLegendView **")
        self.legendView =  LegendView()
        self.legendView?.showLegend(self.viewRecent!)
    }
}
