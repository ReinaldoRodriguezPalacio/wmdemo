//
//  TPKeyboardAvoidingScrollView.m
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingScrollView.h"



@interface TPKeyboardAvoidingScrollView () <UITextFieldDelegate, UITextViewDelegate,UIScrollViewDelegate>
@property (nonatomic,strong)UITextField * label;

@end

@implementation TPKeyboardAvoidingScrollView
@synthesize mapValues = _mapValues;

@synthesize dataSource;
@synthesize scrollDelegate;


#pragma mark - Setup/Teardown

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    self.mapValues = [[NSMutableDictionary alloc] init];
    return self;
}

-(void)awakeFromNib {
    [self setup];
    

}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self TPKeyboardAvoiding_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self TPKeyboardAvoiding_updateFromContentSizeChange];
}

- (void)contentSizeToFit {
    self.contentSize = [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
}

- (BOOL)focusNextTextField {
    return [self TPKeyboardAvoiding_focusNextTextField];
    
}
- (void)scrollToActiveTextField {
    return [self TPKeyboardAvoiding_scrollToActiveTextField];
}

-(CGSize)TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames{
    if(scrollDelegate != nil) {
        return [scrollDelegate contentSizeForScrollView:self];
    }
    return [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
}

#pragma mark - Responders, events

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self TPKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {//qyui
       [textField resignFirstResponder];
       
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _label = textField;
    if(scrollDelegate != nil) {
        if  ([scrollDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
             return [scrollDelegate textFieldDidBeginEditingTP:textField];
    }
    [self scrollToActiveTextField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(scrollDelegate != nil) {
        return [scrollDelegate textFieldDidEndEditingTP:textField];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self scrollToActiveTextField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.delegate = self;


    return YES;
    
}


- (BOOL)textField:(UITextField *)textfield shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(scrollDelegate != nil) {
        if  ([scrollDelegate respondsToSelector:@selector(textModify:)])
            [scrollDelegate textModify:textfield];
    }
    return YES;
}



#pragma mark - TextFieldPickerDelegate


-(void)nextFirtsResponder:(UITextField*)field{
   
}






-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

@end
