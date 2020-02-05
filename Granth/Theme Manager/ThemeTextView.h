//
//  ThemeTextView.h

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface ThemeTextView : UITextView <ThemeUpdateProtocol>
/**
 
 *
 - 0: Primary Text View: PRIMARY_FONT, fSize2, PRIMARY_COLOR_TEXT

 */
@property (nonatomic)IBInspectable int type;

@end
