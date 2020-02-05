//
//  ThemeManager.m

#import "ThemeManager.h"
#import "UIColor+HexColors.h"

#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

NSString * const ThemeManagerDidChangeThemes = @"ThemeManagerDidChangeThemes";

@interface ThemeManager()

@property (nonatomic, strong, readwrite) NSDictionary *styles;
@property (nonatomic, strong, readwrite) NSString *currentThemeName;
@end

@implementation ThemeManager


#pragma mark -
#pragma mark - Singleton

+ (ThemeManager *)sharedManager {
    static ThemeManager *_sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTheme = [[self alloc] init];
    });
    
    return _sharedTheme;
}

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *themeName = [defaults objectForKey:@"defaulttheme"];
        if (! themeName) {
            if (IPAD) {
                themeName = @"default_iPad";
            } else {
                themeName = @"default";
            }
        }
//        themeName = @"default";
        [self changeTheme:themeName];
    }
    return self;
}


#pragma mark -
#pragma mark - Setter Methods

- (void)setStyles:(NSDictionary *)styles {
    BOOL isFirst = _styles == nil;
    _styles = styles;
    if (! isFirst) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ThemeManagerDidChangeThemes object:nil];
    }
}

- (void)setCurrentThemeName:(NSString *)currentThemeName {
    _currentThemeName = currentThemeName;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentThemeName forKey:@"defaulttheme"];
    [defaults synchronize];
}


#pragma mark -
#pragma mark - Change Theme

- (void)changeTheme:(NSString *)themeName {
    if ([themeName isEqualToString:self.currentThemeName]) {
        return;
    }
    
    self.currentThemeName = themeName;
    NSString *path = [[NSBundle mainBundle] pathForResource:self.currentThemeName ofType:@"plist"];
    NSDictionary *styles = [NSDictionary dictionaryWithContentsOfFile:path];
   
    // if our theme inherits from another, then merge
    if (styles[@"inherit_from"] != nil) {
        styles = [self inheritedThemeWithParentTheme:styles[@"inherit_from"] childTheme:styles];
    }
    
    self.styles = styles;
}

- (NSDictionary *)inheritedThemeWithParentTheme:(NSString *)parentThemeName childTheme:(NSDictionary *)childTheme {
    NSString *path = [[NSBundle mainBundle] pathForResource:parentThemeName ofType:@"plist"];
    NSMutableDictionary *parent = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    
    // merge child into parent overriding parent values
    [childTheme enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        parent[key] = obj;
    }];
    
    return parent;
}

#pragma mark -
#pragma mark - Set Fonts

- (UIFont *)fontForKey:(NSString*)key withSizeKey:(NSString *)sizeKey{
//    NSString *sizeKey = [key stringByAppendingString:@"Size"];
    
    NSString *fontName = self.styles[key];
    NSString *size = self.styles[sizeKey];
    
    while (self.styles[fontName]) {
        fontName = self.styles[fontName];
    }
    
    while (self.styles[size]) {
        size = self.styles[size];
    }
    
    if (fontName && size) {
        return [UIFont fontWithName:fontName size:size.floatValue];
    }
    return nil;
}


#pragma mark -
#pragma mark - Set Colors

- (UIColor *)colorForKey:(NSString *)key {
    NSString *hexString = self.styles[key];
    
    while (self.styles[hexString]) {
        hexString = self.styles[hexString];
    }
    
    if (hexString) {
        return [UIColor colorWithHexString:hexString];
    }
    return nil;
}

@end

