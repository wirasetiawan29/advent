//
//  ThemeTextField.m

#import "ThemeTextField.h"


#pragma mark -
#pragma mark - init methods

@implementation ThemeTextField

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
        font = [[ThemeManager sharedManager] fontForKey:@"font0" withSizeKey:@"fSize1"];
    }
    else if (_type == 1 || _type == 3 || _type == 4) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize2"];
    }
    else if (_type == 2) {
        font = [[ThemeManager sharedManager] fontForKey:@"font0" withSizeKey:@"fSize5"];
    }
    
    self.font = font;
    
    UIColor *textColor, *pColor = nil;
    if (_type == 0 || _type == 2) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"primaryTextColor"];
        pColor = [[ThemeManager sharedManager] colorForKey:@"secondaryTextColor"];
    }
    else if (_type == 1) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"Secondary_Color1"];
        pColor = [[ThemeManager sharedManager] colorForKey:@"secondaryTextColor"];
    }
    
    else if (_type == 3) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"Secondary_Color1"];
        pColor = [[ThemeManager sharedManager] colorForKey:@"secondaryTextColor"];
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
        self.layer.masksToBounds = YES;
    }
    else if (_type == 4) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"Secondary_Color1"];
        pColor = [[ThemeManager sharedManager] colorForKey:@"secondaryTextColor"];
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.lightGrayColor.CGColor;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.layer.cornerRadius = 25;
        }
        else {
            self.layer.cornerRadius = 20;
        }
        self.layer.masksToBounds = YES;
    }
    
    
    self.textColor = textColor;
    
    if (self.placeholder == nil) {
        self.placeholder = @" ";
    }
    [self setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: pColor}]];
    
    if (_type == 1) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    if (_type == 3) {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 0)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
}


#pragma mark -
#pragma mark - set observer for change theme

- (void)themeDidChangeNotification:(NSNotification *)notification {
    [self applyTheme];
}

@end
