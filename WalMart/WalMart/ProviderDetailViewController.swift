//
//  ProviderDetailViewController.swift
//  WalMart
//
//  Created by Daniel V on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

protocol ProviderDetailViewControllerDelegate: class {
  func addProductToShoppingCart(_ upc:String,desc:String,price:String,imageURL:String, comments:String)
}

class ProviderDetailViewController : BaseController {
  
  var titlelbl : UILabel!
  var headerView : UIView!
  var buttonBk: UIButton!
  var currentHeaderView : UIView!
  var viewAdd : UIView!
  var buttonShop : UIButton!
  
  var providerTable: UITableView!
  var provider : [String:Any]?
  var providerDetails : [String:Any]?
  var questions : [[String:Any]]?
  var nameProvider : String = ""
  var rating : Double = 0.0
  var sellerId: String = ""
  
  var prodUpc : String! = ""
  var prodImageUrl: String! = ""
  var prodDescription: String! = ""
  var prodPrice : String! = ""
  var prodComments : String! = ""
  
  var quantity: NSNumber! = 0
  var isAviableToShoppingCart : Bool = true 
  
  var satisfactionPorc : Double = 0.0
  var totalQuestion : Int = 0
  var totalCount :Int = 0
    
  var viewLoad: WMLoadingView? = nil
  
  weak var delegate : ProviderDetailViewControllerDelegate?
  
