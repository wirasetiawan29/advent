//
//  ThemImageView.m

#import "ThemeManager.h"
#import "ThemeImageView.h"

@implementation ThemeImageView


#pragma mark -
#pragma mark - init methods

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChangeNotification:) name:ThemeManagerDidChangeThemes object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self applyTheme];
}

- (void)dealloc {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        // do nothing, only unregistering self from notifications
    }
}


#pragma mark -
#pragma mark - set theme

- (void)applyTheme {
    
    UIColor *color, *primaryTintColor = nil;
    if (_type == 2) {
        color = [[ThemeManager sharedManager] colorForKey:@"black"];
    }
    else if (_type == 3) {
        color = [[ThemeManager sharedManager] colorForKey:@"white"];
    }
    else if (_type == 4) {
        color = [[ThemeManager sharedManager] colorForKey:@"textChildColor"];
    }
    else if (_type == 5) {
        color = [[ThemeManager sharedManager] colorForKey:@"green"];
    }
    else if (_type == 6) {
        color = [[ThemeManager sharedManager] colorForKey:@"textChildColor"];
    }
    
    if (_type == 0) {
        primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"black"];
        self.layer.borderWidth = 1;
        self.layer.borderColor = primaryTintColor.CGColor;
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
    }
    else if (_type == 1) {
        primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"black"];
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = primaryTintColor.CGColor;
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
    }
    else  if (_type == 6) {
        UIImage *img = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tintColor = color;
        self.image = img;
    }
}

+ (UIImageView *)setTintImage:(UIImageView *)imgVw withColor:(UIColor *)color {
    UIImage *img = [imgVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imgVw.tintColor = color;
    imgVw.image = img;
    
    return imgVw;
}


#pragma mark -
#pragma mark - set observer for change theme

- (void)themeDidChangeNotification:(NSNotification *)notification {
    [self applyTheme];
}

@end
