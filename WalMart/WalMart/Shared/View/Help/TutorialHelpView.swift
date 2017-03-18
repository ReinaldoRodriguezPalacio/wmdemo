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
        
        buttonClose = UIButton(frame: CGRect(x: 0, y: 20, width: 44, height: 44))
        buttonClose.setImage(UIImage(named:"tutorial_close"), for: UIControlState())
        buttonClose.addTarget(self, action: #selector(TutorialHelpView.removeHelp), for: UIControlEvents.touchUpInside)
        self.addSubview(buttonClose)
        
        
        
        labelTitle = UILabel(frame: CGRect(x: 30, y: 72, width: self.frame.width - 60, height: 44))
        labelTitle.font = WMFont.fontMyriadProLightOfSize(16)
        labelTitle.textAlignment = .center
        labelTitle.textColor = UIColor.white
        labelTitle.text = ""
        labelTitle.numberOfLines = 2
        self.addSubview(labelTitle)
        
        //Logo
        logoImage = UIImageView(frame: CGRect(x: (self.frame.width / 2) - 55, y: 0, width: 110, height: 44))
        logoImage.image = UIImage(named:"navBar_logo")
        logoImage.contentMode = .center
        self.addSubview(logoImage)
        
        scrollHelp = UIScrollView(frame:CGRect(x: 0, y: buttonClose.frame.maxY, width: self.bounds.width, height: self.bounds.height - buttonClose.frame.maxY))
       self.addSubview(scrollHelp)
        
        self.pointSection = UIView()
        self.pointSection?.backgroundColor = UIColor.clear
        self.pointSection?.frame = CGRect(x: 0, y: self.scrollHelp.frame.maxY + 32 , width: self.frame.width, height: 20)
        self.addSubview(self.pointSection!)

        
        let first = self.items![0]
        labelTitle.text = first["details"] as String!
        self.currentItem = 0
        
         NotificationCenter.default.addObserver(self, selector: #selector(TutorialHelpView.removeHelp), name:NSNotification.Name(rawValue: "OPEN_TUTORIAL"), object: nil)
    }
    
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if scrollHelp != nil && buttonClose != nil   {
            self.buildViewImages()
            
            labelTitle.frame = CGRect(x: 30, y: 72, width: self.frame.width - 60, height: 44)
            scrollHelp.frame = CGRect(x: 0, y: scrollHelp.frame.minY, width: self.bounds.width, height: scrollHelp.frame.height)
            logoImage.frame = CGRect(x: (self.frame.width / 2) - 55, y: 20, width: 110, height: 44)
            pointSection?.frame = CGRect(x: 0, y: self.scrollHelp.frame.maxY + 32 , width: self.frame.width, height: 20)
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
                imageForHelp.contentMode = UIViewContentMode.center
                imageForHelp.frame = CGRect(x: currentX , y: 0,width: self.frame.width , height: imgHelp!.size.height)
                currentHeigth = imgHelp!.size.height
                scrollHelp.addSubview(imageForHelp)
                scrollHelp.isPagingEnabled = true
                currentX = currentX + self.frame.width
            }
            
            let viewFinish = UIView()
            viewFinish.frame = CGRect(x: currentX , y: 0,width: self.frame.width , height: 400)
            viewFinish.backgroundColor = UIColor.clear
            
            
            let labelDesc = UILabel(frame: CGRect(x: 30, y: 84, width: self.frame.width - 60, height: 44))
            labelDesc.font = WMFont.fontMyriadProLightOfSize(16)
            labelDesc.textAlignment = .center
            labelDesc.textColor = UIColor.white
            labelDesc.text = "Consulta este tutorial en cualquier \nmomento desde el menú de Ayuda."
            labelDesc.numberOfLines = 2
            viewFinish.addSubview(labelDesc)
            
            let buttonFinish = UIButton(frame: CGRect(x: (self.frame.width / 2) - 80, y: 160, width: 160, height: 36))
//            buttonFinish.setTitle("Entiendo", forState: UIControlState.Normal)
            buttonFinish.setTitle("Ok", for: UIControlState())
            buttonFinish.layer.cornerRadius = 18
            buttonFinish.titleLabel?.font = WMFont.fontMyriadProRegularOfSize(14)
            buttonFinish.backgroundColor = WMColor.green
            buttonFinish.addTarget(self, action: #selector(TutorialHelpView.finishRemoveHelp), for: UIControlEvents.touchUpInside)
            viewFinish.addSubview(buttonFinish)

            
            scrollHelp.addSubview(viewFinish)
            currentX = currentX + self.frame.width
            
            scrollHelp.frame = CGRect(x: 0, y: buttonClose.frame.maxY + 60, width: self.bounds.width, height: currentHeigth)
            scrollHelp.contentSize = CGSize(width: currentX,height: scrollHelp.frame.height)
            scrollHelp.showsHorizontalScrollIndicator = false
            
            
            buildButtonSection()
        }
        
    }
    
    func removeHelp() {
        if onClose != nil {
              NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "OPEN_TUTORIAL"), object: nil)
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
                let point = UIButton(type: .custom)
                point.frame = CGRect(x: x, y: 0, width: bsize, height: bsize)
                point.setImage(UIImage(named: "control_help_inactivo"), for: UIControlState())
                point.setImage(UIImage(named: "control_help_activo"), for: .selected)
                point.setImage(UIImage(named: "control_help_activo"), for: .highlighted)
                point.addTarget(self, action: #selector(TutorialHelpView.pointSelected(_:)), for: .touchUpInside)
                point.isSelected = idx == self.currentItem!
                x = point.frame.maxX
                if idx < size {
                    x += sep
                }
                self.pointContainer!.addSubview(point)
                buttons.append(point)
            }
            let pbounds = self.pointSection!.frame
            self.pointContainer!.frame = CGRect(x: (pbounds.size.width - x)/2,  y: (20.0 - bsize)/2, width: x, height: 20.0)
        }
        self.pointButtons = buttons
    }
    
    
    func pointSelected(_ sender:UIButton) {
        for button: UIButton in self.pointButtons! {
            button.isSelected = button === sender
        }
        if (self.pointButtons!).index(of: sender) != nil {
            self.scrollHelp!.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.frame.width, height: self.scrollHelp!.frame.height), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = self.scrollHelp!.contentOffset.x / self.scrollHelp!.frame.size.width
        self.currentItem = Int(currentIndex)
        let array = self.pointButtons! as [Any]
        if let button = array[self.currentItem!] as? UIButton {
            for inner: UIButton in self.pointButtons! {
                inner.isSelected = button === inner
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