  override func getScreenGAIName() -> String {
    return WMGAIUtils.SCREEN_PRODUCTDETAIL.rawValue
  }
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 46))
    headerView.backgroundColor = WMColor.light_light_gray
    self.buttonBk = UIButton(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
    buttonBk.setImage(UIImage(named:"BackProduct"), for: UIControlState())
    buttonBk.addTarget(self, action: #selector(ProviderDetailViewController.back), for: UIControlEvents.touchUpInside)
    headerView.addSubview(buttonBk)
    
    if IS_IPAD {
        self.buttonBk?.setImage(UIImage(named:"detail_close"), for: .normal)
    }
    
    titlelbl = UILabel(frame: CGRect(x: 46, y: 0, width: self.view.frame.width - (46 * 2), height: 46))
    titlelbl.textAlignment = .center
    titlelbl.text = nameProvider
    titlelbl.numberOfLines = 1
    titlelbl.font = WMFont.fontMyriadProRegularOfSize(14)
    titlelbl.textColor = WMColor.light_blue
    titlelbl.adjustsFontSizeToFitWidth = true
    titlelbl.minimumScaleFactor = 9 / 12
    
    headerView.addSubview(titlelbl)
    self.view.addSubview(headerView)
    
    providerTable = UITableView()
    providerTable.delegate = self
    providerTable.dataSource = self
    providerTable.register(DetailProvidertableViewCell.self, forCellReuseIdentifier: "providerDetailInfo")
    providerTable.register(RatingQuestionTableViewCell.self, forCellReuseIdentifier: "providerRatingQuestion")
    providerTable.register(RatingStarsTableViewCell.self, forCellReuseIdentifier: "providerRatingStars")
    providerTable.backgroundColor = UIColor.white
    providerTable.separatorStyle = .none
    providerTable.autoresizingMask = UIViewAutoresizing()
    
    self.view.addSubview(providerTable)
    
    viewAdd = UIView(frame: CGRect(x: 0, y: self.view.frame.height - self.headerView!.frame.maxY - 46.0, width: self.view.frame.width, height: 64))
    viewAdd.backgroundColor = UIColor.white
    
    let separatorViewAdd = UIView(frame:CGRect(x: 0, y: 1.0, width: viewAdd.frame.width, height: 1.0))
    separatorViewAdd.backgroundColor = WMColor.light_light_gray
    viewAdd.addSubview(separatorViewAdd)
    
    buttonShop = UIButton(frame: CGRect(x: (viewAdd.frame.width - 188.0) / 2, y: (viewAdd.frame.height - 34) / 2, width: 188.0, height: 34))
    buttonShop!.backgroundColor = WMColor.yellow
    buttonShop!.titleLabel!.textColor = UIColor.white
    buttonShop!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
    buttonShop!.titleLabel!.textColor = UIColor.white
    buttonShop!.layer.cornerRadius = 17
    buttonShop!.addTarget(self, action: #selector(ProviderDetailViewController.buyAction), for: UIControlEvents.touchUpInside)
    viewAdd.addSubview(buttonShop)
    
    self.reloadBtnShop()
    
    self.view.addSubview(viewAdd)
    self.invokeServiceProviderDetail()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    showLoadingView()
    self.providerTable!.reloadData()
  }
  
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    //let bounds = self.view.bounds
    let heighViewAd : CGFloat = IS_IPAD ? 66 : 64
    
    titlelbl.frame = CGRect(x: 46, y: 0, width: self.view.frame.width - (46 * 2), height: 46)
    viewAdd.frame = CGRect(x: 0, y: self.view.frame.height - heighViewAd - (IS_IPAD ? 0.0 : 46.0), width: self.view.frame.width, height: heighViewAd)
    buttonShop.frame = CGRect(x: (viewAdd.frame.width - 188.0) / 2, y: (viewAdd.frame.height - 34) / 2, width: 188.0, height: 34)
    providerTable.frame =  CGRect(x: 0,  y: self.headerView!.frame.maxY , width: self.view.frame.width, height: self.view.frame.height - self.headerView!.frame.maxY - heighViewAd - (IS_IPAD ? 0.0 : 46.0))
  }
  
  //MARK: - Actions
  func back () {
    if IS_IPAD {
        self.dismiss(animated: true, completion: nil)
    }else{
       self.navigationController!.popViewController(animated: true)
    }
    
  }
  
  func buyAction() {
    delegate?.addProductToShoppingCart(self.prodUpc, desc: self.prodDescription, price:self.prodPrice, imageURL: self.prodImageUrl, comments:"")
    self.reloadBtnShop()
  }
  
  func reloadBtnShop() {
    let productincar = UserCurrentSession.sharedInstance.userHasQuantityUPCShoppingCart(self.prodUpc)
    var text = NSLocalizedString("productdetail.shop",comment:"")
    quantity = 0
    
    if isAviableToShoppingCart  {
      if productincar != nil && productincar?.quantity != 0 {
        quantity = productincar!.quantity
        if quantity.int32Value == 1 {
          text = String(format: NSLocalizedString("list.detail.quantity.piece", comment:""), quantity)
        }
        else {
          text = String(format: NSLocalizedString("list.detail.quantity.pieces", comment:""), quantity)
        }
      }
    }else {
      text = NSLocalizedString("productdetail.shopna",comment:"")
      
      buttonShop!.setTitle(text, for: UIControlState())
      buttonShop!.setTitleColor(WMColor.light_blue, for: UIControlState())
      buttonShop!.setTitle(text, for: UIControlState.selected)
      buttonShop!.setTitleColor(WMColor.light_blue, for: UIControlState.selected)
      buttonShop!.backgroundColor = WMColor.light_gray
    }
    
    buttonShop.setTitle(text, for: .normal)
  }
  
  //MARK: - Services
  /**
   Gets product detail info from service
   */
    func invokeServiceProviderDetail() {
        let service =  ProviderDetailService()
        service.buildParams("2024")//self.sellerId)
        service.callService([:], successBlock: { (response:[String:Any]) -> Void in
            let responseArray  =  response["responseArray"] as! [Any]
            self.provider = responseArray[0] as? [String:Any]
            
            self.rating =  self.provider!["gradeGeneral"] as! Double
            let evaluations = self.provider!["evaluations"] as! [String:Any]
            self.satisfactionPorc = evaluations["porcentageGeneral"] as! Double
            self.providerDetails = self.provider!["seller"] as? [String : Any]
            self.totalQuestion = evaluations.count
            self.totalCount = evaluations["total_count"] as! Int
            self.questions = evaluations["summaryEvaluations"] as? [[String : Any]]
            self.removeLoadingView()
            self.providerTable!.reloadData()
        
        }, errorBlock: { (error:NSError) -> Void in
            print("Error")
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func showLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.removeFromSuperview()
            self.viewLoad = nil
        }
        
        self.viewLoad = WMLoadingView(frame: CGRect(x: 0.0, y: self.headerView!.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.headerView!.frame.maxY))
        self.viewLoad!.backgroundColor = UIColor.white
        self.view.addSubview(self.viewLoad!)
        self.viewLoad!.startAnnimating(true)
    }
    
    func removeLoadingView() {
        if self.viewLoad != nil {
            self.viewLoad!.stopAnnimating()
            self.viewLoad = nil
        }
    }

}


//MARK: TableViewDataSource
extension ProviderDetailViewController : UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.providerDetails != nil ? 2 : 1
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.provider != nil {
      return section == 0 ? (self.questions != nil ? (questions!.count + 1 ) : 1) : 2
    } else {
      return 0
    }
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if indexPath.section == 0 {
        return indexPath.row == 0 ? 97.0 : (self.questions != nil ? 86.0 : 0.0)
    } else {
      if self.provider != nil {
        let textCell = self.providerDetails!["description"] as! String
        let size = DetailProvidertableViewCell.sizeText(textCell, width: self.view.frame.width - (32.0))
        
        return size + 60.0
      }
    }
    
    return 0
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 46.0 : 0.0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
    header.backgroundColor = UIColor.white
    
    if section == 0 {
      let porcStrn = String(format: "%.2f", satisfactionPorc)
      
      let attrStringLab = NSAttributedString(string:"\(porcStrn)% ", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(20),NSForegroundColorAttributeName:WMColor.light_blue])
      let size = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
      
      let numberPercentage = UILabel(frame: CGRect(x: 16.0, y:12.0, width: size.width, height: 20.0))
      numberPercentage.textColor = WMColor.light_blue
      numberPercentage.font = WMFont.fontMyriadProRegularOfSize(20)
      numberPercentage.text = "\(porcStrn)% "
      
      let titleSatisfaction = UILabel(frame: CGRect(x: numberPercentage.frame.maxX, y: 14.0, width: header.frame.width - numberPercentage.frame.maxX, height: 16.0))
      titleSatisfaction.textColor = WMColor.light_blue
      titleSatisfaction.font = WMFont.fontMyriadProRegularOfSize(16)
      titleSatisfaction.text = NSLocalizedString("provider.satisfaction",comment:"")
      
      header.addSubview(numberPercentage)
      header.addSubview(titleSatisfaction)
      
      let separatorView = UIView(frame:CGRect(x: 0, y: self.view.frame.height - 1.0, width: self.view.frame.width, height: 1.0))
      separatorView.backgroundColor = WMColor.light_light_gray
      header.addSubview(separatorView)
    }
    
    return header
  }
}

