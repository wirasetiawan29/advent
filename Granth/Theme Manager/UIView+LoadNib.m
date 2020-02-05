//
//  UIView+LoadNib.m

#import <UIKit/UIKit.h>
#import "UIView+LoadNib.h"

@implementation UIView (LoadNib)

+(UIView*)loadFromNibNamed:(NSString *)NibName{
    return  (UIView *)[[NSBundle mainBundle] loadNibNamed:NibName owner:self options:nil][0];
}

@end
