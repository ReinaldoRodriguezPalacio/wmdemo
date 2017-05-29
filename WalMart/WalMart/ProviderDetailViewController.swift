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
  var providerDetails : [[String:Any]] = []
  var nameProvider : String = ""
  var rating : Double = 0.0
  

  
  
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
    buttonAdd!.setTitle("Agregar", for:UIControlState())
    buttonAdd!.titleLabel!.textColor = UIColor.white
    buttonAdd!.titleLabel!.font = WMFont.fontMyriadProRegularOfSize(14)
    buttonAdd!.titleLabel!.textColor = UIColor.white
    buttonAdd!.layer.cornerRadius = 17
    buttonAdd!.addTarget(self, action: #selector(ProviderDetailViewController.addProvider), for: UIControlEvents.touchUpInside)
    viewAdd.addSubview(buttonAdd)
    
    self.view.addSubview(viewAdd)
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
    
    let bounds = self.view.bounds
    viewAdd.frame = CGRect(x: 0, y: bounds.height - self.headerView!.frame.maxY - 64.0, width: self.view.frame.width, height: 64)
    providerTable.frame =  CGRect(x: 0,  y: self.headerView!.frame.maxY , width: bounds.width, height: bounds.height - self.headerView!.frame.maxY - self.viewAdd!.frame.height - 46.0)
  }
  
  //MARK: - Actions
  func back () {
    self.navigationController!.popViewController(animated: true)
  }
  
  func addProvider() {
    
  }
  
  func showRating() {
    
  }
  
  //MARK: - Services
  
  
}

//MARK: TableViewDataSource
extension ProviderDetailViewController : UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.row == 0 ? 140 : 140
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 46.0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
    header.backgroundColor = UIColor.white
    
    let viewRating = UIView(frame: CGRect(x: 16.0, y: 14.0, width: 64.0, height: 18.0))
    viewRating.backgroundColor = WMColor.blue
    viewRating.layer.cornerRadius = 4.0
    
    let titleRating = UILabel(frame: CGRect(x: 6.0, y: 0.0, width: viewRating.frame.width - 7.0, height: 18.0))
    titleRating.textColor = UIColor.white
    titleRating.font = WMFont.fontMyriadProRegularOfSize(11)
    
    let attachment = NSTextAttachment()
    attachment.image = UIImage(named: "rating_star")
    let attachmentString = NSAttributedString(attachment: attachment)
    let attrs = [NSFontAttributeName : WMFont.fontMyriadProRegularOfSize(11)]
    let string = NSMutableAttributedString(string:"\(rating) de 5   ", attributes:attrs)
    string.append(attachmentString)
    titleRating.attributedText = string
    
    viewRating.addSubview(titleRating)
    header.addSubview(viewRating)
    
    let titleShowRating = UILabel(frame: CGRect(x: self.view.frame.width - 90.0 - 37.5, y: 0.0, width: 90.0, height: 46.0))
    titleShowRating.textColor = WMColor.light_blue
    titleShowRating.font = WMFont.fontMyriadProRegularOfSize(14)
    titleShowRating.text = "Ver calificación"
    header.addSubview(titleShowRating)
    
    let buttonRating = UIButton(frame: CGRect(x: self.view.frame.width - 46.0, y: 0, width: 46, height: 46))
    buttonRating.setImage(UIImage(named:"see_more"), for: UIControlState())
    buttonRating.addTarget(self, action: #selector(ProviderDetailViewController.showRating), for: UIControlEvents.touchUpInside)
    header.addSubview(buttonRating)
    
    let separatorView = UIView(frame:CGRect(x: 0, y: self.view.frame.height - 1.0, width: self.view.frame.width, height: 1.0))
    separatorView.backgroundColor = WMColor.light_light_gray
    header.addSubview(separatorView)
    
    return header
  }
}

//MARK: TableviewDelegate
extension ProviderDetailViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell : UITableViewCell! = nil
    
    //Provider detail
    let cellProvider = providerTable.dequeueReusableCell(withIdentifier: providerDetailIdentifier(), for: indexPath) as! DetailProvidertableViewCell
    
    let infoDetail = self.providerDetails[indexPath.row]
    let titleCell = indexPath.row == 0 ? "Acerca de \(nameProvider)" : "Devoluciones"
    cellProvider.setValues(titleCell, detailTxt: infoDetail["description"] as! String)
    
    cell = cellProvider
    //cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.row != 0  {
      
    }
  }
  
  func providerDetailIdentifier()  -> String {
    return "providerDetailInfo"
  }

}
