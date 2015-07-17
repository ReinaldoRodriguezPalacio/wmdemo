//
//  LoadingIconView.m
//  WalMart
//
//  Created by Gerardo Ramirez on 9/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

#import "LoadingIconView.h"


@interface LoadingIconView ()
@property (readwrite, nonatomic, strong) UIColor *_yellowColor;
@property (readwrite, nonatomic, strong) UIColor *_grayColor;
@property (readwrite, nonatomic, assign) int _index;
@property (readwrite, nonatomic, assign) double _speed;

@property (readwrite, nonatomic, assign) bool _needsToDraw;
@property (readwrite, nonatomic, strong) NSTimer* _timmer;
@end


@implementation LoadingIconView

@synthesize _yellowColor = yellowColor;
@synthesize _grayColor = grayColor;
@synthesize _index = index;
@synthesize _isAnnimating = isAnnimating;
@synthesize _speed = speed;
@synthesize _needsToDraw = needsToDraw;
@synthesize _timmer = timmer;



-(void)startAnnimating {
    
    self.backgroundColor = self.superview.backgroundColor;
    
    yellowColor = [UIColor colorWithRed: 1 green: 0.709 blue: 0 alpha: 1];
    grayColor = [UIColor colorWithRed: 0.89 green: 0.89 blue: 0.898 alpha: 1];
    speed = 0.15;
    isAnnimating = YES;
    needsToDraw = YES;
    if(timmer != NULL) {
        [timmer invalidate];
    }
    timmer = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(nextStep) userInfo:nil repeats:YES];
    
    [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:speed];
}


-(void)stopAnnimating {
    isAnnimating = NO;
}

