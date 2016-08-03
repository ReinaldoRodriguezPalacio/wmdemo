//
//  ABCalendarPickerDefaultDaysProvider.m
//  ABCalendarPicker
//
//  Created by Anton Bukov on 26.06.12.
//  Copyright (c) 2013 Anton Bukov. All rights reserved.
//

#import "CustomCalendarPickerDefaultDaysProvider.h"

@interface CustomCalendarPickerDefaultDaysProvider()
@property (strong,nonatomic) NSDateFormatter * dateFormatter;
@property (strong,nonatomic) NSDateFormatter * dateFormatterTitle;
@end

@implementation CustomCalendarPickerDefaultDaysProvider

@synthesize dateOwner = _dateOwner;
@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;
@synthesize dateFormatterTitle = _dateFormatterTitle;

- (id)init
{
    if (self = [super init])
    {
        self.calendar = [NSCalendar currentCalendar];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"ccccc";
        self.dateFormatterTitle = [[NSDateFormatter alloc] init];
//        self.dateFormatterTitle.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"LLLL yyyy" options:0 locale:[NSLocale currentLocale]];
        self.dateFormatterTitle.dateFormat = @"MMMM yyyy";
    }
    return self;
}

- (NSInteger)canDiffuse
{
    return 1;
}

- (NSDate *)mainDateBegin
{
    NSDateComponents * comps = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[self.dateOwner highlightedDate]];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)mainDateEnd
{
    NSDateComponents * comps = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[self.dateOwner highlightedDate]];
    comps.day = 1;
    
    NSDateComponents * month = [[NSDateComponents alloc] init];
    month.month = 1;

    NSDateComponents * mday = [[NSDateComponents alloc] init];
    mday.day = -1;
    
    NSDate * date = [self.calendar dateFromComponents:comps];
    date = [self.calendar dateByAddingComponents:month toDate:date options:0];
    date = [self.calendar dateByAddingComponents:mday toDate:date options:0];
    
    return date;
}

- (ABCalendarPickerAnimation)animationForPrev {
    return ABCalendarPickerAnimationScrollLeft;
}
- (ABCalendarPickerAnimation)animationForNext {
    return ABCalendarPickerAnimationScrollRight;
}
- (ABCalendarPickerAnimation)animationForZoomInToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    if (provider == nil)
        return ABCalendarPickerAnimationNone;
    return 2*ABCalendarPickerAnimationScrollUpOrDownBase - [provider animationForZoomOutToProvider:self];
}
- (ABCalendarPickerAnimation)animationForZoomOutToProvider:(id<ABCalendarPickerDateProviderProtocol>)provider {
    return ABCalendarPickerAnimationZoomOut;
}

- (ABCalendarPickerAnimation)animationForLongPrev {
    return ABCalendarPickerAnimationScrollLeft;
}
- (ABCalendarPickerAnimation)animationForLongNext {
    return ABCalendarPickerAnimationScrollRight;
}

- (NSDate*)dateForPrevAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.month = -1;
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];   
}

- (NSDate*)dateForNextAnimation
{
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.month = 1;
    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0]; 
}

//Para ocultar botones
//- (NSDate*)dateForLongPrevAnimation
//{
//    NSDateComponents * components = [[NSDateComponents alloc] init];
//    components.year = -1;
//    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];
//}

//Para ocultar botones
//- (NSDate*)dateForLongNextAnimation
//{
//    NSDateComponents * components = [[NSDateComponents alloc] init];
//    components.year = 1;
//    return [self.calendar dateByAddingComponents:components toDate:[self.dateOwner highlightedDate] options:0];
//}

- (NSInteger)rowsCount
{
    return [self.calendar rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:[self.dateOwner highlightedDate]].length;
}

- (NSInteger)columnsCount
{
    return 7;
}

- (NSString*)columnName:(NSInteger)column
{
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = column + self.calendar.firstWeekday - 1;
    NSDate * date = [self.calendar dateFromComponents:dateComponents];
    NSString * txt = [self.dateFormatter stringFromDate:date];
    txt = [txt uppercaseStringWithLocale:[NSLocale currentLocale]];
    return txt;
}

- (NSString*)titleText
{
    NSString * date = [self.dateFormatterTitle stringFromDate:[self.dateOwner highlightedDate]];
    date = [date uppercaseStringWithLocale:[NSLocale currentLocale]];
    return date;
}

- (NSDate*)dateForRow:(NSInteger)row 
            andColumn:(NSInteger)column 
{
    NSInteger index = row*7 + column + 1;
    
    NSDateComponents * comps = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:[self.dateOwner highlightedDate]];
    NSInteger highlightedDay = comps.day;
    NSInteger highlightedWeekday = comps.weekday - self.calendar.firstWeekday + 1;
    NSInteger firstWeekday = (highlightedWeekday - highlightedDay + 35)%7 + 1;
    
    comps.weekday = 0;
    //NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    comps.day = index - firstWeekday - (highlightedDay-1);
    return [self.calendar dateByAddingComponents:comps toDate:[self.dateOwner highlightedDate] options:0];
}

- (NSString*)labelForDate:(NSDate*)date
{
    NSUInteger day = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return [NSString stringWithFormat:@"%lu", (unsigned long)day, nil];
}

- (UIControlState)controlStateForDate:(NSDate*)date
{
    NSInteger currentMonth = [self.calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:date];
    NSInteger selectedMonth = [self.calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedMonth = [self.calendar ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:[self.dateOwner highlightedDate]];
    
    NSInteger currentDay = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSInteger selectedDay = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self.dateOwner selectedDate]];
    NSInteger highlightedDay = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self.dateOwner highlightedDate]];
    
    NSInteger currentYear = [self.calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:date];
    NSInteger selectedYear = [self.calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:[self.dateOwner selectedDate]];
    //NSInteger highlightedYear = [self.calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:[self.dateOwner highlightedDate]];

    //SAMS
//    NSInteger dayOfweek = [self.calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:date];
//    BOOL isWeekend = dayOfweek == 1 || dayOfweek == 7;
    
//    BOOL isDisabled = (currentMonth != highlightedMonth) || isWeekend;
    BOOL isDisabled = (currentMonth != highlightedMonth); //SAMS
    BOOL isSelected = (currentDay == selectedDay) && (currentMonth == selectedMonth) && (currentYear == selectedYear);
    BOOL isHilighted = (currentDay == highlightedDay) && (currentMonth == highlightedMonth);
    
//    return (isDisabled ? UIControlStateDisabled : 0)
//         | (isSelected ? UIControlStateSelected : 0)
//         | (isHilighted ? UIControlStateHighlighted : 0);
    return (isDisabled ? UIControlStateDisabled : 0) | (isSelected ? UIControlStateSelected : 0);
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
