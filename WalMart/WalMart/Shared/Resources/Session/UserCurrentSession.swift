    //
//  UserCurrentSession.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class UserCurrentSession : NSObject {
    
    var userSigned : User? = nil
    
    var userSignedOnService  = false
    
    var phoneNumber : String! = ""
    var workNumber : String! = ""
    var cellPhone : String! = ""
    var mustUpdatePhone : Bool = false
    
    var itemsMG : [String:Any]? = nil
    var itemsGR : [String:Any]? = nil
    
    var dateStart : Date! = Date()
    var dateEnd : Date! = Date()
    var version : String! = ""
    var storeName: String? = nil
    var storeId: String? = nil
    var addressId: String? = nil
    
    var isReviewActive : Bool = false
    
    var isAssociated : Int! = 0
    var porcentageAssociate : Double! =  0.0
    
    var deviceToken = ""
    var finishConfig = false
    
    //Action in check out
    var activeCommens : Bool = false
    var upcSearch : [String]! = []
    var messageInCommens : String! = ""
    
    var screenCategory: String! = ""
    var screenSubCategory: String! = ""
    var screenSubSubCategory: String! = ""
    var screenViewArray : [String:Any]! = [:]
    var nameListToTag =  ""
    
    var JSESSIONID = ""
    var JSESSIONATG = ""

    var jsessionIdArray : [String]! = []

    
    //Singleton init
    static let sharedInstance = UserCurrentSession()
    private override init() {}

    
    class func hasLoggedUser() -> Bool{
        return !(UserCurrentSession.sharedInstance.userSigned == nil)
    }

    class func currentDevice() -> String{
        let validateIpad = IS_IPAD ? "Ipad" : "Iphone"
        return validateIpad
    }
    
    class func systemVersion() -> String{
        return "iOS \(UIDevice.current.systemVersion)"
    }
    
    
    func searchForCurrentUser(){
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "User" as String)
        
        request.returnsObjectsAsFaults = false
        
        let sorter = NSSortDescriptor(key:"lastLogin" , ascending:false)
        request.sortDescriptors = [sorter]
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        if fetchedResult?.count > 0 {
            
            if let userSigned = fetchedResult?[0] as? User {
                
                let cadUserId : NSString? = userSigned.idUserGR
                if cadUserId == nil || cadUserId == "" || cadUserId?.length == 0 {
                    UserCurrentSession.sharedInstance.userSigned = nil
                    UserCurrentSession.sharedInstance.deleteAllUsers()
                    return
                }
                
                self.userSigned = userSigned
                self.validateUserAssociate(UserCurrentSession.sharedInstance.isAssociated == 0 ? true : false)
                
                let loginService = LoginWithEmailService()
                let emailUser = UserCurrentSession.sharedInstance.userSigned!.email
                
                
                loginService.callService(["email":emailUser], successBlock: { (result:[String:Any]) -> Void in
                    
                    }, errorBlock: { (error:NSError) -> Void in
                })
            }
        }
        
    }
    
  
    func createUpdateUser(_ userDictionaryMG:[String:Any], userDictionaryGR:[String:Any]) {
        
        let resultProfileJSONMG = userDictionaryMG["profile"] as! [String:Any]
        var resultProfileJSONGR : [String:Any]? = nil
        
        if let userDictPrGR = userDictionaryGR["profile"] as? [String:Any] {
            resultProfileJSONGR = userDictPrGR
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var usr : User
        let idUser = userDictionaryMG["idUser"] as! String
        let predicate = NSPredicate(format: "idUser == %@ ", idUser)
        
        let array =  self.retrieve("User",sortBy:nil,isAscending:true,predicate:predicate) as! NSArray
        
        var profile : Profile
        if array.count > 0{
            usr = array[0] as! User
            profile = usr.profile
        }else{
            usr = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
            profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context) as! Profile
        }
        
        usr.profile = profile
        usr.idUser = idUser as NSString
        
        //Fill user MG
        usr.email = userDictionaryMG["email"] as! String as NSString
        usr.idUser = userDictionaryMG["idUser"] as! String as NSString
        usr.cartId = userDictionaryMG["cartId"] as! String as NSString
        usr.login = userDictionaryMG["login"] as! String as NSString
        if let token = userDictionaryMG["token"] as? String{
            usr.token = token as NSString
        }
        //usr.token = userDictionaryMG["token"] as String
    
        //Fill user GR
        if let usrGR = userDictionaryGR["idUser"] as? String {
            usr.idUserGR = usrGR as NSString
        }
        if let cartGR = userDictionaryGR["cartId"] as? String {
            usr.cartIdGR = cartGR as NSString
        }
        if let address = userDictionaryGR["address"] as? [String:Any]{
            self.getStoreByAddress(address)
        }
        
        
        let date = Date()
        usr.lastLogin = date
        
        //Fill profile MG
        if let idProfile = resultProfileJSONMG["id"] as? String{
            profile.idProfile = idProfile as NSString
        }
        profile.name = resultProfileJSONMG["name"] as! String as NSString
        profile.lastName = resultProfileJSONMG["lastName"] as! String as NSString
        profile.lastName2 = resultProfileJSONMG["lastName2"] as! String as NSString
        profile.allowMarketingEmail = resultProfileJSONMG["allowMarketingEmail"] as! String as NSString
        if let valueProfile =  resultProfileJSONMG["allowTransfer"] as? String {
            profile.allowTransfer = valueProfile as NSString
        }else {
             profile.allowTransfer = "\(false)" as NSString
        }
        
        if let minimumAmount = resultProfileJSONMG["minimumAmount"] as? Double{
            profile.minimumAmount = NSNumber(value: minimumAmount)
        }
        if let token = resultProfileJSONMG["token"] as? String{
            profile.token = token as NSString
        }
        
        
        if resultProfileJSONGR != nil {
            //Fill profile GR
            profile.allowMarketingEmail = resultProfileJSONMG["allowMarketingEmail"] as! String as NSString
            if let birthDateVal = resultProfileJSONMG["birthdate"] as? String {
                profile.birthDate = birthDateVal as NSString
            } else {
                profile.birthDate = "01/01/2015"
            }
            profile.cellPhone = resultProfileJSONGR!["cellPhone"] as! String as NSString
            profile.homeNumberExtension = resultProfileJSONGR!["homeNumberExtension"] as! String as NSString
            profile.maritalStatus = resultProfileJSONGR!["maritalStatus"] as! String as NSString
            profile.phoneHomeNumber = resultProfileJSONGR!["phoneHomeNumber"] as! String as NSString
            profile.phoneWorkNumber = resultProfileJSONGR!["phoneWorkNumber"] as! String as NSString
            profile.profession = resultProfileJSONGR!["profession"] as! String as NSString

            
            if let genderVal = resultProfileJSONMG["gender"] as? String{
                profile.sex = genderVal as NSString
            } else {
                profile.sex = "Male"
            }
            profile.workNumberExtension = resultProfileJSONGR!["workNumberExtension"] as! String as NSString
        }
        
        do {
            try context.save()
        } catch {
           print("context save error in createUpdateUser")
        }

        self.userSigned = usr
        
        updatePhoneProfile(true)
        self.validateUserAssociate(UserCurrentSession.sharedInstance.isAssociated == 0 ? true : false)
        UserCurrentSession.sharedInstance.userSigned!.profile.cellPhone = resultProfileJSONGR!["cellPhone"] as! String as NSString
        UserCurrentSession.sharedInstance.userSigned!.profile.phoneWorkNumber = resultProfileJSONGR!["phoneWorkNumber"] as! String as NSString
        UserCurrentSession.sharedInstance.userSigned!.profile.phoneHomeNumber = resultProfileJSONGR!["phoneHomeNumber"] as! String as NSString

        
        UserCurrentSession.sharedInstance.userSigned!.profile.cellPhone = resultProfileJSONGR!["cellPhone"] as! String as NSString
        UserCurrentSession.sharedInstance.userSigned!.profile.phoneWorkNumber = resultProfileJSONGR!["phoneWorkNumber"] as! String as NSString
        UserCurrentSession.sharedInstance.userSigned!.profile.phoneHomeNumber = resultProfileJSONGR!["phoneHomeNumber"] as! String as NSString
        
        let homeNumber = resultProfileJSONGR!["phoneHomeNumber"] as! String
        if homeNumber !=  "" {
            UserCurrentSession.sharedInstance.cellPhone = resultProfileJSONGR!["cellPhone"] as! String
            UserCurrentSession.sharedInstance.workNumber = resultProfileJSONGR!["phoneWorkNumber"] as! String
            UserCurrentSession.sharedInstance.phoneNumber = homeNumber
        }


        self.loadShoppingCarts { () -> Void in
            self.invokeGroceriesUserListService()
        }
    }
    
    func deleteAllUsers() {
        deleteAllObjectsNamed("Cart")
        deleteAllObjectsNamed("Wishlist")
        deleteAllObjectsNamed("List")
        deleteAllObjectsNamed("Product")
        deleteAllObjectsNamed("User")
        itemsMG = nil
        itemsGR = nil
        storeName = nil
        storeId = nil
    }
    
    func deleteAllObjectsInShoppingCart() {
        deleteAllObjectsNamed("Cart")
    }
    
    func deleteAllObjectsNamed(_ namedb:String) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: namedb as String)
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        if fetchedResult != nil {
            for objDelete in fetchedResult! {
                context.delete(objDelete as! NSManagedObject)
            }
        }
        do {
            try context.save()
        } catch let error1 as NSError {
            error = error1
        }
    }
    
    func userItemsInWishlist() -> Int {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ &&  status != %@", userSigned!,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }else {
            predicate = NSPredicate(format: "user == nil &&  status != %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Wishlist" as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult!.count
    }
    
    
    func userHasUPCWishlist(_ upc:String) -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@", userSigned!,upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }else {
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Wishlist" as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func userHasUPCUserlist(_ upc:String) -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && ANY products.upc == %@ ", userSigned!,upc)
        }else {
            predicate = NSPredicate(format: "user == nil && ANY products.upc == %@ ", upc)
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "List" as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func userHasUPCUserlist(_ upc:String, listId: String) -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && idList == %@ && ANY products.upc == %@ ", userSigned!,listId,upc)
        }else {
            predicate = NSPredicate(format: "user == nil && name == %@ && ANY products.upc == %@ ",listId, upc)
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "List" as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func getProductQuantityForList(_ upc:String, listId: String) -> Int {
        var predicate : NSPredicate? = nil
        var productQuantity: Int = 0
        if userSigned != nil {
            predicate = NSPredicate(format: "list.idList == %@ && ANY upc == %@ ", listId,upc)
        }else {
            predicate = NSPredicate(format: "list.name == %@ && ANY upc == %@ ",listId, upc)
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Product" as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(String(describing: error))")
        }
        
        if fetchedResult?.count > 0 {
            let productList = fetchedResult!.first! as! Product
            productQuantity = Int(productList.quantity.int32Value)
        }
        
        return productQuantity
    }
    
    func userHasUPCShoppingCart(_ upc:String) -> Bool {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@",userSigned!, upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart" as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
        
    }
    
    func userHasQuantityUPCShoppingCart(_ upc:String) -> Cart? {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@",userSigned!, upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart" as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        
        let  hasQuantity = fetchedResult?.count != 0
        var productIncar : Cart? =  nil
        if hasQuantity {
            if let resultProduct = fetchedResult?[0] as? Cart {
                productIncar = resultProduct
            }
        }
        
        return productIncar
    }
    
    func userHasNoteUPCShoppingCart(_ upc:String) -> Bool {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@",userSigned!, upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart" as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        
        var hasNote = fetchedResult?.count != 0
        if hasNote {
            if let resultProduct = fetchedResult?[0] as? Cart {
                hasNote = resultProduct.note != ""
            }
        }
        
        return hasNote
    }
    
    
    
    
    
    
    func WishlistWithoutUser() -> [Wishlist]? {
        let predicate = NSPredicate(format: "user == nil && status != %@",NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Wishlist" as String)
        request.predicate = predicate
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult as? [Wishlist]
        
    }
    
    
    func retrieve(_ entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil) -> AnyObject {
        return retrieve(entityName, sortBy:sortBy , isAscending:isAscending, predicate:predicate,expression:nil)
    }
    
    func retrieve(_ entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil,expression :NSExpressionDescription?) -> AnyObject {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName as String)
        
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        if (sortBy != nil) {
            let sorter = NSSortDescriptor(key:sortBy! , ascending:isAscending)
            request.sortDescriptors = [sorter]
        }
        
        if expression != nil {
            request.resultType = NSFetchRequestResultType.dictionaryResultType;
            request.propertiesToFetch = [expression!];
        }
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        return fetchedResult! as AnyObject
    }


    //MARK: - UserList
    
    func invokeGroceriesUserListService() {
        //Update users lists on core data
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { ()->() in
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:[String:Any]) -> Void in

                },
                errorBlock: { (error:NSError) -> Void in
                    
            })
            
        //})
    }
    
    
    //MARK: Shopping cart user
    
    
    func loadShoppingCarts(_ result:@escaping (() -> Void)) {
        NotificationCenter.default.post(name:.updateShoppingCartBegin, object: nil)
        self.loadMGShoppingCart { () -> Void in
            self.loadGRShoppingCart({ () -> Void in
                //TODO: Decide shop preShopping Cart, Empty or cart
              NotificationCenter.default.post(name: .updateShoppingCartEnd, object: nil)
                UserCurrentSession.sharedInstance.updateTotalItemsInCarts()
              result()
            })
        }
    }
    
    func loadMGShoppingCart(_ endLoadSC:@escaping (() -> Void)) {
        let service = ShoppingCartProductsService()
        service.callService([:], successBlock: { (result:[String:Any]) -> Void in
            print(result)
            self.itemsMG = result
            endLoadSC()
            }) { (error:NSError) -> Void in
                if error.code != -100 {
                    endLoadSC()
                }
                
        }
    }
    
    
    
    func loadGRShoppingCart(_ endLoadSC:@escaping (() -> Void)) {
        let service = GRShoppingCartProductsService()
        service.callService(requestParams: [:],
            successBlock: { (resultCall:[String:Any]) -> Void in
                self.itemsGR = resultCall
                endLoadSC()
            },
            errorBlock: { (error:NSError) -> Void in
                self.itemsGR = nil
                endLoadSC()
            }
        )
    }
    
    func isEmptyMG() -> Bool {
        if self.itemsMG != nil {
            if let itemsInShoppingCart = self.itemsMG!["items"] as? NSArray {
                return itemsInShoppingCart.count == 0
            }
        }
        return true
    }
    
    func isEmptyGR() -> Bool {
        if self.itemsGR != nil {
            if let itemsInShoppingCart = self.itemsGR!["items"] as? NSArray {
                return itemsInShoppingCart.count == 0
            }
        }
        return true
    }
    
    
    
    func numberOfArticlesMG() -> Int {
        var countItems = 0
        let arrayCart : [Cart]? = self.userCartByType(ResultObjectType.Mg.rawValue)
        if arrayCart != nil {
            countItems = arrayCart!.count
            
        }
        return countItems
        
        
    }
    
    func identicalMG() -> Bool {
        var countItems = false
        let arrayCart : [Cart]? = self.userCartByType(ResultObjectType.Mg.rawValue)
        if arrayCart != nil {
            for product in arrayCart!{
                if product.product.isPreorderable == "true"{
                    countItems = true
                    break
                }
                
            }
        }
        
        return countItems
    }
    
    
    
    
    
    
    
    func estimateTotalMG() -> Double {
        if self.itemsMG != nil {
            if let numTotal = self.itemsMG!["totalEstimado"] as? NSNumber {
                return numTotal.doubleValue
            }
        }
        return 0.0
    }
    
    func estimateTotalGR() -> Double {
        var totalGR = 0.0
        
        let arrayCart : [Cart]? = self.userCartByType(ResultObjectType.Groceries.rawValue)
        if arrayCart != nil {
            for prodCart in arrayCart! {
                if  prodCart.product.type == 0 {
                    totalGR += prodCart.quantity.doubleValue * prodCart.product.price.doubleValue
                } else {
                    if prodCart.product.orderByPiece.boolValue {
                        totalGR += ((prodCart.quantity.doubleValue * prodCart.product.equivalenceByPiece.doubleValue) * prodCart.product.price.doubleValue ) / 1000
                    }else{
                        totalGR += (prodCart.quantity.doubleValue / 1000.0) * prodCart.product.price.doubleValue
                    }
                }
            }
        }
        
        return totalGR
    }
    
    func estimateSavingGR() -> Double {
        var totalGRSV = 0.0
        if self.itemsGR != nil {
            if let savingGR = self.itemsGR!["saving"] as? NSNumber {
                totalGRSV = savingGR.doubleValue
            }
            if let savingGR = self.itemsGR!["saving"] as? NSString {
                totalGRSV = savingGR.doubleValue
            }
        }
        return totalGRSV
    }
    
    func numberOfArticlesGR() -> Int {
        var countItems = 0
        if self.itemsGR != nil {
            let arrayCart = self.itemsGR!["items"] as? [AnyObject]
            countItems = arrayCart!.count
        }else{
           let arrayCart : [Cart]? = self.userCartByType(ResultObjectType.Groceries.rawValue)
            if arrayCart != nil {
                countItems = arrayCart!.count
            }
        }
        self.updateTotalItemsInCarts(itemsInGR:countItems)
        return countItems
    }
    
    
    
    func updateTotalItemsInCarts() {
        let countItems = self.numberOfArticlesMG() + numberOfArticlesGR()
        let params = ["quantity":countItems]
        NotificationCenter.default.post(name: .updateBadge, object: params)
    }
    
    
    func updateTotalItemsInCarts(itemsInGR:Int) {
        let countItems = self.numberOfArticlesMG() + itemsInGR
        let params = ["quantity":countItems]
        NotificationCenter.default.post(name: .updateBadge, object: params)
    }
    
    func updateTotalItemsInCarts(itemsInMG:Int) {
        let countItems = itemsInMG + self.numberOfArticlesGR()
        let params = ["quantity":countItems]
        NotificationCenter.default.post(name: .updateBadge, object: params)
    }
    
    func coreDataShoppingCart(_ predicate:NSPredicate) -> [Cart] {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart" as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult as! [Cart]
        

    }
    
    func userCartByType(_ type:String) -> [Cart]? {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && type == %@ && status != %@",userSigned!, type,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && type == %@ && status != %@", type,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart" as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        if  fetchedResult?.count != 0 {
            return fetchedResult as? [Cart]
        }
        return nil
        
    }
    
    
    func setMustUpdatePhoneProfile(_ home:String,work:String,cellPhone:String) {
        self.mustUpdatePhone = true
        self.phoneNumber = home
        self.workNumber = work
        self.cellPhone = cellPhone
        
        if userSigned != nil {
            self.updatePhoneProfile(false)
        }
        
    }
    
    func validateUserAssociate(_ validate:Bool){
        
        if  UserCurrentSession.hasLoggedUser() {
           // if UserCurrentSession.sharedInstance.isAssociated == 0 {
            if validate {
                let servicePromotion = PromotionsMgService()
                let paramsRec = Dictionary<String, String>()
                servicePromotion.callService(paramsRec,
                    successBlock: { (response:[String:Any]) -> Void in
                        let promotions = response["responseArray"] as! NSArray
                        let promo = promotions[0] as! [String:Any]
                        let isActive = promo["isActive"] as! Bool
                        let porcentangeDiscount = promo["percentageDiscount"] as! Double
                        
                        print(isActive)
                        UserCurrentSession.sharedInstance.isAssociated = isActive ? 1 : 0
                        UserCurrentSession.sharedInstance.porcentageAssociate = porcentangeDiscount
                        
                    }) { (error:NSError) -> Void in
                        // mostrar alerta de error de info
                          UserCurrentSession.sharedInstance.isAssociated = 0
                         UserCurrentSession.sharedInstance.porcentageAssociate = 0.0
                        print(error)
                }
            }
        }
    
    }
    
    
    func updatePhoneProfile(_ newProfile:Bool) {
        if self.mustUpdatePhone {
            
            let svcProfile = GRUpdateUserProfileService()
            let profileParams = svcProfile.buildParams(
                UserCurrentSession.sharedInstance.userSigned!.profile.name as String,
                lastName: UserCurrentSession.sharedInstance.userSigned!.profile.lastName as String,
                sex: "",
                birthDate: UserCurrentSession.sharedInstance.userSigned!.profile.birthDate as String,
                maritalStatus: "",
                profession: "",
                phoneWorkNumber:  self.workNumber,
                workNumberExtension: "",
                phoneHomeNumber: self.phoneNumber,
                homeNumberExtension: "",
                cellPhone: self.cellPhone ,
                allowMarketingEmail: "false",
                user: "",
                password: "",
                newPassword: "",
                maximumAmount: 0,device:IS_IPAD ? "25" : "24")
            
            svcProfile.callService(requestParams: profileParams, successBlock: { (result:[String:Any]) -> Void in
                print("Se actualizo el perfil")
                
                
                //if !newProfile {
                    if UserCurrentSession.hasLoggedUser() {
                        UserCurrentSession.sharedInstance.userSigned!.profile.cellPhone = self.cellPhone as NSString
                        UserCurrentSession.sharedInstance.userSigned!.profile.phoneWorkNumber = self.workNumber as NSString
                        UserCurrentSession.sharedInstance.userSigned!.profile.phoneHomeNumber = self.phoneNumber as NSString
                    }
                //}
                }, errorBlock: { (error:NSError) -> Void in
                    print("Se actualizo el perfil")
            })
        }
    }
  

    class func urlWithRootPath(_ urlCall:String) -> String? {
        let strUrlUsr = "superamaapp"
        let strApiKey = "R_a58bb67ba6a171692b80d85e05b89f17"
        let customAllowedSet =  CharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}").inverted
        var stringUrl  = urlCall as NSString
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: customAllowedSet)! as NSString
        let urlChange = URL(string: "http://api.bit.ly/v3/shorten?login=\(strUrlUsr)&apikey=\(strApiKey)&longUrl=\(stringUrl)&format=txt")!
        let strResult = try? String(contentsOf: urlChange, encoding: String.Encoding.utf8)
        return strResult
    }
    
    func hasPreorderable() -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "product.isPreorderable == %@ && status != %@", "true",NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }else {
            predicate = NSPredicate(format: "product.isPreorderable == %@ && status != %@",  "true",NSNumber(value: WishlistStatus.deleted.rawValue as Int))
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart" as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.fetch(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func getStoreByAddress(_ address: [String:Any]){
        self.storeId = address["storeID"] as? String
        self.storeName = address["storeName"] as? String
        self.addressId = address["addressID"] as? String
        if self.storeId != nil {
            let serviceZip = GRZipCodeService()
            serviceZip.buildParams(address["zipCode"] as! String)
            serviceZip.callService([:], successBlock: { (result:[String:Any]) -> Void in
                let storesDic = result["stores"] as! [[String:Any]]
                for dic in  storesDic {
                    let name = dic["name"] as! String!
                    let idStore = dic["id"] as! String!
                    if self.storeId != nil{
                        if idStore == self.storeId! {
                            self.storeName = name
                            self.storeId = idStore
                            break
                        }
                    }
                }
                }, errorBlock: { (error:NSError) -> Void in
                   self.storeName = ""
                  })
        }

    }

    
}
