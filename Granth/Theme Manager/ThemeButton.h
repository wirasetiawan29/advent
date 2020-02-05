//
//  ThemeButton.h

#import <UIKit/UIKit.h>
#import "ThemeManager.h"

IB_DESIGNABLE
@interface ThemeButton : UIButton <ThemeUpdateProtocol>

/**
 *
 - 0: Main Button: FONT_BOLD, fSize2, WHITE_TEXT, BG_PRIMARY_COLOR
 
 *
 - 1: Simple Button: FONT, fSize2, PRIMARY_COLOR
 
 *
 - 2: Simple Button: FONT, fSize2, WHITE_COLOR, BG_PRIMARY_COLOR
 
 *
 - 101: Primary Tint Button: PRIMARY_COLOR
 
 *
 - 102: White Tint Button: WHITE_COLOR
 
 */
@property (nonatomic) IBInspectable int type;

+ (UIButton *)setButtonTintColor:(UIButton *)button imageName:(NSString *)imageName state:(UIControlState)state tintColor:(UIColor *)color;

@end
