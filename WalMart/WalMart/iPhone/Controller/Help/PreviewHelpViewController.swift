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
    //var actionLabel : String! = ""
    //var categoryLabel : String! = ""
    
    override func getScreenGAIName() -> String {
        return WMGAIUtils.SCREEN_FREQUENTQUESTIONS.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.titleLabel == nil {
            self.header!.removeFromSuperview()
        }
        
        self.webShowDetail = UIWebView()
        self.webShowDetail.contentMode = UIViewContentMode.scaleAspectFill
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
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                let myFilePath = documentDirectory.appendingPathComponent("AvisoPrivacidad.pdf")
                let manager = FileManager.default
                
                if (manager.fileExists(atPath: myFilePath)) {
                    let request = URLRequest(url: URL(fileURLWithPath: myFilePath))
                    self.webShowDetail.loadRequest(request)
                }
                else{
                    let filePath = Bundle.main.url(forResource: "privacy", withExtension: "pdf")
                    let request = URLRequest(url: filePath!)
                    self.webShowDetail.loadRequest(request)
                }
            }
            else{
                let htmlFile : NSString = Bundle.main.path(forResource: resource as String, ofType: self.type as String)! as NSString
                
                switch self.type {
                case "html":
                    var  htmlString : NSString = try! NSString(contentsOfFile:htmlFile as String, encoding: String.Encoding.utf8.rawValue)
                    
                    if imgFile != nil{
                        let imgFilePath  = Bundle.main.path(forResource: imgFile as? String, ofType: "jpg")
                        htmlString = htmlString.replacingOccurrences(of: "$pathImage$", with: imgFilePath!) as NSString
                    }
                    self.webShowDetail.loadHTMLString(htmlString as String, baseURL: nil)
                case "pdf":
                    let request = URLRequest(url: URL(string: htmlFile as String)!)
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
            self.webShowDetail!.frame =  CGRect(x: 0,  y: self.header!.frame.maxY , width: bounds.width, height: bounds.height - self.header!.frame.maxY )
        }
        else {
            self.webShowDetail!.frame =  CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height )
        }
    }
    
    
    override func back() {
//        if !actionLabel.isEmpty {
//            //BaseController.sendAnalytics(categoryLabel, action:actionLabel , label:"Tutorial")
//        }
        super.back()
    }
    
}
