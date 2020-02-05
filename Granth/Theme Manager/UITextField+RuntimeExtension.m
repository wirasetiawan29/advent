//
//  UITextField+RuntimeExtension.m

#import <UIKit/UIKit.h>
#import "UITextField+RuntimeExtension.h"
#import "UIColor+HexColors.h"

@implementation UITextField (RuntimeExtension)

- (void)customRightViewWithImage:(NSString *)image width:(int)width height:(int)height {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    imageView.image = [UIImage imageNamed:image];
    imageView.contentMode = UIViewContentModeLeft;
    self.rightView = imageView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)errorRightView {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.height, self.frame.size.height)];
    lbl.text = @"*";
    lbl.textColor = [UIColor whiteColor];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    self.rightView = lbl;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)leftMargin:(int)width {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)customRightButtonWithImage:(id)target image:(NSString *)image selector:(SEL)selector {
    UIView *vw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 40, 40)];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40, 40)];
    imageView.image = [UIImage imageNamed:image];
    imageView.contentMode = UIViewContentModeCenter;
    [vw addSubview:imageView];
    [vw addSubview:btn];

    self.rightView = vw;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (void)placeholderColor {
    [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"66FFFFFF"]}]];
}

- (void)setTextFieldFont:(NSString *)font color:(UIColor *)color size:(float)size {
    [self setFont:[UIFont fontWithName:font size:size]];
    [self setTextColor:color];
}


@end
