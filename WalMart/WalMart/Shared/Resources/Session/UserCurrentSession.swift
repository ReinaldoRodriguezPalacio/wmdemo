    //
//  UserCurrentSession.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData
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
    
    var deviceToken = ""
    var finishConfig = false
    
    //Action in check out
    var activeCommens : Bool = false
    var upcSearch : [String]! = []
    var messageInCommens : String! = ""
    
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        request.returnsObjectsAsFaults = false
        
        let sorter = NSSortDescriptor(key:"lastLogin" , ascending:false)
        request.sortDescriptors = [sorter]
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
                
                let cadUserId : NSString? = userSigned.idUser
                if cadUserId == nil || cadUserId == "" || cadUserId?.length == 0 {
                    UserCurrentSession.sharedInstance.userSigned = nil
                    UserCurrentSession.sharedInstance.deleteAllUsers()
                    return
                }
                
                self.userSigned = userSigned
                
                
                let loginService = LoginWithIdService()
                //let emailUser = UserCurrentSession.sharedInstance.userSigned!.email
                let idUser = UserCurrentSession.sharedInstance.userSigned!.idUser
                
                loginService.callService(["profileId":idUser], successBlock: { (result:[String:Any]) -> Void in
                    print("User signed")
                    }, errorBlock: { (error:NSError) -> Void in
                })
            }
        }
        
    }
    
  
    func createUpdateUser(_ loginResult:[String:Any], profileResult:[String:Any]) {
        
        let loginProfile = loginResult["profile"] as! [String:Any]
        let userProfile = loginResult["profile"] as! [String:Any]
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        var usr : User
        let idUser = loginResult["idUser"] as? String//profileId
        let predicate = NSPredicate(format: "idUser == %@ ", idUser!)
        
        let array =  self.retrieve("User",sortBy:nil,isAscending:true,predicate:predicate) as! [AnyObject]
        
        var profile : Profile
        if array.count > 0{
            usr = array[0] as! User
            profile = usr.profile
        }else{
            usr = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
            profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context) as! Profile
        }
        
        usr.profile = profile
        usr.idUser = idUser! as NSString
        
        usr.email = loginResult["email"] as! String as NSString
        usr.idUser = loginResult["idUser"] as! String as NSString
        usr.cartId = loginResult["cartId"] as! String as NSString
    
        if let addressArray = profileResult["address"] as? [[String:Any]] {
            for address in addressArray{
                let prefered = address["preferred"] as! String
                if prefered == "true"{
                    self.addressId = address["id"] as? String
                    self.storeId = userProfile["storeId"] as? String
                    self.storeName = profileResult["nameStore"] as? String
                    break
                }
            }
            
        }
        
        let date = Date()
        usr.lastLogin = date

        if let idProfile = loginResult["idUser"] as? String{
            profile.idProfile = idProfile as NSString
        }
        
        if let minimumAmount = loginProfile["minimumAmount"] as? Double{
            profile.minimumAmount = NSNumber(value: minimumAmount)
        }
        
        profile.name = loginProfile["name"] as! String as NSString
        profile.lastName = loginProfile["lastName"] as? String as NSString? ?? ""
        
        profile.lastName2 = loginProfile["lastName2"] as! String as NSString
        
        profile.allowMarketingEmail = userProfile["receivePromoEmail"] as? String as NSString? ?? ""
        
        profile.allowTransfer = loginProfile["allowTransfer"] as? String as NSString? ?? "\(false)" as NSString
        
        profile.birthDate = userProfile["dateOfBirth"] as? String as NSString? ?? "01/01/2015"
        
        profile.cellPhone = userProfile["mobileNumber"] as? String as NSString? ?? ""
        
        profile.homeNumberExtension = userProfile["phoneExtension"] as? String as NSString? ?? ""
        
        profile.phoneHomeNumber = userProfile["phoneNumber"] as? String as NSString? ?? ""
        
        profile.profession = userProfile["occupation"] as? String as NSString? ?? ""
        
        profile.sex = userProfile["gender"] as? String as NSString? ?? "Femenino"
        
        //Associate
        profile.associateNumber = userProfile["associateNumber"] as? String as NSString? ?? ""
        profile.associateStore = userProfile["associateStore"] as? String as NSString? ?? ""
        profile.joinDate = userProfile["joinDate"] as? String as NSString? ?? ""
        profile.locale = userProfile["locale"] as? String as NSString? ?? ""
        
        do {
            try context.save()
        } catch {
           print("context save error in createUpdateUser")
        }

        self.userSigned = usr
        
        updatePhoneProfile(true)

        //TODO No llegan en servicio de mustang  de registro
        //UserCurrentSession.sharedInstance.userSigned!.profile.cellPhone = userProfile["mobileNumber"] as! String
        //UserCurrentSession.sharedInstance.userSigned!.profile.phoneHomeNumber = userProfile["phoneNumber"] as! String
        
