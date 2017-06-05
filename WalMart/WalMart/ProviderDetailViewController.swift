//
//  ProviderDetailViewController.swift
//  WalMart
//
//  Created by Daniel V on 26/05/17.
//  Copyright © 2017 BCG Inc. All rights reserved.
//

import Foundation

class ProviderDetailViewController : BaseController {
  
  var titlelbl : UILabel!
  var headerView : UIView!
  var buttonBk: UIButton!
  var currentHeaderView : UIView!
  var viewAdd : UIView!
  var buttonAdd : UIButton!
  
  var providerTable: UITableView!
  var provider : [String:Any]?
  var providerDetails : [[String:Any]]?
  var questions : [[String:Any]]?
  var nameProvider : String = ""
  var rating : Double = 0.0
  
  var satisfactionPorc : Double = 0.0
  var totalQuestion : Int = 0
  
  
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
    
    buttonAdd = UIButton(frame: CGRect(x: (viewAdd.frame.width - 188.0) / 2, y: (viewAdd.frame.height - 34) / 2, width: 188.0, height: 34))
    buttonAdd!.backgroundColor = WMColor.yellow
    buttonAdd!.setTitle("Comprar", for:UIControlState())
    buttonAdd!.titleLabel!.textColor = UIColor.white
    buttonAdd!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
    buttonAdd!.titleLabel!.textColor = UIColor.white
    buttonAdd!.layer.cornerRadius = 17
    buttonAdd!.addTarget(self, action: #selector(ProviderDetailViewController.buyAction), for: UIControlEvents.touchUpInside)
    viewAdd.addSubview(buttonAdd)
    
    self.view.addSubview(viewAdd)
    
    self.invokeServiceProviderDetail()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //self.showLoadingView()
    /*self.reloadList(
     success:{() -> Void in
     self.removeLoadingView()
     },
     failure: {(error:NSError) -> Void in
     self.removeLoadingView()
     }
     )*/
    
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
    buttonAdd.frame = CGRect(x: (viewAdd.frame.width - 188.0) / 2, y: (viewAdd.frame.height - 34) / 2, width: 188.0, height: 34)
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
    
  }
  
  //MARK: - Services
  /**
   Gets product detail info from service
   */
  func invokeServiceProviderDetail() {
    let service =  ProviderDetailService()
    let params = service.buildParams("id001")
    service.callService(params, successBlock: { (response:[String:Any]) -> Void in
      let responseArray  =  response["responseArray"] as! [Any]
      //print(responseArray)
      self.provider = responseArray[0] as? [String:Any]
      
      self.rating = self.provider!["rating"] as! Double
      self.satisfactionPorc = self.provider!["satisfactionPorc"] as! Double
      self.providerDetails = self.provider!["Info"] as? [[String : Any]]
      self.totalQuestion = self.provider!["totalQuestion"] as! Int
      self.questions = self.provider!["questions"] as? [[String : Any]]
      
      self.providerTable!.reloadData()
      
    }, errorBlock: { (error:NSError) -> Void in
      print("Error")
      
    })
  }
}

//MARK: TableViewDataSource
extension ProviderDetailViewController : UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.provider != nil {
      return section == 0 ? questions!.count + 1 : 2
    } else {
      return 0
    }
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if indexPath.section == 0 {
      return indexPath.row == 0 ? 97.0 : 86.0
    } else {
      if self.provider != nil {
        let infoDetail = self.providerDetails![indexPath.row]
        let textCell = infoDetail["description"] as! String
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
      let porcStrn = String(format: "%.0f", satisfactionPorc)
      
      let attrStringLab = NSAttributedString(string:"\(porcStrn)% ", attributes: [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(20),NSForegroundColorAttributeName:WMColor.light_blue])
      let size = attrStringLab.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
      
      let numberPercentage = UILabel(frame: CGRect(x: 16.0, y:12.0, width: size.width, height: 20.0))
      numberPercentage.textColor = WMColor.light_blue
      numberPercentage.font = WMFont.fontMyriadProRegularOfSize(20)
      numberPercentage.text = "\(porcStrn)% "
      
      let titleSatisfaction = UILabel(frame: CGRect(x: numberPercentage.frame.maxX, y: 14.0, width: header.frame.width - numberPercentage.frame.maxX, height: 16.0))
      titleSatisfaction.textColor = WMColor.light_blue
      titleSatisfaction.font = WMFont.fontMyriadProRegularOfSize(16)
      titleSatisfaction.text = "de satisfacción de los clientes"
      
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
          
          cellProviderStars.setValues("3.5", totalQuestion: self.totalQuestion)
          cell = cellProviderStars
          
        } else {
          //cell questions
          let cellProvider = providerTable.dequeueReusableCell(withIdentifier: providerRatingQIdentifier(), for: indexPath) as! RatingQuestionTableViewCell
          let dataQuestion = self.questions![indexPath.row - 1]
          cellProvider.setValues(dataQuestion, totalQuestion: self.totalQuestion)
          
          cell = cellProvider
          }
        
      } else {
        //Provider detail
        let cellProvider = providerTable.dequeueReusableCell(withIdentifier: providerDetailIdentifier(), for: indexPath) as! DetailProvidertableViewCell
        
        let infoDetail = self.providerDetails![indexPath.row]
        let titleCell = indexPath.row == 0 ? "Acerca de \(nameProvider)" : "Devoluciones"
        cellProvider.setValues(titleCell, detailTxt: infoDetail["description"] as! String)
        
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
