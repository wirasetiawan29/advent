//
//  ThemImageView.h

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface ThemeImageView : UIImageView <ThemeUpdateProtocol>

/**
 
 *
 - 0: Primary Tint iamge: PRIMARY_COLOR
 
 *
 - 1: White Tint image: WHITE_COLOR
 
 */
@property (nonatomic)IBInspectable int type;

+ (UIImageView *)setTintImage:(UIImageView *)imgVw withColor:(UIColor *)color;
@end