//        self.loadShoppingCarts { () -> Void in
//            self.invokeGroceriesUserListService()
//        }
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: namedb)
        
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Wishlist")
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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

    /**
     Find upc in local list
     
     - parameter upc: upc search
     
     - returns: true or false
     */
    func userHasUPCUserlist(_ upc:String) -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && ANY products.upc == %@ ", userSigned!,upc)
        }else {
            predicate = NSPredicate(format: "user == nil && ANY products.upc == %@ ", upc)
        }
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Wishlist")
        request.predicate = predicate
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
        let request    =  NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
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
        var fetchedResult: [Any]?
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateShoppingCartBegin.rawValue), object: nil)
        self.loadMGShoppingCart { () -> Void in
            //self.loadGRShoppingCart({ () -> Void in
                //TODO: Decide shop preShopping Cart, Empty or cart
              result()
            //})
        }
    }
    
    //Shopping Cart para combinar
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
    
    
    
    /*func loadGRShoppingCart(endLoadSC:(() -> Void)) {
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
    }*/
    
    func isEmptyMG() -> Bool {
        if self.itemsMG != nil {
            if let itemsInShoppingCart = self.itemsMG!["items"] as? [[String:Any]] {
                return itemsInShoppingCart.count == 0
            }
        }
        return true
    }
    
    func isEmptyGR() -> Bool {
        if self.itemsGR != nil {
            if let itemsInShoppingCart = self.itemsGR!["items"] as? [[String:Any]] {
                return itemsInShoppingCart.count == 0
            }
        }
        return true
    }
    
    
    
    func numberOfArticlesMG() -> Int {
        var countItems = 0
        let arrayCart : [Cart]? = self.userCartByType()//ResultObjectType.Mg.rawValue
        if arrayCart != nil {
            countItems = arrayCart!.count
            
        }
        return countItems
        
        
    }
    
    func identicalMG() -> Bool {
        var countItems = false
        let arrayCart : [Cart]? = self.userCartByType()//ResultObjectType.Mg.rawValue
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
        
        let arrayCart : [Cart]? = self.userCartByType()//ResultObjectType.Groceries.rawValue
        if arrayCart != nil {
            for prodCart in arrayCart! {
                if  prodCart.product.type == 0 {
                    totalGR += prodCart.quantity.doubleValue * prodCart.product.price.doubleValue
                } else {
                    totalGR += (prodCart.quantity.doubleValue / 1000.0) * prodCart.product.price.doubleValue
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
        let countItems = 0
        /*if self.itemsGR != nil {
            let arrayCart = self.itemsGR!["items"] as? [Any]
            countItems = arrayCart!.count
        }else{
           let arrayCart : [Cart]? = self.userCartByType()//ResultObjectType.Groceries.rawValue
            if arrayCart != nil {
                countItems = arrayCart!.count
            }
        }
        self.updateTotalItemsInCarts(itemsInGR:countItems)*/
        return countItems
    }
    
    
    
    func updateTotalItemsInCarts() {
        let countItems = self.numberOfArticlesMG()// + numberOfArticlesGR()
        let params = ["quantity":countItems]
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateBadge.rawValue), object: params)
    }
    
    
    func updateTotalItemsInCarts(itemsInGR:Int) {
        let countItems = self.numberOfArticlesMG() + itemsInGR
        let params = ["quantity":countItems]
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateBadge.rawValue), object: params)
    }
    
    func updateTotalItemsInCarts(itemsInMG:Int) {
        let countItems = itemsInMG + self.numberOfArticlesGR()
        let params = ["quantity":countItems]
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.UpdateBadge.rawValue), object: params)
    }
    
    func coreDataShoppingCart(_ predicate:NSPredicate) -> [Cart] {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
    
    func userCartByType() -> [Cart]? {//type:String
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            //predicate = NSPredicate(format: "user == %@ && type == %@ && status != %@",userSigned!, type,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            predicate = NSPredicate(format: "user == %@ && status != %@",userSigned!,NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            //predicate = NSPredicate(format: "user == nil && type == %@ && status != %@", type,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            predicate = NSPredicate(format: "user == nil && status != %@", NSNumber(value: WishlistStatus.deleted.rawValue as Int))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
    
    
    func setMustUpdatePhoneProfile(_ home:String,cellPhone:String) {
        self.mustUpdatePhone = true
        self.phoneNumber = home
        self.cellPhone = cellPhone
        
        if userSigned != nil {
            self.updatePhoneProfile(false)
        }
        
    }
    
    func updatePhoneProfile(_ newProfile:Bool) {
        if self.mustUpdatePhone {
            //TODO: Meter los datos del update
            let svcProfile = UpdateUserProfileService()
            let profileParams: [String:Any] = [:]
            svcProfile.callService(profileParams, successBlock: { (result:[String:Any]) -> Void in
                print("Se actualizo el perfil")
                
                
                //if !newProfile {
                    if UserCurrentSession.hasLoggedUser() {
                        UserCurrentSession.sharedInstance.userSigned!.profile.cellPhone = self.cellPhone as NSString
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
        let request    = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [Any]?
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
        if self.storeId != nil && (self.storeName == nil || self.storeName!.isEmpty) {
            let serviceZip = GRZipCodeService()
            serviceZip.buildParams(address["zipCode"] as! String)
            serviceZip.callService([:], successBlock: { (result:[String:Any]) -> Void in
                let storesDic = result["stores"] as! [[String:Any]]
                for dic in  storesDic {
                    let name = dic["name"] as! String!
                    let idStore = dic["id"] as! String!
                    if idStore == self.storeId! {
                        self.storeName = name
                        break
                    }
                }
                }, errorBlock: { (error:NSError) -> Void in
                   self.storeName = ""
                  })
        }

    }
    
    
    func getArrayPLP(_ Item: [String:Any]) ->  [String:Any]{
        //Add priceEvent, promotion, characteristics
        var plpShow : [String:Any] = [:]
        var dicReturn : [String:Any] = [:]
        var promoDescription = "" //2x$21 or Ahorra $23
        
        var plpArray: [[String:Any]] = []
        
        //PriceEvent
        var flagAhorra = false
        var isMoreSave = false
        if let priceEvent = Item["priceEvent"] as? [String:Any] {
            if priceEvent["isPriceStrike"] as? Bool == true {
                flagAhorra = true
                isMoreSave = true
                
                //si isPriceStrike es true entra como ahorra más
                //if let priceThr = priceEvent["savingsAmount"] as? NSInteger {
                //promoDescription = String(priceThr)
                if let priceThr = priceEvent["specialPrice"] as? NSString {
                    promoDescription = priceThr as String
                }
                
                var textPriceEvent = ""
                switch priceEvent["priceEventText"] as! String {
                case "Hot-Sale":
                    textPriceEvent = "Hs"
                case "Cyber-Martes":
                    textPriceEvent = "Cm"
                case "Buen Fin":
                    textPriceEvent = "Bf"
                case "Liquidacición":
                    textPriceEvent = "L"
                case "Rebajas":
                    textPriceEvent = "R"
                default:
                    textPriceEvent = ""
                }
                if textPriceEvent != "" {
                    plpShow = ["text":textPriceEvent, "color": WMColor.red]
                    plpArray.append(plpShow)
                }
            }
        }
        
        //Promotion
        var flagPromAho = true
        
        if Item["promotion"] != nil && (Item["promotion"] as! [[String:Any]]).count > 0 {//  as? [String:Any]
            let lenght = (Item["promotion"] as! [[String:Any]]).count
            let promotion = Item["promotion"] as? [[String:Any]]
            
            for idx in 0 ..< lenght{
                
                plpShow = [:]
                let description = promotion![idx]
                
                switch description["description"] as! String {
                case "MSI":
                    plpShow = ["text":"MSI", "color": WMColor.yellow]
                case "Envío Gratis":
                    plpShow = ["text":"Eg", "color": WMColor.light_blue]
                case "Precios mas bajos":
                    plpShow = ["text":"-$", "color": WMColor.red]
                default:
                    plpShow = [:]
                }
                
                if plpShow.count > 0 {
                    plpArray.append(plpShow)
                }
                
                let textDescription = description["description"] as! String
                print(textDescription)
                if textDescription.lowercased().characters.contains("x") && textDescription.lowercased().characters.contains("$") && flagPromAho{
                    
                    if flagAhorra {
                        //"Ahorra más"
                        plpShow = ["text":"A+", "color": WMColor.red]
                        plpArray.append(plpShow)
                        flagPromAho = false
                        //isMoreSave = true
                    } else {
                        //"Mas articulos por menos"
                        // si en description viene "x$" se tomará en cuenta ejemplo "3x$200"
                        plpShow = ["text":"+A-", "color": WMColor.yellow]
                        plpArray.append(plpShow)
                        promoDescription = textDescription
                        flagPromAho = false
                        isMoreSave = false
                    }   
                }
            }
        }
        
        if flagAhorra && flagPromAho {
            //"Ahorra más"
            plpShow = ["text":"A+", "color": WMColor.red]
            plpArray.append(plpShow)
        }
        
        //characteristics
        //Ultimas piezas
        if Item["lowStock"] as? String == "true" {
            plpShow = ["text":"Up", "color": WMColor.red]
            plpArray.append(plpShow)
        }
        //Preventa
        if Item["isPreorderable"] as? String == "true" {
            plpShow = ["text":"Pv", "color": WMColor.light_light_light_blue]
            plpArray.append(plpShow)
        }
        //Nuevo
        if Item["isNew"] as? String == "true" {
            plpShow = ["text":"N", "color": WMColor.green]
            plpArray.append(plpShow)
        }
        //Paquete
        if Item["isBundle"] as? String == "true" {
            plpShow = ["text":"P", "color": WMColor.light_blue]
            plpArray.append(plpShow)
        }
        //Recoger en tienda
        if Item["sellingAtStore"] as? String == "true" {
            plpShow = ["text":"Rt", "color": WMColor.light_blue]
            plpArray.append(plpShow)
        }
        //Sobre pedido
        if Item["isOnDemand"] as? String == "true" {
            plpShow = ["text":"Sp", "color": WMColor.light_light_light_blue]
            plpArray.append(plpShow)
        }
        
        dicReturn = ["arrayItems":plpArray, "promo": promoDescription, "isMore": isMoreSave]
        
        return dicReturn as [String:Any]
    }
    
}
