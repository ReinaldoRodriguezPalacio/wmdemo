//
//  ABCalendarPickerDelegateProtocol.h
//  ABCalendarPicker
//
//  Created by Anton Bukov on 05.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABCalendarPicker;

typedef enum {
    ABCalendarPickerStateWeekdays = 1,
    ABCalendarPickerStateDays     = 2,
    ABCalendarPickerStateMonths   = 3,
    ABCalendarPickerStateYears    = 4,
    ABCalendarPickerStateEras     = 5,
} ABCalendarPickerState;

typedef enum {
    ABCalendarPickerAnimationNone,
    ABCalendarPickerAnimationTransition,
    ABCalendarPickerAnimationZoomIn,
    ABCalendarPickerAnimationZoomOut,
    ABCalendarPickerAnimationScrollUp,
    ABCalendarPickerAnimationScrollDown,
    ABCalendarPickerAnimationScrollLeft,
    ABCalendarPickerAnimationScrollRight,
    
    ABCalendarPickerAnimationScrollDownFor6Rows = 94,
    ABCalendarPickerAnimationScrollDownFor5Rows = 95,
    ABCalendarPickerAnimationScrollDownFor4Rows = 96,
    ABCalendarPickerAnimationScrollDownFor3Rows = 97,
    ABCalendarPickerAnimationScrollDownFor2Rows = 98,
    ABCalendarPickerAnimationScrollDownFor1Rows = 99,
    ABCalendarPickerAnimationScrollUpOrDownBase = 100,
    ABCalendarPickerAnimationScrollUpFor1Rows = 101,
    ABCalendarPickerAnimationScrollUpFor2Rows = 102,
    ABCalendarPickerAnimationScrollUpFor3Rows = 103,
    ABCalendarPickerAnimationScrollUpFor4Rows = 104,
    ABCalendarPickerAnimationScrollUpFor5Rows = 105,
    ABCalendarPickerAnimationScrollUpFor6Rows = 106,
} ABCalendarPickerAnimation;

@protocol ABCalendarPickerDelegateProtocol
@optional
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
      animateNewHeight:(CGFloat)height;
- (BOOL)calendarPicker:(ABCalendarPicker*)calendarPicker
        shouldSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState;
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
          willSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState;
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
           didSetState:(ABCalendarPickerState)state
             fromState:(ABCalendarPickerState)fromState;
- (BOOL)calendarPicker:(ABCalendarPicker*)calendarPicker
       shoudSelectDate:(NSDate*)date
             withState:(ABCalendarPickerState)state;
- (void)calendarPicker:(ABCalendarPicker*)calendarPicker
          dateSelected:(NSDate*)date
             withState:(ABCalendarPickerState)state;

//SAMS
- (CGFloat) calendarPickerHeightForHeader:(ABCalendarPicker*)calendarPicker;
- (CGFloat) calendarPickerHeightForColumnHeader:(ABCalendarPicker*)calendarPicker;
- (void) calendarPicker:(ABCalendarPicker*)calendarPicker willAnimateWith:(ABCalendarPickerAnimation) animation;
@end
