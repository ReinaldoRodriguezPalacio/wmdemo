//
//  ISOLACalendarStyleProvider.m
//  ISOLAfore
//
//  Created by neftali on 10/10/13.
//  Copyright (c) 2013 ISOL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CustomCalendarStyleProvider.h"
#import "ABViewPool.h"
#import "UIMyButton.h"

@interface CustomCalendarStyleProvider()
@property (strong,nonatomic) ABViewPool * controlsPool;
@end

@implementation CustomCalendarStyleProvider

@synthesize maxNumberOfDots = _maxNumberOfDots;
@synthesize controlsPool = _controlsPool;

@synthesize textColor = _textColor;
@synthesize textShadowColor = _textShadowColor;
@synthesize patternImageForGradientBar = _patternImageForGradientBar;

@synthesize columnFont = _columnFont;
@synthesize tileTitleFont = _tileTitleFont;
@synthesize tileDotFont = _tileDotFont;

@synthesize normalImage = _normalImage;
@synthesize selectedImage = _selectedImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize selectedHighlightedImage = _selectedHighlightedImage;

@synthesize normalTextColor = _normalTextColor;
@synthesize disabledTextColor = _disabledTextColor;
@synthesize selectedTextColor = _selectedTextColor;


- (ABViewPool *)controlsPool
{
    if (_controlsPool == nil)
        _controlsPool = [[ABViewPool alloc] init];
    return _controlsPool;
}

- (void) clearControlPool {
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIColor *)textColor
{
    return [self normalTextColor];
}

- (void)setTextColor:(UIColor *)textColor
{
    [self setNormalTextColor:textColor];
}

- (UIColor *)textShadowColor
{
    return nil;
}

- (void)setTextShadowColor:(UIColor *)textShadowColor
{
}

- (UIFont *)titleFontForColumnTitlesVisible
{
    if (_titleFontForColumnTitlesVisible == nil)
        _titleFontForColumnTitlesVisible = [UIFont systemFontOfSize:13.0f];
    return _titleFontForColumnTitlesVisible;
}

- (UIFont *)titleFontForColumnTitlesInvisible
{
    if (_titleFontForColumnTitlesInvisible == nil)
        _titleFontForColumnTitlesInvisible = [UIFont systemFontOfSize:18.0f];
    return _titleFontForColumnTitlesInvisible;
}

- (UIFont *)columnFont
{
    if (_columnFont == nil)
        _columnFont = [UIFont fontWithName:@"Whitney-Medium" size:15.0f];
    return _columnFont;
}

- (UIFont *)tileTitleFont
{
    if (_tileTitleFont == nil)
        _tileTitleFont = [UIFont fontWithName:@"Whitney-Medium" size:21.0f];
    return _tileTitleFont;
}

- (UIFont *)tileDotFont
{
    if (_tileDotFont == nil)
        _tileDotFont = [UIFont systemFontOfSize:21.0];
    return _tileDotFont;
}

#pragma mark - Images

- (UIImage *)patternImageForGradientBar
{
    if (_patternImageForGradientBar == nil)
        _patternImageForGradientBar = [UIImage imageNamed:@"GradientBar"];
    return _patternImageForGradientBar;
}

- (UIImage *)normalImage
{
    if (_normalImage == nil)
        _normalImage = [UIImage imageNamed:@"TileNormal"];
    return _normalImage;
}

- (void)setNormalImage:(UIImage *)image
{
    _normalImage = image;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIImage *)selectedImage
{
    if (_selectedImage == nil)
        _selectedImage = [UIImage imageNamed:@"reminder_marked_day.png"];
    return _selectedImage;
}

- (void)setSelectedImage:(UIImage *)image
{
    _selectedImage = image;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIImage*)highlightedImage
{
    if (_highlightedImage == nil)
        _highlightedImage = [UIImage imageNamed:@"reminder_selected_day.png"];
    return _highlightedImage;
}

- (void)setHighlightedImage:(UIImage *)image
{
    _highlightedImage = image;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIImage*)selectedHighlightedImage
{
    if (_selectedHighlightedImage == nil)
        _selectedHighlightedImage = [UIImage imageNamed:@"reminder_selected_day.png"];
    return _selectedHighlightedImage;
}

