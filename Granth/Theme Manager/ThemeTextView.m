//
//  ThemeTextView.m

#import "ThemeManager.h"
#import "ThemeTextView.h"

@implementation ThemeTextView
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
#pragma mark - apply theme

- (void)applyTheme {
    UIFont *font = nil;
    if (_type == 0) {
        font = [[ThemeManager sharedManager] fontForKey:@"font0" withSizeKey:@"fSize2"];
    }
    
    UIColor *textColor, *background = nil;
    
    if (_type == 0) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"primaryTextColor"];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[ThemeManager sharedManager] colorForKey:@"textChildColor"].CGColor;
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        background = [[ThemeManager sharedManager] colorForKey:@"white"];
    }
    self.textColor = textColor;
    self.backgroundColor = background;
}


#pragma mark -
#pragma mark - set observer for change theme

- (void)themeDidChangeNotification:(NSNotification *)notification {
    [self applyTheme];
}

@end
