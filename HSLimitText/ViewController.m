//
//  ViewController.m
//  HSLimitText
//
//  Created by anyfish03 on 15/12/18.
//  Copyright © 2015年 hslimitText. All rights reserved.
//

#import "ViewController.h"
#import "HSLimitText.h"


#define textLength     10
#define textViewLength 30
@interface ViewController ()<HSLimitTextDelegate>
@property (nonatomic, weak) UILabel *labTextFieldCount;  ///< textField字数限制
@property (nonatomic, strong)UILabel *labTextViewCount ;  ///<textView
@property (nonatomic, weak) HSLimitText *textField;  ///< textField
@property (nonatomic, weak) HSLimitText *textView;  ///< textView

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    HSLimitText *textField = [[HSLimitText alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 50, 200, 44) type:TextInputTypeTextfield];
    [textField setBackgroundColor:[UIColor greenColor]];
    textField.delegate = self;
    textField.placeholder = @"最大输入10个字符";
    textField.maxLength = 10;
    textField.isBecomFirstResponder = YES;
    [self.view addSubview:textField];
    self.textField = textField;
    
    CGRect frame = CGRectMake(CGRectGetMaxX(textField.frame) - 50, CGRectGetMaxY(textField.frame) + 10, 50, 40);
    UILabel *labCount = [[UILabel alloc] initWithFrame:frame];
    labCount.text = @"0/10";
    labCount.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:labCount];
    self.labTextFieldCount = labCount;
    
    frame.origin.y = CGRectGetMaxY(frame);
    frame.origin.x = (self.view.frame.size.width - 200)/2;
    frame.size.height = 100;
    frame.size.width = 200;
    HSLimitText *textView = [[HSLimitText alloc] initWithFrame:frame type:TextInputTypeTextView];
    textView.placeholder = @"这是一个自定义place(label)";
    textView.text = @"输入";
    textView.labPlaceHolder.textColor = [UIColor redColor];
    textView.delegate = self;
    textView.maxLength = textViewLength;
    [self.view addSubview:textView];
    self.textView = textView;
    
    frame = CGRectMake(CGRectGetMaxX(textView.frame) - 50, CGRectGetMaxY(textView.frame) + 10, 50, 40);
    labCount = [[UILabel alloc] initWithFrame:frame];
    labCount.text = @"0/30";
    labCount.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:labCount];
    self.labTextViewCount = labCount;
}

- (void)limitTextLimitInputOverStop:(HSLimitText *)textLimitInput
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"超出字数" message:@"超出字数限制" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

- (void)limitTextLimitInput:(HSLimitText *)textLimitInput text:(NSString *)text
{
    if([textLimitInput isEqual:self.textField]){
         self.labTextFieldCount.text = [NSString stringWithFormat:@"%d/%d",(int)text.length,textLength];
    }
    else{
        self.labTextViewCount.text = [NSString stringWithFormat:@"%d/%d",(int)text.length,textViewLength];
    }
   
}



@end
