//
//  AFFVLimitTextField.m
//  AnyfishApp
//
//  Created by anyfish03 on 15/10/15.
//  Copyright © 2015年 Anyfish. All rights reserved.
//

#import "HSLimitText.h"

#define TextViewPlaceHolderOrignX    6
#define TextViewPlaceHolderOrignY    8
#define TextViewPlaceHolderWidth     self.textView.frame.size.width
#define TextViewPlaceHolderHeight    15


@interface HSLimitText()<UITextFieldDelegate,UITextViewDelegate>
{
    NSString *contentText;
    BOOL hasText; //是否设置过文本
}

@end

@implementation HSLimitText

- (instancetype)initWithFrame:(CGRect)frame type:(TextInputType)type
{
    self.type = type;
    return [self initWithFrame:frame];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        
        
        //默认设置
        self.maxLength = UID_MAX;
        
        if(self.type == TextInputTypeTextfield){
            //初始化
            [self setupTextField];
            //添加通知
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                        name:UITextFieldTextDidChangeNotification object:self.textField];
        }else{
            //初始化
            [self setuptTextView];
            //添加通知
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                        name:UITextViewTextDidChangeNotification object:self.textView];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showKeyboard:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideKeyboard:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}


- (void)showKeyboard:(NSNotification *)notification
{
    NSDictionary *useInfo =notification.userInfo;
    if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInput:keyBordShow:userInfo:)]){
        [self.delegate limitTextLimitInput:self keyBordShow:YES userInfo:useInfo];
    }
}

- (void)hideKeyboard:(NSNotification *)notification
{
    NSDictionary *useInfo =notification.userInfo;
    if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInput:keyBordShow:userInfo:)]){
        [self.delegate limitTextLimitInput:self keyBordShow:NO userInfo:useInfo];
    }
}
- (void)setupTextField
{
    UITextField *textField = [[UITextField alloc]initWithFrame:self.bounds];
    textField.delegate = self;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor grayColor];
    textField.font = [UIFont systemFontOfSize:13.0];
    [self  addSubview:textField];
    [textField becomeFirstResponder];
    self.textField = textField;
    
    UIView  *leftView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.frame.size.height)];
    [leftView setBackgroundColor:[UIColor clearColor]];
    textField.leftView  = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    if(self.textField){
        self.textField.placeholder = placeholder;
    }else{
        if([self.textView.text isEqual:@""]  && !hasText){
            //没有文本才能展示placeHolder
            [self addLabPlaceholder];
        }
    }
}

- (void)addLabPlaceholder
{
    if(!self.labPlaceHolder){
        self.labPlaceHolder = [[UILabel alloc] init];
        self.labPlaceHolder.font = [UIFont systemFontOfSize:13.0];
        self.labPlaceHolder.textColor = [UIColor grayColor];
        [self.textView addSubview:self.labPlaceHolder];
        self.labPlaceHolder.text = self.placeholder;
        [self layoutSubviews];
    }
    self.labPlaceHolder.hidden = NO;
}

- (void)hideLabPlaceHolder
{
    self.labPlaceHolder.hidden = YES;
}

- (void)setKeyType:(UIKeyboardType)keyType
{
    _keyType = keyType;
    self.textField.keyboardType = keyType;
}

- (void)setText:(NSString *)text
{
    _text = text;
    if(self.textField){
        self.textField.text = text;
    }
    else{
        self.textView.text = text;
        hasText = YES;
        [self hideLabPlaceHolder];
    }
}

- (void)setMaxLength:(NSInteger)maxLength
{
    _maxLength = maxLength;
}

