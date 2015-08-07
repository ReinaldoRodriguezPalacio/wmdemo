//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@protocol TPKeyboardAvoidingScrollViewDelegate <NSObject>

@optional -(CGSize)contentSizeForScrollView:(id)sender;
@optional -(void)textFieldDidEndEditingTP:(UITextField *)sender;
@optional -(void)textFieldDidBeginEditingTP:(UITextField *)sender;
@optional -(void)textModify:(UITextField *)sender;
@end


@interface TPKeyboardAvoidingScrollView : UIScrollView
- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@property (nonatomic, strong) UIPopoverController *answerPickerPopover;
@property (nonatomic,strong) NSMutableDictionary* mapValues;
@property (nonatomic, assign)   id <UITableViewDataSource> dataSource;
@property (nonatomic, assign)   id <TPKeyboardAvoidingScrollViewDelegate> scrollDelegate;




@end