- (void)setSelectedHighlightedImage:(UIImage *)image
{
    _selectedHighlightedImage = image;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

#pragma mark - Colors

- (UIColor *)normalTextColor
{
    if (_normalTextColor == nil)
        _normalTextColor = [self UIColorFromRGB:0x807F83];
    return _normalTextColor;
}

- (void)setNormalTextColor:(UIColor *)color
{
    _normalTextColor = color;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIColor *)disabledTextColor
{
    if (_disabledTextColor == nil)
        _disabledTextColor = [self UIColorFromRGB:0xBEC0C2];
    return _disabledTextColor;
}

- (void)setDisabledTextColor:(UIColor *)color
{
    _disabledTextColor = color;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIColor *)selectedTextColor
{
    if (_selectedTextColor == nil)
        _selectedTextColor = [self UIColorFromRGB:0x0069AA];
    return _selectedTextColor;
}

- (void)setSelectedTextColor:(UIColor *)color
{
    _selectedTextColor = color;
    [self.controlsPool clear];
    [[UIMyButton stateSizeImageDict] removeAllObjects];
}

- (UIControl*)calendarPicker:(ABCalendarPicker*)calendarPicker
            cellViewForTitle:(NSString*)cellTitle
                    andState:(ABCalendarPickerState)state
{
    UIButton * button = (UIButton *)[self.controlsPool giveExistingOrCreateNewWith:^ {
        UIButton * button = [[UIButton alloc] init];
        [[button titleLabel] setFont:[UIFont fontWithName:@"Whitney-Book" size:18]];
//        button.tileTitleFont = [UIFont fontWithName:@"Whitney-Book" size:18];
//        button.tileDotFont = [UIFont fontWithName:@"Whitney-Book" size:18];
        button.opaque = YES;
        button.userInteractionEnabled = NO;
        button.clipsToBounds = YES;
                              

        [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        [button setTitleColor:self.disabledTextColor forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [button setTitleColor:self.selectedTextColor forState:UIControlStateHighlighted];
        

        [button setBackgroundImage:self.normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.normalImage forState:UIControlStateDisabled];
        [button setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];

        //TODAY
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateDisabled | UIControlStateSelected];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        [button setBackgroundImage:self.highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setBackgroundImage:self.normalImage forState:UIControlStateDisabled | UIControlStateSelected];
        [button setBackgroundImage:self.normalImage forState:UIControlStateSelected];
//        [button setTitleColor:self.selectedTextColor forState:UIControlStateSelected | UIControlStateHighlighted];
//        [button setTitleColor:self.selectedTextColor forState:UIControlStateDisabled | UIControlStateSelected];
//        [button setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
//        [button setBackgroundImage:self.selectedHighlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
//        [button setBackgroundImage:self.selectedImage forState:UIControlStateDisabled | UIControlStateSelected];
//        [button setBackgroundImage:self.selectedImage forState:UIControlStateSelected];
        
        return button;
        
    }];
    
    //button.numberOfDots = 0;
    [button setTitle:cellTitle forState:UIControlStateNormal];
    return button;
}

- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
 postUpdateForCellView:(UIControl*)control
        onControlState:(UIControlState)controlState
            withEvents:(NSInteger)eventsCount
              andState:(ABCalendarPickerState)state
{
    if (state != ABCalendarPickerStateDays
        && state != ABCalendarPickerStateWeekdays)
        return;
    
    UIButton * button = (UIButton *)control;
    NSInteger numberOfDots = MIN(self.maxNumberOfDots,eventsCount);
//    button.numberOfDots = MIN(self.maxNumberOfDots,eventsCount);
    if (numberOfDots > 0) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:self.disabledTextColor forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [button setBackgroundImage:self.selectedImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.normalImage forState:UIControlStateDisabled];
        [button setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];
        
        //TODAY
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateDisabled | UIControlStateSelected];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        [button setBackgroundImage:self.highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setBackgroundImage:self.normalImage forState:UIControlStateDisabled | UIControlStateSelected];
        [button setBackgroundImage:self.normalImage forState:UIControlStateSelected];
        
    }
    else {
        [button setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        [button setTitleColor:self.disabledTextColor forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [button setBackgroundImage:self.normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.normalImage forState:UIControlStateDisabled];
        [button setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];
        
        //TODAY
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateDisabled | UIControlStateSelected];
        [button setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        [button setBackgroundImage:self.highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setBackgroundImage:self.normalImage forState:UIControlStateDisabled | UIControlStateSelected];
        [button setBackgroundImage:self.normalImage forState:UIControlStateSelected];
    }
}

- (UIColor*) UIColorFromRGB:(int)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

- (id)init
{
    if (self = [super init])
    {
        self.maxNumberOfDots = 1;
    }
    return self;
}

@end
