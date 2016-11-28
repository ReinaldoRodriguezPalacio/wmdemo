//
//  HelpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 30/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol HelpViewControllerDelegate {
    func selectedDetail(_ row:Int, item: [String:Any])
}

class HelpViewController:  NavigationViewController,  UITableViewDelegate, UITableViewDataSource {

    var delegate:HelpViewControllerDelegate!
    var table: UITableView!
    var array : NSArray!
    var selected : Int! = -1
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_HOWTOUSETHEAPP.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.table = UITableView()
        self.table.register(HelpViewCell.self, forCellReuseIdentifier: "labelCell")
        
        self.table?.backgroundColor = UIColor.white
        
        self.table.separatorStyle = .none
        self.table.autoresizingMask = UIViewAutoresizing()
        self.titleLabel!.text = NSLocalizedString("moreoptions.title.Help", comment: "")
        
        let filePath =  Bundle.main.path(forResource: "help", ofType: "json")
        let jsonData: Data?
        do {
            jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath!), options: NSData.ReadingOptions.mappedIfSafe)
        } catch {
            jsonData = nil
        }
        let resultArray = (try! JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSArray
        
        array = resultArray
        
        self.view.addSubview(self.table!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        self.table!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY , width: bounds.width, height: bounds.height - self.header!.frame.maxY )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if delegate == nil || self.table.delegate == nil {
            self.table.delegate = self
            self.table.dataSource = self
            self.table.reloadData()
            
           // self.table.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
  
    

    
    //MARK: - UITableView
    /*
    *@method: Obtain number of sections on menu
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    *@method: Obtain the number of rows for table view
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.array!.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = 46
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(indexPath.row == selected, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? HelpViewCell
        

        
        if indexPath.row == 2  {
            cell!.setValues(NSLocalizedString("help.item.terms.qualifies", comment: ""),
                font:WMFont.fontMyriadProLightOfSize(16),
                numberOfLines: 2,
                textColor: WMColor.dark_gray,
                padding: 12,
                align:NSTextAlignment.left)
            
            cell!.selectionStyle = UITableViewCellSelectionStyle.none

            return cell!
        }
        if  indexPath.row  == 0 {
            cell!.setValues(NSLocalizedString("help.item.howto.tutorial", comment: ""),
                font:WMFont.fontMyriadProLightOfSize(16),
                numberOfLines: 2,
                textColor: WMColor.dark_gray,
                padding: 12,
                align:NSTextAlignment.left)
            
            cell!.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell!
        }

        let item = self.array![0] as! [String:Any]
        let name = item["title"] as! String
        
        cell!.setValues(NSLocalizedString(name, comment: ""), font: WMFont.fontMyriadProLightOfSize(16), numberOfLines: 2, textColor: WMColor.dark_gray, padding: 12,align:NSTextAlignment.left)

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row

        if  indexPath.row  == 2 {
             //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_OPEN_RATE_APP.rawValue , label:"")
            
            let url  = URL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
            if UIApplication.shared.canOpenURL(url!) == true  {
                UIApplication.shared.openURL(url!)
            }
        }
        else  if  indexPath.row  == 0 {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_OPEN_TUTORIAL.rawValue , label:"Tutorial")
            NotificationCenter.default.post(name: Notification.Name(rawValue: CustomBarNotification.ShowHelp.rawValue), object: nil)
        } else {
            let item = self.array![0] as! [String:Any]
            if delegate != nil {
                delegate!.selectedDetail(indexPath.row, item: item)
            }
            else {
                let controller = PreviewHelpViewController()
                let name = item["title"] as! String
                controller.titleText = NSLocalizedString(name, comment: "") as NSString!
                controller.resource = item["resource"] as! String as NSString!
                controller.type = item["type"] as! String as NSString!
                //controller.actionLabel = WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue
                //controller.categoryLabel = WMGAIUtils.CATEGORY_FREQUENT_QUESTIONS.rawValue
        
                if  let imgFile = item["imgFile"] as? String{
                    controller.imgFile = imgFile as NSString?
                }
                
                //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_OPEN_QUESTIONS.rawValue , label:name)

        
                self.navigationController!.pushViewController(controller, animated: true)
            
            }
        }
        
        self.table.reloadData()
        
    }
    
    override func back() {
        //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label:"")
        super.back()
    }
    
}

