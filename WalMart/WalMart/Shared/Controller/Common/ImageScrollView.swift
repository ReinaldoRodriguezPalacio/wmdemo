//
//  ImageScrollView.swift
//  WalMart
//
//  Created by neftali on 21/08/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    var imageView: UIImageView?
    var index: Int?
    let contentModeOrig = UIViewContentMode.scaleAspectFit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageScrollView.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapRecognizer)
        
        let twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageScrollView.scrollViewTwoFingerTapped(_:)))
        twoFingerTapRecognizer.numberOfTapsRequired = 1
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        self.addGestureRecognizer(twoFingerTapRecognizer)

    }
    
    //MARK: - TapHandlers
    func scrollViewDoubleTapped(_ sender:UIGestureRecognizer) {
        if (self.zoomScale == self.maximumZoomScale) {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else {
            self.setZoomScale(self.maximumZoomScale, animated: true)
        }
    }
    
    func scrollViewTwoFingerTapped(_ sender:UIGestureRecognizer) {
        var newZoomScale:CGFloat = self.zoomScale / 1.5
        newZoomScale = max(newZoomScale, self.minimumZoomScale)
        self.setZoomScale(newZoomScale, animated: true)
    }

    //MARK: - Override layoutSubviews to center content
    override func layoutSubviews() {
        super.layoutSubviews()
        // center the image as it becomes smaller than the size of the screen
        
        let boundsSize:CGSize = self.bounds.size
        var frameToCenter:CGRect = self.imageView!.frame
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        self.imageView!.frame = frameToCenter
    }
    //MARK: - UIScrollView delegate methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView!
    }
    
    
    //MARK: - Configure scrollView to display new image (tiled or not)
    func displayImage(_ image:UIImage) {
        // clear the previous imageView
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        // make a new UIImageView for the new image
        self.imageView = UIImageView(image: image)
        self.addSubview(self.imageView!)
        
        self.contentSize = image.size
        self.setMaxMinZoomScalesForCurrentBounds()
        self.zoomScale = self.minimumZoomScale
    }
    
    func displayImageWithUrl(_ urlImage:String) {
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        self.imageView = UIImageView()
        self.addSubview(self.imageView!)

        self.imageView!.contentMode = UIViewContentMode.center
        self.imageView!.setImageWith(URL(string: urlImage), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:URLRequest!, response:HTTPURLResponse!, image:UIImage!) -> Void in
            self.imageView!.contentMode = self.contentModeOrig
            self.imageView!.image = image
            self.imageView!.frame = CGRect(x: 0.0,y: 0.0,width: image.size.width, height: image.size.height)
            self.contentSize = image.size
            self.setMaxMinZoomScalesForCurrentBounds()
            self.zoomScale = self.minimumZoomScale
            }, failure: nil)
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        let boundsSize:CGSize = self.bounds.size
        let imageSize:CGSize = self.imageView!.bounds.size
        
        // calculate min/max zoomscale
        let xScale:CGFloat = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale:CGFloat = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        let minScale:CGFloat = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        let maxScale:CGFloat = max(xScale, yScale)
//        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
//        // maximum zoom scale to 0.5.
//        var maxScale:CGFloat = 1.0 / UIScreen.mainScreen().scale
//        
//        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
//        if (minScale > maxScale) {
//            minScale = maxScale
//        }
    
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
    }
    
    //MARK: - Methods called during rotation to preserve the zoomScale and the visible portion of the image
    
    // returns the center point, in image coordinate space, to try to restore after rotation.
    func pointToCenterAfterRotation() -> CGPoint! {
        let boundsCenter:CGPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        return self.convert(boundsCenter, to: self.imageView!)
    }
    
    // returns the zoom scale to attempt to restore after rotation.
    func scaleToRestoreAfterRotation() -> CGFloat {
        var contentScale:CGFloat = self.zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if (contentScale <= self.minimumZoomScale + CGFloat(FLT_EPSILON)) {
            contentScale = 0.0
        }
        
        return contentScale
    }
    
    func maximumContentOffset() -> CGPoint {
        let contentSize:CGSize = self.contentSize
        let boundsSize:CGSize = self.bounds.size
        return CGPoint(x: contentSize.width - boundsSize.width, y: contentSize.height - boundsSize.height);
    }
    
    func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }

    func restoreCenterPoint(_ oldCenter:CGPoint, oldScale:CGFloat) {
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        self.zoomScale = min(self.maximumZoomScale, max(self.minimumZoomScale, oldScale))
        // Step 2: restore center point, first making sure it is within the allowable range.
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter:CGPoint = self.convert(oldCenter, from: self.imageView!)
        // 2b: calculate the content offset that would yield that center point
        var offset:CGPoint = CGPoint(x: boundsCenter.x - self.bounds.size.width / 2.0,
            y: boundsCenter.y - self.bounds.size.height / 2.0);
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset:CGPoint = self.maximumContentOffset()
        let minOffset:CGPoint = self.minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
        self.contentOffset = offset
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        BaseController.sendAnalytics(WMGAIUtils.CATEGORY_ZOOMPRODUCTDETAIL_AUTH.rawValue, categoryNoAuth: WMGAIUtils.CATEGORY_ZOOMPRODUCTDETAIL_NO_AUTH.rawValue, action: WMGAIUtils.ACTION_ZOMMIMAGE_PRODUCTDETAIL.rawValue, label: "")
    }
    
}
