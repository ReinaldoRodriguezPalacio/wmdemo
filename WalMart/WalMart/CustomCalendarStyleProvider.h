//
//  ISOLACalendarStyleProvider.h
//  ISOLAfore
//
//  Created by neftali on 10/10/13.
//  Copyright (c) 2013 ISOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABCalendarPicker.h"
#import "ABCalendarPickerStyleProviderProtocol.h"

@interface CustomCalendarStyleProvider : NSObject<ABCalendarPickerStyleProviderProtocol>

@property (strong,nonatomic) UIColor * textColor;
@property (strong,nonatomic) UIColor * textShadowColor;
@property (strong,nonatomic) UIImage * patternImageForGradientBar;

@property (strong,nonatomic) UIFont * titleFontForColumnTitlesVisible;
@property (strong,nonatomic) UIFont * titleFontForColumnTitlesInvisible;
@property (strong,nonatomic) UIFont * columnFont;
@property (strong,nonatomic) UIFont * tileTitleFont;
@property (strong,nonatomic) UIFont * tileDotFont;

- (UIControl*)calendarPicker:(ABCalendarPicker*)calendarPicker
            cellViewForTitle:(NSString*)cellTitle
                    andState:(ABCalendarPickerState)state;

- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
 postUpdateForCellView:(UIControl*)control
        onControlState:(UIControlState)controlState
            withEvents:(NSInteger)eventsCount
              andState:(ABCalendarPickerState)state;

@property (strong,nonatomic) UIImage * normalImage;
@property (strong,nonatomic) UIImage * selectedImage;
@property (strong,nonatomic) UIImage * highlightedImage;
@property (strong,nonatomic) UIImage * selectedHighlightedImage;

@property (strong,nonatomic) UIColor * normalTextColor;
@property (strong,nonatomic) UIColor * disabledTextColor;
@property (strong,nonatomic) UIColor * selectedTextColor;

@property (assign,nonatomic) NSInteger maxNumberOfDots;

- (void) clearControlPool;

@end
