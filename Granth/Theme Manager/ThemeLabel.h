//
//  ThemeLabel.h

#import <UIKit/UIKit.h>
#import "ThemeManager.h"

IB_DESIGNABLE
@interface ThemeLabel : UILabel <ThemeUpdateProtocol>

/**
 
 *
 - 0: Header Label: PRIMARY_FONT, fSize2, WHITE_TEXT
 
 *
 - 1: Default Label: PRIMARY_FONT, fSize2, SECONDARY_COLOR_TEXT
 
 *
 - 2: Primary Label: PRIMARY_FONT, fSize2, PRIMARY_COLOR_TEXT
 
 *
 - 3: Secondary Label: PRIMARY_FONT, fSize1, SECONDARY_COLOR_TEXT
 
 *
 - 4: Plain_Label,Header_Title_Label: PRIMARY_FONT, fSize2, WHITE_COLOR
 
 *
 - 5: Title_Label: PRIMARY_FONT, fSize3, PRIMARY_COLOR_TEXT
 
 *
 - 10: Error Label: PRIMARY_FONT, fSize0, RED_COLOR_TEXT
 
 *
 - 21: Side Title Label: PRIMARY_FONT_BOLD, fSize1, SECONDARY_COLOR_TEXT
 
 *
 - 22: Side Sub Title Label: PRIMARY_FONT, fSize1, WHITE_TEXT
 
 */
@property (nonatomic) IBInspectable int type;

@end
