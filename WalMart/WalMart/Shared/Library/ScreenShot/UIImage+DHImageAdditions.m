//
//  UIImage+ImageFromArrayUtils.m
//  TableViewScreenshots
//
//  Created by Hernandez Alvarez, David on 11/28/13.
//  Copyright (c) 2013 David Hernandez. All rights reserved.
//

#import "UIImage+DHImageAdditions.h"


@implementation UIImage (Crop)

- (UIImage *)crop:(CGRect)rect {
    
    rect = CGRectMake(rect.origin.x*self.scale,
                      rect.origin.y*self.scale,
                      rect.size.width*self.scale,
                      rect.size.height*self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end

@implementation UIImage (DHImageUtils)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIImage *image;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) return nil;
        
        [color set];
        CGContextFillRect(context, CGRectMake(0.f, 0.f, size.width, size.height));
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
	
    return image;
}


+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius
{
    UIImage *image;
    @autoreleasepool {
        // create image sized context
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //Bg coloe
        [color setFill];
        
        // add rounded rect clipping path to context using radius
        CGRect imageBounds = CGRectMake(0, 0, size.width, size.height);
        UIBezierPath *oPath = [UIBezierPath bezierPathWithRoundedRect:imageBounds cornerRadius:radius];
        [oPath fill];
        CGPathRef clippingPath = oPath.CGPath;
        CGContextAddPath(context, clippingPath);
        CGContextClip(context);
        
        // get the image
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return image;
}

+ (UIImage *)imageFromView:(UIView *)view
{
    UIImage *image;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) return nil;
        
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return image;
}

+ (UIImage *)imageFromView:(UIView *)view  size:(CGSize)size;
{
    UIImage *image;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context == NULL) return nil;
        
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return image;
}


@end

@implementation UIImage (DHImageFromArrayUtils)



+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray andWidth:(CGFloat)width
{
    UIImage *unifiedImage = nil;
    CGSize totalImageSize = [self verticalAppendedTotalImageSizeFromImagesArray:imagesArray];
    UIGraphicsBeginImageContextWithOptions(totalImageSize, NO, 0.f);
    // For each image found in the array, create a new big image vertically
    int imageOffsetFactor = 0;
    for (UIImage *img in imagesArray) {
        [img drawInRect:CGRectMake(0, imageOffsetFactor, width, img.size.height)];
        imageOffsetFactor += img.size.height;
    }
    
    unifiedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return unifiedImage;
}


+ (UIImage *)verticalImageFromArrayProdDetail:(NSArray *)imagesArray
{
    UIImage *unifiedImage = nil;
    CGSize totalImageSize = [self verticalAppendedTotalImageSizeFromImagesArray:imagesArray];
    CGFloat totalHeigth = 0;
    int imageSizeFactor = 0;
    for (UIImage *img in imagesArray) {
        if(imageSizeFactor == 0){
            imageSizeFactor = img.size.width;
            totalHeigth += img.size.height;
        }else{
            CGFloat height = (imageSizeFactor * img.size.height) / img.size.width;
            totalHeigth += height;
        }
    }
    
    totalImageSize = CGSizeMake(totalImageSize.width, totalHeigth);
    UIGraphicsBeginImageContextWithOptions(totalImageSize, NO, 0.f);
    // For each image found in the array, create a new big image vertically
    int imageOffsetFactor = 0;
    imageSizeFactor = 0;
    for (UIImage *img in imagesArray) {
        if(imageSizeFactor == 0){
            [img drawAtPoint:CGPointMake(0, imageOffsetFactor)];
            imageOffsetFactor += img.size.height;
            imageSizeFactor = img.size.width;
        }else{
            CGFloat height = (imageSizeFactor * img.size.height) / img.size.width;
            [img drawInRect:CGRectMake(0, imageOffsetFactor, imageSizeFactor, height)];
            imageOffsetFactor += height;
        }
    }
    
    unifiedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return unifiedImage;
}


+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray
{
	UIImage *unifiedImage = nil;
	CGSize totalImageSize = [self verticalAppendedTotalImageSizeFromImagesArray:imagesArray];
	UIGraphicsBeginImageContextWithOptions(totalImageSize, NO, 0.f);
	// For each image found in the array, create a new big image vertically
	int imageOffsetFactor = 0;
    int imageSizeFactor = 0;
	for (UIImage *img in imagesArray) {
        [img drawAtPoint:CGPointMake(0, imageOffsetFactor)];
        imageOffsetFactor += img.size.height;
        imageSizeFactor = img.size.width;
      
	}
	
	unifiedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	return unifiedImage;
}

+ (CGSize)verticalAppendedTotalImageSizeFromImagesProdDetailArray:(NSArray *)imagesArray
{
    CGSize totalSize = CGSizeZero;
    for (UIImage *im in imagesArray) {
        CGSize imSize = [im size];
        totalSize.height += imSize.height;
        // The total width is gonna be always the wider found on the array
        totalSize.width = MAX(totalSize.width, imSize.width);
    }
    return totalSize;
}


+ (CGSize)verticalAppendedTotalImageSizeFromImagesArray:(NSArray *)imagesArray
{
	CGSize totalSize = CGSizeZero;
	for (UIImage *im in imagesArray) {
		CGSize imSize = [im size];
		totalSize.height += imSize.height;
		// The total width is gonna be always the wider found on the array
		totalSize.width = MAX(totalSize.width, imSize.width);
	}
	return totalSize;
}

@end
