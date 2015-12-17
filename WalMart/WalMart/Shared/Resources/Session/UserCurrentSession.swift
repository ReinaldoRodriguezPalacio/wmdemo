    //
//  UserCurrentSession.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 21/07/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit
import CoreData


class UserCurrentSession : NSObject {
    
    var userSigned : User? = nil
    
    var userSignedOnService  = false
    
    var phoneNumber : String! = ""
    var workNumber : String! = ""
    var cellPhone : String! = ""
    var mustUpdatePhone : Bool = false
    
    var itemsMG : NSDictionary? = nil
    var itemsGR : NSDictionary? = nil
    
    var dateStart : NSDate! = NSDate()
    var dateEnd : NSDate! = NSDate()
    var version : String! = ""
    var storeName: String? = nil
    var storeId: String? = nil
    
    var isAssociated : Int! = 0
    var porcentageAssociate : Double! =  0.0
    
    //Singleton init
    class func sharedInstance()-> UserCurrentSession! {
        struct Static {
            static var instance : UserCurrentSession? = nil
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = self.init()
        }
        
        return Static.instance!
    }
    
    required override init() {
        
    }
    
    class func hasLoggedUser() -> Bool{
        return !(UserCurrentSession.sharedInstance().userSigned == nil)
    }

    class func currentDevice() -> String{
        let validateIpad = IS_IPAD ? "Ipad" : "Iphone"
        return validateIpad
    }
    
    class func systemVersion() -> String{
        return "iOS \(UIDevice.currentDevice().systemVersion)"
    }
    
    func searchForCurrentUser(){
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "User" as NSString as String)
        
        request.returnsObjectsAsFaults = false
        
