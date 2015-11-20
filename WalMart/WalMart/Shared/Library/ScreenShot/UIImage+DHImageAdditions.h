//
//  UIImage+ImageFromArrayUtils.h
//  TableViewScreenshots
//
//  Created by Hernandez Alvarez, David on 11/28/13.
//  Copyright (c) 2013 David Hernandez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)crop:(CGRect)rect;

@end

@interface UIImage (DHImageUtils)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageFromView:(UIView *)view;
+ (UIImage *)imageFromView:(UIView *)view  size:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight;

@end

@interface UIImage (DHImageFromArrayUtils)

+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray;
+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray andWidth:(CGFloat)width;
+ (UIImage *)verticalImageFromArrayProdDetail:(NSArray *)imagesArray;


@end
