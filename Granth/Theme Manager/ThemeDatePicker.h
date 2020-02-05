//
//  ThemeDatePicker.h

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface ThemeDatePicker : UIDatePicker <ThemeUpdateProtocol>

@property (nonatomic)IBInspectable int type;

@end