        let sorter = NSSortDescriptor(key:"lastLogin" , ascending:false)
        request.sortDescriptors = [sorter]
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
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
                    UserCurrentSession.sharedInstance().userSigned = nil
                    UserCurrentSession.sharedInstance().deleteAllUsers()
                    return
                }
                
                self.userSigned = userSigned
                self.validateUserAssociate(UserCurrentSession.sharedInstance().isAssociated == 0 ? true : false)
                
                let loginService = LoginWithEmailService()
                let emailUser = UserCurrentSession.sharedInstance().userSigned!.email
                
                loginService.callService(["email":emailUser], successBlock: { (result:NSDictionary) -> Void in
                    print("User signed")
                    }, errorBlock: { (error:NSError) -> Void in
                })
            }
        }
        
    }
    
  
    func createUpdateUser(userDictionaryMG:NSDictionary, userDictionaryGR:NSDictionary) {
        
        let resultProfileJSONMG = userDictionaryMG["profile"] as! NSDictionary
        var resultProfileJSONGR : [String:AnyObject]? = nil
        if let userDictPrGR = userDictionaryGR["profile"] as? [String:AnyObject] {
            resultProfileJSONGR = userDictPrGR
        }
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
            usr = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
            profile = NSEntityDescription.insertNewObjectForEntityForName("Profile", inManagedObjectContext: context) as! Profile
        }
        
        usr.profile = profile
        usr.idUser = idUser
        
        //Fill user MG
        usr.email = userDictionaryMG["email"] as! String
        usr.idUser = userDictionaryMG["idUser"] as! String
        usr.cartId = userDictionaryMG["cartId"] as! String
        usr.login = userDictionaryMG["login"] as! String
        if let token = userDictionaryMG["token"] as? String{
            usr.token = token
        }
        //usr.token = userDictionaryMG["token"] as String
    
        //Fill user GR
        if let usrGR = userDictionaryGR["idUser"] as? String {
            usr.idUserGR = usrGR
        }
        if let cartGR = userDictionaryGR["cartId"] as? String {
            usr.cartIdGR = cartGR
        }
        if let address = userDictionaryGR["address"] as? NSDictionary{
            self.getStoreByAddress(address)
        }
        
        
        let date = NSDate()
        usr.lastLogin = date
        
        //Fill profile MG
        if let idProfile = resultProfileJSONMG["id"] as? String{
            profile.idProfile = idProfile
        }
        profile.name = resultProfileJSONMG["name"] as! String
        profile.lastName = resultProfileJSONMG["lastName"] as! String
        profile.lastName2 = resultProfileJSONMG["lastName2"] as! String
        profile.allowMarketingEmail = resultProfileJSONMG["allowMarketingEmail"] as! String
        if let valueProfile =  resultProfileJSONMG["allowTransfer"] as? String {
            profile.allowTransfer = valueProfile
        }else {
             profile.allowTransfer = "\(false)"
        }
        
        if let minimumAmount = resultProfileJSONMG["minimumAmount"] as? Double{
            profile.minimumAmount = minimumAmount
        }
        if let token = resultProfileJSONMG["token"] as? String{
            profile.token = token
        }
        
        
        if resultProfileJSONGR != nil {
            //Fill profile GR
            profile.allowMarketingEmail = resultProfileJSONMG["allowMarketingEmail"] as! String
            if let birthDateVal = resultProfileJSONMG["birthdate"] as? String {
                profile.birthDate = birthDateVal
            } else {
                profile.birthDate = "01/01/2015"
            }
            profile.cellPhone = resultProfileJSONGR!["cellPhone"] as! String
            profile.homeNumberExtension = resultProfileJSONGR!["homeNumberExtension"] as! String
            profile.maritalStatus = resultProfileJSONGR!["maritalStatus"] as! String
            profile.phoneHomeNumber = resultProfileJSONGR!["phoneHomeNumber"] as! String
            profile.phoneWorkNumber = resultProfileJSONGR!["phoneWorkNumber"] as! String
            profile.profession = resultProfileJSONGR!["profession"] as! String
            if let genderVal = resultProfileJSONMG["gender"] as? String{
                profile.sex = genderVal
            } else {
                profile.sex = "Male"
            }
            profile.workNumberExtension = resultProfileJSONGR!["workNumberExtension"] as! String
        }
        
        do {
            try context.save()
        } catch {
           print("context save error in createUpdateUser")
        }

        self.userSigned = usr
        
        updatePhoneProfile()
        self.validateUserAssociate(UserCurrentSession.sharedInstance().isAssociated == 0 ? true : false)
        
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
    
    func deleteAllObjectsNamed(namedb:String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: namedb as NSString as String)
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        if fetchedResult != nil {
            for objDelete in fetchedResult! {
                context.deleteObject(objDelete as! NSManagedObject)
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
            predicate = NSPredicate(format: "user == %@ &&  status != %@", userSigned!,NSNumber(integer:WishlistStatus.Deleted.rawValue))
        }else {
            predicate = NSPredicate(format: "user == nil &&  status != %@",NSNumber(integer:WishlistStatus.Deleted.rawValue))
        }
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Wishlist" as NSString as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult!.count
    }
    
    
    func userHasUPCWishlist(upc:String) -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@", userSigned!,upc,NSNumber(integer:WishlistStatus.Deleted.rawValue))
        }else {
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(integer:WishlistStatus.Deleted.rawValue))
        }
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Wishlist" as NSString as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func userHasUPCUserlist(upc:String) -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && ANY products.upc == %@ ", userSigned!,upc)
        }else {
            predicate = NSPredicate(format: "user == nil && ANY products.upc == %@ ", upc)
        }
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "List" as NSString as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func userHasUPCShoppingCart(upc:String) -> Bool {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@",userSigned!, upc,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Cart" as NSString as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
        
    }
    
    func userHasNoteUPCShoppingCart(upc:String) -> Bool {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && product.upc == %@ && status != %@",userSigned!, upc,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && product.upc == %@ && status != %@", upc,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Cart" as NSString as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
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
        let predicate = NSPredicate(format: "user == nil && status != %@",NSNumber(integer:WishlistStatus.Deleted.rawValue))
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Wishlist" as NSString as String)
        request.predicate = predicate
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult as? [Wishlist]
        
    }
    
    
    func retrieve(entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil) -> AnyObject {
        return retrieve(entityName, sortBy:sortBy , isAscending:isAscending, predicate:predicate,expression:nil)
    }
    
    func retrieve(entityName : String, sortBy:String? = nil, isAscending:Bool = true, predicate:NSPredicate? = nil,expression :NSExpressionDescription?) -> AnyObject {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    =  NSFetchRequest(entityName: entityName as NSString as String)
        
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        if (sortBy != nil) {
            let sorter = NSSortDescriptor(key:sortBy! , ascending:isAscending)
            request.sortDescriptors = [sorter]
        }
        
        if expression != nil {
            request.resultType = NSFetchRequestResultType.DictionaryResultType;
            request.propertiesToFetch = [expression!];
        }
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        return fetchedResult!
    }


    //MARK: - UserList
    
    func invokeGroceriesUserListService() {
        //Update users lists on core data
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { ()->() in
            let userListsService = GRUserListService()
            userListsService.callService([:],
                successBlock: { (result:NSDictionary) -> Void in

                },
                errorBlock: { (error:NSError) -> Void in
                    
            })
            
        //})
    }
    
    
    //MARK: Shopping cart user
    
    
    func loadShoppingCarts(result:(() -> Void)) {
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateShoppingCartBegin.rawValue, object: nil)
        self.loadMGShoppingCart { () -> Void in
            self.loadGRShoppingCart({ () -> Void in
                //TODO: Decide shop preShopping Cart, Empty or cart
                
                
              result()
                
            })
        }
    }
    
    func loadMGShoppingCart(endLoadSC:(() -> Void)) {
        let service = ShoppingCartProductsService()
        service.callService([:], successBlock: { (result:NSDictionary) -> Void in
            print(result)
            self.itemsMG = result
            endLoadSC()
            }) { (error:NSError) -> Void in
                if error.code != -100 {
                    endLoadSC()
                }
                
        }
    }
    
    
    
    func loadGRShoppingCart(endLoadSC:(() -> Void)) {
        let service = GRShoppingCartProductsService()
        service.callService(requestParams: [:],
            successBlock: { (resultCall:NSDictionary) -> Void in
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
        var countItems = 0
        let arrayCart : [Cart]? = self.userCartByType(ResultObjectType.Groceries.rawValue)
        if arrayCart != nil {
            countItems = arrayCart!.count
        }
        self.updateTotalItemsInCarts(itemsInGR:countItems)
        return countItems
    }
    
    
    
    func updateTotalItemsInCarts() {
        let countItems = self.numberOfArticlesMG() + numberOfArticlesGR()
        let params = ["quantity":countItems]
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
    }
    
    
    func updateTotalItemsInCarts(itemsInGR itemsInGR:Int) {
        let countItems = self.numberOfArticlesMG() + itemsInGR
        let params = ["quantity":countItems]
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
    }
    
    func updateTotalItemsInCarts(itemsInMG itemsInMG:Int) {
        let countItems = itemsInMG + self.numberOfArticlesGR()
        let params = ["quantity":countItems]
        NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.UpdateBadge.rawValue, object: params)
    }
    
    func coreDataShoppingCart(predicate:NSPredicate) -> [Cart] {
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Cart" as NSString as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult as! [Cart]
        

    }
    
    func userCartByType(type:String) -> [Cart]? {
        var  predicate  : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "user == %@ && type == %@ && status != %@",userSigned!, type,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            //let setItems = userSigned?.productsInCart.filteredSetUsingPredicate(predicate!)
            //return setItems?.count != 0
        }else{
            predicate = NSPredicate(format: "user == nil && type == %@ && status != %@", type,NSNumber(integer:WishlistStatus.Deleted.rawValue))
            
        }
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Cart" as NSString as String)
        request.predicate = predicate
        
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
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
    
    
    func setMustUpdatePhoneProfile(home:String,work:String,cellPhone:String) {
        self.mustUpdatePhone = true
        self.phoneNumber = home
        self.workNumber = work
        self.cellPhone = cellPhone
        
        if userSigned != nil {
            self.updatePhoneProfile()
        }
        
    }
    
    func validateUserAssociate(validate:Bool){
        
        if  UserCurrentSession.hasLoggedUser() {
           // if UserCurrentSession.sharedInstance().isAssociated == 0 {
            if validate {
                let servicePromotion = PromotionsMgService()
                let paramsRec = Dictionary<String, String>()
                servicePromotion.callService(paramsRec,
                    successBlock: { (response:NSDictionary) -> Void in
                        let promotions = response["responseArray"] as! NSArray
                        let promo = promotions[0] as! NSDictionary
                        let isActive = promo["isActive"] as! Int
                        let porcentangeDiscount = promo["percentageDiscount"] as! Double
                        
                        print(isActive)
                        UserCurrentSession.sharedInstance().isAssociated = isActive
                        UserCurrentSession.sharedInstance().porcentageAssociate = porcentangeDiscount
                        
                    }) { (error:NSError) -> Void in
                        // mostrar alerta de error de info
                          UserCurrentSession.sharedInstance().isAssociated = 0
                         UserCurrentSession.sharedInstance().porcentageAssociate = 0.0
                        print(error)
                }
            }
        }
    
    }
    
    
    func updatePhoneProfile() {
        if self.mustUpdatePhone {
            if UserCurrentSession.hasLoggedUser() {
                UserCurrentSession.sharedInstance().userSigned!.profile.cellPhone = self.cellPhone
                UserCurrentSession.sharedInstance().userSigned!.profile.phoneWorkNumber = self.workNumber
                UserCurrentSession.sharedInstance().userSigned!.profile.phoneHomeNumber = self.phoneNumber
            }
            
            let svcProfile = GRUpdateUserProfileService()
            let profileParams = svcProfile.buildParams(
                UserCurrentSession.sharedInstance().userSigned!.profile.name as String,
                lastName: UserCurrentSession.sharedInstance().userSigned!.profile.lastName as String,
                sex: "",
                birthDate: "",
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
            
            svcProfile.callService(requestParams: profileParams, successBlock: { (result:NSDictionary) -> Void in
                print("Se actualizo el perfil")
                }, errorBlock: { (error:NSError) -> Void in
                    print("Se actualizo el perfil")
            })
        }
    }
    

    class func urlWithRootPath(urlCall:String) -> String? {
        let strUrlUsr = "superamaapp"
        let strApiKey = "R_a58bb67ba6a171692b80d85e05b89f17"
        let urlChange = NSURL(string: "http://api.bit.ly/v3/shorten?login=\(strUrlUsr)&apikey=\(strApiKey)&longUrl=\(urlCall)&format=txt")!
        let strResult = try? String(contentsOfURL: urlChange, encoding: NSUTF8StringEncoding)
        return strResult
    }
    
    func hasPreorderable() -> Bool {
        var predicate : NSPredicate? = nil
        if userSigned != nil {
            predicate = NSPredicate(format: "product.isPreorderable == %@ && status != %@", "true",NSNumber(integer:WishlistStatus.Deleted.rawValue))
        }else {
            predicate = NSPredicate(format: "product.isPreorderable == %@ && status != %@",  "true",NSNumber(integer:WishlistStatus.Deleted.rawValue))
        }
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        let request    = NSFetchRequest(entityName: "Cart" as NSString as String)
        request.predicate = predicate!
        
        var error: NSError? = nil
        var fetchedResult: [AnyObject]?
        do {
            fetchedResult = try context.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            fetchedResult = nil
        }
        if error != nil {
            print("errore: \(error)")
        }
        
        return fetchedResult?.count != 0
    }
    
    func getStoreByAddress(address: NSDictionary){
        self.storeId = address["storeID"] as? String
        self.storeName = address["storeName"] as? String
        if self.storeId != nil && (self.storeName == nil || self.storeName!.isEmpty) {
            let serviceZip = GRZipCodeService()
            serviceZip.buildParams(address["zipCode"] as! String)
            serviceZip.callService([:], successBlock: { (result:NSDictionary) -> Void in
                let storesDic = result["stores"] as! [NSDictionary]
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

    
}