-(void)drawRect:(CGRect)rect {
    
    if(needsToDraw){
        UIColor *colorOne = yellowColor;
        UIColor *colorTwo = yellowColor;
        UIColor *colorThree = yellowColor;
        UIColor *colorFour = yellowColor;
        UIColor *colorFive = yellowColor;
        UIColor *colorSix = yellowColor;
        
        if(index == 0){
            colorFive = grayColor;
            colorSix = grayColor;
        }
        if(index == 1){
            colorSix = grayColor;
            colorOne = grayColor;
        }
        if(index == 2){
            colorOne = grayColor;
            colorTwo = grayColor;
        }
        if(index == 3){
            colorTwo = grayColor;
            colorThree = grayColor;
        }
        if(index == 4){
            colorThree = grayColor;
            colorFour = grayColor;
        }
        if(index == 5){
            colorFour = grayColor;
            colorFive = grayColor;
        }
        
        
        UIColor* fillColor = colorOne;
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint: CGPointMake(57,52)];
        [path addCurveToPoint: CGPointMake(59,50) controlPoint1: CGPointMake(58,52) controlPoint2: CGPointMake(59,51)];
        [path addLineToPoint: CGPointMake(60,38)];
        [path addCurveToPoint: CGPointMake(57,36) controlPoint1: CGPointMake(60,37) controlPoint2: CGPointMake(59,36)];
        [path addCurveToPoint: CGPointMake(54,38) controlPoint1: CGPointMake(55,36) controlPoint2: CGPointMake(54,37)];
        [path addLineToPoint: CGPointMake(55,50)];
        [path addCurveToPoint: CGPointMake(57,52) controlPoint1: CGPointMake(55,51) controlPoint2: CGPointMake(56,52)];
        [path addLineToPoint: CGPointMake(57,52)];
        [path addLineToPoint: CGPointMake(57,52)];
        [fillColor setFill];
        [path fill];
        
        UIColor* fillColor1 = colorTwo;
        UIBezierPath* path1 = [UIBezierPath bezierPath];
        [path1 moveToPoint: CGPointMake(64,56)];
        [path1 addCurveToPoint: CGPointMake(66,57) controlPoint1: CGPointMake(64,57) controlPoint2: CGPointMake(65,57)];
        [path1 addLineToPoint: CGPointMake(77,51)];
        [path1 addCurveToPoint: CGPointMake(78,47) controlPoint1: CGPointMake(78,51) controlPoint2: CGPointMake(79,49)];
        [path1 addCurveToPoint: CGPointMake(74,46) controlPoint1: CGPointMake(77,46) controlPoint2: CGPointMake(75,45)];
        [path1 addLineToPoint: CGPointMake(64,53)];
        [path1 addCurveToPoint: CGPointMake(64,56) controlPoint1: CGPointMake(63,54) controlPoint2: CGPointMake(63,55)];
        [path1 addLineToPoint: CGPointMake(64,56)];
        [path1 addLineToPoint: CGPointMake(64,56)];
        [fillColor1 setFill];
        [path1 fill];
        
        UIColor* fillColor3 = colorThree;
        UIBezierPath* path3 = [UIBezierPath bezierPath];
        [path3 moveToPoint: CGPointMake(64,63)];
        [path3 addCurveToPoint: CGPointMake(66,62) controlPoint1: CGPointMake(64,62) controlPoint2: CGPointMake(65,62)];
        [path3 addLineToPoint: CGPointMake(77,68)];
        [path3 addCurveToPoint: CGPointMake(78,72) controlPoint1: CGPointMake(78,68) controlPoint2: CGPointMake(79,70)];
        [path3 addCurveToPoint: CGPointMake(74,73) controlPoint1: CGPointMake(77,73) controlPoint2: CGPointMake(75,74)];
        [path3 addLineToPoint: CGPointMake(64,66)];
        [path3 addCurveToPoint: CGPointMake(64,63) controlPoint1: CGPointMake(63,65) controlPoint2: CGPointMake(63,64)];
        [path3 addLineToPoint: CGPointMake(64,63)];
        [path3 addLineToPoint: CGPointMake(64,63)];
        [fillColor3 setFill];
        [path3 fill];
        
        UIColor* fillColor2 = colorFour;
        UIBezierPath* path2 = [UIBezierPath bezierPath];
        [path2 moveToPoint: CGPointMake(57,67)];
        [path2 addCurveToPoint: CGPointMake(59,69) controlPoint1: CGPointMake(58,67) controlPoint2: CGPointMake(59,68)];
        [path2 addLineToPoint: CGPointMake(60,81)];
        [path2 addCurveToPoint: CGPointMake(57,84) controlPoint1: CGPointMake(60,82) controlPoint2: CGPointMake(59,84)];
        [path2 addCurveToPoint: CGPointMake(54,81) controlPoint1: CGPointMake(55,84) controlPoint2: CGPointMake(54,82)];
        [path2 addLineToPoint: CGPointMake(55,69)];
        [path2 addCurveToPoint: CGPointMake(57,67) controlPoint1: CGPointMake(55,68) controlPoint2: CGPointMake(56,67)];
        [path2 addLineToPoint: CGPointMake(57,67)];
        [path2 addLineToPoint: CGPointMake(57,67)];
        [fillColor2 setFill];
        [path2 fill];
        
        UIColor* fillColor5 = colorFive;
        UIBezierPath* path5 = [UIBezierPath bezierPath];
        [path5 moveToPoint: CGPointMake(50,63)];
        [path5 addCurveToPoint: CGPointMake(50,66) controlPoint1: CGPointMake(51,64) controlPoint2: CGPointMake(51,65)];
        [path5 addLineToPoint: CGPointMake(40,73)];
        [path5 addCurveToPoint: CGPointMake(36,72) controlPoint1: CGPointMake(39,74) controlPoint2: CGPointMake(37,73)];
        [path5 addCurveToPoint: CGPointMake(36,68) controlPoint1: CGPointMake(35,70) controlPoint2: CGPointMake(35,68)];
        [path5 addLineToPoint: CGPointMake(48,62)];
        [path5 addCurveToPoint: CGPointMake(50,63) controlPoint1: CGPointMake(49,62) controlPoint2: CGPointMake(50,62)];
        [path5 addLineToPoint: CGPointMake(50,63)];
        [path5 addLineToPoint: CGPointMake(50,63)];
        [fillColor5 setFill];
        [path5 fill];
        
        UIColor* fillColor4 = colorSix;
        UIBezierPath* path4 = [UIBezierPath bezierPath];
        [path4 moveToPoint: CGPointMake(50,56)];
        [path4 addCurveToPoint: CGPointMake(50,53) controlPoint1: CGPointMake(51,55) controlPoint2: CGPointMake(51,54)];
        [path4 addLineToPoint: CGPointMake(40,46)];
        [path4 addCurveToPoint: CGPointMake(36,47) controlPoint1: CGPointMake(39,45) controlPoint2: CGPointMake(37,46)];
        [path4 addCurveToPoint: CGPointMake(36,51) controlPoint1: CGPointMake(35,49) controlPoint2: CGPointMake(35,51)];
        [path4 addLineToPoint: CGPointMake(48,57)];
        [path4 addCurveToPoint: CGPointMake(50,56) controlPoint1: CGPointMake(49,57) controlPoint2: CGPointMake(50,57)];
        [path4 addLineToPoint: CGPointMake(50,56)];
        [path4 addLineToPoint: CGPointMake(50,56)];
        [fillColor4 setFill];
        [path4 fill];
        
    }
    
}

-(void)nextStep {
    needsToDraw = YES;
    if(index == 5){
        index = 0;
    }else{
        index = index + 1;
    }
    [self setNeedsDisplay];
}




@end
