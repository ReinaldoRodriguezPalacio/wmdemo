//
//  Delivery.swift
//  MercurySDK
//
//  Created by Gerardo Ramirez on 29/09/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation


public class Delivery : EVObject {
    
    public var id : String? = nil
    public var idActivity : String? = nil
    public var status : String? = nil
    public var acceptOrderRequest : String? = nil
    public var totalAmount : String? = nil
    public var chatMessages : String? = nil
    public var consumerDeviceToken : String? = nil
    
    public var shopper : String? = nil
    public var shoppers : String? = nil
    public var storeID : String? = nil
    
    public var originalOrderRequest : Order? = nil
    public var address : Address? = nil
    
    public var consumer : Consumer? = nil
    public var timeSlot : ServiceDetail? = nil
    
    
    
    
    public func setOrder (date orderDate: NSDate, deliveryInstructions: String?, orderTotalCost:  Double?, orderShipmentCost:  Double?) {
        
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        
        self.originalOrderRequest = Order()
        self.originalOrderRequest?.orderDate = formatter.stringFromDate(orderDate)
        self.originalOrderRequest?.deliveryInstructions = deliveryInstructions
        self.originalOrderRequest?.orderTotalCost = orderTotalCost
        self.originalOrderRequest?.orderShipmentCost = orderShipmentCost
        
    }
    
    
    public func setDeliveryAddress(address: String?,city: String?,state: String?,postalCode: String?,country:String?,longitude:Double?,latitude:Double?,internalNumber:String?,externalNumber:String?,betweenStreet1:String?,betweenStreet2:String?,addressReference:String?) {
        
        self.address = Address()
        self.address?.address = address
        self.address?.city = city
        self.address?.state = state
        self.address?.postalCode = postalCode
        self.address?.country = country
        self.address?.longitude = longitude
        self.address?.latitude = latitude
        
        self.address?.internalNumber = internalNumber
        self.address?.externalNumber = externalNumber
        self.address?.betweenStreet1 = betweenStreet1
        self.address?.betweenStreet2 = betweenStreet2
        self.address?.addressReference = addressReference
        
    }
    
    
    
    public func addItemToOrder(itemId : String?,
        name : String?,
        unitSalePrice : Double?,
        totalPrice : Double?,
        upc : String?,
        shortDescription : String?,
        longDescription : String?,
        thumbnailImage : String?,
        quantity : Int?,
        unitType : OrderItemUnit,
        comments : String?,
        additionType : String?,
        orderItemStatus : String?,
        marketplace : String?,
        modelNumber : String?,
        stock : String?,
        status : String?,
        aisle : String?,
        consecutive : Int?) {
            
            if self.originalOrderRequest?.orderRequestItems == nil {
                self.originalOrderRequest?.orderRequestItems = []
            }
            
            
            let orderItem = OrderItem()
            orderItem.id = upc
            orderItem.itemId = itemId
            orderItem.name = name
            orderItem.unitSalePrice = unitSalePrice
            orderItem.totalPrice = totalPrice
            orderItem.upc = upc
            orderItem.shortDescription = shortDescription
            orderItem.longDescription = longDescription
            orderItem.thumbnailImage = thumbnailImage
            orderItem.quantity = quantity
            orderItem.unitType = unitType.rawValue
            orderItem.comments = comments
            orderItem.additionType = additionType
            orderItem.marketplace = marketplace
            orderItem.modelNumber = modelNumber
            orderItem.stock = stock
            orderItem.status = status
            orderItem.aisle = aisle
            orderItem.consecutive = consecutive
            
            self.originalOrderRequest?.orderRequestItems?.append(orderItem)
        
    }
    
    public func setConsumer(email:String?,name:String?,lastName:String?) {
        if self.consumer == nil {
            self.consumer = Consumer()
        }
        if self.consumer?.user == nil {
            self.consumer?.user = UserMerc()
        }
        if self.consumer?.user?.person == nil {
            self.consumer?.user?.person = Person()
        }

        self.consumer?.user?.email = email
        self.consumer?.user?.userName = email
        self.consumer?.user?.person?.name = name
        self.consumer?.user?.person?.lastname = lastName
    }
    
    
    public func setApplicationInfo(appId:Int?,appName:String?){
        
            
        let device = Device()
        device.identifierForVendor = UIDevice.currentDevice().identifierForVendor!.UUIDString
        device.version = UIDevice.currentDevice().systemVersion
        device.systemName = UIDevice.currentDevice().systemName
        device.model = UIDevice.currentDevice().model
        device.localizedMode = UIDevice.currentDevice().localizedModel
        
        if self.consumer == nil {
            self.consumer = Consumer()
        }
        
        if self.consumer?.user?.person == nil {
           self.consumer?.user?.person = Person()
        }
        
        if self.consumer?.user?.application == nil {
            self.consumer?.user?.application = Application()
        }

        
        self.consumer?.user?.application?.id = appId
        self.consumer?.user?.application?.applicationName = "Walmart"
        self.consumer?.user?.devices = [device]
        
    }
    
    public func setPaymentMethod(idPayment:Int,name:String) {
        let payMethod = PaymentMethod()
        payMethod.id = idPayment
        payMethod.paymentMethodCode = name
        self.consumer?.customerPaymentMethods = [payMethod]
       
    }
    
    public func setDetailService(serviceType:ServiceType,deliveryDate:NSDate,idShopper:String,idStore:String,idTimeSlot:Int) {
        
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        
        let serviceDetail = ServiceDetail()
        serviceDetail.serviceType = serviceType.rawValue
        serviceDetail.deliveryDate = formatter.stringFromDate(deliveryDate)
        serviceDetail.idShopper = idShopper
        serviceDetail.idStore = idStore
        serviceDetail.idTimeSlot = idTimeSlot
        self.timeSlot = serviceDetail
        
    }
    
    
    
    
}
