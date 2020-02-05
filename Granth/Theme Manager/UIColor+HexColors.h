//
//  UIColor+HexColors.h

@interface UIColor (HexColors)

+(UIColor *)colorFromHexString:(NSString *)hexString;
+(NSString *)hexValuesFromUIColor:(UIColor *)color;
+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
