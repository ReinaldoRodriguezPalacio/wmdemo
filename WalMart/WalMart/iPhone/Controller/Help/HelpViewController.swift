//
//  HelpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 30/09/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation


protocol HelpViewControllerDelegate {
    func selectedDetail(row:Int, item: NSDictionary)
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
        self.table.registerClass(HelpViewCell.self, forCellReuseIdentifier: "labelCell")
        
        self.table?.backgroundColor = UIColor.whiteColor()
        
        self.table.separatorStyle = .None
        self.table.autoresizingMask = UIViewAutoresizing.None
        self.titleLabel!.text = NSLocalizedString("moreoptions.title.Help", comment: "")
        
        let filePath =  NSBundle.mainBundle().pathForResource("help", ofType: "json")
        let jsonData: NSData?
        do {
            jsonData = try NSData(contentsOfFile:filePath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch {
            jsonData = nil
        }
        let resultArray = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments)) as! NSArray
        
        array = resultArray
        
        self.view.addSubview(self.table!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        self.table!.frame =  CGRectMake(0,  self.header!.frame.maxY , bounds.width, bounds.height - self.header!.frame.maxY )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    *@method: Obtain the number of rows for table view
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.array!.count + 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height: CGFloat = 46
        return height
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.setSelected(indexPath.row == selected, animated: false)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath) as? HelpViewCell
        

        
        if indexPath.row == 2  {
            cell!.setValues(NSLocalizedString("help.item.terms.qualifies", comment: ""),
                font:WMFont.fontMyriadProLightOfSize(16),
                numberOfLines: 2,
                textColor: WMColor.dark_gray,
                padding: 12,
                align:NSTextAlignment.Left)
            
            cell!.selectionStyle = UITableViewCellSelectionStyle.None

            return cell!
        }
        if  indexPath.row  == 0 {
            cell!.setValues(NSLocalizedString("help.item.howto.tutorial", comment: ""),
                font:WMFont.fontMyriadProLightOfSize(16),
                numberOfLines: 2,
                textColor: WMColor.dark_gray,
                padding: 12,
                align:NSTextAlignment.Left)
            
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell!
        }

        let item = self.array![0] as! NSDictionary
        let name = item["title"] as! String
        
        cell!.setValues(NSLocalizedString(name, comment: ""), font: WMFont.fontMyriadProLightOfSize(16), numberOfLines: 2, textColor: WMColor.dark_gray, padding: 12,align:NSTextAlignment.Left)

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = indexPath.row

        if  indexPath.row  == 2 {
             BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_OPEN_RATE_APP.rawValue , label:"")
            
            let url  = NSURL(string: "itms-apps://itunes.apple.com/mx/app/walmart-mexico/id823947897?mt=8")
            if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                UIApplication.sharedApplication().openURL(url!)
            }
        }
        else  if  indexPath.row  == 0 {
            BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_OPEN_TUTORIAL.rawValue , label:"Tutorial")
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ClearSearch.rawValue, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.CloseShoppingCart.rawValue, object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName(CustomBarNotification.ShowHelp.rawValue, object: nil)
        } else {
            let item = self.array![0] as! NSDictionary
            if delegate != nil {
                delegate!.selectedDetail(indexPath.row, item: item)
            }
            else {
                let controller = PreviewHelpViewController()
                let name = item["title"] as! String
                controller.titleText = NSLocalizedString(name, comment: "")
                controller.resource = item["resource"] as! String
                controller.type = item["type"] as! String
                controller.actionLabel = WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue
                controller.categoryLabel = WMGAIUtils.CATEGORY_FREQUENT_QUESTIONS.rawValue
        
                if  let imgFile = item["imgFile"] as? String{
                    controller.imgFile = imgFile
                }
                
                BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_OPEN_QUESTIONS.rawValue , label:name)

        
                self.navigationController!.pushViewController(controller, animated: true)
            
            }
        }
        
        self.table.reloadData()
        
    }
    
    override func back() {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_HOW_TO_USE_THE_APP.rawValue, action:WMGAIUtils.ACTION_BACK_TO_MORE_OPTIONS.rawValue , label:"")
        super.back()
    }
    
}

