//
//  UIScrollView+TPKeyboardAvoidingAdditions.h
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 30/09/2013.
//
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIScrollView (TPKeyboardAvoidingAdditions)
- (BOOL)TPKeyboardAvoiding_focusNextTextField;
- (UIView*)TPKeyboardAvoiding_focusNextTextFieldAfterView:(UIView*)lastFirstResponder;
- (void)TPKeyboardAvoiding_scrollToActiveTextField;

- (void)TPKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_updateContentInset;
- (void)TPKeyboardAvoiding_updateFromContentSizeChange;
- (void)TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view;
- (UIView*)TPKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view;
-(CGSize)TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames;

@end
