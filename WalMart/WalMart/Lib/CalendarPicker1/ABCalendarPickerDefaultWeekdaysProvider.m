//
//  ABCalendarPickerDefaultWeekdaysProvider.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 06.07.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "ABCalendarPickerDefaultDaysProvider.h"
#import "ABCalendarPickerDefaultWeekdaysProvider.h"

@interface ABCalendarPickerDefaultWeekdaysProvider()
@property (strong,nonatomic) NSDateFormatter * colDateFormatter;
@property (strong,nonatomic) NSDateFormatter * dateFormatter;
@property (strong,nonatomic) ABCalendarPickerDefaultDaysProvider * daysProvider;
@end

@implementation ABCalendarPickerDefaultWeekdaysProvider

@synthesize dateOwner = _dateOwner;
@synthesize calendar = _calendar;
@synthesize colDateFormatter = _colDateFormatter;
@synthesize dateFormatter = _dateFormatter;
@synthesize daysProvider = _daysProvider;

- (ABCalendarPickerDefaultDaysProvider*)daysProvider
{
    if (_daysProvider == nil)
    {
        _daysProvider = [[ABCalendarPickerDefaultDaysProvider alloc] init];
        _daysProvider.calendar = self.calendar;
    }
    return _daysProvider;
}

- (void)setDateOwner:(id<ABCalendarPickerDateOwner>)dateOwner
{
    _dateOwner = dateOwner;
    self.daysProvider.dateOwner = dateOwner;
}

- (void)setCalendar:(NSCalendar *)calendar
{
    _calendar = calendar;
    _calendar.minimumDaysInFirstWeek = 1;
    self.daysProvider.calendar = calendar;
}

- (id)init
{
    if (self = [super init])
    {
        self.calendar = [NSCalendar currentCalendar];
        self.colDateFormatter = [[NSDateFormatter alloc] init];
        self.colDateFormatter.dateFormat = @"ccc";
        self.dateFormatter = [[NSDateFormatter alloc] init];
//        self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"d MMMM yyyy" options:0 locale:[NSLocale currentLocale]];
        self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"LLLL yyyy" options:0 locale:[NSLocale currentLocale]];
    }
    return self;
}

- (NSInteger)canDiffuse
{
    return 0;
}

- (ABCalendarPickerAnimation)animationForPrev {
    return ABCalendarPickerAnimationScrollUp;
}
- (ABCalendarPickerAnimation)animationForNext {
    return ABCalendarPickerAnimationScrollDown;
}
- (ABCalendarPickerAnimation)animationForZoomInToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    return ABCalendarPickerAnimationNone;
}
- (ABCalendarPickerAnimation)animationForZoomOutToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    NSInteger weekNumber = [self.calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:[self.dateOwner highlightedDate]];
    return ABCalendarPickerAnimationScrollUpOrDownBase - weekNumber;
}

- (NSDate*)dateForPrevAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.weekOfMonth = -1;
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];
}

- (NSDate*)dateForNextAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.weekOfMonth = 1;
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];
}

- (NSInteger)rowsCount
{
    return 1;
}

- (NSInteger)columnsCount
{
    return 7;
}

- (NSString*)columnName:(NSInteger)column
{
//    return [self.daysProvider columnName:column];
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = column + self.calendar.firstWeekday - 1;
    NSDate * date = [self.calendar dateFromComponents:dateComponents];
    return [[self.colDateFormatter stringFromDate:date] uppercaseStringWithLocale:[NSLocale currentLocale]];
}

- (NSString*)titleText
{
    return [self.dateFormatter stringFromDate:[self.dateOwner highlightedDate]];
}

- (NSDate*)dateForRow:(NSInteger)row
            andColumn:(NSInteger)column
{
    NSInteger index = column + 1 + row*7;
    NSInteger highlightedDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[self.dateOwner highlightedDate]];
    NSInteger highlightedWeekday = [self.calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[self.dateOwner highlightedDate]];
    NSInteger firstWeekday = (highlightedWeekday - highlightedDay + 35)%7 + 1;
    
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = index - firstWeekday - (highlightedDay-1);
    return [self.calendar dateByAddingComponents:dateComponents toDate:[self.dateOwner highlightedDate] options:0];
}

- (NSString*)labelForDate:(NSDate*)date
{
    NSUInteger day = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return [NSString stringWithFormat:@"%lu", (unsigned long)day, nil];
}

- (UIControlState)controlStateForDate:(NSDate*)date
{
    NSInteger currentMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    NSInteger selectedMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedMonth = [self.calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    NSInteger currentDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSInteger selectedDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    NSInteger currentYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
    NSInteger selectedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner selectedDate]];
    //NSInteger highlightedYear = [self.calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:[self.dateOwner highlightedDate]];
    
    NSInteger dayOfweek = [self.calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:date];
    BOOL isWeekend = dayOfweek == 1 || dayOfweek == 7;

    BOOL isDisabled = (currentMonth != highlightedMonth) || isWeekend;
    BOOL isSelected = (currentDay == selectedDay) && (currentMonth == selectedMonth) && (currentYear == selectedYear);
    BOOL isHilighted = (currentDay == highlightedDay) && (currentMonth == highlightedMonth);
    
    return (isDisabled ? UIControlStateDisabled : 0)
         | (isSelected ? UIControlStateSelected : 0)
         | (isHilighted ? UIControlStateHighlighted : 0);
}

- (NSString*)labelForRow:(NSInteger)row
               andColumn:(NSInteger)column
{
    return [self labelForDate:[self dateForRow:row andColumn:column]];
}

- (UIControlState)controlStateForRow:(NSInteger)row
                           andColumn:(NSInteger)column
{
    return [self controlStateForDate:[self dateForRow:row andColumn:column]];
}

@end
