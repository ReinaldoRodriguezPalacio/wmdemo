//
//  GRAddressViewCell.swift
//  WalMart
//
//  Created by Luis Alonso Salcido Martinez on 07/04/16.
//  Copyright © 2016 BCG Inc. All rights reserved.
//

import Foundation

/// Celda para listado de direcciones
class GRAddressViewCell: UITableViewCell {
    var titleLabel : UILabel!
    var addressID : String!
    var imageDisclousure : UIImageView!
    var imageErrorField: UIImageView!
    
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
        self.titleLabel!.numberOfLines = 2
        
        
        imageDisclousure = UIImageView(image: UIImage(named: "disclosure"))
        imageDisclousure.contentMode = UIViewContentMode.Center
        
        imageErrorField = UIImageView(image: UIImage(named: "profile_field_error"))
        imageErrorField.contentMode = UIViewContentMode.Center
        imageErrorField.hidden = true
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(imageDisclousure)
        self.contentView.addSubview(imageErrorField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRectMake(0 , 1, self.bounds.width - 41  , self.bounds.height - 1)
        imageDisclousure.frame = CGRectMake(self.frame.width - 48 , 1, 48, self.frame.height)
        imageErrorField.frame = CGRectMake(self.frame.width - 72 , 1, 48, self.frame.height)
        
    }
    
    /**
     Seta los parametros de la celda
     
     - parameter title:         titulo de la celda
     - parameter font:          tipo de letra
     - parameter numberOfLines: numero de lineas del titulo
     - parameter textColor:     color del texto
     - parameter align:         alineacion del texto
     - parameter addressID:     identificador de la direccion
     */
    func setValues(title:String,font:UIFont,numberOfLines:Int,textColor:UIColor,align:NSTextAlignment,addressID: String){
        titleLabel.text  = title
        titleLabel.font = font
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = align
        titleLabel.textColor = textColor
        self.addressID = addressID
    }
    
    /**
     Muestra o oculta el indicador de dirrecion incompleta
     
     - parameter show: indica si se muestra o se oculta el indicador
     */
    func showErrorFieldImage(show:Bool){
        self.imageErrorField.hidden = !show
    }
    
}
