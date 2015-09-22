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
    let contentModeOrig = UIViewContentMode.ScaleAspectFit
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self

        var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapRecognizer)
        
        var twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewTwoFingerTapped:")
        twoFingerTapRecognizer.numberOfTapsRequired = 1
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        self.addGestureRecognizer(twoFingerTapRecognizer)

    }
    
    //MARK: - TapHandlers
    func scrollViewDoubleTapped(sender:UIGestureRecognizer) {
        if (self.zoomScale == self.maximumZoomScale) {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else {
            self.setZoomScale(self.maximumZoomScale, animated: true)
        }
    }
    
    func scrollViewTwoFingerTapped(sender:UIGestureRecognizer) {
        var newZoomScale:CGFloat = self.zoomScale / 1.5
        newZoomScale = max(newZoomScale, self.minimumZoomScale)
        self.setZoomScale(newZoomScale, animated: true)
    }

    //MARK: - Override layoutSubviews to center content
    override func layoutSubviews() {
        super.layoutSubviews()
        // center the image as it becomes smaller than the size of the screen
        
        var boundsSize:CGSize = self.bounds.size
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
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView!
    }
    
    
    //MARK: - Configure scrollView to display new image (tiled or not)
    func displayImage(image:UIImage) {
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
    
    func displayImageWithUrl(urlImage:String) {
        self.imageView?.removeFromSuperview()
        self.imageView = nil
        
        self.imageView = UIImageView()
        self.addSubview(self.imageView!)

        self.imageView!.contentMode = UIViewContentMode.Center
        self.imageView!.setImageWithURL(NSURL(string: urlImage), placeholderImage: UIImage(named:"img_default_cell"), success: { (request:NSURLRequest!, response:NSHTTPURLResponse!, image:UIImage!) -> Void in
            self.imageView!.contentMode = self.contentModeOrig
            self.imageView!.image = image
            self.imageView!.frame = CGRectMake(0.0,0.0,image.size.width, image.size.height)
            self.contentSize = image.size
            self.setMaxMinZoomScalesForCurrentBounds()
            self.zoomScale = self.minimumZoomScale
            }, failure: nil)
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        var boundsSize:CGSize = self.bounds.size
        var imageSize:CGSize = self.imageView!.bounds.size
        
        // calculate min/max zoomscale
        var xScale:CGFloat = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        var yScale:CGFloat = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        var minScale:CGFloat = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
        var maxScale:CGFloat = max(xScale, yScale)
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
        var boundsCenter:CGPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        return self.convertPoint(boundsCenter, toView: self.imageView!)
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
        var contentSize:CGSize = self.contentSize
        var boundsSize:CGSize = self.bounds.size
        return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
    }
    
    func minimumContentOffset() -> CGPoint {
        return CGPointZero
    }

    func restoreCenterPoint(oldCenter:CGPoint, oldScale:CGFloat) {
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        self.zoomScale = min(self.maximumZoomScale, max(self.minimumZoomScale, oldScale))
        // Step 2: restore center point, first making sure it is within the allowable range.
        // 2a: convert our desired center point back to our own coordinate space
        var boundsCenter:CGPoint = self.convertPoint(oldCenter, fromView: self.imageView!)
        // 2b: calculate the content offset that would yield that center point
        var offset:CGPoint = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
            boundsCenter.y - self.bounds.size.height / 2.0);
        // 2c: restore offset, adjusted to be within the allowable range
        var maxOffset:CGPoint = self.maximumContentOffset()
        var minOffset:CGPoint = self.minimumContentOffset()
        offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
        offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
        self.contentOffset = offset
    }

}
