//
//  ThemeView.m

#import "ThemeView.h"

@implementation ThemeView
#define OBJ_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


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
    
    UIColor *backgroundColor = nil;
    if (_type == 0) {
        backgroundColor = [[ThemeManager sharedManager] colorForKey:@"white"];
    }
    else if (_type == 1) {
        backgroundColor = [[ThemeManager sharedManager] colorForKey:@"white"];
        self.layer.shadowColor   = UIColor.blackColor.CGColor;
        self.layer.shadowRadius  = 1.0;
        self.layer.shadowOpacity = 0.9;
        self.layer.shadowOffset  = CGSizeZero;
        self.layer.masksToBounds = NO;
    }
    
    self.backgroundColor = backgroundColor;
}


#pragma mark -
#pragma mark - set observer for change theme

- (void)themeDidChangeNotification:(NSNotification *)notification {
    [self applyTheme];
}

@end
