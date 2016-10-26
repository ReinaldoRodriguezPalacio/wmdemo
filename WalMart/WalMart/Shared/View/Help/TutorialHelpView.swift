//
//  TutorialHelpView.swift
//  WalMart
//
//  Created by Gerardo Ramirez on 18/05/15.
//  Copyright (c) 2015 BCG Inc. All rights reserved.
//

import Foundation

class TutorialHelpView : UIView, UIScrollViewDelegate{
    
    var onClose : (() -> Void)!
    var pointSection: UIView? = nil
    var pointContainer: UIView? = nil
    var labelTitle : UILabel! = nil
    var pointButtons: [UIButton]? = nil
    var items : [[String:String]]? = nil
    var currentItem: Int? = nil
    var scrollHelp : UIScrollView!
    var  logoImage : UIImageView!
    
    var buttonClose : UIButton!
    
    init(frame: CGRect,properties:[[String:String]]) {
        super.init(frame:frame)
        self.items = properties
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    

    func setup() {
        
        buttonClose = UIButton(frame: CGRectMake(0, 20, 44, 44))
        buttonClose.setImage(UIImage(named:"tutorial_close"), forState: UIControlState.Normal)
        buttonClose.addTarget(self, action: #selector(TutorialHelpView.removeHelp), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonClose)
        
        
        
        labelTitle = UILabel(frame: CGRectMake(30, 72, self.frame.width - 60, 44))
        labelTitle.font = WMFont.fontMyriadProLightOfSize(16)
        labelTitle.textAlignment = .Center
        labelTitle.textColor = UIColor.whiteColor()
        labelTitle.text = ""
        labelTitle.numberOfLines = 2
        self.addSubview(labelTitle)
        
        //Logo
        logoImage = UIImageView(frame: CGRectMake((self.frame.width / 2) - 55, 0, 110, 44))
        logoImage.image = UIImage(named:"navBar_logo")
        logoImage.contentMode = .Center
        self.addSubview(logoImage)
        
        scrollHelp = UIScrollView(frame:CGRectMake(0, buttonClose.frame.maxY, self.bounds.width, self.bounds.height - buttonClose.frame.maxY))
       self.addSubview(scrollHelp)
        
        self.pointSection = UIView()
        self.pointSection?.backgroundColor = UIColor.clearColor()
        self.pointSection?.frame = CGRectMake(0, self.scrollHelp.frame.maxY + 32 , self.frame.width, 20)
        self.addSubview(self.pointSection!)

        
        let first = self.items![0]
        labelTitle.text = first["details"] as String!
        self.currentItem = 0
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TutorialHelpView.removeHelp), name:"OPEN_TUTORIAL", object: nil)
    }
    
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if scrollHelp != nil && buttonClose != nil   {
            self.buildViewImages()
            
            labelTitle.frame = CGRectMake(30, 72, self.frame.width - 60, 44)
            scrollHelp.frame = CGRectMake(0, scrollHelp.frame.minY, self.bounds.width, scrollHelp.frame.height)
            logoImage.frame = CGRectMake((self.frame.width / 2) - 55, 20, 110, 44)
            pointSection?.frame = CGRectMake(0, self.scrollHelp.frame.maxY + 32 , self.frame.width, 20)
        }
    }

    
    func buildViewImages() {
        
        if buttonClose != nil {
            for imageView in scrollHelp.subviews {
                imageView.removeFromSuperview()
            }
            
            scrollHelp.delegate = self
            var currentX : CGFloat = 0.0
            var currentHeigth : CGFloat = 0.0
            for itemTutorial in self.items! {
                let imgHelp = UIImage(named:itemTutorial["image"] as String!)
                let imageForHelp = UIImageView(image: imgHelp)
                imageForHelp.contentMode = UIViewContentMode.Center
                imageForHelp.frame = CGRectMake(currentX , 0,self.frame.width , imgHelp!.size.height)
                currentHeigth = imgHelp!.size.height
                scrollHelp.addSubview(imageForHelp)
                scrollHelp.pagingEnabled = true
                currentX = currentX + self.frame.width
            }
            
            let viewFinish = UIView()
            viewFinish.frame = CGRectMake(currentX , 0,self.frame.width , 400)
            viewFinish.backgroundColor = UIColor.clearColor()
            
            
            let labelDesc = UILabel(frame: CGRectMake(30, 84, self.frame.width - 60, 44))
            labelDesc.font = WMFont.fontMyriadProLightOfSize(16)
            labelDesc.textAlignment = .Center
            labelDesc.textColor = UIColor.whiteColor()
            labelDesc.text = "Puedes consultar este Tutorial\ndesde Ayuda"
            labelDesc.numberOfLines = 2
            viewFinish.addSubview(labelDesc)
            
            let buttonFinish = UIButton(frame: CGRectMake((self.frame.width / 2) - 80, 160, 160, 36))
//            buttonFinish.setTitle("Entiendo", forState: UIControlState.Normal)
            buttonFinish.setTitle("Ok", forState: UIControlState.Normal)
            buttonFinish.layer.cornerRadius = 18
            buttonFinish.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
            buttonFinish.backgroundColor = WMColor.green
            buttonFinish.addTarget(self, action: #selector(TutorialHelpView.finishRemoveHelp), forControlEvents: UIControlEvents.TouchUpInside)
            viewFinish.addSubview(buttonFinish)

            
            scrollHelp.addSubview(viewFinish)
            currentX = currentX + self.frame.width
            
            scrollHelp.frame = CGRectMake(0, buttonClose.frame.maxY + 60, self.bounds.width, currentHeigth)
            scrollHelp.contentSize = CGSizeMake(currentX,scrollHelp.frame.height)
            scrollHelp.showsHorizontalScrollIndicator = false
            
            
            buildButtonSection()
        }
        
    }
    
    func removeHelp() {
        if onClose != nil {
              NSNotificationCenter.defaultCenter().removeObserver(self, name: "OPEN_TUTORIAL", object: nil)
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TUTORIAL_AUTH.rawValue,categoryNoAuth:WMGAIUtils.CATEGORY_TUTORIAL_NO_AUTH.rawValue , action: WMGAIUtils.ACTION_CLOSE_TUTORIAL.rawValue, label: "")
            onClose()
        }
    }
    
    func finishRemoveHelp(){
        if onClose != nil {
            //BaseController.sendAnalytics(WMGAIUtils.CATEGORY_TUTORIAL_AUTH.rawValue,categoryNoAuth: WMGAIUtils.CATEGORY_TUTORIAL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_CLOSE_END_TUTORIAL.rawValue, label: "")
            onClose()
        }
    }
    
    func buildButtonSection() {
        if let container = self.pointContainer {
            container.removeFromSuperview()
        }
        self.pointContainer = UIView()
        self.pointSection!.addSubview(self.pointContainer!)
        
        var buttons = Array<UIButton>()
        let size = self.items!.count + 1
        if size > 0 {
            let bsize: CGFloat = 8.0
            var x: CGFloat = 0.0
            let sep: CGFloat = 5.0
            for idx in 0 ..< size {
                let point = UIButton(type: .Custom)
                point.frame = CGRectMake(x, 0, bsize, bsize)
                point.setImage(UIImage(named: "control_help_inactivo"), forState: .Normal)
                point.setImage(UIImage(named: "control_help_activo"), forState: .Selected)
                point.setImage(UIImage(named: "control_help_activo"), forState: .Highlighted)
                point.addTarget(self, action: #selector(TutorialHelpView.pointSelected(_:)), forControlEvents: .TouchUpInside)
                point.selected = idx == self.currentItem!
                x = CGRectGetMaxX(point.frame)
                if idx < size {
                    x += sep
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            let pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRectMake((pbounds.size.width - x)/2,  (20.0 - bsize)/2, x, 20.0)
        }
        self.pointButtons = buttons
    }
    
    
    func pointSelected(sender:UIButton) {
        for button: UIButton in self.pointButtons! {
            button.selected = button === sender
        }
        if (self.pointButtons!).indexOf(sender) != nil {
            self.scrollHelp!.scrollRectToVisible(CGRectMake(0, 0, self.frame.width, self.scrollHelp!.frame.height), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentIndex = self.scrollHelp!.contentOffset.x / self.scrollHelp!.frame.size.width
        self.currentItem = Int(currentIndex)
        let nsarray = self.pointButtons! as NSArray
        if let button = nsarray.objectAtIndex(self.currentItem!) as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.selected = button === inner
            }
        }
        if self.items?.count == self.currentItem! {
            labelTitle!.text = ""
        } else {
            let first = self.items![self.currentItem!]
            labelTitle!.text = first["details"] as String!
        }
    }
    
}

