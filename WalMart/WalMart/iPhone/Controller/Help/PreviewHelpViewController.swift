//
//  PreviewHelpViewController.swift
//  WalMart
//
//  Created by Everardo Trejo Garcia on 02/10/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import Foundation

class PreviewHelpViewController: NavigationViewController,UIScrollViewDelegate {
    var webShowDetail: UIWebView!
    var titleText: NSString!
    var resource: NSString!
    var type: NSString!
    var imgFile : NSString? = nil
    var showTitle : Bool? = true
    var actionLabel : String! = ""
    var categoryLabel : String! = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_FREQUENTQUESTIONS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if self.titleLabel == nil {
            self.header!.removeFromSuperview()
        }
        
        self.webShowDetail = UIWebView()
        self.webShowDetail.contentMode = UIViewContentMode.ScaleAspectFill
        self.webShowDetail!.scalesPageToFit = true
        self.webShowDetail.scrollView.delegate = self
        self.view.addSubview(webShowDetail)
        self.loadPreview()
    }

    func loadPreview () {
        if self.type != nil {
            if self.titleText != nil {
                self.titleLabel!.text = self.titleText! as String
            }
            
            if resource == "privacy" {
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                let myFilePath = documentDirectory.stringByAppendingPathComponent("AvisoPrivacidad.pdf")
                let manager = NSFileManager.defaultManager()
                
                if (manager.fileExistsAtPath(myFilePath)) {
                    let request = NSURLRequest(URL: NSURL(fileURLWithPath: myFilePath))
                    self.webShowDetail.loadRequest(request)
                }
                else{
                    let filePath = NSBundle.mainBundle().URLForResource("privacy", withExtension: "pdf")
                    let request = NSURLRequest(URL: filePath!)
                    self.webShowDetail.loadRequest(request)
                }
            }
            else{
                let htmlFile : NSString = NSBundle.mainBundle().pathForResource(resource as String, ofType: self.type as String)!
                
                switch self.type {
                case "html":
                    var  htmlString : NSString = try! NSString(contentsOfFile:htmlFile as String, encoding: NSUTF8StringEncoding)
                    
                    if imgFile != nil{
                        let imgFilePath  = NSBundle.mainBundle().pathForResource(imgFile as? String, ofType: "jpg")
                        htmlString = htmlString.stringByReplacingOccurrencesOfString("$pathImage$", withString: imgFilePath!)
                    }
                    self.webShowDetail.loadHTMLString(htmlString as String, baseURL: nil)
                case "pdf":
                    let request = NSURLRequest(URL: NSURL(string: htmlFile as String)!)
                    self.webShowDetail.loadRequest(request)
                default :
                    break
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let bounds = self.view.bounds
        if self.titleText != nil  {
            self.webShowDetail!.frame =  CGRectMake(0,  self.header!.frame.maxY , bounds.width, bounds.height - self.header!.frame.maxY )
        }
        else {
            self.webShowDetail!.frame =  CGRectMake(0, 0, bounds.width, bounds.height )
        }
    }
    
    
    override func back() {
        if !actionLabel.isEmpty {
            //BaseController.sendAnalytics(categoryLabel, action:actionLabel , label:"Tutorial")
        }
        super.back()
    }
    
}
