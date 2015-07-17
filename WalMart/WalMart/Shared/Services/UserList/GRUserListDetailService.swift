//
//  GRUserListDetailService.swift
//  WalMart
//
//  Created by neftali on 20/01/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import UIKit

class GRUserListDetailService: GRBaseService {

    var listId: String?
    
    func buildParams(listId:String?) {
        self.listId = listId
    }
    
    func callService(params:NSDictionary, successBlock:((NSDictionary) -> Void)?, errorBlock:((NSError) -> Void)?) {
        super.callGETService(params, successBlock: { (resultCall:NSDictionary) -> Void in
                //self.jsonFromObject(resultCall)
                successBlock?(resultCall)
                return
            },
            errorBlock:{ (error:NSError) -> Void in
                errorBlock?(error)
                return
            }
        )
    }
    
    override func serviceUrl() -> String {
        return super.serviceUrl() + "/"  + (self.listId == nil ? "" : self.listId!)
    }

/*
    {
    "id" : "3a5be959-a91e-46a1-9944-69d955242279",
    "codeMessage" : 0,
    "items" : [
    {
    "longDescription" : "",
    "equivalenceByPiece" : "",
    "productIsInStores" : "",
    "stock" : true,
    "upc" : "0003223905526",
    "type" : "0",
    "baseUomcd" : "Pieza(s)",
    "imageUrl" : "http:\/\/www.walmart.com.mx\/super\/images\/Products\/img_small\/0003223905526s.jpg",
    "quantity" : 3,
    "bulkPrice" : 24.3,
    "department" : {
				"idDepto" : "d-Bebidas",
				"description" : "Bebidas"
    },
    "line" : {
				"id" : "l-Jugo-de-Frutas",
				"name" : "Jugo de Frutas"
    },
    "depDesc" : "Bebidas",
    "family" : {
				"id" : "f-Jugos-y-Nectares",
				"name" : "Jugos y Néctares"
    },
    "characteristics" : "Bebida Beberé sabor ponche cítrico.",
    "details" : "",
    "promoDescription" : "",
    "comments" : "",
    "price" : 24.3,
    "pesable" : "",
    "description" : "Bebida Beberé  sabor ponche cítrico 3.78 lt"
    }
    ],
    "name" : "husknd",
    "message" : "Artículos de la lista."
    }
*/
}
