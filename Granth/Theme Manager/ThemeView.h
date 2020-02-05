//
//  ThemeView.h

#import <UIKit/UIKit.h>
#import "ThemeManager.h"

IB_DESIGNABLE
@interface ThemeView : UIView <ThemeUpdateProtocol>
/**
 *
 - 0: background - WHITE
 
 *
 - 1: popupBackground - black WITH alpha
 
 *
 - 2: line - primary color
 
 *
 - Color: 0: PRIMARY_COLOR
 *
 - Color: 1: PRIMARY_COLOR_DARK
 *
 - Color: 2: PRIMARY_COLOR_TEXT
 *
 - Color: 3: SECONDARY_COLOR_TEXT
 *
 - Color: 4: WHITE_COLOR
 *
 - Color: 5: RED_COLOR
 */
@property (nonatomic)IBInspectable int type;
@property (nonatomic,strong,readonly) NSString *backgroundColorKey;

@end