//MARK: TableviewDelegate
extension ProviderDetailViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell : UITableViewCell! = nil
    if self.provider != nil {
      if indexPath.section == 0 {
        
        if indexPath.row == 0 {
          //cell rating Stars
          let cellProviderStars = providerTable.dequeueReusableCell(withIdentifier: providerRatingStarsIdentifier(), for: indexPath) as! RatingStarsTableViewCell
          cellProviderStars.setValues(String(self.rating), totalQuestion: self.totalCount)
          cell = cellProviderStars
          
        } else {
          //cell questions
            if self.questions != nil {
                let cellProvider = providerTable.dequeueReusableCell(withIdentifier: providerRatingQIdentifier(), for: indexPath) as! RatingQuestionTableViewCell
                let dataQuestion = self.questions![indexPath.row - 1]
                cellProvider.setValues(dataQuestion, totalQuestion: self.totalCount)
                
                cell = cellProvider
            }
          }
        
      } else {
        //Provider detail
        let cellProvider = providerTable.dequeueReusableCell(withIdentifier: providerDetailIdentifier(), for: indexPath) as! DetailProvidertableViewCell
        
        let infoDetail = indexPath.row == 0 ? self.providerDetails!["description"] as! String : self.providerDetails!["description"] as! String
        
        let titleCell = indexPath.row == 0 ? String(format: NSLocalizedString("provider.about", comment:""), nameProvider) : NSLocalizedString("provider.returns",comment:"")
        cellProvider.setValues(titleCell, detailTxt: infoDetail)
        
        cell = cellProvider
      }
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.row != 0  {
      
    }
  }
  
  func providerDetailIdentifier()  -> String {
    return "providerDetailInfo"
  }
  
  func providerRatingQIdentifier()  -> String {
    return "providerRatingQuestion"
  }
  
  func providerRatingStarsIdentifier()  -> String {
    return "providerRatingStars"
  }

}
