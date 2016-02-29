//
//  NHPCalendarPickerDateProvider.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 01.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol ABCalendarPickerDateOwner
- (NSDate*)selectedDate;
- (NSDate*)highlightedDate;
@end

@protocol ABCalendarPickerDateProviderProtocol

@property (weak,nonatomic) id<ABCalendarPickerDateOwner> dateOwner;

- (NSInteger)canDiffuse;

- (ABCalendarPickerAnimation)animationForPrev;
- (ABCalendarPickerAnimation)animationForNext;
//@optional
- (ABCalendarPickerAnimation)animationForZoomInToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider;
- (ABCalendarPickerAnimation)animationForZoomOutToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider;
//- (ABCalendarPickerAnimation)animationForZoomInFromProvider:(id<ABCalendarPickerDateProviderProtocol>)provider;
//- (ABCalendarPickerAnimation)animationForZoomOutFromProvider:(id<ABCalendarPickerDateProviderProtocol>)provider;
@optional
- (ABCalendarPickerAnimation)animationForLongPrev;
- (ABCalendarPickerAnimation)animationForLongNext;
@required

- (NSDate*)dateForPrevAnimation;
- (NSDate*)dateForNextAnimation;

@optional
- (NSDate*)dateForLongPrevAnimation;
- (NSDate*)dateForLongNextAnimation;
@required

- (NSInteger)rowsCount;
- (NSInteger)columnsCount;
- (NSString*)columnName:(NSInteger)column;
- (NSString*)titleText;

@optional
- (NSDate *)mainDateBegin;
- (NSDate *)mainDateEnd;
@required

- (NSDate*)dateForRow:(NSInteger)row andColumn:(NSInteger)column;
- (NSString*)labelForDate:(NSDate*)date;
- (UIControlState)controlStateForDate:(NSDate*)date;
- (NSString*)labelForRow:(NSInteger)row andColumn:(NSInteger)column;
- (UIControlState)controlStateForRow:(NSInteger)row andColumn:(NSInteger)column;

@property (strong,nonatomic) NSCalendar * calendar;

@end
