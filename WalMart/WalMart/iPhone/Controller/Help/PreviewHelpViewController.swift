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
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: WMGAIUtils.SCREEN_HELP_DETAIL.rawValue)
            tracker.send(GAIDictionaryBuilder.createScreenView().build())
        }
        
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
                self.titleLabel!.text = self.titleText!
            }
            
            if resource == "privacy" {
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let myFilePath = documentDirectory.stringByAppendingPathComponent("AvisoPrivacidad.pdf")
                let manager = NSFileManager.defaultManager()
                
                if (manager.fileExistsAtPath(myFilePath)) {
                    var request = NSURLRequest(URL: NSURL(fileURLWithPath: myFilePath)!)
                    self.webShowDetail.loadRequest(request)
                }
            }
            else{
                let htmlFile : NSString = NSBundle.mainBundle().pathForResource(resource, ofType: self.type)!
                
                switch self.type {
                case "html":
                    var  htmlString : NSString = NSString(contentsOfFile:htmlFile, encoding: NSUTF8StringEncoding, error: nil)!
                    
                    if imgFile != nil{
                        let imgFilePath  = NSBundle.mainBundle().pathForResource(imgFile, ofType: "jpg")
                        htmlString = htmlString.stringByReplacingOccurrencesOfString("$pathImage$", withString: imgFilePath!)
                    }
                    self.webShowDetail.loadHTMLString(htmlString, baseURL: nil)
                case "pdf":
                    let request = NSURLRequest(URL: NSURL(string: htmlFile)!)
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
        var bounds = self.view.bounds
        if self.titleText != nil  {
            self.webShowDetail!.frame =  CGRectMake(0,  self.header!.frame.maxY , bounds.width, bounds.height - self.header!.frame.maxY )
        }
        else {
            self.webShowDetail!.frame =  CGRectMake(0, 0, bounds.width, bounds.height )
        }
    }
    
}