- (void)setIsBecomFirstResponder:(BOOL)isBecomFirstResponder
{
    _isBecomFirstResponder = isBecomFirstResponder;
    if(self.textField){
        if(!isBecomFirstResponder){
            [self.textField resignFirstResponder];
        }else{
            [self.textField becomeFirstResponder];
        }
    }else{
        if(!isBecomFirstResponder){
            [self.textView resignFirstResponder];
        }else{
            [self.textView becomeFirstResponder];
        }
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.textField){
        self.textField.frame= self.bounds;
    }
    if(self.textView){
        self.textView.frame = self.bounds;
    }
    if(self.labPlaceHolder){
       self.labPlaceHolder.frame = CGRectMake(TextViewPlaceHolderOrignX, TextViewPlaceHolderOrignY, TextViewPlaceHolderWidth, TextViewPlaceHolderHeight);
    }
}
- (void)setuptTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds];
    textView.backgroundColor = [UIColor whiteColor];
    textView.backgroundColor = [UIColor whiteColor];
    textView.textColor = [UIColor grayColor];
    textView.font = [UIFont systemFontOfSize:13.0];
    
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.returnKeyType = UIReturnKeyDone;
    textView.delegate = self;
    [self addSubview:textView];
    self.textView = textView;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    
    NSString *toBeString = (self.type == TextInputTypeTextfield ?self.textField.text:self.textView.text);
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [(self.type == TextInputTypeTextfield ?self.textField:self.textView) markedTextRange];
        //高亮部分
        UITextPosition *position = [(self.type == TextInputTypeTextfield ?self.textField:self.textView) positionFromPosition:selectedRange.start offset:0];
        //已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > self.maxLength) {
                if(self.type == TextInputTypeTextfield)
                    self.textField.text = [toBeString substringToIndex:self.maxLength];
                else
                    self.textView.text = [toBeString substringToIndex:self.maxLength];
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInputOverStop:)]){
                    [self.delegate limitTextLimitInputOverStop:self];
                }
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInput:text:)]){
                NSString *text;
                
                if(self.type == TextInputTypeTextfield){
                    text  = self.textField.text;
                }
                else{
                    text  = self.textView.text;
                }
                contentText = text;
                [self.delegate limitTextLimitInput:self text:text];
            }
        }
    }
    else{
        if (toBeString.length > self.maxLength) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInputOverStop:)]){
                [self.delegate limitTextLimitInputOverStop:self];
            }
            
            if(self.type == TextInputTypeTextfield)
                self.textField.text = [toBeString substringToIndex:self.maxLength];
            else
                self.textView.text = [toBeString substringToIndex:self.maxLength];
        }
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInput:text:)]){
            NSString *text;
            
            if(self.type == TextInputTypeTextfield){
                text  = self.textField.text;
            }
            else{
                text  = self.textView.text;
            }
            contentText = text;
            [self.delegate limitTextLimitInput:self text:text];
        }
    }
}


#pragma mark textField  和 textView 代理方法
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextShouldBeginEditing:)]){
        [self.delegate limitTextShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextDidBeginEditing:)]){
        [self.delegate limitTextDidBeginEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //有时键盘需要处理删除符号
    const char *str = [string UTF8String];
    if(*str == 0){
        return YES;
    }
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        int number = (int)textField.text.length;
        if(number == self.maxLength -1){
            if(string.length > 1){
                if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInputOverStop:)]){
                    [self.delegate limitTextLimitInputOverStop:self];
                    return NO;
                }
            }
        }
        if(textField.text.length > self.maxLength){
            if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInputOverStop:)]){
                [self.delegate limitTextLimitInputOverStop:self];
                return NO;
            }
        }
    }
    if([string isEqual:@"\n"]){
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}



// textView 代理方法
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextShouldBeginEditing:)]){
        [self.delegate limitTextShouldBeginEditing:self];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextDidBeginEditing:)]){
        [self.delegate limitTextDidBeginEditing:self];
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    //不为空
    if(![textView.text isEqual:@""]){
        if(self.labPlaceHolder){
            [self hideLabPlaceHolder];
        }
        
    }else{
        //为空
        if(![self.placeholder isEqual:@""] && !hasText){
            [self addLabPlaceholder];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    const char *str = [text UTF8String];
    if(*str == 0){
        return YES;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        int number = (int)textView.text.length;
        if(number == self.maxLength -1){
            if(text.length > 1){
                if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInputOverStop:)]){
                    [self.delegate limitTextLimitInputOverStop:self];
                    return NO;
                }
            }
            
        }
        if(textView.text.length > self.maxLength){
            if(self.delegate && [self.delegate respondsToSelector:@selector(limitTextLimitInputOverStop:)]){
                [self.delegate limitTextLimitInputOverStop:self];
                return NO;
            }
        }
    }
    
    if([text isEqual:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if(self.textField){
         [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        self.textField.delegate = nil;
        self.textField = nil;
    }
    if(self.textView){
          [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
           self.textView.delegate = nil;
           self.textView = nil;
    }
}
@end
