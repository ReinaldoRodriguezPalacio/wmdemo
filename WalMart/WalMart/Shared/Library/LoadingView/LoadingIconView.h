//
//  LoadingIconView.h
//  WalMart
//
//  Created by Gerardo Ramirez on 9/12/14.
//  Copyright (c) 2014 BCG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingIconView : UIView

@property (readwrite, nonatomic, assign) bool _isAnnimating;

-(void)startAnnimating;
-(void)stopAnnimating;

@end
