//
//  ThemeManager.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+HexColors.h"

extern NSString * const ThemeManagerDidChangeThemes;

@protocol ThemeUpdateProtocol <NSObject>
    @required
    - (void)applyTheme;

@end

@interface ThemeManager : NSObject

+ (ThemeManager*)sharedManager;

@property (nonatomic, strong, readonly) NSDictionary *styles;
@property (nonatomic, strong, readonly) NSString *currentThemeName;

- (UIFont *)fontForKey:(NSString*)key withSizeKey:(NSString *)sizeKey;
- (UIColor *)colorForKey:(NSString *)key;
- (void)changeTheme:(NSString *)themeName;

@end
