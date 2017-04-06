//
//  ProfileViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 18/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation
import CoreData

class ProfileViewController: IPOBaseController, UITableViewDelegate, UITableViewDataSource  {
    var viewProfile : UIView!
    var imageBG : UIImageView!
    var imageProfile : UIImageView?
    var nameLabel : UILabel!
    var emailLabel : UILabel!
    var table: UITableView!
    var signOutButton: UIButton?
    var editProfileButton: UIButton?
    var backButton: UIButton!
    var hiddenBack = false
    var alertView: IPOWMAlertViewController?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

         NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.setValues), name: NSNotification.Name(rawValue: ProfileNotification.updateProfile.rawValue), object: nil)
        
        imageBG = UIImageView()
        imageBG!.image = UIImage(named: "profileBg")
        self.viewProfile = UIView()
        self.viewProfile.backgroundColor = UIColor.white
        self.viewProfile.addSubview(imageBG!)
        self.view.addSubview(self.viewProfile!)
        
        imageProfile = UIImageView()
        imageProfile?.image = UIImage(named: "userProfile")
        self.viewProfile!.addSubview(self.imageProfile!)
        
        self.nameLabel = UILabel()
        self.nameLabel!.textColor = UIColor.white
        self.nameLabel!.textAlignment = .center
        self.nameLabel!.font = WMFont.fontMyriadProRegularOfSize(25)
        self.nameLabel!.numberOfLines = 2
        
        self.viewProfile!.addSubview(self.nameLabel!)
        
        emailLabel = UILabel()
        emailLabel!.textColor = UIColor.white
        emailLabel!.textAlignment = .center
        emailLabel!.font = WMFont.fontMyriadProRegularOfSize(16)
        
        signOutButton = UIButton()
        signOutButton!.setTitle(NSLocalizedString("profile.signOut", comment: ""), for: UIControlState())
        signOutButton!.setTitleColor(UIColor.white, for: UIControlState())
        signOutButton!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(12)
        signOutButton!.backgroundColor = WMColor.dark_blue
        signOutButton?.addTarget(self, action: #selector(ProfileViewController.signOut(_:)), for: .touchUpInside)
        signOutButton!.layer.cornerRadius = 14.0
        self.viewProfile!.addSubview(self.signOutButton!)

        self.editProfileButton = UIButton()
        self.editProfileButton?.addTarget(self, action: #selector(ProfileViewController.editProfile(_:)), for: .touchUpInside)
        self.editProfileButton!.setImage(UIImage(named: "editProfile"), for: UIControlState())
        self.editProfileButton!.setImage(UIImage(named: "editProfile_active"), for: UIControlState.selected)
        self.editProfileButton!.setImage(UIImage(named: "editProfile_active"), for: UIControlState.highlighted)
        self.viewProfile!.addSubview(self.editProfileButton!)
        self.viewProfile!.addSubview(self.emailLabel!)
        
        if !hiddenBack{
            self.backButton = UIButton()
            self.backButton?.addTarget(self, action: #selector(ProfileViewController.back), for: .touchUpInside)
            self.backButton!.setImage(UIImage(named: "search_back"), for: UIControlState())
            self.backButton!.setImage(UIImage(named: "search_back"), for: UIControlState.selected)
            self.backButton!.setImage(UIImage(named: "search_back"), for: UIControlState.highlighted)
            self.viewProfile!.addSubview(self.backButton!)
        }
        
        self.table = UITableView()
        self.table.register(ProfileViewCell.self, forCellReuseIdentifier: "ProfileViewCell")
        self.table?.backgroundColor = UIColor.clear
        self.table.separatorStyle = .none
        self.table.autoresizingMask = UIViewAutoresizing()
        self.table.delegate = self
        self.table.dataSource = self
        self.viewProfile.addSubview(self.table!)
        //self.table.reloadData()
    }
    
    deinit {
        print("Remove NotificationCenter Deinit")
        NotificationCenter.default.removeObserver(self)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if  UserCurrentSession.sharedInstance.userSigned == nil {
            if self.navigationController != nil {
                self.navigationController!.popToRootViewController(animated: false)
            }
        }
        
        self.signOutButton?.isEnabled = true
        self.table.reloadData()
        self.setValues()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {
        let bounds = self.view.bounds
        self.viewProfile!.frame = CGRect(x: 0,y: 0,width: bounds.width, height: bounds.height )
        self.imageBG!.frame = CGRect(x: 0,y: 0,width: bounds.width, height: 210 )
        self.imageProfile!.frame = CGRect(x: (bounds.width - 24 )/2 , y: 40 , width: 24, height: 24 )
        self.nameLabel!.frame = CGRect(x: 15,y: self.imageProfile!.frame.maxY ,width: bounds.width - 30, height: 50)
        self.emailLabel!.frame = CGRect(x: 0,y: self.nameLabel!.frame.maxY  , width: bounds.width, height: 16)
        self.editProfileButton!.frame = CGRect(x: bounds.width - 63, y: 0 , width: 63, height: 63 )
        if !hiddenBack{
            self.backButton.frame =  CGRect(x: 0, y: 0 , width: 63, height: 63 )
        }
        self.signOutButton!.frame = CGRect(x: (bounds.width - 86) / 2,y: self.emailLabel!.frame.maxY + 32 , width: 86, height: 28 )
        self.table!.frame = CGRect(x: 0, y: 210, width: bounds.width, height: bounds.height -  210)
    }
    
    func setValues(){
        var user: User?
        if UserCurrentSession.hasLoggedUser() {
            user = UserCurrentSession.sharedInstance.userSigned!
            self.nameLabel!.text = (user!.profile.name as String) + " " + (user!.profile.lastName as String)
            self.emailLabel!.text = user!.email as String
        }//if UserCurrentSession.hasLoggedUser()
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 65
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileViewCell", for: indexPath) as! ProfileViewCell
        
        //cell.selectionStyle = .None
        if indexPath.row == 0 {
            cell.setValues(NSLocalizedString("profile.misarticulos", comment: ""), image: "topSales" , size:16 ,  colorText: WMColor.light_blue, colorSeparate:  WMColor.light_gray )
        } else  if indexPath.row == 1 {
            cell.setValues(NSLocalizedString("profile.myAddress", comment: ""), image: "myAddresses" , size:16 ,  colorText: WMColor.light_blue, colorSeparate:  WMColor.light_gray )
        } else if indexPath.row == 2 {
            cell.setValues(NSLocalizedString("profile.myOrders", comment: ""), image: "myOrders" , size:16 ,  colorText: WMColor.light_blue, colorSeparate:  WMColor.light_gray )
        }
        
        if cell.selectedBackgroundView != nil {
            cell.selectedBackgroundView!.removeFromSuperview()
            cell.selectedBackgroundView = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let controller = RecentProductsViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        }else if indexPath.row == 1 {
            
            let controller = MyAddressViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        }else if indexPath.row == 2 {
            let controller = OrderViewController()
            controller.reloadPreviousOrders()
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func signOut(_ sender: UIButton?) {
        
        if IS_IPAD  {
            self.alertView = IPAWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        } else {
            self.alertView = IPOWMAlertViewController.showAlert(UIImage(named:"user_waiting"),imageDone:UIImage(named:"done"),imageError:UIImage(named:"user_error"))
        }

        self.alertView!.setMessage(NSLocalizedString("profile.message.logout",comment:""))

        signOutButton?.isEnabled = false
        
  
        
        let logoutService = LogoutService()
        logoutService.callService(Dictionary<String, String>(),
                                  successBlock: { (response:[String:Any]) -> Void in
                                    
                                    let authorizationService =  AuthorizationService()
                                    authorizationService.callGETService("", successBlock: { (response:[String:Any]) in
                                        print("::Call service AuthorizationService in LogoutService ::")
                                        self.deleteData()
                                        
                                        },errorBlock:{ (error:NSError) in
                                            print(error.localizedDescription)
                                            self.deleteData()
                                            
                                    })
                                    
                                    print("Call service LogoutService success")
            },
                                  errorBlock: { (error:NSError) -> Void in
                                    print("Call service LogoutService error \(error)")
            }
        )        
        
    }
    
    func deleteData(){
        print("deleteData")
    
        delay(0.3) {
            if  UserCurrentSession.hasLoggedUser() {
                UserCurrentSession.sharedInstance.userSigned = nil
                UserCurrentSession.sharedInstance.deleteAllUsers()
                self.signOutButton?.isEnabled = true
                let shoppingService = ShoppingCartProductsService()
                shoppingService.callCoreDataService([:], successBlock: { (result:[String:Any]) -> Void in
                    
                    self.alertView!.setMessage("Ok")
                    self.alertView!.showDoneIcon()
                    NotificationCenter.default.post(name:.userLogOut, object: nil)
                    
                }
                    , errorBlock: { (error:NSError) -> Void in
                        print("")
                        self.alertView!.setMessage(error.localizedDescription)
                        self.alertView!.showErrorIcon("Ok")
                        self.signOutButton?.isEnabled = true
                        NotificationCenter.default.post(name:.userLogOut, object: nil)
                })
            }
        }
    }
    
    
    func editProfile(_ sender:UIButton) {
                
        let controller = EditProfileViewController()
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func back() {
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
}
