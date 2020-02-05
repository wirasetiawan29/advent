//
//  UITextField+RuntimeExtension.h


@interface UITextField (RuntimeExtension)

- (void)customRightViewWithImage:(NSString *)image width:(int)width height:(int)height;
- (void)customRightButtonWithImage:(id)target image:(NSString *)image selector:(SEL)selector;
- (void)leftMargin:(int)width;
- (void)placeholderColor;
- (void)errorRightView;
- (void)setTextFieldFont:(NSString *)font color:(UIColor *)color size:(float)size;

@end
